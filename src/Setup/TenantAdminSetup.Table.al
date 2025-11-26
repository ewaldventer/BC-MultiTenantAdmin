namespace EwaldVenter.TenantAdmin.Setup;
using System.Security.Encryption;

table 72000 "Tenant Admin Setup EV"
{
    Caption = 'Tenant Admin Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the primary key for the setup table.';
        }
        field(5; "Certificate No."; Code[20])
        {
            Caption = 'Certificate No.';
            DataClassification = CustomerContent;
            TableRelation = "Isolated Certificate";
            ToolTip = 'Specifies the certificate number used for authentication.';
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Admin Center API Client ID';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the Azure AD App Registration Application (client) ID for Admin Center API authentication.';
        }
        field(11; "Key Vault Name"; Text[100])
        {
            Caption = 'Key Vault Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name of the Azure Key Vault containing the authentication certificate.';
        }
        field(12; "Certificate Name"; Text[100])
        {
            Caption = 'Certificate Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name of the certificate in the Azure Key Vault.';
        }
        field(20; "Setup Completed"; Boolean)
        {
            Caption = 'Setup Completed';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies whether the Tenant Admin setup has been completed.';
        }
        field(21; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when the setup was last modified.';
        }
        field(30; "API Version"; Decimal)
        {
            Caption = 'API Version';
            DataClassification = SystemMetadata;
            DecimalPlaces = 1 : 2;
            MinValue = 1.00;
            ToolTip = 'Specifies the version of the Admin Center API to use.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
