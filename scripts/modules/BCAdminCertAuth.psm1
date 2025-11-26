<#
.SYNOPSIS
Business Central Admin Center Certificate-Based Authentication Module

.DESCRIPTION
Provides functions for Service-to-Service authentication to Business Central Admin Center API
using certificates stored in Azure Key Vault. Designed to work with Managed Identity in Azure
DevOps pipelines and other Azure-hosted environments.

.AUTHOR
Business Central Administration Team

.VERSION
1.0.0

.NOTES
Requires:
- Az.KeyVault module
- Az.Identity module
- PowerShell 5.1 or later

Usage:
    Import-Module -Name "BCAdminCertAuth.psm1"
    $cert = Get-BCCertificateFromKeyVault -KeyVaultName "key-vault-name" -CertificateName "cert-name"
    $token = Get-BCAuthenticationToken -TenantId "..." -ClientId "..." -Certificate $cert
#>

# Module Dependencies: Az.KeyVault, Az.Identity
# These are dynamically loaded when needed, not required for unit tests

$script:MaxRetries = 3
$script:RetryDelaySeconds = @(2, 4, 8)  # Exponential backoff: 2s, 4s, 8s

# ============================================================================
# Helper Function: Ensure Azure Modules are Loaded
# ============================================================================

function Ensure-AzureModulesLoaded {
    [CmdletBinding()]
    param()

    $requiredModules = @('Az.Accounts', 'Az.KeyVault')
    
    foreach ($moduleName in $requiredModules) {
        if (-not (Get-Module -Name $moduleName)) {
            Write-Verbose "Loading module: $moduleName"
            try {
                Import-Module -Name $moduleName -ErrorAction Stop | Out-Null
            }
            catch {
                throw "Failed to load required module '$moduleName'. Please install it using: Install-Module -Name $moduleName -Force"
            }
        }
    }
}

# ============================================================================
# Function: Get-BCCertificateFromKeyVault
# ============================================================================

<#
.SYNOPSIS
Retrieves a certificate from Azure Key Vault using Managed Identity

.DESCRIPTION
Retrieves a certificate (with private key) from Azure Key Vault. Authenticates using
Managed Identity when running in Azure context, or uses current user context otherwise.

.PARAMETER KeyVaultName
Mandatory. Name of the Azure Key Vault (e.g., "key-vault-name")

.PARAMETER CertificateName
Mandatory. Name of the certificate in Key Vault (e.g., "cert-name")

.PARAMETER ManagedIdentityClientId
Optional. Client ID of User-Assigned Managed Identity. If not provided, auto-detects
in Azure context or uses current user credentials.

.OUTPUTS
[System.Security.Cryptography.X509Certificates.X509Certificate2]
The certificate object with private key for use in token generation

.EXAMPLE
$cert = Get-BCCertificateFromKeyVault -KeyVaultName "key-vault-name" -CertificateName "cert-name"

