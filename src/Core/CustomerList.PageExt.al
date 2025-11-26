namespace EwaldVenter.TenantAdmin.Core;

using Microsoft.Sales.Customer;

pageextension 72105 "CustomerList EV" extends "Customer List"
{
    actions
    {
        addlast(Navigation)
        {
            action("ManagedTenants EV")
            {
                ApplicationArea = All;
                Caption = 'Managed Tenants';
                Image = Database;
                RunObject = page "Managed Tenant List EV";
                RunPageLink = "Customer No." = field("No.");
                ToolTip = 'Opens the list of Business Central tenants managed for this customer.';
            }
        }
        addlast(Category_Category7)
        {
            actionref("ManagedTenants_Promoted EV"; "ManagedTenants EV") { }
        }
    }
}
