namespace EwaldVenter.TenantAdmin.Apps.PTE;

page 72702 "Per-Tenant Extension Card EV"
{
    ApplicationArea = All;
    Caption = 'Per-Tenant Extension Card';
    DataCaptionFields = "Extension Name";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Per-Tenant Extension EV";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Extension Name"; Rec."Extension Name") { }
                field(Publisher; Rec."Publisher") { }
                field("Extension ID"; Rec."Extension ID") { }
                field(Version; Rec."Version") { }
                field(Scope; Rec."Scope") { }
            }
            group(Status)
            {
                Caption = 'Status';

                field("Is Published"; Rec."Is Published") { }
                field("Is Installed"; Rec."Is Installed") { }
                field("Last Operation Result"; Rec."Last Operation Result")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
            group(Environment)
            {
                Caption = 'Environment';

                field("Environment Name"; Rec."Environment Name") { }
                field("Tenant ID"; Rec."Tenant ID") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
        area(Promoted)
        {
            group(Category_Process)
            {
                // actionref(PublishExtension_Promoted; PublishExtension) { }
                actionref(InstallExtension_Promoted; InstallExtension) { }
                actionref(UninstallExtension_Promoted; UninstallExtension) { }
                actionref(UnpublishExtension_Promoted; UnpublishExtension) { }
            }
        }
    }
}
