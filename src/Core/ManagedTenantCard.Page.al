namespace EwaldVenter.TenantAdmin.Core;

using EwaldVenter.TenantAdmin.Environment;
using Microsoft.Sales.Customer;

page 72102 "Managed Tenant Card EV"
{
    ApplicationArea = All;
    Caption = 'Managed Tenant Card';
    PageType = Card;
    SourceTable = "Managed Tenant EV";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Tenant Name"; Rec."Tenant Name") { }
                field("Tenant ID"; Rec."Tenant ID") { }
                field(Active; Rec."Active") { }
            }
            group(CustomerGroup)
            {
                Caption = 'Customer';

                field("Customer No."; Rec."Customer No.") { }

                field("Customer Name"; Rec."Customer Name") { }
            }
            group(Statistics)
            {
                Caption = 'Statistics';

                field("Environment Count"; Rec."Environment Count") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
            part(TenantEnvironments; "Tenant Env. ListPart EV")
            {
                ApplicationArea = All;
                Caption = 'Tenant Environments';
                SubPageLink = "Tenant ID" = field("Tenant ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Refresh Environments';
                Image = Refresh;
                ToolTip = 'Fetches the latest environment data from the Admin Center API.';

                trigger OnAction()
                var
                    EnvironmentAPIMgt: Codeunit "Environment API Mgt. EV";
                begin
                    EnvironmentAPIMgt.RefreshEnvironments(Rec."Tenant ID");
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(Customer)
            {
                ApplicationArea = All;
                Caption = 'Customer';
                Image = Customer;
                RunObject = page "Customer Card";
                RunPageLink = "No." = field("Customer No.");
                ToolTip = 'Opens the customer card.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(RefreshEnvironments_Promoted; RefreshEnvironments) { }
            }
        }
    }
}
