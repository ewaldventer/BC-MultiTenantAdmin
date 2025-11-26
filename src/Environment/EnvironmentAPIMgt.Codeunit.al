namespace EwaldVenter.TenantAdmin.Environment;

using EwaldVenter.TenantAdmin.Core;
using System.RestClient;
using EwaldVenter.TenantAdmin.RestClient;
using System.Text.Json;

codeunit 72310 "Environment API Mgt. EV"
{
    /// <summary>
    /// Refreshes environment data from the Admin Center API for a specific tenant.
    /// Parses the API response and creates or updates environment records.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    procedure RefreshEnvironments(TenantID: Guid)
    var
        RestClient: Codeunit "Admin Center Rest Client EV";
        ManagedTenantMgt: Codeunit "Managed Tenant Mgt. EV";
        response: Text;
    begin
        if RestClient.GetTenantEnvironments(TenantID, response) then begin
            ClearTenantEnvironments(TenantID);
            ParseAndInsertEnvironments(TenantID, response);
        end;

        ManagedTenantMgt.UpdateLastSyncDateTime(TenantID);
    end;

    /// <summary>
    /// Creates or updates an environment record.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    /// <param name="EnvironmentType">The type (Production/Sandbox).</param>
    /// <param name="ApplicationVersion">The BC application version.</param>
    /// <param name="PlatformVersion">The BC platform version.</param>
    /// <param name="CountryCode">The country/region code.</param>
    procedure CreateOrUpdateEnvironment(TenantID: Guid; EnvironmentName: Text[100]; EnvironmentType: Option; ApplicationVersion: Text[50]; PlatformVersion: Text[50]; CountryCode: Code[10])
    var
        tenantEnvironment: Record "Tenant Environment EV";
    begin
        tenantEnvironment.SetRange("Tenant ID", TenantID);
        tenantEnvironment.SetRange("Environment Name", EnvironmentName);
        if tenantEnvironment.FindFirst() then begin
            tenantEnvironment."Environment Type" := EnvironmentType;
            tenantEnvironment."Application Version" := ApplicationVersion;
            tenantEnvironment."Platform Version" := PlatformVersion;
            tenantEnvironment."Country Code" := CountryCode;
            tenantEnvironment."Last Sync DateTime" := CurrentDateTime;
            tenantEnvironment.Modify(true);
        end else begin
            tenantEnvironment.Init();
            tenantEnvironment."Tenant ID" := TenantID;
            tenantEnvironment."Environment Name" := EnvironmentName;
            tenantEnvironment."Environment Type" := EnvironmentType;
            tenantEnvironment."Application Version" := ApplicationVersion;
            tenantEnvironment."Platform Version" := PlatformVersion;
            tenantEnvironment."Country Code" := CountryCode;
            tenantEnvironment.Status := tenantEnvironment.Status::Active;
            tenantEnvironment."Last Sync DateTime" := CurrentDateTime;
            tenantEnvironment.Insert(true);
        end;
    end;

    /// <summary>
    /// Clears all environment records for a specific tenant.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    local procedure ClearTenantEnvironments(TenantID: Guid)
    var
        tenantEnvironment: Record "Tenant Environment EV";
    begin
        tenantEnvironment.SetRange("Tenant ID", TenantID);
        tenantEnvironment.DeleteAll(false);
    end;

    /// <summary>
    /// Parses the environment response JSON and inserts environment records.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="JsonResponse">The JSON response from the Admin Center API.</param>
    local procedure ParseAndInsertEnvironments(TenantID: Guid; JsonResponse: Text)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        EnvironmentObject: JsonObject;
        Index: Integer;
        EnvironmentName: Text[100];
        EnvironmentType: Option;
        ApplicationVersion: Text[50];
        PlatformVersion: Text[50];
        CountryCode: Code[10];
        EnvironmentTypeText: Text;
    begin
        if not JsonObject.ReadFrom(JsonResponse) then
            exit;

        if not JsonObject.Get('value', JsonToken) then
            exit;

        JsonArray := JsonToken.AsArray();

        for Index := 0 to JsonArray.Count() - 1 do begin
            JsonArray.Get(Index, JsonToken);
            EnvironmentObject := JsonToken.AsObject();

            EnvironmentName := CopyStr(GetJsonString(EnvironmentObject, 'name'), 1, 100);
            EnvironmentTypeText := GetJsonString(EnvironmentObject, 'type');
            ApplicationVersion := CopyStr(GetJsonString(EnvironmentObject, 'applicationVersion'), 1, 50);
            PlatformVersion := CopyStr(GetJsonString(EnvironmentObject, 'platformVersion'), 1, 50);
            CountryCode := CopyStr(GetJsonString(EnvironmentObject, 'countryCode'), 1, 10);

            EnvironmentType := ConvertEnvironmentType(EnvironmentTypeText);

            CreateOrUpdateEnvironment(TenantID, EnvironmentName, EnvironmentType, ApplicationVersion, PlatformVersion, CountryCode);
        end;
    end;

    /// <summary>
    /// Extracts a string value from a JSON object by key.
    /// </summary>
    /// <param name="JsonObject">The JSON object to extract from.</param>
    /// <param name="KeyName">The key name.</param>
    /// <returns>The string value, or empty string if not found.</returns>
    local procedure GetJsonString(JsonObject: JsonObject; KeyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            exit(JsonToken.AsValue().AsText());
        exit('');
    end;

    /// <summary>
    /// Converts the environment type string to the corresponding option value.
    /// </summary>
    /// <param name="EnvironmentTypeText">The environment type text (Production or Sandbox).</param>
    /// <returns>The corresponding option value.</returns>
    local procedure ConvertEnvironmentType(EnvironmentTypeText: Text): Integer
    var
        tenantEnvironment: Record "Tenant Environment EV";
    begin
        if EnvironmentTypeText = 'Sandbox' then
            exit(tenantEnvironment."Environment Type"::Sandbox);
        exit(tenantEnvironment."Environment Type"::Production);
    end;

}