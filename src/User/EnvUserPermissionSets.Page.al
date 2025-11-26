namespace EwaldVenter.TenantAdmin.User;

page 72871 "Env. User Permission Sets EV"
{
    ApplicationArea = All;
    Caption = 'User Permission Sets';
    Editable = false;
    PageType = List;
    SourceTable = "Env. User Permission Set EV";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Security ID"; Rec."User Security ID") { }
                field("Permission Set ID"; Rec."Permission Set ID") { }
                field("Environment Name"; Rec."Environment Name") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }
}
