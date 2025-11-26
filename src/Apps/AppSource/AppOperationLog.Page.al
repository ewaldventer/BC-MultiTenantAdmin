namespace EwaldVenter.TenantAdmin.Apps.AppSource;

page 72521 "App Operation Log EV"
{
    ApplicationArea = All;
    Caption = 'App Operation Log';
    Editable = false;
    PageType = List;
    SourceTable = "App Operation Log EV";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Operation DateTime"; Rec."Operation DateTime") { }
                field("Operation Type"; Rec."Operation Type") { }
                field("App Name"; Rec."App Name") { }
                field("Environment Name"; Rec."Environment Name") { }
                field(Success; Rec."Success") { }
                field("Error Message"; Rec."Error Message") { }
            }
        }
    }
}
