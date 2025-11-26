namespace EwaldVenter.TenantAdmin.Apps.AppSource;

using EwaldVenter.TenantAdmin.RestClient;
using System.Text.Json;

codeunit 72510 "AppSource App API Mgt. EV"
{
    /// <summary>
    /// Refreshes AppSource app data from the Admin Center API.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    procedure RefreshApps(TenantID: Guid; EnvironmentName: Text[100])
    var
        RestClient: Codeunit "Admin Center Rest Client EV";
        response: Text;
    begin
        if RestClient.GetInstalledApps(TenantID, EnvironmentName, response) then begin
            ClearEnvironmentApps(TenantID, EnvironmentName);
            ParseAndInsertApps(TenantID, EnvironmentName, response);
        end;

        UpdateLastSyncDateTime(TenantID, EnvironmentName);
    end;

    /// <summary>
    /// Clears all AppSource app records for a specific tenant and environment.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    local procedure ClearEnvironmentApps(TenantID: Guid; EnvironmentName: Text[100])
    var
        AppSourceApp: Record "AppSource App EV";
    begin
        AppSourceApp.SetRange("Tenant ID", TenantID);
        AppSourceApp.SetRange("Environment Name", EnvironmentName);
        AppSourceApp.DeleteAll(false);
    end;

    /// <summary>
    /// Parses the installed apps response JSON and inserts app records.
    /// </summary>
    /// <param name="_TenantID">The Azure AD Tenant ID.</param>
    /// <param name="_EnvironmentName">The name of the environment.</param>
    /// <param name="_JsonResponse">The JSON response from the Admin Center API.</param>
    local procedure ParseAndInsertApps(_TenantID: Guid; _EnvironmentName: Text[100]; _JsonResponse: Text)
    var
        AppSourceApp: Record "AppSource App EV";
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        AppObject: JsonObject;
        StateText: Text;
        State: Option;
    begin
        if not JsonObject.ReadFrom(_JsonResponse) then
            exit;

        if not JsonObject.Get('value', JsonToken) then
            exit;

        JsonArray := JsonToken.AsArray();

        foreach JsonToken in JsonArray do begin
            AppObject := JsonToken.AsObject();

            StateText := CopyStr(AppObject.GetText('state'), 1, MaxStrLen(StateText));
            State := ConvertAppState(StateText);

            AppSourceApp.Init();
            AppSourceApp."Tenant ID" := _TenantID;
            AppSourceApp."Environment Name" := _EnvironmentName;
            AppSourceApp."App ID" := AppObject.GetText('id');
            AppSourceApp."App Name" := CopyStr(AppObject.GetText('name'), 1, MaxStrLen(AppSourceApp."App Name"));
            AppSourceApp.Publisher := CopyStr(AppObject.GetText('publisher'), 1, MaxStrLen(AppSourceApp.Publisher));
            AppSourceApp.Version := CopyStr(AppObject.GetText('version'), 1, MaxStrLen(AppSourceApp.Version));
            AppSourceApp.State := State;
            AppSourceApp."Last Sync DateTime" := CurrentDateTime;
            if not AppSourceApp.Insert(true) then
                AppSourceApp.Modify(true);
        end;
    end;

    /// <summary>
    /// Converts the app state string to the corresponding option value.
    /// </summary>
    /// <param name="StateText">The state text from API (Installed, UpdatePending, Updating).</param>
    /// <returns>The corresponding option value.</returns>
    local procedure ConvertAppState(StateText: Text): Integer
    var
        AppSourceApp: Record "AppSource App EV";
    begin
        case StateText of
            'Installed':
                exit(AppSourceApp.State::Installed);
            'UpdatePending':
                exit(AppSourceApp.State::UpdatePending);
            'Updating':
                exit(AppSourceApp.State::Updating);
            else
                exit(AppSourceApp.State::Installed);
        end;
    end;

    local procedure UpdateLastSyncDateTime(TenantID: Guid; EnvironmentName: Text[100])
    var
        AppSourceApp: Record "AppSource App EV";
    begin
        AppSourceApp.SetRange("Tenant ID", TenantID);
        AppSourceApp.SetRange("Environment Name", EnvironmentName);
        if AppSourceApp.FindSet() then
            repeat
                AppSourceApp."Last Sync DateTime" := CurrentDateTime;
                AppSourceApp.Modify(true);
            until AppSourceApp.Next() = 0;
    end;

    /// <summary>
    /// Refreshes available app updates from the Admin Center API.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    procedure RefreshAvailableUpdates(TenantID: Guid; EnvironmentName: Text[100])
    var
        RestClient: Codeunit "Admin Center Rest Client EV";
        response: Text;
    begin
        if RestClient.GetAvailableAppUpdates(TenantID, EnvironmentName, response) then
            ParseAndUpdateAvailableVersions(TenantID, EnvironmentName, response);
    end;

    /// <summary>
    /// Parses the available updates response JSON and updates app records with available versions.
    /// </summary>
    /// <param name="_TenantID">The Azure AD Tenant ID.</param>
    /// <param name="_EnvironmentName">The name of the environment.</param>
    /// <param name="_JsonResponse">The JSON response from the Admin Center API.</param>
    local procedure ParseAndUpdateAvailableVersions(_TenantID: Guid; _EnvironmentName: Text[100]; _JsonResponse: Text)
    var
        AppSourceApp: Record "AppSource App EV";
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        UpdateObject, JsonObject : JsonObject;
        AppID: Guid;
        AvailableVersion: Text[50];
    begin
        if not JsonObject.ReadFrom(_JsonResponse) then
            exit;

        JsonArray := JsonObject.GetArray('value');

        // Clear all available versions first
        ClearAvailableVersions(_TenantID, _EnvironmentName);

        foreach JsonToken in JsonArray do begin
            UpdateObject := JsonToken.AsObject();

            AppID := UpdateObject.GetText('appId');
            AvailableVersion := CopyStr(UpdateObject.GetText('version'), 1, 50);

            // Find and update the corresponding app record
            AppSourceApp.SetRange("Tenant ID", _TenantID);
            AppSourceApp.SetRange("Environment Name", _EnvironmentName);
            AppSourceApp.SetRange("App ID", AppID);
            if AppSourceApp.FindFirst() then begin
                AppSourceApp."Available Version" := AvailableVersion;
                AppSourceApp."Update Available" := true;
                AppSourceApp.Modify(true);
            end;
        end;
    end;

    /// <summary>
    /// Clears available version information for all apps in an environment.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    local procedure ClearAvailableVersions(TenantID: Guid; EnvironmentName: Text[100])
    var
        AppSourceApp: Record "AppSource App EV";
    begin
        AppSourceApp.SetRange("Tenant ID", TenantID);
        AppSourceApp.SetRange("Environment Name", EnvironmentName);
        if AppSourceApp.FindSet() then
            repeat
                AppSourceApp."Available Version" := '';
                AppSourceApp."Update Available" := false;
                AppSourceApp.Modify(true);
            until AppSourceApp.Next() = 0;
    end;

    /// <summary>
    /// Installs an AppSource app.
    /// </summary>
    procedure InstallApp(var AppSourceApp: Record "AppSource App EV")
    var
        RestClient: Codeunit "Admin Center Rest Client EV";
        InstallTxt: Label 'Install: %1', Comment = '%1=Message';
        response: Text;
        JsonObject: JsonObject;
        StatusText: Text;
        Success: Boolean;
    begin
        Success := RestClient.InstallApp(AppSourceApp, response);

        if Success and JsonObject.ReadFrom(response) then begin
            StatusText := JsonObject.GetText('status');
            AppSourceApp."Last Operation Result" := CopyStr(StrSubstNo(InstallTxt, StatusText), 1, MaxStrLen(AppSourceApp."Last Operation Result"));
            AppSourceApp.Modify(true);
            Message('App install initiated successfully. Status: %1', StatusText);
            LogOperation('Install', AppSourceApp, true, '');
        end else begin
            AppSourceApp."Last Operation Result" := 'Install failed';
            AppSourceApp.Modify(true);
            LogOperation('Install', AppSourceApp, false, response);
            Error('Failed to install app %1. Response: %2', AppSourceApp."App Name", response);
        end;
    end;

    /// <summary>
    /// Updates an AppSource app to the available version.
    /// </summary>
    procedure UpdateApp(var AppSourceApp: Record "AppSource App EV")
    var
        RestClient: Codeunit "Admin Center Rest Client EV";
        UpdateTxt: Label 'Update: %1', Comment = '%1=Message';
        response: Text;
        JsonObject: JsonObject;
        StatusText: Text;
        Success: Boolean;
    begin
        if AppSourceApp."Available Version" = '' then
            Error('No available version to update to for app %1', AppSourceApp."App Name");

        Success := RestClient.UpdateApp(AppSourceApp, response);

        if Success and JsonObject.ReadFrom(response) then begin
            StatusText := JsonObject.GetText('status');
            AppSourceApp."Last Operation Result" := CopyStr(StrSubstNo(UpdateTxt, StatusText), 1, MaxStrLen(AppSourceApp."Last Operation Result"));
            AppSourceApp.Modify(true);
            Message('App update initiated successfully. Status: %1\Target Version: %2', StatusText, AppSourceApp."Available Version");
            LogOperation('Update', AppSourceApp, true, '');
        end else begin
            AppSourceApp."Last Operation Result" := 'Update failed';
            AppSourceApp.Modify(true);
            LogOperation('Update', AppSourceApp, false, response);
            Error('Failed to update app %1. Response: %2', AppSourceApp."App Name", response);
        end;
    end;

    /// <summary>
    /// Uninstalls an AppSource app.
    /// </summary>
    procedure UninstallApp(var AppSourceApp: Record "AppSource App EV")
    var
        RestClient: Codeunit "Admin Center Rest Client EV";
        UninstallTxt: Label 'Uninstall: %1', Comment = '%1=Message';
        response: Text;
        JsonObject: JsonObject;
        StatusText: Text;
        Success: Boolean;
    begin
        if not Confirm('Are you sure you want to uninstall app %1?', false, AppSourceApp."App Name") then
            exit;

        Success := RestClient.UninstallApp(AppSourceApp."Tenant ID", AppSourceApp."Environment Name", AppSourceApp."App ID", response);

        if Success and JsonObject.ReadFrom(response) then begin
            StatusText := JsonObject.GetText('status');
            AppSourceApp."Last Operation Result" := CopyStr(StrSubstNo(UninstallTxt, StatusText), 1, MaxStrLen(AppSourceApp."Last Operation Result"));
            AppSourceApp.Modify(true);
            Message('App uninstall initiated successfully. Status: %1', StatusText);
            LogOperation('Uninstall', AppSourceApp, true, '');
        end else begin
            AppSourceApp."Last Operation Result" := 'Uninstall failed';
            AppSourceApp.Modify(true);
            LogOperation('Uninstall', AppSourceApp, false, response);
            Error('Failed to uninstall app %1. Response: %2', AppSourceApp."App Name", response);
        end;
    end;

    local procedure LogOperation(OperationType: Text[50]; var AppSourceApp: Record "AppSource App EV"; Success: Boolean; ErrorText: Text)
    var
        AppOperationLog: Record "App Operation Log EV";
    begin
        AppOperationLog.Init();
        AppOperationLog."Tenant ID" := AppSourceApp."Tenant ID";
        AppOperationLog."Environment Name" := AppSourceApp."Environment Name";
        AppOperationLog."App ID" := AppSourceApp."App ID";
        AppOperationLog."App Name" := AppSourceApp."App Name";
        AppOperationLog."Operation Type" := OperationType;
        AppOperationLog."Operation DateTime" := CurrentDateTime;
        AppOperationLog.Success := Success;
        AppOperationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(AppOperationLog."Error Message"));
        AppOperationLog.Insert(true);
    end;
}
