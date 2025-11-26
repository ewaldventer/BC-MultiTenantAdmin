namespace EwaldVenter.TenantAdmin.Apps.AppSource;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72520 "App Operation Log EV"
{
    Caption = 'App Operation Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique entry number for this app operation log record.';
        }
        field(10; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant where the app operation was performed.';
        }
        field(11; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where the app operation was performed.';
        }
        field(20; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for the app on which the operation was performed.';
        }
        field(21; "App Name"; Text[250])
        {
            Caption = 'App Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the display name of the app on which the operation was performed.';
        }
        field(30; "Operation Type"; Text[50])
        {
            Caption = 'Operation Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of operation that was performed on the app.';
        }
        field(40; "Operation DateTime"; DateTime)
        {
            Caption = 'Operation Date Time';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time when the app operation was performed.';
        }
        field(50; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the app operation completed successfully.';
        }
        field(60; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the error message if the app operation failed.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenantEnvApp; "Tenant ID", "Environment Name", "App ID", "Operation DateTime")
        {
        }
    }
}
