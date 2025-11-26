namespace EwaldVenter.TenantAdmin.Setup;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

table 72020 "Tenant Admin Activities EV"
{
    Caption = 'Tenant Admin Activities';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the primary key for the activities table.';
        }
        field(10; "Active Tenants"; Integer)
        {
            CalcFormula = count("Managed Tenant EV" where(Active = const(true)));
            Caption = 'Active Tenants';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of active managed tenants.';
        }
        field(11; "Total Environments"; Integer)
        {
            CalcFormula = count("Tenant Environment EV");
            Caption = 'Total Environments';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the total number of Business Central environments across all tenants.';
        }
        field(12; "Production Environments"; Integer)
        {
            CalcFormula = count("Tenant Environment EV" where("Environment Type" = const(Production)));
            Caption = 'Production Environments';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of production environments across all tenants.';
        }
        field(13; "Sandbox Environments"; Integer)
        {
            CalcFormula = count("Tenant Environment EV" where("Environment Type" = const(Sandbox)));
            Caption = 'Sandbox Environments';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of sandbox environments across all tenants.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
