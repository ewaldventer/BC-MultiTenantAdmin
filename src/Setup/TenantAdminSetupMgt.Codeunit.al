namespace EwaldVenter.TenantAdmin.Setup;

codeunit 72010 "Tenant Admin Setup Mgt. EV"
{
    /// <summary>
    /// Runs the setup wizard to guide users through initial configuration.
    /// </summary>
    procedure RunSetupWizard()
    var
        TenantAdminSetupWizard: Page "Tenant Admin Setup Wizard EV";
    begin
        TenantAdminSetupWizard.RunModal();
    end;

    /// <summary>
    /// Validates the setup configuration.
    /// </summary>
    /// <returns>True if setup is valid, otherwise false.</returns>
    procedure ValidateSetup(): Boolean
    var
        TenantAdminSetup: Record "Tenant Admin Setup EV";
    begin
        if not TenantAdminSetup.Get() then
            exit(false);

        if IsNullGuid(TenantAdminSetup."Client ID") then
            exit(false);

        if TenantAdminSetup."Key Vault Name" = '' then
            exit(false);

        if TenantAdminSetup."Certificate Name" = '' then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Marks the setup as completed.
    /// </summary>
    procedure CompleteSetup()
    var
        TenantAdminSetup: Record "Tenant Admin Setup EV";
    begin
        if TenantAdminSetup.Get() then begin
            TenantAdminSetup."Setup Completed" := true;
            TenantAdminSetup."Last Modified DateTime" := CurrentDateTime;
            TenantAdminSetup.Modify(true);
        end;
    end;
}
