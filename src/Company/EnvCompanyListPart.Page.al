namespace EwaldVenter.TenantAdmin.Company;

page 72801 "Env. Company ListPart EV"
{
    ApplicationArea = All;
    Caption = 'Environment Companies';
    CardPageId = "Environment Company Card EV";
    Editable = false;
    PageType = ListPart;
    SourceTable = "Environment Company EV";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name") { }
                field("Display Name"; Rec."Display Name") { }
                field("Environment Name"; Rec."Environment Name")
                {
                    Visible = false;
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshCompanies)
            {
                ApplicationArea = All;
                Caption = 'Refresh Companies';
                Image = Refresh;
                ToolTip = 'Fetches the latest company data for this environment from the Automation API.';

                trigger OnAction()
                var
                    CompanyAPIMgt: Codeunit "Company API Mgt. EV";
                begin
                    CompanyAPIMgt.RefreshCompanies(Rec."Tenant ID", Rec."Environment Name");
                    CurrPage.Update(false);
                end;
            }
            action(CreateCompany)
            {
                ApplicationArea = All;
                Caption = 'Create Company';
                Image = NewDocument;
                ToolTip = 'Creates a new company in the environment.';

                trigger OnAction()
                var
                    CompanyOperations: Codeunit "Company Operations EV";
                begin
                    CompanyOperations.CreateCompany(Rec."Tenant ID", Rec."Environment Name");
                end;
            }
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
    }
}
