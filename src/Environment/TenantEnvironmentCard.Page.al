namespace EwaldVenter.TenantAdmin.Environment;

using EwaldVenter.TenantAdmin.Apps.AppSource;
using EwaldVenter.TenantAdmin.Apps.PTE;
using EwaldVenter.TenantAdmin.Company;
using EwaldVenter.TenantAdmin.User;
using EwaldVenter.TenantAdmin.Core;

page 72302 "Tenant Environment Card EV"
{
    ApplicationArea = All;
    Caption = 'Tenant Environment Card';
    PageType = Card;
    SourceTable = "Tenant Environment EV";
    DataCaptionFields = "Environment Name";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;

                field("Environment Name"; Rec."Environment Name") { }
                field("Environment Type"; Rec."Environment Type") { }
                field("Tenant Name"; Rec."Tenant Name") { }
                field(Status; Rec."Status") { }
            }
            group(Version)
            {
                Caption = 'Version';
                Editable = false;

                field("Application Version"; Rec."Application Version") { }
                field("Platform Version"; Rec."Platform Version") { }
                field("Country Code"; Rec."Country Code") { }
            }
            group(Statistics)
            {
                Caption = 'Statistics';

                field("AppSource App Count"; Rec."AppSource App Count") { }
                field("PTE Count"; Rec."PTE Count") { }
                field("Company Count"; Rec."Company Count") { }
                field("User Count"; Rec."User Count") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
            part(AppSourceAppsList; "AppSource App ListPart EV")
            {
                Caption = 'AppSource Apps';
                SubPageLink = "Tenant ID" = field("Tenant ID"),
                              "Environment Name" = field("Environment Name");
                UpdatePropagation = Both;
            }
            part(ExtensionsList; "Per-Tenant Extensions EV")
            {
                Caption = 'PTE Apps';
                SubPageLink = "Tenant ID" = field("Tenant ID"),
                              "Environment Name" = field("Environment Name");
            }
            part(EnvironmentUsers; "Environment User ListPart EV")
            {
                Caption = 'Environment Users';
                SubPageLink = "Tenant ID" = field("Tenant ID"),
                              "Environment Name" = field("Environment Name");
            }
            part(EnvironmentCompanies; "Env. Company ListPart EV")
            {
                Caption = 'Environment Companies';
                SubPageLink = "Tenant ID" = field("Tenant ID"),
                              "Environment Name" = field("Environment Name");
            }
            part(AutomationCompanies; "Autom. Company ListPart EV")
            {
                Caption = 'Automation Companies';
                SubPageLink = "Tenant ID" = field("Tenant ID"),
                              "Environment Name" = field("Environment Name");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(EnvironmentActions)
            {
                Caption = 'Environment Management';

                action(RenameEnvironment)
                {
                    ApplicationArea = All;
                    Caption = 'Rename Environment';
                    Image = ServiceCode;
                    ToolTip = 'Rename this environment (Sandbox only).';
                    Enabled = Rec."Environment Type" = Rec."Environment Type"::Sandbox;

                    trigger OnAction()
                    var
                        NewEnvironmentName: Text;
                    begin
                        NewEnvironmentName := '';
                        if Prompt('Enter new environment name:', NewEnvironmentName) then
                            EnvironmentOperations.RenameEnvironment(Rec, NewEnvironmentName);
                    end;
                }

                action(CopyEnvironment)
                {
                    ApplicationArea = All;
                    Caption = 'Copy Environment';
                    Image = Copy;
                    ToolTip = 'Create a copy of this environment (Sandbox destination only).';

                    trigger OnAction()
                    var
                        DestinationName: Text;
                    begin
                        DestinationName := '';
                        if Prompt('Enter destination environment name:', DestinationName) then
                            EnvironmentOperations.CopyEnvironment(Rec, DestinationName, 'Sandbox');
                    end;
                }

                separator(EnvironmentSeparator) { }

                action(DeleteSoft)
                {
                    ApplicationArea = All;
                    Caption = 'Delete (Recoverable)';
                    Image = Delete;
                    ToolTip = 'Soft delete - can be recovered for 14 days (Sandbox only).';
                    Enabled = Rec."Environment Type" = Rec."Environment Type"::Sandbox;

                    trigger OnAction()
                    begin
                        if Confirm('Delete %1 for recovery? It can be recovered for 14 days.', false, Rec."Environment Name") then
                            EnvironmentOperations.DeleteEnvironmentSoft(Rec);
                    end;
                }

                action(DeletePermanent)
                {
                    ApplicationArea = All;
                    Caption = 'Delete (Permanent)';
                    Image = Delete;
                    ToolTip = 'Hard delete - CANNOT be recovered (Sandbox only).';
                    Enabled = Rec."Environment Type" = Rec."Environment Type"::Sandbox;

                    trigger OnAction()
                    begin
                        if Confirm('PERMANENTLY DELETE %1? This cannot be undone.', false, Rec."Environment Name") then
                            EnvironmentOperations.DeleteEnvironmentHard(Rec);
                    end;
                }
            }

            group(UpdateActions)
            {
                Caption = 'Updates';

                action(RefreshUpdates)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Available Updates';
                    Image = Refresh;
                    ToolTip = 'Get latest available updates for this environment.';

                    trigger OnAction()
                    begin
                        EnvironmentOperations.RefreshEnvironmentUpdates(Rec);
                        CurrPage.Update(false);
                    end;
                }

                action(ScheduleUpdate)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule Update';
                    Image = Calendar;
                    ToolTip = 'Select target version and schedule update date/time.';

                    trigger OnAction()
                    var
                        ScheduleUpdateDialogPage: Page "Schedule Update Dialog EV";
                    begin
                        if ScheduleUpdateDialogPage.RunModal() = Action::OK then
                            ScheduleUpdateDialogPage.GetScheduleDetails(Rec, EnvironmentOperations);
                    end;
                }

                action(CancelUpdate)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Running Update';
                    Image = Cancel;
                    ToolTip = 'Cancel the currently running update (if allowed).';

                    trigger OnAction()
                    var
                        OperationIdText: Text;
                    begin
                        OperationIdText := '';
                        if Prompt('Enter the operation ID of the running update to cancel:', OperationIdText) then
                            if Confirm('Cancel the currently running update? Environment will be restored to previous state.', false) then
                                EnvironmentOperations.CancelEnvironmentUpdate(Rec, OperationIdText);
                    end;
                }
            }

            action(RefreshEnvironment)
            {
                ApplicationArea = All;
                Caption = 'Refresh Environment Data';
                Image = Refresh;
                ToolTip = 'Fetches the latest data for this environment from the Admin Center API.';

                trigger OnAction()
                var
                    EnvironmentAPIMgt: Codeunit "Environment API Mgt. EV";
                begin
                    EnvironmentAPIMgt.RefreshEnvironments(Rec."Tenant ID");
                    CurrPage.Update(false);
                end;
            }

            action(RestartEnvironment)
            {
                ApplicationArea = All;
                Caption = 'Restart Environment';
                Image = ResetStatus;
                ToolTip = 'Restarts this Business Central environment.';

                trigger OnAction()
                var
                    EnvironmentOperations: Codeunit "Environment Operations EV";
                begin
                    if Confirm('Are you sure you want to restart environment %1?', false, Rec."Environment Name") then
                        EnvironmentOperations.RestartEnvironment(Rec);
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(RefreshEnvironment_Promoted; RefreshEnvironment) { }
                actionref(RestartEnvironment_Promoted; RestartEnvironment) { }
                actionref(RefreshUpdates_Promoted; RefreshUpdates) { }
                actionref(ScheduleUpdate_Promoted; ScheduleUpdate) { }
            }
        }
    }

    var
        EnvironmentOperations: Codeunit "Environment Operations EV";


    local procedure Prompt(Question: Text; var Answer: Text): Boolean
    var
        simpleInput: Page "Simple Input EV";
    begin
        simpleInput.SetCaptionValue(Question);
        simpleInput.SetNewValue('');
        if (simpleInput.RunModal() = Action::OK) or simpleInput.IsValidEntry() then begin
            Answer := StrSubstNo('@*%1*', simpleInput.GetNewValue());
            exit(true);
        end;
    end;
}