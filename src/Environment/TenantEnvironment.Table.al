namespace EwaldVenter.TenantAdmin.Environment;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Apps.AppSource;
using EwaldVenter.TenantAdmin.Apps.PTE;
using EwaldVenter.TenantAdmin.Company;
using EwaldVenter.TenantAdmin.User;

table 72300 "Tenant Environment EV"
{
    Caption = 'Tenant Environment';
    DataClassification = CustomerContent;
    // LookupPageId = "Tenant Environment List EV";
    // DrillDownPageId = "Tenant Environment List EV";

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
            ToolTip = 'Specifies the name of the environment (e.g., Production, Sandbox).';
        }
        field(11; "Tenant Name"; Text[100])
        {
            CalcFormula = lookup("Managed Tenant EV"."Tenant Name" where("Tenant ID" = field("Tenant ID")));
            Caption = 'Tenant Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the tenant (from Managed Tenant table).';
        }
        field(21; "Environment Type"; Option)
        {
            Caption = 'Environment Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Production,Sandbox';
            OptionMembers = Production,Sandbox;
            ToolTip = 'Specifies whether this is a Production or Sandbox environment.';
        }
        field(30; "Application Version"; Text[50])
        {
            Caption = 'Application Version';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Business Central application version.';
        }
        field(31; "Platform Version"; Text[50])
        {
            Caption = 'Platform Version';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Business Central platform version.';
        }
        field(32; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the country/region localization.';
        }
        field(40; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Active,Inactive,Suspended,Deleted';
            OptionMembers = Active,Inactive,Suspended,Deleted;
            ToolTip = 'Specifies the current status of the environment.';
        }
        field(50; "AppSource App Count"; Integer)
        {
            CalcFormula = count("AppSource App EV" where("Tenant ID" = field("Tenant ID"),
                                                      "Environment Name" = field("Environment Name")));
            Caption = 'AppSource App Count';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of AppSource apps installed in this environment.';
        }
        field(51; "PTE Count"; Integer)
        {
            CalcFormula = count("Per-Tenant Extension EV" where("Tenant ID" = field("Tenant ID"),
                                                             "Environment Name" = field("Environment Name")));
            Caption = 'PTE Count';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of Per-Tenant Extensions in this environment.';
        }
        field(52; "Company Count"; Integer)
        {
            CalcFormula = count("Environment Company EV" where("Tenant ID" = field("Tenant ID"),
                                                   "Environment Name" = field("Environment Name")));
            Caption = 'Company Count';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of companies in this environment.';
        }
        field(53; "User Count"; Integer)
        {
            CalcFormula = count("Environment User EV" where("Tenant ID" = field("Tenant ID"),
                                               "Environment Name" = field("Environment Name")));
            Caption = 'User Count';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of users in this environment.';
        }
        field(60; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies when environment data was last synchronized.';
        }
    }

    keys
    {
        key(PK; "Tenant ID", "Environment Name")
        {
            Clustered = true;
        }
    }
}
