namespace EwaldVenter.TenantAdmin.Apps.PTE;
using EwaldVenter.TenantAdmin.RestClient;
using System.Text.Json;

codeunit 72710 "PTE API Mgt. EV"
{
    /// <summary>
    /// Refreshes Per-Tenant Extension data from the Admin Center API.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    procedure RefreshExtensions(TenantID: Guid; EnvironmentName: Text[100])
    begin
        // Phase 2: Implement actual API call to Admin Center API
        Message('PTE refresh will be implemented in Phase 2.\Tenant ID: %1\Environment: %2', TenantID, EnvironmentName);

        UpdateLastSyncDateTime(TenantID, EnvironmentName);
    end;

    local procedure UpdateLastSyncDateTime(TenantID: Guid; EnvironmentName: Text[100])
    var
        PTE: Record "Per-Tenant Extension EV";
    begin
        PTE.SetRange("Tenant ID", TenantID);
        PTE.SetRange("Environment Name", EnvironmentName);
        if PTE.FindSet() then
            repeat
                PTE."Last Sync DateTime" := CurrentDateTime;
                PTE.Modify(true);
            until PTE.Next() = 0;
    end;

    /// <summary>
    /// Creates or updates a Per-Tenant Extension record.
    /// </summary>
    procedure CreateOrUpdateExtension(TenantID: Guid; EnvironmentName: Text[100]; ExtensionID: Guid; ExtensionName: Text[250]; Publisher: Text[250]; Version: Text[50]; IsPublished: Boolean; IsInstalled: Boolean)
    var
        PTE: Record "Per-Tenant Extension EV";
    begin
        PTE.Init();
        PTE."Tenant ID" := TenantID;
        PTE."Environment Name" := EnvironmentName;
        PTE."Extension ID" := ExtensionID;
        PTE."Extension Name" := ExtensionName;
        PTE.Publisher := Publisher;
        PTE.Version := Version;
        PTE."Is Published" := IsPublished;
        PTE."Is Installed" := IsInstalled;
        PTE."Last Sync DateTime" := CurrentDateTime;
        if not PTE.Insert(true) then
            PTE.Modify(true);
    end;

    internal procedure RefreshPTEs(TenantID: Guid; EnvironmentName: Text[100])
    var
        AutomationRestClient: Codeunit "Automation Rest Client EV";
        response: Text;
    begin
        if AutomationRestClient.GetExtensions(TenantID, EnvironmentName, response) then begin
            ClearEnvironmentPTEs(TenantID, EnvironmentName);
            ParseAndInsertPTEs(TenantID, EnvironmentName, response);
        end;

        UpdateLastSyncDateTime(TenantID, EnvironmentName);
    end;

    /// <summary>
    /// Clears all PTE records for a specific tenant and environment.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    local procedure ClearEnvironmentPTEs(TenantID: Guid; EnvironmentName: Text[100])
    var
        PTE: Record "Per-Tenant Extension EV";
    begin
        PTE.SetRange("Tenant ID", TenantID);
        PTE.SetRange("Environment Name", EnvironmentName);
        PTE.DeleteAll(false);
    end;

    /// <summary>
    /// Parses the extensions response JSON and inserts PTE records.
    /// </summary>
    /// <param name="_TenantID">The Azure AD Tenant ID.</param>
    /// <param name="_EnvironmentName">The name of the environment.</param>
    /// <param name="_JsonResponse">The JSON response from the Automation API.</param>
    local procedure ParseAndInsertPTEs(_TenantID: Guid; _EnvironmentName: Text[100]; _JsonResponse: Text)
    var
        PTE: Record "Per-Tenant Extension EV";
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        ExtensionObject, jsonObject : JsonObject;
    begin
        if not jsonObject.ReadFrom(_JsonResponse) then
            exit;

        JsonArray := jsonObject.GetArray('value');

        foreach JsonToken in JsonArray do begin
            ExtensionObject := JsonToken.AsObject();

            PTE.Init();
            PTE."Tenant ID" := _TenantID;
            PTE."Environment Name" := _EnvironmentName;
            PTE."Extension ID" := ExtensionObject.GetText('id');
            PTE."Extension Name" := CopyStr(ExtensionObject.GetText('displayName'), 1, MaxStrLen(PTE."Extension Name"));
            PTE.Publisher := CopyStr(ExtensionObject.GetText('publisher'), 1, MaxStrLen(PTE.Publisher));
            PTE.Version := BuildVersionString(ExtensionObject);
            PTE."Is Installed" := ExtensionObject.GetBoolean('isInstalled');
            PTE."Is Published" := true;
            Evaluate(PTE.Scope, ExtensionObject.GetText('publishedAs'));
            PTE."Last Sync DateTime" := CurrentDateTime;
            if not PTE.Insert(true) then
                PTE.Modify(true);
        end;
    end;

    /// <summary>
    /// Builds a version string from JSON object version fields.
    /// </summary>
    local procedure BuildVersionString(JsonObject: JsonObject): Text[50]
    var
        VersionMajor: Integer;
        VersionMinor: Integer;
        VersionBuild: Integer;
        VersionRevision: Integer;
        VersionText: Text;
    begin
        VersionMajor := JsonObject.GetInteger('versionMajor');
        VersionMinor := JsonObject.GetInteger('versionMinor');
        VersionBuild := JsonObject.GetInteger('versionBuild');
        VersionRevision := JsonObject.GetInteger('versionRevision');

        VersionText := StrSubstNo('%1.%2.%3.%4', VersionMajor, VersionMinor, VersionBuild, VersionRevision);
        exit(CopyStr(VersionText, 1, 50));
    end;

    // /// <summary>
    // /// Converts publishedAs string to Scope option value.
    // /// </summary>
    // local procedure ConvertPublishedAsToScope(PublishedAs: Text): Integer
    // var
    //     PTE: Record "Per-Tenant Extension EV";
    // begin
    //     if PublishedAs = 'Global' then
    //         exit(PTE.Scope::Global);
    //     exit(PTE.Scope::Tenant);
    // end;
}
