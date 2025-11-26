namespace EwaldVenter.TenantAdmin.Apps.PTE;

codeunit 72711 "PTE Operations EV"
{
    // /// <summary>
    // /// Publishes a Per-Tenant Extension.
    // /// Phase 2: This will implement actual API calls.
    // /// </summary>
    // procedure PublishExtension(var PTE: Record "Per-Tenant Extension EV")
    // begin
    //     // Phase 2: Implement actual API call to publish extension
    //     Message('Extension publish will be implemented in Phase 2.\Extension: %1', PTE."Extension Name");

    //     LogOperation('Publish', PTE, true, '');
    // end;

    /// <summary>
    /// Installs a Per-Tenant Extension.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    procedure InstallExtension(var PTE: Record "Per-Tenant Extension EV")
    begin
        // Phase 2: Implement actual API call to install extension
        Message('Extension install will be implemented in Phase 2.\Extension: %1', PTE."Extension Name");

        LogOperation('Install', PTE, true, '');
    end;

    /// <summary>
    /// Uninstalls a Per-Tenant Extension.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    procedure UninstallExtension(var PTE: Record "Per-Tenant Extension EV")
    begin
        // Phase 2: Implement actual API call to uninstall extension
        Message('Extension uninstall will be implemented in Phase 2.\Extension: %1', PTE."Extension Name");

        LogOperation('Uninstall', PTE, true, '');
    end;

    /// <summary>
    /// Unpublishes a Per-Tenant Extension.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    procedure UnpublishExtension(var PTE: Record "Per-Tenant Extension EV")
    begin
        // Phase 2: Implement actual API call to unpublish extension
        Message('Extension unpublish will be implemented in Phase 2.\Extension: %1', PTE."Extension Name");

        LogOperation('Unpublish', PTE, true, '');
    end;

    local procedure LogOperation(OperationType: Text[50]; var PTE: Record "Per-Tenant Extension EV"; Success: Boolean; ErrorText: Text)
    var
        ExtensionDeploymentStatus: Record "Ext. Deployment Status EV";
    begin
        ExtensionDeploymentStatus.Init();
        ExtensionDeploymentStatus."Tenant ID" := PTE."Tenant ID";
        ExtensionDeploymentStatus."Environment Name" := PTE."Environment Name";
        ExtensionDeploymentStatus."Extension ID" := PTE."Extension ID";
        ExtensionDeploymentStatus."Extension Name" := PTE."Extension Name";
        ExtensionDeploymentStatus."Operation Type" := OperationType;
        ExtensionDeploymentStatus."Operation DateTime" := CurrentDateTime;
        ExtensionDeploymentStatus.Success := Success;
        ExtensionDeploymentStatus."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(ExtensionDeploymentStatus."Error Message"));
        ExtensionDeploymentStatus.Insert(true);
    end;
}
