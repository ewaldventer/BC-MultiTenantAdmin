namespace EwaldVenter.TenantAdmin.Environment;

using EwaldVenter.TenantAdmin.Apps.AppSource;
using EwaldVenter.TenantAdmin.Apps.PTE;
using EwaldVenter.TenantAdmin.Company;
using EwaldVenter.TenantAdmin.User;

page 72301 "Tenant Env. ListPart EV"
{
    ApplicationArea = All;
    Caption = 'Tenant Environments';
    CardPageId = "Tenant Environment Card EV";
    Editable = false;
    PageType = ListPart;
    SourceTable = "Tenant Environment EV";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Environment Name"; Rec."Environment Name") { }
                field("Environment Type"; Rec."Environment Type") { }
                field("Tenant Name"; Rec."Tenant Name") { }
                field("Application Version"; Rec."Application Version") { }
                field("Country Code"; Rec."Country Code") { }
                field(Status; Rec."Status") { }
                field("AppSource App Count"; Rec."AppSource App Count") { }
                field("PTE Count"; Rec."PTE Count") { }
                field("Company Count"; Rec."Company Count") { }
                field("User Count"; Rec."User Count") { }
                field("Last Sync DateTime"; Rec."Last Sync DateTime") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
    }
}
