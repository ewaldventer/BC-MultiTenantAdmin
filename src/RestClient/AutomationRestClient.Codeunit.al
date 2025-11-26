namespace EwaldVenter.TenantAdmin.RestClient;

using System.RestClient;
using EwaldVenter.TenantAdmin.Setup;

codeunit 72001 "Automation Rest Client EV"
{
    Access = Internal;

    // local procedure Initialize(_TenantId: Guid; _EnvironmentName: Text)
    // begin
    //     Initialize(_TenantId, _EnvironmentName, '');
    // end;

    local procedure Initialize()
    var
        tenantAdminSetup: Record "Tenant Admin Setup EV";
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

#if not CERTIFICATES
        HttpAuthOAuthClientCredentials.Initialize(
           StrSubstNo(AuthorityUrlTxt, CleanGuid(TenantId))
           , tenantAdminSetup."Client ID"
           , SecretText.SecretStrSubstNo('<get_password_from_isolated_storage>')
           , scopes);
#else
        tenantAdminSetup.TestField("Certificate No.");
        IsolatedCertificate.Get(tenantAdminSetup."Certificate No.");

        // CertificateManagement.GetCertPrivateKey(IsolatedCertificate, signatureKey);
        HttpAuthOAuthClientCredentials.Initialize(
            StrSubstNo(AuthorityUrlTxt, CleanGuid(_TenantId))
            , tenantAdminSetup."Client ID"
            , SecretStrSubstNo(CertificateManagement.GetRawCertDataAsBase64String(IsolatedCertificate))
            , SecretText.SecretStrSubstNo('Br@!ntree2025')
            , scopes);
#endif


        RestClient.Initialize(HttpClientHandler, HttpAuthOAuthClientCredentials);
        RestClient.SetBaseAddress(GetBaseAddress());

        Initialized := true;
    end;

    local procedure Post(_Url: Text; _Content: JsonObject; var _ResponseText: Text) _Success: Boolean
    var
        content: Codeunit "Http Content";
    begin
        Initialize();
        content := content.Create(_Content);
        ResponseMessage := RestClient.Post(_Url, content);
        _ResponseText := ResponseMessage.GetContent().AsText();
        _Success := ResponseMessage.GetIsSuccessStatusCode() and (ResponseMessage.GetHttpStatusCode() = 200);
    end;

    // local procedure Get(_TenantId: Guid; _Url: Text; var _ResponseText: Text) _Success: Boolean
    // begin
    //     Initialize(_TenantId);
    //     ResponseMessage := RestClient.Get(_Url);
    //     _ResponseText := ResponseMessage.GetContent().AsText();
    //     _Success := ResponseMessage.GetIsSuccessStatusCode() and (ResponseMessage.GetHttpStatusCode() = 200);
    // end;

    local procedure Get(_Url: Text; var _ResponseText: Text) _Success: Boolean
    begin
        Initialize();
        ResponseMessage := RestClient.Get(_Url);
        _ResponseText := ResponseMessage.GetContent().AsText();
        _Success := ResponseMessage.GetIsSuccessStatusCode() and (ResponseMessage.GetHttpStatusCode() = 200);
    end;

    #region Automation Methods
    local procedure GetFirstCompanyId() _CompanyId: Text
    var
        companyAsToken: JsonToken;
    begin
        if not GetFirstCompany(companyAsToken) then
            Error(UnableToFetchCompaniesTxt, EnvironmentName);

        _CompanyId := companyAsToken.AsObject().GetText('id', true);
    end;

    procedure GetFirstCompany(var _CompanyAsToken: JsonToken) _Success: Boolean
    var
        companiesResponse: JsonObject;
        companies: JsonArray;
        response: Text;
    begin
        if not GetCompanies(TenantId, EnvironmentName, response) then
            exit;

        companiesResponse.ReadFrom(response);
        companies := companiesResponse.GetArray('value');

        _Success := companies.Get(0, _CompanyAsToken);
    end;

    procedure GetCompanies(_TenantId: Guid; _EnvironmentName: Text; var _Response: Text) _Success: Boolean
    begin
        SetGlobals(_TenantId, _EnvironmentName);
        _Success := Get('/companies', _Response);
    end;

    procedure GetExtensions(_TenantId: Guid; _EnvironmentName: Text; var _Response: Text) _Success: Boolean
    var
        CompaniesUrlTxt: Label '/companies(%1)/extensions?$filter=publishedAs eq ''PTE'' or publishedAs eq ''Dev''', Locked = true;
    begin
        SetGlobals(_TenantId, _EnvironmentName);
        _Success := Get(StrSubstNo(CompaniesUrlTxt, GetFirstCompanyId()), _Response);
    end;

    procedure InstallPublishedExtension(_TenantId: Guid; _EnvironmentName: Text; _PackageID: Guid; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
        InstallAppLbl: Label '/companies(%1)/extensions(%2)/Microsoft.NAV.install', Locked = true, Comment = '%1=Company ID, %2=Package ID';
    begin
        SetGlobals(_TenantId, _EnvironmentName);
        _Success := Post(StrSubstNo(InstallAppLbl, GetFirstCompanyId(), CleanGuid(_PackageID)), content, _Response);
    end;

    procedure UnInstallExtension(_TenantId: Guid; _EnvironmentName: Text; _PackageID: Guid; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
        UnInstallAppLbl: Label '/companies(%1)/extensions(%2)/Microsoft.NAV.uninstall', Locked = true, Comment = '%1=Company ID, %2=Package ID';
    begin
        SetGlobals(_TenantId, _EnvironmentName);
        _Success := Post(StrSubstNo(UnInstallAppLbl, GetFirstCompanyId(), CleanGuid(_PackageID)), content, _Response);
    end;

    procedure UnPublishExtension(_TenantId: Guid; _EnvironmentName: Text; _PackageID: Guid; var _Response: Text) _Success: Boolean
    var
        content: JsonObject;
        UnPublishAppLbl: Label '/companies(%1)/extensions(%2)/Microsoft.NAV.unpublish', Locked = true, Comment = '%1=Company ID, %2=Package ID';
    begin
        SetGlobals(_TenantId, _EnvironmentName);
        _Success := Post(StrSubstNo(UnPublishAppLbl, GetFirstCompanyId(), CleanGuid(_PackageID)), content, _Response);
    end;
    #endregion Automation Methods

    local procedure GetBaseAddress() _Url: Text
    begin
        _Url := StrSubstNo(AutomationBaseAddressLbl, CleanGuid(TenantId), EnvironmentName);
    end;

    local procedure SetGlobals(_TenantId: Guid; _EnvironmentName: Text)
    begin
        TenantId := _TenantId;
        EnvironmentName := _EnvironmentName;
    end;

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
        TenantId: Guid;
        EnvironmentName: Text;
        AuthorityUrlTxt: Label 'https://login.microsoftonline.com/%1', Locked = true, Comment = '%1=Tenant ID';
        AutomationBaseAddressLbl: Label 'https://api.businesscentral.dynamics.com/v2.0/%1/%2/api/microsoft/automation/v2.0', Locked = true, Comment = '%1=Tenant ID, %2=Environment Name, %3=Company ID';
        // CompaniesLbl: Label 'https://api.businesscentral.dynamics.com/v2.0/%1/%2/api/microsoft/automation/v2.0/companies', Locked = true, Comment = '%1=Tenant ID, %2=Environment Name';
        UnableToFetchCompaniesTxt: Label 'Unable to retrieve list of companies for environment %1', Comment = '%1=Environment Name';
}
