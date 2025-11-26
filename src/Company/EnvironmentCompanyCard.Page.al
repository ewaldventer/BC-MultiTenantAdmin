namespace EwaldVenter.TenantAdmin.Company;

page 72802 "Environment Company Card EV"
{
    ApplicationArea = All;
    Caption = 'Environment Company Card';
    PageType = Card;
    SourceTable = "Environment Company EV";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Company Name"; Rec."Company Name") { }
                field("Display Name"; Rec."Display Name") { }
                field("Company ID"; Rec."Company ID") { }
            }
            group(Environment)
            {
                Caption = 'Environment';

                field("Environment Name"; Rec."Environment Name") { }
                field("Tenant ID"; Rec."Tenant ID") { }
            }
            group(Status)
            {
                Caption = 'Status';

                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteCompany)
            {
                ApplicationArea = All;
                Caption = 'Delete Company';
                Image = Delete;
                ToolTip = 'Deletes this company from the environment.';

                trigger OnAction()
                var
                    CompanyOperations: Codeunit "Company Operations EV";
                begin
                    if Confirm('Are you sure you want to delete company %1?', false, Rec."Company Name") then
                        CompanyOperations.DeleteCompany(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(DeleteCompany_Promoted; DeleteCompany) { }
            }
        }
    }
}