.EXAMPLE
# With explicit Managed Identity Client ID
$cert = Get-BCCertificateFromKeyVault `
    -KeyVaultName "key-vault-name" `
    -CertificateName "cert-name" `
    -ManagedIdentityClientId "df5cc8ca-c57b-4ff6-b97e-27139c2050d1"
#>

function Get-BCCertificateFromKeyVault {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyVaultName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CertificateName,

        [Parameter(Mandatory = $false)]
        [string]$ManagedIdentityClientId
    )

    begin {
        Write-Verbose "Starting Get-BCCertificateFromKeyVault"
        Write-Verbose "KeyVaultName: $KeyVaultName"
        Write-Verbose "CertificateName: $CertificateName"
    }

    process {
        try {
            # Ensure required Azure modules are loaded
            Ensure-AzureModulesLoaded

            # Ensure we're authenticated to Azure
            $context = Get-AzContext -ErrorAction SilentlyContinue
            if (-not $context) {
                Write-Verbose "No Azure context found. Attempting authentication..."
                
                # Try Managed Identity first (for pipeline execution)
                if ($ManagedIdentityClientId) {
                    Write-Verbose "Using Managed Identity with Client ID: $ManagedIdentityClientId"
                    Connect-AzAccount -Identity -AccountId $ManagedIdentityClientId -ErrorAction Stop | Out-Null
                    Write-Verbose "Connected using Managed Identity"
                } else {
                    # Try Managed Identity without specific client ID
                    Write-Verbose "Attempting Managed Identity authentication..."
                    try {
                        Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
                        Write-Verbose "Connected using Managed Identity"
                    }
                    catch {
                        # Fall back to interactive login for local development
                        Write-Verbose "Managed Identity failed, attempting interactive login..."
                        Connect-AzAccount -ErrorAction Stop | Out-Null
                        Write-Verbose "Connected using interactive login"
                    }
                }
            } else {
                Write-Verbose "Already authenticated: $($context.Account.Id)"
            }

            # Retrieve certificate from Key Vault
            Write-Verbose "Retrieving certificate '$CertificateName' from Key Vault '$KeyVaultName'..."
            
            $kvSecret = Get-AzKeyVaultSecret `
                -VaultName $KeyVaultName `
                -Name $CertificateName `
                -ErrorAction Stop

            if (-not $kvSecret) {
                throw "Certificate '$CertificateName' not found in Key Vault '$KeyVaultName'"
            }

            # Convert secret to certificate object
            $secretValue = $kvSecret.SecretValue
            $secretValueText = ConvertFrom-SecureString -SecureString $secretValue -AsPlainText

            Write-Verbose "Certificate format detection..."
            Write-Verbose "First 50 chars: $($secretValueText.Substring(0, [Math]::Min(50, $secretValueText.Length)))"

            # Determine certificate format and convert appropriately
            $certificate = $null
            
            # Check if it's PEM format (starts with -----BEGIN)
            if ($secretValueText -match '^-----BEGIN') {
                Write-Verbose "Detected PEM format certificate"
                
                # Extract the base64 content between BEGIN and END markers
                $pemContent = $secretValueText -replace '-----BEGIN CERTIFICATE-----', '' -replace '-----END CERTIFICATE-----', '' -replace '\s', ''
                $certificateBytes = [Convert]::FromBase64String($pemContent)
            }
            # Check if it's already base64 (all valid base64 chars)
            elseif ($secretValueText -match '^[A-Za-z0-9+/=]+$') {
                Write-Verbose "Detected base64 format certificate"
                $certificateBytes = [Convert]::FromBase64String($secretValueText)
            }
            else {
                Write-Verbose "Attempting to use certificate text as-is (may be binary)"
                $certificateBytes = [System.Text.Encoding]::UTF8.GetBytes($secretValueText)
            }

            Write-Verbose "Certificate bytes length: $($certificateBytes.Length)"
            Write-Verbose "Certificate bytes type: $($certificateBytes.GetType())"

            # Create certificate object using constructor
            # This is required for .NET Core/PowerShell 7 compatibility
            $certificate = $null
            
            try {
                Write-Verbose "Creating X509Certificate2 from bytes..."
                # Try simple constructor first - no password, no flags
                $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificateBytes)
                Write-Verbose "✓ Certificate created successfully"
            }
            catch {
                Write-Verbose "Simple constructor failed: $($_.Exception.Message)"
                
                # Try with empty password
                try {
                    Write-Verbose "Retrying with empty password parameter..."
                    $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificateBytes, "")
                    Write-Verbose "✓ Certificate created with empty password"
                }
                catch {
                    Write-Verbose "Password approach failed: $($_.Exception.Message)"
                    throw "Failed to create certificate from Key Vault secret. The secret may not contain a valid certificate. Error: $($_.Exception.Message)"
                }
            }

            if (-not $certificate) {
                throw "Certificate object is null after creation"
            }

            Write-Verbose "Certificate retrieved successfully"
            Write-Verbose "Certificate subject: $($certificate.Subject)"
            Write-Verbose "Certificate expires: $($certificate.NotAfter)"
            Write-Verbose "Certificate thumbprint: $($certificate.Thumbprint)"
            Write-Verbose "Certificate has private key: $($certificate.HasPrivateKey)"

            # Return certificate object
            $outputObject = [PSCustomObject]@{
                Certificate          = $certificate
                CertificateName       = $CertificateName
                Subject               = $certificate.Subject
                Thumbprint            = $certificate.Thumbprint
                ValidFrom             = $certificate.NotBefore
                ValidTo               = $certificate.NotAfter
                DaysUntilExpiry       = [Math]::Floor(($certificate.NotAfter - (Get-Date)).TotalDays)
                IsExpired             = $certificate.NotAfter -lt (Get-Date)
                KeyVaultName          = $KeyVaultName
                RetrievedAt           = Get-Date
            }

            Write-Host "✓ Certificate retrieved successfully" -ForegroundColor Green
            Write-Host "  Subject: $($certificate.Subject)"
            Write-Host "  Expires: $($certificate.NotAfter.ToString('yyyy-MM-dd'))" -ForegroundColor $(if ($outputObject.DaysUntilExpiry -lt 30) { 'Yellow' } else { 'Green' })

            return $outputObject
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-Host "✗ Failed to retrieve certificate from Key Vault" -ForegroundColor Red
            Write-Host "  Error: $errorMessage" -ForegroundColor Red
            
            if ($errorMessage -match "does not exist" -or $errorMessage -match "not found") {
                Write-Host "  Suggestion: Verify certificate name exists in Key Vault" -ForegroundColor Yellow
                Write-Host "  To list certificates: Get-AzKeyVaultCertificate -VaultName '$KeyVaultName'" -ForegroundColor Yellow
            }
            elseif ($errorMessage -match "Access Denied" -or $errorMessage -match "Forbidden") {
                Write-Host "  Suggestion: Managed Identity may not have 'Key Vault Reader' role on the Key Vault" -ForegroundColor Yellow
            }

            throw
        }
    }

    end {
        Write-Verbose "Get-BCCertificateFromKeyVault completed"
    }
}

