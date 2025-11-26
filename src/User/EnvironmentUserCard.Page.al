namespace EwaldVenter.TenantAdmin.User;

page 72852 "Environment User Card EV"
{
    ApplicationArea = All;
    Caption = 'Environment User Card';
    PageType = Card;
    SourceTable = "Environment User EV";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("User Name"; Rec."User Name") { }
                field("Full Name"; Rec."Full Name") { }
                field(Email; Rec."Email") { }
                field("User Security ID"; Rec."User Security ID") { }
                field(State; Rec."State") { }
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
            action(DisableUser)
            {
                Caption = 'Disable User';
                Enabled = Rec.State = Rec.State::Enabled;
                Image = Lock;
                ToolTip = 'Disables this user account.';

                trigger OnAction()
                var
                    UserOperations: Codeunit "User Operations EV";
                begin
                    if Confirm('Are you sure you want to disable user %1?', false, Rec."User Name") then
                        UserOperations.DisableUser(Rec);
                end;
            }
            action(EnableUser)
            {
                Caption = 'Enable User';
                Enabled = Rec.State = Rec.State::Disabled;
                Image = Approve;
                ToolTip = 'Enables this user account.';

                trigger OnAction()
                var
                    UserOperations: Codeunit "User Operations EV";
                begin
                    UserOperations.EnableUser(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(DisableUser_Promoted; DisableUser) { }
                actionref(EnableUser_Promoted; EnableUser) { }
            }
        }
    }
}
