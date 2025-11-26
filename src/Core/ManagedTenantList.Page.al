namespace EwaldVenter.TenantAdmin.Core;

using EwaldVenter.TenantAdmin.Environment;
using Microsoft.Sales.Customer;

page 72101 "Managed Tenant List EV"
{
    ApplicationArea = All;
    Caption = 'Managed Tenants';
    CardPageId = "Managed Tenant Card EV";
    Editable = false;
    PageType = List;
    SourceTable = "Managed Tenant EV";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tenant Name"; Rec."Tenant Name") { }
                field("Tenant ID"; Rec."Tenant ID") { }
                field("Customer No."; Rec."Customer No.") { }
                field("Customer Name"; Rec."Customer Name") { }
                field("Environment Count"; Rec."Environment Count") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
                field(Active; Rec."Active") { }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links) { }
            systempart(Notes; Notes) { }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Customer)
            {
                ApplicationArea = All;
                Caption = 'Customer';
                Image = Customer;
                RunObject = page "Customer Card";
                RunPageLink = "No." = field("Customer No.");
                ToolTip = 'Opens the customer card for this tenant.';
            }
        }
    }
}