# ============================================================================
# Function: Get-BCAuthenticationToken
# ============================================================================

<#
.SYNOPSIS
Generates an Azure AD authentication token using a certificate

.DESCRIPTION
Generates a valid Bearer token for Business Central Admin Center API by authenticating
with Azure AD using the provided certificate.

.PARAMETER TenantId
Mandatory. Azure AD tenant ID (GUID format)

.PARAMETER ClientId
Mandatory. App Registration client ID (GUID format)

.PARAMETER Certificate
Mandatory. X509Certificate2 object with private key (from Get-BCCertificateFromKeyVault)

.OUTPUTS
[string]
Bearer token for use in Authorization header

.EXAMPLE
$cert = Get-BCCertificateFromKeyVault -KeyVaultName "key-vault-name" -CertificateName "cert-name"
$token = Get-BCAuthenticationToken `
    -TenantId "00000000-0000-0000-0000-000000000000" `
    -ClientId "10000000-0000-0000-0000-000000000001" `
    -Certificate $cert

# Use in API call
Invoke-RestMethod -Uri "..." -Headers @{ Authorization = "Bearer $token" }
#>

function Get-BCAuthenticationToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    begin {
        Write-Verbose "Starting Get-BCAuthenticationToken"
        Write-Verbose "TenantId: $TenantId"
        Write-Verbose "ClientId: $ClientId"
        Write-Verbose "Certificate Thumbprint: $($Certificate.Thumbprint)"
    }

    process {
        $retryCount = 0
        
        while ($retryCount -lt $script:MaxRetries) {
            try {
                # Azure AD token endpoint
                $tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

                # Create JWT assertion
                $jwtAssertion = New-JwtAssertion -Certificate $Certificate -ClientId $ClientId -TenantId $TenantId

                # Request token
                $body = @{
                    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
                    client_assertion      = $jwtAssertion
                    client_id             = $ClientId
                    scope                 = "https://api.businesscentral.dynamics.com/.default"
                    grant_type            = "client_credentials"
                }

                Write-Verbose "Requesting token from $tokenEndpoint"

                $response = Invoke-RestMethod `
                    -Uri $tokenEndpoint `
                    -Method Post `
                    -Body $body `
                    -ContentType "application/x-www-form-urlencoded" `
                    -ErrorAction Stop

                if ($response.access_token) {
                    Write-Host "✓ Authentication token generated successfully" -ForegroundColor Green
                    Write-Verbose "Token expires in $($response.expires_in) seconds"
                    
                    $outputObject = [PSCustomObject]@{
                        AccessToken  = $response.access_token
                        TokenType    = $response.token_type
                        ExpiresIn    = $response.expires_in
                        ExpiresAt    = (Get-Date).AddSeconds($response.expires_in)
                        GeneratedAt  = Get-Date
                    }

                    return $outputObject.AccessToken
                } else {
                    throw "No access token in response"
                }
            }
            catch {
                $retryCount++
                $errorMessage = $_.Exception.Message

                if ($retryCount -lt $script:MaxRetries) {
                    $delaySeconds = $script:RetryDelaySeconds[$retryCount - 1]
                    Write-Verbose "Token generation attempt $retryCount failed. Retrying in $delaySeconds seconds..."
                    Write-Verbose "Error: $errorMessage"
                    Start-Sleep -Seconds $delaySeconds
                }
                else {
                    Write-Host "✗ Failed to generate authentication token (after $script:MaxRetries attempts)" -ForegroundColor Red
                    Write-Host "  Error: $errorMessage" -ForegroundColor Red
                    
                    if ($errorMessage -match "invalid_client" -or $errorMessage -match "AADSTS700016") {
                        Write-Host "  Suggestion: Verify ClientId and TenantId are correct" -ForegroundColor Yellow
                    }
                    elseif ($errorMessage -match "certificate" -or $errorMessage -match "invalid_assertion") {
                        Write-Host "  Suggestion: Verify certificate is valid and matches App Registration" -ForegroundColor Yellow
                    }
                    
                    throw
                }
            }
        }
    }

    end {
        Write-Verbose "Get-BCAuthenticationToken completed"
    }
}

