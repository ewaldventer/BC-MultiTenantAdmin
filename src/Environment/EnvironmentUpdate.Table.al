namespace EwaldVenter.TenantAdmin.Environment;

using EwaldVenter.TenantAdmin.Core;

table 72310 "Environment Update EV"
{
    Caption = 'Environment Update';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the Azure AD Tenant ID.';
        }
        field(2; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name of the environment.';
        }
        field(3; "Target Version"; Text[50])
        {
            Caption = 'Target Version';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the target version for update (e.g., 26.1, 26.2).';
        }
        field(4; Available; Boolean)
        {
            Caption = 'Available';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether this target version has been released.';
        }
        field(5; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether this target version is selected as the next update.';
        }
        field(6; "Target Version Type"; Option)
        {
            Caption = 'Target Version Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'GA,Preview';
            OptionMembers = GA,Preview;
            ToolTip = 'Specifies the type of the target version (GA or Preview).';
        }
        field(7; "Latest Selectable Date"; DateTime)
        {
            Caption = 'Latest Selectable Date';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the last date for which this update can be scheduled.';
        }
        field(8; "Selected DateTime"; DateTime)
        {
            Caption = 'Selected DateTime';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when this update is scheduled to start.';
        }
        field(9; "Ignore Update Window"; Boolean)
        {
            Caption = 'Ignore Update Window';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the environment update window is ignored for this update.';
        }
        field(10; "Rollout Status"; Text[50])
        {
            Caption = 'Rollout Status';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the rollout status (Active, UnderMaintenance, Postponed).';
        }
        field(11; "Expected Month"; Integer)
        {
            Caption = 'Expected Month';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the month when unreleased version is expected to be available.';
        }
        field(12; "Expected Year"; Integer)
        {
            Caption = 'Expected Year';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the year when unreleased version is expected to be available.';
        }
        field(13; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync DateTime';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies when the update information was last synchronized from API.';
        }
    }

    keys
    {
        key(PK; "Tenant ID", "Environment Name", "Target Version")
        {
            Clustered = true;
        }
    }
}
