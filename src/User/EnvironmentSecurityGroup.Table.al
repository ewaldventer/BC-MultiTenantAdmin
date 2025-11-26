namespace EwaldVenter.TenantAdmin.User;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72880 "Environment Security Group EV"
{
    Caption = 'Environment Security Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique entry number for this security group record.';
        }
        field(10; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant that contains this security group.';
        }
        field(11; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where this security group is assigned.';
        }
        field(20; "Security Group ID"; Guid)
        {
            Caption = 'Security Group ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for this security group.';
        }
        field(21; "Security Group Name"; Text[100])
        {
            Caption = 'Security Group Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name of the security group.';
        }
        field(30; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when this security group was last synchronized with the Business Central environment.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenantEnvGroup; "Tenant ID", "Environment Name", "Security Group ID")
        {
        }
    }
}