# ============================================================================
# Function: Test-BCCertificateExpiration
# ============================================================================

<#
.SYNOPSIS
Tests certificate expiration and returns status/alerts

.DESCRIPTION
Checks certificate expiration date and returns status object with days remaining
and alert if approaching expiration threshold.

.PARAMETER Certificate
Mandatory. X509Certificate2 object (from Get-BCCertificateFromKeyVault)

.PARAMETER AlertDaysBeforeExpiry
Optional. Number of days before expiry to trigger alert (default: 30)

.OUTPUTS
[PSCustomObject]
Properties: CertificateInfo, DaysUntilExpiry, IsExpiring, Alert

.EXAMPLE
$cert = Get-BCCertificateFromKeyVault -KeyVaultName "key-vault-name" -CertificateName "cert-name"
$status = Test-BCCertificateExpiration -Certificate $cert.Certificate

if ($status.IsExpiring) {
    Write-Host "⚠️  Alert: $($status.Alert)"
}
#>

function Test-BCCertificateExpiration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(Mandatory = $false)]
        [int]$AlertDaysBeforeExpiry = 30
    )

    begin {
        Write-Verbose "Starting Test-BCCertificateExpiration"
        Write-Verbose "Certificate Subject: $($Certificate.Subject)"
        Write-Verbose "Alert threshold: $AlertDaysBeforeExpiry days"
    }

    process {
        try {
            $now = Get-Date
            $expiryDate = $Certificate.NotAfter
            $daysRemaining = [Math]::Floor(($expiryDate - $now).TotalDays)
            $isExpired = $expiryDate -lt $now
            $isExpiring = $daysRemaining -le $AlertDaysBeforeExpiry -and -not $isExpired

            $alert = $null
            if ($isExpired) {
                $alert = "Certificate has EXPIRED (expired $([Math]::Abs($daysRemaining)) days ago)"
            }
            elseif ($isExpiring) {
                $alert = "Certificate expires in $daysRemaining days (before $($expiryDate.ToString('yyyy-MM-dd')))"
            }

            $outputObject = [PSCustomObject]@{
                CertificateInfo      = $Certificate.Subject
                Subject              = $Certificate.Subject
                Thumbprint           = $Certificate.Thumbprint
                ValidFrom            = $Certificate.NotBefore
                ValidTo              = $Certificate.NotAfter
                DaysUntilExpiry      = $daysRemaining
                IsExpired            = $isExpired
                IsExpiring           = $isExpiring
                Alert                = $alert
                CheckedAt            = $now
            }

            # Display status
            if ($isExpired) {
                Write-Host "✗ Certificate EXPIRED" -ForegroundColor Red
                Write-Host "  Subject: $($Certificate.Subject)" -ForegroundColor Red
                Write-Host "  Expired: $($expiryDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Red
                Write-Host "  Action: Renew certificate immediately" -ForegroundColor Red
            }
            elseif ($isExpiring) {
                Write-Host "⚠️  Certificate expiring soon" -ForegroundColor Yellow
                Write-Host "  Subject: $($Certificate.Subject)" -ForegroundColor Yellow
                Write-Host "  Expires: $($expiryDate.ToString('yyyy-MM-dd'))" -ForegroundColor Yellow
                Write-Host "  Days remaining: $daysRemaining" -ForegroundColor Yellow
            }
            else {
                Write-Host "✓ Certificate healthy" -ForegroundColor Green
                Write-Host "  Subject: $($Certificate.Subject)" -ForegroundColor Green
                Write-Host "  Expires: $($expiryDate.ToString('yyyy-MM-dd'))" -ForegroundColor Green
                Write-Host "  Days remaining: $daysRemaining" -ForegroundColor Green
            }

            return $outputObject
        }
        catch {
            Write-Host "✗ Error checking certificate expiration: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
    }

    end {
        Write-Verbose "Test-BCCertificateExpiration completed"
    }
}

