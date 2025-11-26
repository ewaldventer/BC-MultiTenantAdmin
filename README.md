# README

# Configuration Steps for Multi-Tenant Automation with Certificate-Based Authentication

1. I have created a self-signed certificate for this purpose of managing multiple tenants.
2. The certificate was exported as a .cer file (public key) and as a .pfx file (private key),
3. and uploaded the .cer file to the App Registration's certificate credentials.
4. I created an Azure Key Vault to securely store the .pfx file
5. I have created a multi-tenant Azure AD App Registration for this purpose. 
6. The app registration has the necessary API permissions assigned: 
    - AdminCenter.ReadWrite.All
    - Automation.ReadWrite.All
    - User.Read
7. Created a Managed Identity for the automation service that will run the scripts.
    - Role Assignment: Key Vault Reader on the Key Vault.
8. Granted the Managed Identity access to the Key Vault to read the certificate.
9. Went to the Business Central Admin Center of the customer, 
    - Added the App Registration's Application (client) ID.
    - Granted admin consent for the API permissions in the App Registration.
10. Created a script to use certificate-based authentication, retrieving the .pfx from the Key Vault.
11. Tested the Web API calls, and it worked successfully with certificate-based authentication.
12. Uploaded the certificate into the Business Central's Isolated Certificate.
13. Tested the AL code to ensure it works with the certificate-based authentication
    - No success yet.
    - Tested using Client Secret authentication, and it works fine.

# What's not working

Struggling to find documentation and working examples to show how to implement it in AL

-   Please see [AdminCenterRestClient.Codeunit.al](./src/RestClient/AdminCenterRestClient.Codeunit.al), Initialize() function.
-  Please see [scripts](./scripts/), for PowerShell implmentation.
- Certificate-based authentication removed with CERTIFICATE preprocessor directive.