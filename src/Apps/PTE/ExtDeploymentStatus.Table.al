namespace EwaldVenter.TenantAdmin.Apps.PTE;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72720 "Ext. Deployment Status EV"
{
    Caption = 'Extension Deployment Status';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique entry number for this extension deployment status record.';
        }
        field(10; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant where the extension deployment was performed.';
        }
        field(11; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where the extension deployment was performed.';
        }
        field(20; "Extension ID"; Guid)
        {
            Caption = 'Extension ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for the extension that was deployed.';
        }
        field(21; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the display name of the extension that was deployed.';
        }
        field(30; "Operation Type"; Text[50])
        {
            Caption = 'Operation Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of deployment operation that was performed.';
        }
        field(40; "Operation DateTime"; DateTime)
        {
            Caption = 'Operation Date Time';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time when the deployment operation was performed.';
        }
        field(50; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the deployment operation completed successfully.';
        }
        field(60; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the error message if the deployment operation failed.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenantEnvExt; "Tenant ID", "Environment Name", "Extension ID", "Operation DateTime")
        {
        }
    }
}
