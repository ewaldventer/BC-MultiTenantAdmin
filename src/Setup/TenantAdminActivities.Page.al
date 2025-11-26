namespace EwaldVenter.TenantAdmin.Setup;

using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;

page 72021 "Tenant Admin Activities EV"
{
    ApplicationArea = All;
    Caption = 'Tenant Admin Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Tenant Admin Activities EV";

    layout
    {
        area(content)
        {
            cuegroup(Tenants)
            {
                Caption = 'Tenants';

                field("Active Tenants"; Rec."Active Tenants") { }
            }
            cuegroup(Environments)
            {
                Caption = 'Environments';

                field("Total Environments"; Rec."Total Environments") { }
                field("Production Environments"; Rec."Production Environments") { }
                field("Sandbox Environments"; Rec."Sandbox Environments") { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
