namespace EwaldVenter.TenantAdmin.Core;

using Microsoft.Sales.Customer;

pageextension 72104 "CustomerCard EV" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Managed Tenant Count EV"; ManagedTenantCount)
            {
                ApplicationArea = All;
                Caption = 'Managed Tenants';
                DrillDown = true;
                Editable = false;
                ToolTip = 'Specifies the number of BC tenants managed for this customer.';

                trigger OnDrillDown()
                var
                    ManagedTenant: Record "Managed Tenant EV";
                begin
                    ManagedTenant.SetRange("Customer No.", Rec."No.");
                    Page.Run(Page::"Managed Tenant List EV", ManagedTenant);
                end;
            }
        }
    }

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
        addlast(Category_Category9)
        {
            actionref("ManagedTenants_Promoted EV"; "ManagedTenants EV") { }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalculateManagedTenantCount();
    end;

    local procedure CalculateManagedTenantCount()
    var
        ManagedTenant: Record "Managed Tenant EV";
    begin
        ManagedTenant.SetRange("Customer No.", Rec."No.");
        ManagedTenantCount := ManagedTenant.Count();
    end;

    var
        ManagedTenantCount: Integer;
}
