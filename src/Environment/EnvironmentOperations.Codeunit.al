namespace EwaldVenter.TenantAdmin.Environment;

using System.Text.Json;
using EwaldVenter.TenantAdmin.RestClient;
using EwaldVenter.TenantAdmin.Core;

codeunit 72311 "Environment Operations EV"
{
    /// <summary>
    /// Restarts a Business Central environment.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment to restart.</param>
    procedure RestartEnvironment(_TenantEnvironment: Record "Tenant Environment EV")
    begin
        // Phase 2: Implement actual API call to restart environment
        Message('Environment restart will be implemented in Phase 2.\Tenant ID: %1\Environment: %2', _TenantEnvironment."Tenant ID", _TenantEnvironment."Environment Name");

        LogOperation('Restart', _TenantEnvironment, true, '');
    end;

    /// <summary>
    /// Renames a Business Central environment (Sandbox only).
    /// </summary>
    procedure RenameEnvironment(_TenantEnvironment: Record "Tenant Environment EV"; _NewEnvironmentName: Text)
    var
        xTenantEnvironment: Record "Tenant Environment EV";
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        EnvironmentRenameLbl: Label 'Rename Environment';
        EnvironmentTypeErrorLbl: Label 'Only Sandbox environments can be renamed. This is a Production environment.';
        SuccessLbl: Label 'Environment renamed successfully to %1.', Comment = '%1 = New environment name';
    begin
        if _TenantEnvironment."Environment Type" <> _TenantEnvironment."Environment Type"::Sandbox then
            Error(EnvironmentTypeErrorLbl);

        if (_NewEnvironmentName = '') or (StrLen(_NewEnvironmentName) > 30) then
            Error('Environment name must be between 1 and 30 characters.');

        xTenantEnvironment := _TenantEnvironment;

        // Call API
        if AdminCenterRestClient.RenameEnvironment(_TenantEnvironment, _NewEnvironmentName, ResponseText) then begin
            // Manually update the record with new name (async operation)
            _TenantEnvironment.Rename(_TenantEnvironment."Tenant ID", _TenantEnvironment."Environment Name", _NewEnvironmentName);
            Message(SuccessLbl, _NewEnvironmentName);
            LogOperation(EnvironmentRenameLbl, _TenantEnvironment, true, StrSubstNo(SuccessLbl, _NewEnvironmentName));
        end else begin
            LogOperation(EnvironmentRenameLbl, _TenantEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    /// <summary>
    /// Soft deletes a Business Central environment (Sandbox only, recoverable for 14 days).
    /// </summary>
    procedure DeleteEnvironmentSoft(_TenantEnvironment: Record "Tenant Environment EV")
    var
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        EnvironmentDeleteLbl: Label 'Delete Environment (Soft)';
        EnvironmentTypeErrorLbl: Label 'Only Sandbox environments can be deleted. This is a Production environment.';
        SuccesLbl: Label 'Environment %1 deleted successfully and can be recovered for 14 days.', Comment = '%1=Environment Name';
    begin
        if _TenantEnvironment."Environment Type" <> _TenantEnvironment."Environment Type"::Sandbox then
            Error(EnvironmentTypeErrorLbl);

        if AdminCenterRestClient.DeleteEnvironmentSoftDelete(_TenantEnvironment, ResponseText) then begin
            _TenantEnvironment.Status := _TenantEnvironment.Status::Deleted;
            _TenantEnvironment.Modify(true);
            Message(SuccesLbl, _TenantEnvironment."Environment Name");
            LogOperation(EnvironmentDeleteLbl, _TenantEnvironment, true, StrSubstNo(SuccesLbl, _TenantEnvironment."Environment Name"));
        end else begin
            LogOperation(EnvironmentDeleteLbl, _TenantEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    /// <summary>
    /// Hard deletes a Business Central environment permanently (Sandbox only, cannot be recovered).
    /// </summary>
    procedure DeleteEnvironmentHard(_TenantEnvironment: Record "Tenant Environment EV")
    var
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        EnvironmentDeleteLbl: Label 'Delete Environment (Hard)';
        EnvironmentTypeErrorLbl: Label 'Only Sandbox environments can be deleted. This is a Production environment.';
        SuccessLbl: Label 'Environment %1 permanently deleted.', Comment = '%1=Environment Name';
    begin
        if _TenantEnvironment."Environment Type" <> _TenantEnvironment."Environment Type"::Sandbox then
            Error(EnvironmentTypeErrorLbl);

        if AdminCenterRestClient.DeleteEnvironmentHardDelete(_TenantEnvironment, ResponseText) then begin
            _TenantEnvironment.Delete(true);
            Message(SuccessLbl, _TenantEnvironment."Environment Name");
            LogOperation(EnvironmentDeleteLbl, _TenantEnvironment, true, StrSubstNo(SuccessLbl, _TenantEnvironment."Environment Name"));
        end else begin
            LogOperation(EnvironmentDeleteLbl, _TenantEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    /// <summary>
    /// Copies a Business Central environment (Production→Sandbox or Sandbox→Sandbox).
    /// </summary>
    procedure CopyEnvironment(_SourceEnvironment: Record "Tenant Environment EV"; _DestinationName: Text; _DestinationType: Text)
    var
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        EnvironmentCopyLbl: Label 'Copy Environment';
        InvalidCombinationErrorLbl: Label 'Invalid copy combination. Can only copy to Sandbox destinations.';
        SuccessLbl: Label 'Environment copy operation started. %1 will be created as a %2 environment.', Comment = '%1 = destination name, %2 = environment type';
    begin
        if (_DestinationName = '') or (StrLen(_DestinationName) > 30) then
            Error('Destination name must be between 1 and 30 characters.');

        // Validate copy direction
        if _DestinationType <> 'Sandbox' then
            Error(InvalidCombinationErrorLbl);

        if AdminCenterRestClient.CopyEnvironment(_SourceEnvironment, _DestinationName, _DestinationType, ResponseText) then begin
            // Fire-and-forget: user will refresh to see new environment
            Message(SuccessLbl, _DestinationName, _DestinationType);
            LogOperation(EnvironmentCopyLbl, _SourceEnvironment, true, StrSubstNo(SuccessLbl, _DestinationName, _DestinationType));
        end else begin
            LogOperation(EnvironmentCopyLbl, _SourceEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    procedure RefreshEnvironmentUpdates(_EnvironmentUpdate: Record "Environment Update EV")
    var
        tenantEnvironment: Record "Tenant Environment EV";
    begin
        tenantEnvironment.Get(_EnvironmentUpdate."Tenant ID", _EnvironmentUpdate."Environment Name");
        RefreshEnvironmentUpdates(tenantEnvironment);
    end;

    /// <summary>
    /// Refreshes available environment updates from the Admin Center API.
    /// </summary>
    procedure RefreshEnvironmentUpdates(_TenantEnvironment: Record "Tenant Environment EV")
    var
        EnvironmentUpdate: Record "Environment Update EV";
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        UpdateObject: JsonObject;
        RefreshSuccessLbl: Label 'Environment updates refreshed successfully. %1 versions available.', Comment = '%1 = count';
    begin
        if AdminCenterRestClient.GetEnvironmentUpdates(_TenantEnvironment, ResponseText) then begin
            // Clear old records
            EnvironmentUpdate.SetRange("Tenant ID", _TenantEnvironment."Tenant ID");
            EnvironmentUpdate.SetRange("Environment Name", _TenantEnvironment."Environment Name");
            EnvironmentUpdate.DeleteAll(true);

            // Parse response and insert new records
            JsonObject.ReadFrom(ResponseText);
            JsonArray := JsonObject.GetArray('value');

            foreach JsonToken in JsonArray do begin
                UpdateObject := JsonToken.AsObject();
                InsertUpdateRecord(_TenantEnvironment, UpdateObject);
            end;

            Message(RefreshSuccessLbl, JsonArray.Count());
            LogOperation('Refresh Updates', _TenantEnvironment, true, '');
        end else begin
            LogOperation('Refresh Updates', _TenantEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    /// <summary>
    /// Selects a target version for environment update with optional scheduling.
    /// </summary>
    procedure SelectEnvironmentUpdate(var _TenantEnvironment: Record "Tenant Environment EV"; _TargetVersion: Text; _ScheduleDate: Date; _ScheduleTime: Time; _IgnoreUpdateWindow: Boolean)
    var
        EnvironmentUpdate: Record "Environment Update EV";
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        ScheduleDateTime: DateTime;
        SelectSuccessLbl: Label 'Update to version %1 scheduled successfully.', Comment = '%1 = target version';
    begin
        ScheduleDateTime := CreateDateTime(_ScheduleDate, _ScheduleTime);

        if AdminCenterRestClient.SelectTargetVersion(_TenantEnvironment, _TargetVersion, ScheduleDateTime, _IgnoreUpdateWindow, ResponseText) then begin
            // Update records: deselect all, then select this one
            EnvironmentUpdate.SetRange("Tenant ID", _TenantEnvironment."Tenant ID");
            EnvironmentUpdate.SetRange("Environment Name", _TenantEnvironment."Environment Name");
            if EnvironmentUpdate.FindSet(true) then
                repeat
                    EnvironmentUpdate.Selected := false;
                    EnvironmentUpdate.Modify(true);
                until EnvironmentUpdate.Next() = 0;

            if EnvironmentUpdate.Get(_TenantEnvironment."Tenant ID", _TenantEnvironment."Environment Name", _TargetVersion) then begin
                EnvironmentUpdate.Selected := true;
                EnvironmentUpdate."Selected DateTime" := ScheduleDateTime;
                EnvironmentUpdate."Ignore Update Window" := _IgnoreUpdateWindow;
                EnvironmentUpdate.Modify(true);
            end;

            Message(SelectSuccessLbl, _TargetVersion);
            LogOperation('Schedule Update', _TenantEnvironment, true, StrSubstNo(SelectSuccessLbl, _TargetVersion));
        end else begin
            LogOperation('Schedule Update', _TenantEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    /// <summary>
    /// Cancels a running environment update operation.
    /// </summary>
    procedure CancelEnvironmentUpdate(_TenantEnvironment: Record "Tenant Environment EV"; _OperationId: Text)
    var
        AdminCenterRestClient: Codeunit "Admin Center Rest Client EV";
        ResponseText: Text;
        CancelSuccessLbl: Label 'Update cancellation initiated. Environment will be restored to previous state.';
    begin
        if AdminCenterRestClient.CancelRunningUpdate(_TenantEnvironment, _OperationId, ResponseText) then begin
            Message(CancelSuccessLbl);
            LogOperation('Cancel Update', _TenantEnvironment, true, '');
        end else begin
            LogOperation('Cancel Update', _TenantEnvironment, false, ResponseText);
            Error(ResponseText);
        end;
    end;

    local procedure InsertUpdateRecord(_TenantEnvironment: Record "Tenant Environment EV"; _UpdateObject: JsonObject)
    var
        EnvironmentUpdate: Record "Environment Update EV";
    // TargetVersionTypeTxt: Text;
    begin
        EnvironmentUpdate.Init();
        EnvironmentUpdate."Tenant ID" := _TenantEnvironment."Tenant ID";
        EnvironmentUpdate."Environment Name" := _TenantEnvironment."Environment Name";
        EnvironmentUpdate."Target Version" := CopyStr(_UpdateObject.GetText('targetVersion'), 1, MaxStrLen(EnvironmentUpdate."Target Version"));
        EnvironmentUpdate.Available := _UpdateObject.GetBoolean('available');
        EnvironmentUpdate.Selected := _UpdateObject.GetBoolean('selected');
        EnvironmentUpdate."Rollout Status" := CopyStr(GetTextFromObject('$.scheduleDetails.rolloutStatus', _UpdateObject), 1, MaxStrLen(EnvironmentUpdate."Rollout Status"));
        EnvironmentUpdate."Target Version Type" := ParseVersionType(_UpdateObject.GetText('targetVersionType'));



        // Handle optional schedule details
        if GetTextFromObject('$.scheduleDetails.latestSelectableDateTime', _UpdateObject) <> '' then
            EnvironmentUpdate."Latest Selectable Date" := ParseDateTime(GetTextFromObject('$.scheduleDetails.latestSelectableDateTime', _UpdateObject));

        if GetTextFromObject('$.scheduleDetails.selectedDateTime', _UpdateObject) <> '' then
            EnvironmentUpdate."Selected DateTime" := ParseDateTime(GetTextFromObject('$.scheduleDetails.selectedDateTime', _UpdateObject));

        EnvironmentUpdate."Ignore Update Window" := GetBooleanFromObject('$.scheduleDetails.ignoreUpdateWindow', _UpdateObject);

        // Handle optional expected availability
        if GetIntegerFromObject('$.expectedAvailablity.month', _UpdateObject) > 0 then
            EnvironmentUpdate."Expected Month" := GetIntegerFromObject('$.expectedAvailablity.month', _UpdateObject);
        if GetIntegerFromObject('$.expectedAvailablity.year', _UpdateObject) > 0 then
            EnvironmentUpdate."Expected Year" := GetIntegerFromObject('$.expectedAvailablity.year', _UpdateObject);

        EnvironmentUpdate."Last Sync DateTime" := CurrentDateTime();
        EnvironmentUpdate.Insert(true);
    end;

    local procedure GetTextFromObject(_Key: Text; _JsonObject: JsonObject) _Result: Text
    var
        jsonToken: JsonToken;
    begin
        if not _JsonObject.SelectToken(_Key, jsonToken) then
            exit('');

        _Result := jsonToken.AsValue().AsText();
    end;

    local procedure GetIntegerFromObject(_Key: Text; _JsonObject: JsonObject) _Result: Integer
    var
        jsonToken: JsonToken;
    begin
        if not _JsonObject.SelectToken(_Key, jsonToken) then
            exit(0);

        _Result := jsonToken.AsValue().AsInteger();
    end;

    local procedure GetBooleanFromObject(_Key: Text; _JsonObject: JsonObject) _Result: Boolean
    var
        jsonToken: JsonToken;
    begin
        if not _JsonObject.SelectToken(_Key, jsonToken) then
            exit(false);

        _Result := jsonToken.AsValue().AsBoolean();
    end;

    local procedure ParseVersionType(_VersionType: Text): Integer
    begin
        case _VersionType of
            'Preview':
                exit(1); // Preview
            else
                exit(0); // GA
        end;
    end;

    local procedure ParseDateTime(_DateTimeText: Text): DateTime
    var
        Result: DateTime;
    begin
        if Evaluate(Result, _DateTimeText) then
            exit(Result);
        exit(0DT);
    end;

    local procedure LogOperation(OperationType: Text[50]; _TenantEnvironment: Record "Tenant Environment EV"; Success: Boolean; ErrorText: Text)
    var
        EnvironmentOperationLog: Record "Environment Operation Log EV";
    begin
        EnvironmentOperationLog.Init();
        EnvironmentOperationLog."Tenant ID" := _TenantEnvironment."Tenant ID";
        EnvironmentOperationLog."Environment Name" := _TenantEnvironment."Environment Name";
        EnvironmentOperationLog."Operation Type" := OperationType;
        EnvironmentOperationLog."Operation DateTime" := CurrentDateTime;
        EnvironmentOperationLog.Success := Success;
        EnvironmentOperationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(EnvironmentOperationLog."Error Message"));
        EnvironmentOperationLog.Insert(true);
    end;
}
