namespace EwaldVenter.TenantAdmin.Environment;

page 72321 "Environment Operation Log EV"
{
    ApplicationArea = All;
    Caption = 'Environment Operation Log';
    Editable = false;
    PageType = List;
    SourceTable = "Environment Operation Log EV";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Operation DateTime"; Rec."Operation DateTime") { }
                field("Operation Type"; Rec."Operation Type") { }
                field("Environment Name"; Rec."Environment Name") { }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    Visible = false;
                }
                field(Success; Rec."Success") { }
                field("Error Message"; Rec."Error Message") { }
            }
        }
    }
}
