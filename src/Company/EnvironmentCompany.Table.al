namespace EwaldVenter.TenantAdmin.Company;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72800 "Environment Company EV"
{
    Caption = 'Environment Company';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Managed Tenant EV"."Tenant ID";
            ToolTip = 'Specifies the unique identifier of the tenant that contains this company.';
        }
        field(2; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            TableRelation = "Tenant Environment EV"."Environment Name" where("Tenant ID" = field("Tenant ID"));
            ToolTip = 'Specifies the name of the Business Central environment where this company is located.';
        }
        field(3; "Company ID"; Guid)
        {
            Caption = 'Company ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for this company.';
        }
        field(21; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = OrganizationIdentifiableInformation;
            ToolTip = 'Specifies the internal company name.';
        }
        field(22; "Display Name"; Text[100])
        {
            Caption = 'Display Name';
            DataClassification = OrganizationIdentifiableInformation;
            ToolTip = 'Specifies the display name of the company.';
        }
        field(40; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the date and time when this company was last synchronized with the Business Central environment.';
        }
    }

    keys
    {
        key(PK; "Tenant ID", "Environment Name", "Company ID")
        {
            Clustered = true;
        }
    }
}
