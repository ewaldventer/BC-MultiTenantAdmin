namespace EwaldVenter.TenantAdmin.Apps.AppSource;

page 72501 "AppSource App ListPart EV"
{
    ApplicationArea = All;
    Caption = 'AppSource Apps';
    CardPageId = "AppSource App Card EV";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "AppSource App EV";
    SourceTableView = sorting(Publisher, "App Name", Version);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("App Name"; Rec."App Name") { }
                field(Publisher; Rec."Publisher") { }
                field(Version; Rec."Version") { }
                field("Available Version"; Rec."Available Version") { }
                field("Update Available"; Rec."Update Available") { }
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
            action(RefreshApps)
            {
                ApplicationArea = All;
                Caption = 'Refresh Apps';
                Image = Refresh;
                ToolTip = 'Fetches the latest AppSource app data for this environment.';

                trigger OnAction()
                var
                    AppSourceAppAPIMgt: Codeunit "AppSource App API Mgt. EV";
                begin
                    AppSourceAppAPIMgt.RefreshApps(Rec."Tenant ID", Rec."Environment Name");
                    CurrPage.Update(false);
                end;
            }
            action(RefreshAvailableUpdates)
            {
                ApplicationArea = All;
                Caption = 'Refresh Available Updates';
                Image = Refresh;
                ToolTip = 'Fetches available app updates for this environment.';

                trigger OnAction()
                var
                    AppSourceAppAPIMgt: Codeunit "AppSource App API Mgt. EV";
                begin
                    AppSourceAppAPIMgt.RefreshAvailableUpdates(Rec."Tenant ID", Rec."Environment Name");
                    CurrPage.Update(false);
                end;
            }
            action(InstallApp)
            {
                Caption = 'Install App';
                Image = AddAction;
                ToolTip = 'Installs this app to the environment.';

                trigger OnAction()
                begin
                    AppSourceAppAPIMgt.InstallApp(Rec);
                end;
            }
            action(UpdateApp)
            {
                Caption = 'Update App';
                Enabled = Rec."Update Available";
                Image = UpdateXML;
                ToolTip = 'Updates this app to the latest version.';

                trigger OnAction()
                begin
                    AppSourceAppAPIMgt.UpdateApp(Rec);
                end;
            }
            action(UninstallApp)
            {
                Caption = 'Uninstall App';
                Image = UnApply;
                ToolTip = 'Uninstalls this app from the environment.';

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to uninstall %1?', false, Rec."App Name") then
                        AppSourceAppAPIMgt.UninstallApp(Rec);
                end;
            }
        }
    }

    var
        AppSourceAppAPIMgt: Codeunit "AppSource App API Mgt. EV";
}
