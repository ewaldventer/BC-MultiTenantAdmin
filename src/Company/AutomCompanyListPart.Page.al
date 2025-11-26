namespace EwaldVenter.TenantAdmin.Company;

page 72821 "Autom. Company ListPart EV"
{
    ApplicationArea = All;
    Caption = 'Automation Companies';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Automation Company EV";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name") { }
                field("Company ID"; Rec."Company ID") { }
                field("Environment Name"; Rec."Environment Name") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }
}
