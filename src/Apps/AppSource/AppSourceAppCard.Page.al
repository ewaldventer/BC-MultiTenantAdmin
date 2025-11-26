namespace EwaldVenter.TenantAdmin.Apps.AppSource;

page 72502 "AppSource App Card EV"
{
    ApplicationArea = All;
    Caption = 'AppSource App Card';
    PageType = Card;
    SourceTable = "AppSource App EV";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("App Name"; Rec."App Name") { }
                field(Publisher; Rec."Publisher") { }
                field("App ID"; Rec."App ID") { }
                field(State; Rec."State") { }
            }
            group(VersionGroup)
            {
                Caption = 'Version';

                field(Version; Rec."Version") { }
                field("Available Version"; Rec."Available Version") { }
                field("Update Available"; Rec."Update Available") { }
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

                field("Last Operation Result"; Rec."Last Operation Result")
                {
                    MultiLine = true;
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(InstallApp_Promoted; InstallApp) { }
                actionref(UpdateApp_Promoted; UpdateApp) { }
                actionref(UninstallApp_Promoted; UninstallApp) { }
            }
        }
    }

    var
        AppSourceAppAPIMgt: Codeunit "AppSource App API Mgt. EV";
}