# ============================================================================
# Function: Get-BCKeyVaultSecretExpiration
# ============================================================================

<#
.SYNOPSIS
Checks Key Vault secrets for expiration

.DESCRIPTION
Lists all secrets in a Key Vault and checks their expiration dates.
Useful for monitoring all credentials and certificates in a vault.

.PARAMETER KeyVaultName
Mandatory. Name of the Azure Key Vault

.PARAMETER SecretName
Optional. Check specific secret (if not provided, checks all)

.OUTPUTS
[PSCustomObject[]]
Array of secrets with expiration information

.EXAMPLE
# Check all secrets
Get-BCKeyVaultSecretExpiration -KeyVaultName "key-vault-name"

# Check specific secret
Get-BCKeyVaultSecretExpiration -KeyVaultName "key-vault-name" -SecretName "my-secret"
#>

function Get-BCKeyVaultSecretExpiration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyVaultName,

        [Parameter(Mandatory = $false)]
        [string]$SecretName
    )

    begin {
        Write-Verbose "Starting Get-BCKeyVaultSecretExpiration"
        Write-Verbose "KeyVaultName: $KeyVaultName"
        if ($SecretName) { Write-Verbose "SecretName: $SecretName" }
    }

    process {
        try {
            # Ensure required Azure modules are loaded
            Ensure-AzureModulesLoaded

            # Ensure authenticated
            $context = Get-AzContext -ErrorAction SilentlyContinue
            if (-not $context) {
                Connect-AzAccount -ErrorAction Stop | Out-Null
            }

            Write-Verbose "Retrieving secrets from Key Vault..."

            # Get secrets
            if ($SecretName) {
                $secrets = @(Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -ErrorAction Stop)
            }
            else {
                $secrets = Get-AzKeyVaultSecret -VaultName $KeyVaultName -ErrorAction Stop
            }

            if (-not $secrets) {
                Write-Host "No secrets found in Key Vault '$KeyVaultName'" -ForegroundColor Yellow
                return @()
            }

            $now = Get-Date
            $secretStatus = @()

            foreach ($secret in $secrets) {
                $expiryDate = $secret.Expires
                $daysRemaining = if ($expiryDate) {
                    [Math]::Floor(($expiryDate - $now).TotalDays)
                }
                else {
                    $null  # No expiry set
                }

                $isExpired = if ($expiryDate) { $expiryDate -lt $now } else { $false }
                $isExpiring = if ($daysRemaining -and $daysRemaining -le 30) { $true } else { $false }

                $secretStatus += [PSCustomObject]@{
                    SecretName        = $secret.Name
                    ExpiryDate        = $expiryDate
                    DaysUntilExpiry   = $daysRemaining
                    IsExpired         = $isExpired
                    IsExpiring        = $isExpiring
                    Status            = if ($isExpired) { "EXPIRED" } elseif ($isExpiring) { "EXPIRING" } elseif ($expiryDate) { "HEALTHY" } else { "NO_EXPIRY" }
                    CheckedAt         = $now
                }
            }

            # Display summary
            $expiredCount = @($secretStatus | Where-Object { $_.IsExpired }).Count
            $expiringCount = @($secretStatus | Where-Object { $_.IsExpiring }).Count
            $healthyCount = @($secretStatus | Where-Object { $_.Status -eq "HEALTHY" }).Count

            Write-Host "Key Vault Secret Status Summary" -ForegroundColor Cyan
            Write-Host "================================" -ForegroundColor Cyan
            Write-Host "Total secrets: $($secretStatus.Count)"
            if ($expiredCount -gt 0) { Write-Host "  ✗ Expired: $expiredCount" -ForegroundColor Red }
            if ($expiringCount -gt 0) { Write-Host "  ⚠️  Expiring soon: $expiringCount" -ForegroundColor Yellow }
            if ($healthyCount -gt 0) { Write-Host "  ✓ Healthy: $healthyCount" -ForegroundColor Green }

            # Display detailed status
            $secretStatus | ForEach-Object {
                $statusColor = switch ($_.Status) {
                    "EXPIRED" { "Red" }
                    "EXPIRING" { "Yellow" }
                    "HEALTHY" { "Green" }
                    default { "Gray" }
                }

                Write-Host "  $($_.SecretName)" -ForegroundColor $statusColor -NoNewline
                if ($_.ExpiryDate) {
                    Write-Host " - Expires: $($_.ExpiryDate.ToString('yyyy-MM-dd')) ($($_.DaysUntilExpiry) days)" -ForegroundColor $statusColor
                }
                else {
                    Write-Host " - No expiry set" -ForegroundColor $statusColor
                }
            }

            return $secretStatus
        }
        catch {
            Write-Host "✗ Error retrieving Key Vault secrets: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
    }

    end {
        Write-Verbose "Get-BCKeyVaultSecretExpiration completed"
    }
}

