namespace EwaldVenter.TenantAdmin.Apps.PTE;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72700 "Per-Tenant Extension EV"
{
    Caption = 'Per-Tenant Extension';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant that contains this extension.';
        }
        field(2; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where this extension is deployed.';
        }
        field(3; "Extension ID"; Guid)
        {
            Caption = 'Extension ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for this extension.';
        }
        field(21; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the display name of the extension.';
        }
        field(22; Publisher; Text[250])
        {
            Caption = 'Publisher';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the publisher of the extension.';
        }
        field(4; Version; Text[50])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the version of the extension.';
        }
        field(40; "Is Installed"; Boolean)
        {
            Caption = 'Is Installed';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the extension is installed.';
        }
        field(41; "Is Published"; Boolean)
        {
            Caption = 'Is Published';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the extension is published to the environment.';
        }
        field(50; Scope; Option)
        {
            Caption = 'Scope';
            DataClassification = CustomerContent;
            OptionCaption = 'PTE,Global,Dev';
            OptionMembers = PTE,Global,Dev;
            ToolTip = 'Specifies the scope of the extension.';
        }
        field(60; "Last Operation Result"; Text[250])
        {
            Caption = 'Last Operation Result';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the result message of the last operation performed on this extension.';
        }
        field(70; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when this extension was last synchronized with the Business Central environment.';
        }
    }

    keys
    {
        key(PK; "Tenant ID", "Environment Name", "Extension ID", Version)
        {
            Clustered = true;
        }
        key(SortByPublisher; Publisher, "Extension Name", Version) { }
    }
}
