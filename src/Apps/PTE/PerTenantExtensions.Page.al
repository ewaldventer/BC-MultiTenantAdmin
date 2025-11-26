namespace EwaldVenter.TenantAdmin.Apps.PTE;

page 72701 "Per-Tenant Extensions EV"
{
    ApplicationArea = All;
    Caption = 'Per-Tenant Extensions';
    CardPageId = "Per-Tenant Extension Card EV";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Per-Tenant Extension EV";
    SourceTableView = sorting(Publisher, "Extension Name", Version);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Extension Name"; Rec."Extension Name") { }
                field(Publisher; Rec."Publisher") { }
                field(Version; Rec."Version") { }
                field("Is Published"; Rec."Is Published") { }
                field("Is Installed"; Rec."Is Installed") { }
                field(Scope; Rec."Scope") { }
                field("Environment Name"; Rec."Environment Name")
                {
                    Visible = false;
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshPTEs)
            {
                ApplicationArea = All;
                Caption = 'Refresh PTEs';
                Image = Refresh;
                ToolTip = 'Fetches the latest per-tenant extension data for this environment.';

                trigger OnAction()
                var
                    PTEAPIMgt: Codeunit "PTE API Mgt. EV";
                begin
                    PTEAPIMgt.RefreshPTEs(Rec."Tenant ID", Rec."Environment Name");
                    CurrPage.Update(false);
                end;
            }
            // action(PublishExtension)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Publish Extension';
            //     Image = PostDocument;
            //     ToolTip = 'Publishes the extension to the environment.';

            //     trigger OnAction()
            //     var
            //         PTEOperations: Codeunit "PTE Operations EV";
            //     begin
            //         PTEOperations.PublishExtension(Rec);
            //     end;
            // }
            action(InstallExtension)
            {
                ApplicationArea = All;
                Caption = 'Install Extension';
                Enabled = Rec."Is Published" and not Rec."Is Installed";
                Image = AddAction;
                ToolTip = 'Installs the extension.';

                trigger OnAction()
                var
                    PTEOperations: Codeunit "PTE Operations EV";
                begin
                    PTEOperations.InstallExtension(Rec);
                end;
            }
            action(UninstallExtension)
            {
                ApplicationArea = All;
                Caption = 'Uninstall Extension';
                Enabled = Rec."Is Installed";
                Image = UnApply;
                ToolTip = 'Uninstalls the extension.';

                trigger OnAction()
                var
                    PTEOperations: Codeunit "PTE Operations EV";
                begin
                    if Confirm('Are you sure you want to uninstall %1?', false, Rec."Extension Name") then
                        PTEOperations.UninstallExtension(Rec);
                end;
            }
            action(UnpublishExtension)
            {
                ApplicationArea = All;
                Caption = 'Unpublish Extension';
                Enabled = Rec."Is Published" and not Rec."Is Installed";
                Image = Delete;
                ToolTip = 'Unpublishes the extension from the environment.';

                trigger OnAction()
                var
                    PTEOperations: Codeunit "PTE Operations EV";
                begin
                    if Confirm('Are you sure you want to unpublish %1?', false, Rec."Extension Name") then
                        PTEOperations.UnpublishExtension(Rec);
                end;
            }
        }
    }
}
