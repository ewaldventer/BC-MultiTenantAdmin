<#
.SYNOPSIS
Retrieves Business Central environments for a given tenant using Service-to-Service authentication

.DESCRIPTION
Uses certificate-based authentication to retrieve a list of all Business Central environments
for a specified tenant. Requires the BCAdminCertAuth module and a valid certificate in Azure Key Vault.

.PARAMETER TenantId
Mandatory. The Azure AD tenant ID (GUID format)

.PARAMETER ClientId
Mandatory. The App Registration client ID (GUID format) with permissions to access BC Admin API

.PARAMETER KeyVaultName
Mandatory. Name of the Azure Key Vault containing the authentication certificate

.PARAMETER CertificateName
Mandatory. Name of the certificate in Key Vault (must have private key)

.PARAMETER ManagedIdentityClientId
Optional. Client ID of User-Assigned Managed Identity for Key Vault access.
If not provided, uses current user context or system-managed identity.

.PARAMETER ApiVersion
Optional. Business Central Admin API version. Default: v2.15

.OUTPUTS
[PSCustomObject[]]
Array of environment objects with properties: name, friendlyName, type, countryRegionCode, applicationFamily, etc.

.EXAMPLE
$environments = .\Get-BCEnvironments.ps1 `
    -TenantId "00000000-0000-0000-0000-000000000000" `
    -ClientId "10000000-0000-0000-0000-000000000001" `
    -KeyVaultName "key-vault-name" `
    -CertificateName "cert-name"

