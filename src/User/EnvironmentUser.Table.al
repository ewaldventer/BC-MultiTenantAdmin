namespace EwaldVenter.TenantAdmin.User;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72850 "Environment User EV"
{
    Caption = 'Environment User';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique entry number for this user record.';
        }
        field(10; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant that contains this user.';
        }
        field(11; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where this user exists.';
        }
        field(20; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            ToolTip = 'Specifies the unique security identifier for this user.';
        }
        field(21; "User Name"; Text[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user name (User Principal Name).';
        }
        field(22; "Full Name"; Text[100])
        {
            Caption = 'Full Name';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the full display name of the user.';
        }
        field(30; Email; Text[250])
        {
            Caption = 'Email';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the email address of the user.';
        }
        field(40; State; Option)
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            OptionCaption = 'Enabled,Disabled';
            OptionMembers = Enabled,Disabled;
            ToolTip = 'Specifies the state of the user account.';
        }
        field(50; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when this user was last synchronized with the Business Central environment.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenantEnvUser; "Tenant ID", "Environment Name", "User Security ID")
        {
        }
    }
}
