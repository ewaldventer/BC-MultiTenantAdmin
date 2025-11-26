namespace EwaldVenter.TenantAdmin.Apps.PTE;

page 72721 "Ext. Deployment Status EV"
{
    ApplicationArea = All;
    Caption = 'Extension Deployment Status';
    Editable = false;
    PageType = List;
    SourceTable = "Ext. Deployment Status EV";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Operation DateTime"; Rec."Operation DateTime") { }
                field("Operation Type"; Rec."Operation Type") { }
                field("Extension Name"; Rec."Extension Name") { }
                field("Environment Name"; Rec."Environment Name") { }
                field(Success; Rec."Success") { }
                field("Error Message"; Rec."Error Message") { }
            }
        }
    }
}
