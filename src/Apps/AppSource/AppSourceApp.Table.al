namespace EwaldVenter.TenantAdmin.Apps.AppSource;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72500 "AppSource App EV"
{
    Caption = 'AppSource App';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant that contains this app.';
        }
        field(2; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where this app is installed.';
        }
        field(3; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for this app.';
        }
        field(4; Version; Text[50])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the currently installed version.';
        }
        field(21; "App Name"; Text[250])
        {
            Caption = 'App Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the display name of the app.';
        }
        field(22; Publisher; Text[250])
        {
            Caption = 'Publisher';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the publisher of the app.';
        }
        field(31; "Available Version"; Text[50])
        {
            Caption = 'Available Version';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the latest available version if an update exists.';
        }
        field(40; State; Option)
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            OptionCaption = 'Installed,Update Pending,Updating,Installing,Uninstalling';
            OptionMembers = Installed,UpdatePending,Updating,Installing,Uninstalling;
            ToolTip = 'Specifies the current state of the app.';
        }
        field(50; "Update Available"; Boolean)
        {
            Caption = 'Update Available';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if a newer version is available.';
        }
        field(60; "Last Operation Result"; Text[250])
        {
            Caption = 'Last Operation Result';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the result message of the last operation performed on this app.';
        }
        field(70; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when this app was last synchronized with the Business Central environment.';
        }
    }

    keys
    {
        key(PK; "Tenant ID", "Environment Name", "App ID", Version)
        {
            Clustered = true;
        }
        key(SortByPublisher; Publisher, "App Name", Version) { }
    }
}
