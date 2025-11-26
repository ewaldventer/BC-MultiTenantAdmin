namespace EwaldVenter.TenantAdmin.Company;

using EwaldVenter.TenantAdmin.RestClient;

codeunit 72810 "Company API Mgt. EV"
{
    /// <summary>
    /// Refreshes company data from the Automation API.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    procedure RefreshCompanies(TenantID: Guid; EnvironmentName: Text[100])
    var
        RestClient: Codeunit "Automation Rest Client EV";
        response: Text;
    begin
        if RestClient.GetCompanies(TenantID, EnvironmentName, response) then begin
            ClearEnvironmentCompanies(TenantID, EnvironmentName);
            ParseAndInsertCompanies(TenantID, EnvironmentName, response);
        end;

        UpdateLastSyncDateTime(TenantID, EnvironmentName);
    end;

    /// <summary>
    /// Clears all company records for a specific tenant and environment.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    local procedure ClearEnvironmentCompanies(TenantID: Guid; EnvironmentName: Text[100])
    var
        EnvironmentCompany: Record "Environment Company EV";
    begin
        EnvironmentCompany.SetRange("Tenant ID", TenantID);
        EnvironmentCompany.SetRange("Environment Name", EnvironmentName);
        EnvironmentCompany.DeleteAll(false);
    end;

    /// <summary>
    /// Parses the companies response JSON and inserts company records.
    /// </summary>
    /// <param name="_TenantID">The Azure AD Tenant ID.</param>
    /// <param name="_EnvironmentName">The name of the environment.</param>
    /// <param name="_JsonResponse">The JSON response from the Automation API.</param>
    local procedure ParseAndInsertCompanies(_TenantID: Guid; _EnvironmentName: Text[100]; _JsonResponse: Text)
    var
        EnvironmentCompany: Record "Environment Company EV";
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        CompanyObject: JsonObject;
    begin
        if not JsonObject.ReadFrom(_JsonResponse) then
            exit;

        JsonArray := JsonObject.GetArray('value');

        foreach JsonToken in JsonArray do begin
            CompanyObject := JsonToken.AsObject();

            EnvironmentCompany.Init();
            EnvironmentCompany."Tenant ID" := _TenantID;
            EnvironmentCompany."Environment Name" := _EnvironmentName;
            EnvironmentCompany."Company ID" := CompanyObject.GetText('id');
            EnvironmentCompany."Company Name" := CopyStr(CompanyObject.GetText('name'), 1, MaxStrLen(EnvironmentCompany."Company Name"));
            EnvironmentCompany."Display Name" := CopyStr(CompanyObject.GetText('displayName'), 1, MaxStrLen(EnvironmentCompany."Display Name"));
            EnvironmentCompany."Last Sync DateTime" := CurrentDateTime;
            if not EnvironmentCompany.Insert(true) then
                EnvironmentCompany.Modify(true);
        end;
    end;

    local procedure UpdateLastSyncDateTime(TenantID: Guid; EnvironmentName: Text[100])
    var
        EnvironmentCompany: Record "Environment Company EV";
    begin
        EnvironmentCompany.SetRange("Tenant ID", TenantID);
        EnvironmentCompany.SetRange("Environment Name", EnvironmentName);
        if EnvironmentCompany.FindSet() then
            repeat
                EnvironmentCompany."Last Sync DateTime" := CurrentDateTime;
                EnvironmentCompany.Modify(true);
            until EnvironmentCompany.Next() = 0;
    end;
}
