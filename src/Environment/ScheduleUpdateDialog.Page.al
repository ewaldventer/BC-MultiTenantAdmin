namespace EwaldVenter.TenantAdmin.Environment;

page 72322 "Schedule Update Dialog EV"
{
    Caption = 'Schedule Environment Update';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(ScheduleDetails)
            {
                Caption = 'Update Details';

                field("Target Version"; TargetVersionCode)
                {
                    ApplicationArea = All;
                    Caption = 'Target Version';
                    ToolTip = 'Select the target version to update to (e.g., 26.1, 26.2).';
                }
                field("Schedule Date"; ScheduleDate)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule Date';
                    ToolTip = 'Select the date when the update should start.';
                }
                field("Schedule Time"; ScheduleTime)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule Time';
                    ToolTip = 'Select the time when the update should start.';
                }
                field("Ignore Update Window"; IgnoreUpdateWindow)
                {
                    ApplicationArea = All;
                    Caption = 'Ignore Update Window';
                    ToolTip = 'If checked, the environment update window setting will be ignored for this update.';
                }
            }
        }
    }

    procedure GetScheduleDetails(var _TenantEnvironment: Record "Tenant Environment EV"; var EnvironmentOperations: Codeunit "Environment Operations EV")
    begin
        if (TargetVersionCode <> '') and (ScheduleDate > Today()) then
            EnvironmentOperations.SelectEnvironmentUpdate(_TenantEnvironment, TargetVersionCode, ScheduleDate, ScheduleTime, IgnoreUpdateWindow);
    end;

    procedure SetDefaults(DefaultVersion: Text[50]; DefaultDate: Date; DefaultTime: Time)
    begin
        TargetVersionCode := DefaultVersion;
        ScheduleDate := DefaultDate;
        ScheduleTime := DefaultTime;
    end;

    var
        TargetVersionCode: Text[50];
        ScheduleDate: Date;
        ScheduleTime: Time;
        IgnoreUpdateWindow: Boolean;
}
