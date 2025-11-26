namespace EwaldVenter.TenantAdmin.Environment;

page 72320 "Environment Updates EV"
{
    ApplicationArea = All;
    Caption = 'Environment Updates';
    PageType = List;
    SourceTable = "Environment Update EV";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Updates)
            {
                field("Target Version"; Rec."Target Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the target version for this update.';
                }
                field(Available; Rec.Available)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this target version has been released.';
                }
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this version is selected as the next update.';
                }
                field("Target Version Type"; Rec."Target Version Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the target version (GA or Preview).';
                }
                field("Latest Selectable Date"; Rec."Latest Selectable Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last date for which this update can be scheduled.';
                }
                field("Selected DateTime"; Rec."Selected DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this update is scheduled to start.';
                }
                field("Rollout Status"; Rec."Rollout Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rollout status (Active, UnderMaintenance, Postponed).';
                }
                field("Expected Month"; Rec."Expected Month")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected month for unreleased versions.';
                    Visible = false;
                }
                field("Expected Year"; Rec."Expected Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected year for unreleased versions.';
                    Visible = false;
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the update information was last synchronized.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshUpdates)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refresh the available updates from the Admin Center API.';

                trigger OnAction()
                var
                    EnvironmentOperations: Codeunit "Environment Operations EV";
                begin
                    if not IsNullGuid(Rec."Tenant ID") then
                        EnvironmentOperations.RefreshEnvironmentUpdates(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
