namespace EwaldVenter.TenantAdmin.Environment;

using EwaldVenter.TenantAdmin.Core;

table 72320 "Environment Operation Log EV"
{
    Caption = 'Environment Operation Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique entry number for this environment operation log record.';
        }
        field(10; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant where the operation was performed.';
        }
        field(11; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where the operation was performed.';
        }
        field(20; "Operation Type"; Text[50])
        {
            Caption = 'Operation Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of operation that was performed on the environment.';
        }
        field(30; "Operation DateTime"; DateTime)
        {
            Caption = 'Operation Date Time';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time when the operation was performed.';
        }
        field(40; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the operation completed successfully.';
        }
        field(50; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the error message if the operation failed.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenantEnv; "Tenant ID", "Environment Name", "Operation DateTime")
        {
        }
    }
}
