namespace EwaldVenter.TenantAdmin.User;

page 72851 "Environment User ListPart EV"
{
    ApplicationArea = All;
    Caption = 'Environment Users';
    CardPageId = "Environment User Card EV";
    Editable = false;
    PageType = ListPart;
    SourceTable = "Environment User EV";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; Rec."User Name") { }
                field("Full Name"; Rec."Full Name") { }
                field(Email; Rec."Email") { }
                field(State; Rec."State") { }
                field("Environment Name"; Rec."Environment Name") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateUser)
            {
                ApplicationArea = All;
                Caption = 'Create User';
                Image = NewDocument;
                ToolTip = 'Creates a new user in the environment.';

                trigger OnAction()
                var
                    UserOperations: Codeunit "User Operations EV";
                begin
                    UserOperations.CreateUser(Rec."Tenant ID", Rec."Environment Name");
                end;
            }
            action(DisableUser)
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
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
    }
}
