namespace EwaldVenter.TenantAdmin.RestClient;

using System.RestClient;
using EwaldVenter.TenantAdmin.Apps.AppSource;
using EwaldVenter.TenantAdmin.Setup;
using EwaldVenter.TenantAdmin.Environment;

codeunit 72002 "Admin Center Rest Client EV"
{
    Access = Internal;

    local procedure Initialize(_TenantId: Guid)
    var
        tenantAdminSetup: Record "Tenant Admin Setup EV";
        adminCenterBaseUrl: Text;
#if CERTIFICATES
        IsolatedCertificate: Record "Isolated Certificate";
        CertificateManagement: Codeunit "Certificate Management";
        signatureKey: Codeunit "Signature Key";
#endif
        scopes: List of [Text];
    begin
        Clear(ResponseMessage);
        if Initialized then
            exit;

        scopes.Add('https://api.businesscentral.dynamics.com/.default');
        tenantAdminSetup.Get();
        tenantAdminSetup.TestField("API Version");
        adminCenterBaseUrl := StrSubstNo(AdminCenterBaseAddressLbl, Format(tenantAdminSetup."API Version", 0, 9));

#if CERTIFICATES
        tenantAdminSetup.TestField("Certificate No.");
        // IsolatedCertificate.Get(tenantAdminSetup."Certificate No.");
        // CertificateManagement.GetCertPrivateKey(IsolatedCertificate, signatureKey);

        HttpAuthOAuthClientCredentials.Initialize(
            StrSubstNo(AuthorityUrlTxt, CleanGuid(_TenantId))
            , tenantAdminSetup."Client ID"
            , SecretStrSubstNo(CertificateManagement.GetRawCertDataAsBase64String(IsolatedCertificate))
            , SecretText.SecretStrSubstNo('<get_certificate_password_from_isolated_storage>')
            , scopes);
#else
        HttpAuthOAuthClientCredentials.Initialize(
           StrSubstNo(AuthorityUrlTxt, CleanGuid(_TenantId))
           , tenantAdminSetup."Client ID"
           , SecretText.SecretStrSubstNo('<get_password_from_isolated_storage>')
           , scopes);
#endif


        RestClient.Initialize(HttpClientHandler, HttpAuthOAuthClientCredentials);
        RestClient.SetBaseAddress(adminCenterBaseUrl);

        Initialized := true;
    end;

    local procedure Post(_TenantId: Guid; _Url: Text; _Content: JsonObject; var _ResponseText: Text) _Success: Boolean
    var
        content: Codeunit "Http Content";
    begin
        Initialize(_TenantId);
        content := content.Create(_Content);
        ResponseMessage := RestClient.Post(_Url, content);
        _ResponseText := ResponseMessage.GetContent().AsText();
        _Success := ResponseMessage.GetIsSuccessStatusCode() and (ResponseMessage.GetHttpStatusCode() = 200);
    end;

    local procedure Get(_TenantId: Guid; _Url: Text; var _ResponseText: Text) _Success: Boolean
    begin
        Initialize(_TenantId);
        ResponseMessage := RestClient.Get(_Url);
        _ResponseText := ResponseMessage.GetContent().AsText();
        _Success := ResponseMessage.GetIsSuccessStatusCode() and (ResponseMessage.GetHttpStatusCode() = 200);
    end;

    local procedure Patch(_TenantId: Guid; _Url: Text; _Content: JsonObject; var _ResponseText: Text) _Success: Boolean
    var
        content: Codeunit "Http Content";
    begin
        Initialize(_TenantId);
        content := content.Create(_Content);
        ResponseMessage := RestClient.Patch(_Url, content);
        _ResponseText := ResponseMessage.GetContent().AsText();
        _Success := ResponseMessage.GetIsSuccessStatusCode() and (ResponseMessage.GetHttpStatusCode() = 200);
    end;

    local procedure Delete(_TenantId: Guid; _Url: Text; var _ResponseText: Text) _Success: Boolean
    begin
        Initialize(_TenantId);
        ResponseMessage := RestClient.Delete(_Url);
        _ResponseText := ResponseMessage.GetContent().AsText();
        _Success := ResponseMessage.GetIsSuccessStatusCode();
    end;

    #region Environment Methods
    procedure GetTenantEnvironments(_TenantId: Guid; var _Response: Text) _Success: Boolean
    begin
        _Success := Get(_TenantId, '', _Response);
    end;

    procedure RenameEnvironment(_TenantEnvironment: Record "Tenant Environment EV"; _NewEnvironmentName: Text; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        content.Add('NewEnvironmentName', _NewEnvironmentName);
        _Success := Post(_TenantEnvironment."Tenant ID", StrSubstNo(RenameEnvironmentLbl, _TenantEnvironment."Environment Name"), content, _Response);
    end;

    procedure DeleteEnvironmentSoftDelete(_TenantEnvironment: Record "Tenant Environment EV"; var _Response: Text) _Success: Boolean
    begin
        _Success := Delete(_TenantEnvironment."Tenant ID", StrSubstNo(DeleteEnvironmentLbl, _TenantEnvironment."Environment Name"), _Response);
    end;

    procedure DeleteEnvironmentHardDelete(_TenantEnvironment: Record "Tenant Environment EV"; var _Response: Text) _Success: Boolean
    begin
        _Success := Delete(_TenantEnvironment."Tenant ID", StrSubstNo(DeleteEnvironmentLbl, _TenantEnvironment."Environment Name") + '?force=true', _Response);
    end;

    procedure CopyEnvironment(_SourceTenantEnvironment: Record "Tenant Environment EV"; _DestinationName: Text; _DestinationType: Text; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        content.Add('environmentName', _DestinationName);
        content.Add('type', _DestinationType);
        _Success := Post(_SourceTenantEnvironment."Tenant ID", StrSubstNo(CopyEnvironmentLbl, _SourceTenantEnvironment."Environment Name"), content, _Response);
    end;

    procedure GetEnvironmentUpdates(_TenantEnvironment: Record "Tenant Environment EV"; var _Response: Text) _Success: Boolean
    begin
        _Success := Get(_TenantEnvironment."Tenant ID", StrSubstNo(GetEnvironmentUpdatesLbl, _TenantEnvironment."Environment Name"), _Response);
    end;

    procedure SelectTargetVersion(_TenantEnvironment: Record "Tenant Environment EV"; _TargetVersion: Text; _ScheduleDateTime: DateTime; _IgnoreUpdateWindow: Boolean; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
        scheduleDetails: JsonObject;
    begin
        scheduleDetails.Add('selectedDateTime', Format(_ScheduleDateTime, 0, 9));
        scheduleDetails.Add('ignoreUpdateWindow', _IgnoreUpdateWindow);
        content.Add('selected', true);
        content.Add('scheduleDetails', scheduleDetails);
        _Success := Patch(_TenantEnvironment."Tenant ID", StrSubstNo(SelectTargetVersionLbl, _TenantEnvironment."Environment Name", _TargetVersion), content, _Response);
    end;

    procedure CancelRunningUpdate(_TenantEnvironment: Record "Tenant Environment EV"; _OperationId: Text; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        _Success := Post(_TenantEnvironment."Tenant ID", StrSubstNo(CancelRunningUpdateLbl, _TenantEnvironment."Environment Name", _OperationId), content, _Response);
    end;
    #endregion Environment Methods

    #region App Methods
    procedure GetInstalledApps(_TenantId: Guid; _EnvironmentName: Text; var _Response: Text) _Success: Boolean
    begin
        _Success := Get(_TenantId, StrSubstNo(AppSourceAppsLbl, _EnvironmentName), _Response);
    end;

    procedure InstallApp(_AppSourceApp: Record "AppSource App EV"; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        // content.Add('targetVersion', ''); // Install latest when not specified
        // content.Add('languageId', 'en-US');
        // content.Add('allowPreviewVersion', false);
        content.Add('useEnvironmentUpdateWindow', false);
        content.Add('installOrUpdateNeededDependencies', true);
        content.Add('acceptIsvEula', true);

        _Success := Post(_AppSourceApp."Tenant ID", StrSubstNo(InstallAppSourceAppLbl, _AppSourceApp."Environment Name", CleanGuid(_AppSourceApp."App ID")), content, _Response);
    end;

    procedure UpdateApp(_AppSourceApp: Record "AppSource App EV"; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        content.Add('targetVersion', _AppSourceApp."Available Version"); // Install latest when not specified
        // content.Add('languageId', 'en-US');
        // content.Add('allowPreviewVersion', false);
        content.Add('useEnvironmentUpdateWindow', false);
        content.Add('installOrUpdateNeededDependencies', true);
        content.Add('acceptIsvEula', true);

        _Success := Post(_AppSourceApp."Tenant ID", StrSubstNo(UpdateAppSourceAppLbl, _AppSourceApp."Environment Name", CleanGuid(_AppSourceApp."App ID")), content, _Response);
    end;

    procedure StopBCAppUpdate(_AppSourceApp: Record "AppSource App EV"; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        _Success := Post(_AppSourceApp."Tenant ID", StrSubstNo(UpdateCancelAppSourceAppLbl, _AppSourceApp."Environment Name", CleanGuid(_AppSourceApp."App ID")), content, _Response);
    end;

    procedure UninstallApp(_TenantId: Guid; _EnvironmentName: Text; _AppId: Guid; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
    begin
        content.Add('uninstallDependents', false);
        content.Add('deleteData', false);

        _Success := Post(_TenantId, StrSubstNo(UninstallAppSourceAppLbl, _EnvironmentName, CleanGuid(_AppId)), content, _Response);
    end;

    procedure GetAvailableAppUpdates(_TenantId: Guid; _EnvironmentName: Text; var _Response: Text) _Success: Boolean
    begin
        _Success := Get(_TenantId, StrSubstNo(AppSourceAppUpdatesLbl, _EnvironmentName), _Response);
    end;

    procedure GetUninstallRequirements(_AppSourceApp: Record "AppSource App EV"; var _Response: Text) _Success: Boolean
    begin
        _Success := Get(_AppSourceApp."Tenant ID", StrSubstNo(UninstallRequirementsAppSourceAppLbl, _AppSourceApp."Environment Name", CleanGuid(_AppSourceApp."App ID")), _Response);
    end;

    procedure GetAppOperations(_AppSourceApp: Record "AppSource App EV"; var _Response: Text) _Success: Boolean
    begin
        _Success := Get(_AppSourceApp."Tenant ID", StrSubstNo(AppSourceAppOperationsLbl, _AppSourceApp."Environment Name", CleanGuid(_AppSourceApp."App ID")), _Response);
    end;
    #endregion App Methods

    procedure CleanGuid(_Value: Guid) _Result: Text
    begin
        _Result := Format(_Value, 0, 4);
    end;

    procedure GetStatusCode() _StatusCode: Integer
    begin
        _StatusCode := ResponseMessage.GetHttpStatusCode();
    end;

    procedure GetReasonPhrase() _ReasonPhrase: Text
    begin
        _ReasonPhrase := ResponseMessage.GetReasonPhrase();
    end;

    var
        HttpAuthOAuthClientCredentials: Codeunit HttpAuthOAuthClientCredentials;
        HttpClientHandler: Codeunit "Http Client Handler EV";
        ResponseMessage: Codeunit "Http Response Message";
        RestClient: Codeunit "Rest Client";
        Initialized: Boolean;
        AuthorityUrlTxt: Label 'https://login.microsoftonline.com/%1', Locked = true, Comment = '%1=Tenant ID';
        //TODO: Setup for API version
        AppSourceAppsLbl: Label '/%1/apps', Locked = true, Comment = '%1=Environment Name';
        AppSourceAppUpdatesLbl: Label '/%1/apps/availableUpdates', Locked = true, Comment = '%1=Environment Name';
        InstallAppSourceAppLbl: Label '/%1/apps/%2/install', Locked = true, Comment = '%1=Environment Name, %2=App ID';
        UpdateAppSourceAppLbl: Label '/%1/apps/%2/update', Locked = true, Comment = '%1=Environment Name, %2=App ID';
        UpdateCancelAppSourceAppLbl: Label '/%1/apps/%2/update/cancel', Locked = true, Comment = '%1=Environment Name, %2=App ID';
        UninstallAppSourceAppLbl: Label '/%1/apps/%2/uninstall', Locked = true, Comment = '%1=Environment Name, %2=App ID';
        UninstallRequirementsAppSourceAppLbl: Label '/%1/apps/%2/uninstallRequirements', Locked = true, Comment = '%1=Environment Name, %2=App ID';
        AppSourceAppOperationsLbl: Label '/%1/apps/%2/operations', Locked = true, Comment = '%1=Environment Name, %2=App ID';
        RenameEnvironmentLbl: Label '/%1/rename', Locked = true, Comment = '%1=Environment Name';
        DeleteEnvironmentLbl: Label '/%1', Locked = true, Comment = '%1=Environment Name';
        CopyEnvironmentLbl: Label '/%1/copy', Locked = true, Comment = '%1=Environment Name';
        GetEnvironmentUpdatesLbl: Label '/%1/updates', Locked = true, Comment = '%1=Environment Name';
        SelectTargetVersionLbl: Label '/%1/updates/%2', Locked = true, Comment = '%1=Environment Name, %2=Target Version';
        CancelRunningUpdateLbl: Label '/%1/operations/%2/cancel', Locked = true, Comment = '%1=Environment Name, %2=Operation ID';
        AdminCenterBaseAddressLbl: Label 'https://api.businesscentral.dynamics.com/admin/v%1/applications/BusinessCentral/environments', Locked = true, Comment = '%1=API Version No.';
}