.EXAMPLE
# With Managed Identity
$environments = .\Get-BCEnvironments.ps1 `
    -TenantId "00000000-0000-0000-0000-000000000000" `
    -ClientId "10000000-0000-0000-0000-000000000001" `
    -KeyVaultName "key-vault-name" `
    -CertificateName "cert-name" `
    -ManagedIdentityClientId "df5cc8ca-c57b-4ff6-b97e-27139c2050d1"

$environments | Format-Table -Property name, friendlyName, type, countryRegionCode

.NOTES
Requires:
- BCAdminCertAuth module (in ../modules/BCAdminCertAuth.psm1)
- Az.KeyVault and Az.Accounts modules
- Application must have "Dynamics 365 Business Central" API permissions in Azure AD

API Reference:
https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/administration-center-api

.AUTHOR
Business Central Administration Team

.VERSION
1.0.0
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
    [string]$ClientId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$CertificateName,

    [Parameter(Mandatory = $false)]
    [string]$ManagedIdentityClientId,

    [Parameter(Mandatory = $false)]
    [string]$ApiVersion = 'v2.15'
)

# ============================================================================
# Setup
# ============================================================================

$ErrorActionPreference = 'Stop'

# Import the BCAdminCertAuth module
$modulePath = Join-Path $PSScriptRoot '..\scripts\modules\BCAdminCertAuth.psm1'
if (-not (Test-Path $modulePath)) {
    throw "BCAdminCertAuth module not found at $modulePath"
}

Write-Verbose "Importing BCAdminCertAuth module from $modulePath"
Import-Module $modulePath -Force

# ============================================================================
# Helper: Authenticate to Azure in pipeline environment
# ============================================================================

function Connect-AzureForPipeline {
    <#
    .SYNOPSIS
    Handles Azure authentication for both interactive and pipeline environments
    #>
    param()
    
    try {
        # Check if already connected
        $context = Get-AzContext -ErrorAction SilentlyContinue
        if ($context) {
            Write-Verbose "Already authenticated to Azure as $($context.Account.Id)"
            return
        }

        # Try Managed Identity first (for Azure DevOps/Pipeline execution)
        Write-Verbose "Attempting Managed Identity authentication..."
        try {
            Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
            Write-Verbose "✓ Connected using Managed Identity"
            return
        }
        catch {
            Write-Verbose "Managed Identity authentication failed: $($_.Exception.Message)"
        }

        # Fall back to interactive authentication for local/developer runs
        Write-Verbose "Attempting interactive authentication..."
        Connect-AzAccount -ErrorAction Stop | Out-Null
        Write-Verbose "✓ Connected using interactive authentication"
    }
    catch {
        throw "Failed to authenticate to Azure: $($_.Exception.Message). Ensure Managed Identity is enabled or you're logged in interactively."
    }
}

# ============================================================================
# Main Script
# ============================================================================

try {
    Write-Host "Business Central Environment Retrieval" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Tenant ID: $TenantId"
    Write-Host "Client ID: $ClientId"
    Write-Host "Key Vault: $KeyVaultName"
    Write-Host "Certificate: $CertificateName"
    Write-Host "API Version: $ApiVersion"
    Write-Host ""

    # Step 0: Authenticate to Azure
    Write-Host "Step 0: Authenticating to Azure..." -ForegroundColor Yellow
    Connect-AzureForPipeline
    Write-Host "✓ Azure authentication successful" -ForegroundColor Green
    Write-Host ""

    # Step 1: Retrieve certificate from Key Vault
    Write-Host "Step 1: Retrieving certificate from Key Vault..." -ForegroundColor Yellow
    $certResult = Get-BCCertificateFromKeyVault `
        -KeyVaultName $KeyVaultName `
        -CertificateName $CertificateName `
        -ManagedIdentityClientId $ManagedIdentityClientId

    if (-not $certResult) {
        throw "Failed to retrieve certificate from Key Vault"
    }

    $certificate = $certResult.Certificate
    Write-Host "✓ Certificate retrieved successfully" -ForegroundColor Green

    # Step 2: Check certificate expiration
    Write-Host ""
    Write-Host "Step 2: Checking certificate expiration..." -ForegroundColor Yellow
    $expirationStatus = Test-BCCertificateExpiration -Certificate $certificate
    
    if ($expirationStatus.IsExpired) {
        throw "Certificate has expired. Cannot proceed with authentication."
    }
    
    if ($expirationStatus.IsExpiring) {
        Write-Host "⚠️  Warning: Certificate expires in $($expirationStatus.DaysUntilExpiry) days" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Certificate is valid (expires in $($expirationStatus.DaysUntilExpiry) days)" -ForegroundColor Green
    }

    # Step 3: Generate authentication token
    Write-Host ""
    Write-Host "Step 3: Generating authentication token..." -ForegroundColor Yellow
    $tokenResult = Get-BCAuthenticationToken `
        -TenantId $TenantId `
        -ClientId $ClientId `
        -Certificate $certificate

    if (-not $tokenResult) {
        throw "Failed to generate authentication token"
    }

    $token = $tokenResult
    Write-Host "✓ Authentication token generated successfully" -ForegroundColor Green

    # Step 4: Call Business Central Admin API
    Write-Host ""
    Write-Host "Step 4: Retrieving environments from Business Central Admin API..." -ForegroundColor Yellow
    
    $apiUrl = "https://api.businesscentral.dynamics.com/admin/$ApiVersion/applications/BusinessCentral/environments"
    Write-Host "API Endpoint: $apiUrl"
    Write-Verbose "Token (first 50 chars): $($token.Substring(0, [Math]::Min(50, $token.Length)))..."

    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type'  = 'application/json'
    }

    try {
        $response = Invoke-RestMethod `
            -Uri $apiUrl `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
    }
    catch {
        $errorResponse = $_
        Write-Host ""
        Write-Host "API Error Details:" -ForegroundColor Yellow
        Write-Host "  Status Code: $($errorResponse.Exception.Response.StatusCode)" -ForegroundColor Yellow
        Write-Host "  Message: $($errorResponse.Exception.Message)" -ForegroundColor Yellow
        
        if ($errorResponse.Exception.Response.StatusCode -eq 401) {
            Write-Host ""
            Write-Host "Unauthorized (401) - Possible causes:" -ForegroundColor Yellow
            Write-Host "  1. Certificate is not registered with the App Registration" -ForegroundColor Yellow
            Write-Host "     - Check certificate thumbprint matches app in Azure AD" -ForegroundColor Yellow
            Write-Host "  2. App Registration doesn't have required permissions" -ForegroundColor Yellow
            Write-Host "     - Ensure 'Dynamics 365 Business Central' API has 'user_impersonation' permission" -ForegroundColor Yellow
            Write-Host "  3. Token is for wrong audience" -ForegroundColor Yellow
            Write-Host "     - Verify Client ID and Tenant ID are correct" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Certificate Details:" -ForegroundColor Yellow
            Write-Host "  Subject: $($certificate.Subject)" -ForegroundColor Yellow
            Write-Host "  Thumbprint: $($certificate.Thumbprint)" -ForegroundColor Yellow
        }
        
        throw
    }

    # Step 5: Process and return results as JSON
    Write-Host ""
    Write-Host "✓ Environments retrieved successfully" -ForegroundColor Green

    $environments = $response.value
    
    if ($environments.Count -eq 0) {
        Write-Host "No environments found for tenant $TenantId" -ForegroundColor Yellow
        return @()
    }

    Write-Host "Found $($environments.Count) environment(s)" -ForegroundColor Cyan
    Write-Host ""

    # Return ONLY the JSON array to stdout
    $environments | ConvertTo-Json -Depth 10
}
catch {
    Write-Host ""
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Provide helpful error messages
    $errorMessage = $_.Exception.Message
    
    if ($errorMessage -match "window handle|WAM|authentication failed|InteractiveBrowserCredential") {
        Write-Host ""
        Write-Host "Authentication Error Detected:" -ForegroundColor Yellow
        Write-Host "  This appears to be a pipeline environment without interactive support." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Solutions:" -ForegroundColor Yellow
        Write-Host "  1. Ensure Azure DevOps pipeline has 'Make secrets available to builds of branches' enabled" -ForegroundColor Yellow
        Write-Host "  2. Configure pipeline to use Managed Identity (recommended)" -ForegroundColor Yellow
        Write-Host "  3. Or use a Service Connection with certificate or secret credentials" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "For Managed Identity:" -ForegroundColor Yellow
        Write-Host "  - The pipeline agent must run under a user-assigned managed identity" -ForegroundColor Yellow
        Write-Host "  - Grant the managed identity 'Key Vault Reader' role on the Key Vault" -ForegroundColor Yellow
        Write-Host "  - Grant the managed identity read access to secrets/certificates" -ForegroundColor Yellow
    }
    elseif ($errorMessage -match "Unauthorized\|401") {
        Write-Host "Suggestion: Verify that the certificate is registered with the App Registration and has correct permissions" -ForegroundColor Yellow
    }
    elseif ($errorMessage -match "Forbidden\|403") {
        Write-Host "Suggestion: The app may not have permission to access Business Central environments. Check API permissions in Azure AD." -ForegroundColor Yellow
    }
    elseif ($errorMessage -match "Not Found\|404") {
        Write-Host "Suggestion: Verify the API endpoint is correct for the API version specified" -ForegroundColor Yellow
    }
    elseif ($errorMessage -match "not found in Key Vault") {
        Write-Host "Suggestion: Verify the certificate name '$CertificateName' exists in Key Vault '$KeyVaultName'" -ForegroundColor Yellow
        Write-Host "  To list certificates: Get-AzKeyVaultCertificate -VaultName '$KeyVaultName'" -ForegroundColor Yellow
    }
    
    throw
}
