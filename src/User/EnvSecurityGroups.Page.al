namespace EwaldVenter.TenantAdmin.User;

page 72881 "Env. Security Groups EV"
{
    ApplicationArea = All;
    Caption = 'Environment Security Groups';
    Editable = false;
    PageType = List;
    SourceTable = "Environment Security Group EV";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Security Group Name"; Rec."Security Group Name") { }
                field("Security Group ID"; Rec."Security Group ID") { }
                field("Environment Name"; Rec."Environment Name") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }
}