# ============================================================================
# Private Functions
# ============================================================================

<#
.SYNOPSIS
Creates a JWT assertion for certificate-based client authentication
.NOTES
Internal function - not exported
#>

function New-JwtAssertion {
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$TenantId
    )

    # JWT Header
    $header = @{
        alg = "RS256"
        typ = "JWT"
        x5t = Convert-ByteArrayToBase64Url -Bytes $Certificate.GetCertHash()
    } | ConvertTo-Json

    # JWT Payload (Claims)
    $now = [Math]::Floor([decimal](Get-Date -UFormat %s))
    $payload = @{
        aud = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
        exp = $now + 3600  # 1 hour expiry
        iss = $ClientId
        jti = [Guid]::NewGuid().ToString()
        nbf = $now
        sub = $ClientId
    } | ConvertTo-Json

    # Encode Header and Payload
    $headerEncoded = Convert-StringToBase64Url -String $header
    $payloadEncoded = Convert-StringToBase64Url -String $payload
    $signatureInput = "$headerEncoded.$payloadEncoded"

    # Sign with Certificate
    $signature = $Certificate.PrivateKey.SignData(
        [System.Text.Encoding]::UTF8.GetBytes($signatureInput),
        [System.Security.Cryptography.HashAlgorithmName]::SHA256,
        [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
    )

    $signatureEncoded = Convert-ByteArrayToBase64Url -Bytes $signature

    # Return JWT
    return "$headerEncoded.$payloadEncoded.$signatureEncoded"
}

function Convert-StringToBase64Url {
    param([string]$String)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
    $base64 = [System.Convert]::ToBase64String($bytes)
    return $base64.Replace('+', '-').Replace('/', '_').TrimEnd('=')
}

function Convert-ByteArrayToBase64Url {
    param([byte[]]$Bytes)
    $base64 = [System.Convert]::ToBase64String($Bytes)
    return $base64.Replace('+', '-').Replace('/', '_').TrimEnd('=')
}

# ============================================================================
# Module Exports
# ============================================================================

Export-ModuleMember -Function @(
    'Get-BCCertificateFromKeyVault',
    'Get-BCAuthenticationToken',
    'Test-BCCertificateExpiration',
    'Get-BCKeyVaultSecretExpiration'
)
