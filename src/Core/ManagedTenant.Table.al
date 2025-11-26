namespace EwaldVenter.TenantAdmin.Core;

using Microsoft.Sales.Customer;
using EwaldVenter.TenantAdmin.Environment;

table 72100 "Managed Tenant EV"
{
    Caption = 'Managed Tenant';
    DataClassification = CustomerContent;
    DrillDownPageId = "Managed Tenant List EV";
    LookupPageId = "Managed Tenant List EV";

    fields
    {
        field(1; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            ToolTip = 'Specifies the Azure AD Tenant ID (GUID) for this Business Central tenant.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            ToolTip = 'Specifies the customer associated with this tenant.';
        }
        field(11; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive name for this tenant.';
        }
        field(21; "Customer Name"; Text[100])
        {
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the customer (from Customer table).';
        }
        field(30; "Environment Count"; Integer)
        {
            CalcFormula = count("Tenant Environment EV" where("Tenant ID" = field("Tenant ID")));
            Caption = 'Environment Count';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of Business Central environments in this tenant.';
        }
        field(40; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies when data was last synchronized from the Admin Center API.';
        }
        field(50; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
            ToolTip = 'Specifies if this tenant is actively managed.';
        }
    }

    keys
    {
        key(PK; "Tenant ID", "Customer No.")
        {
            Clustered = true;
        }
    }
}
