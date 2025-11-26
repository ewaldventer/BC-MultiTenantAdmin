namespace EwaldVenter.TenantAdmin.Setup;

using EwaldVenter.TenantAdmin.Core;
using Microsoft.Sales.Customer;

page 72022 "Tenant Admin Role Center EV"
{
    ApplicationArea = All;
    Caption = 'Tenant Administration';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "Tenant Admin Activities EV") { }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Tenants)
            {
                Caption = 'Tenants';
                action(ManagedTenants)
                {
                    ApplicationArea = All;
                    Caption = 'Managed Tenants';
                    RunObject = page "Managed Tenant List EV";
                    ToolTip = 'Opens a list of Managed Tenants.';
                }
            }
            group(CustomersGroup)
            {
                Caption = 'Customers';
                action(Customers)
                {
                    ApplicationArea = All;
                    Caption = 'Customers with Tenants';
                    RunObject = page "Customer List";
                    ToolTip = 'Opens a list of Customers with Tenants.';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action(TenantAdminSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Tenant Admin Setup';
                    RunObject = page "Tenant Admin Setup EV";
                    ToolTip = 'Opens Tenant Admin Setup.';
                }
            }
        }
        area(Embedding)
        {
            action(EmbeddedTenants)
            {
                ApplicationArea = All;
                Caption = 'Tenants';
                RunObject = page "Managed Tenant List EV";
                ToolTip = 'Executes the Tenants action.';
            }
            action(EmbeddedCustomers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                RunObject = page "Customer List";
                ToolTip = 'Executes the Customers action.';
            }
        }
    }
}
