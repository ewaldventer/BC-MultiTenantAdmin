namespace EwaldVenter.TenantAdmin.Setup;

codeunit 72011 "Tenant Admin Install EV"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitializeSetup();
    end;

    local procedure InitializeSetup()
    var
        TenantAdminSetup: Record "Tenant Admin Setup EV";
    begin
        if TenantAdminSetup.Get() then
            exit;

        TenantAdminSetup.Init();
        TenantAdminSetup."Primary Key" := '';
        TenantAdminSetup."API Version" := 2.28;
        TenantAdminSetup.Insert();
    end;
}
