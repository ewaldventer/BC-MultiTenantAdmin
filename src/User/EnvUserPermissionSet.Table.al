namespace EwaldVenter.TenantAdmin.User;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72870 "Env. User Permission Set EV"
{
    Caption = 'Environment User Permission Set';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique entry number for this user permission set record.';
        }
        field(10; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant that contains this user permission set.';
        }
        field(11; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where this user permission set is assigned.';
        }
        field(20; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            TableRelation = "Environment User EV"."User Security ID" where("Tenant ID" = field("Tenant ID"), "Environment Name" = field("Environment Name"));
            ToolTip = 'Specifies the unique security identifier of the user to whom this permission set is assigned.';
        }
        field(30; "Permission Set ID"; Code[20])
        {
            Caption = 'Permission Set ID';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the permission set identifier.';
        }
        field(40; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when this user permission set was last synchronized with the Business Central environment.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenantEnvUser; "Tenant ID", "Environment Name", "User Security ID", "Permission Set ID")
        {
        }
    }
}
