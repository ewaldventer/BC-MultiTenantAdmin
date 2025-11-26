namespace EwaldVenter.TenantAdmin.Core;

codeunit 72110 "Managed Tenant Mgt. EV"
{
    /// <summary>
    /// Creates or updates a managed tenant record.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="TenantName">The descriptive name for the tenant.</param>
    /// <param name="CustomerNo">The customer number associated with this tenant.</param>
    procedure CreateOrUpdateTenant(TenantID: Guid; TenantName: Text[100]; CustomerNo: Code[20])
    var
        ManagedTenant: Record "Managed Tenant EV";
    begin
        ManagedTenant.SetRange("Tenant ID", TenantID);
        if ManagedTenant.FindFirst() then begin
            ManagedTenant."Tenant Name" := TenantName;
            ManagedTenant."Customer No." := CustomerNo;
            ManagedTenant."Last Sync DateTime" := CurrentDateTime;
            ManagedTenant.Modify(true);
        end else begin
            ManagedTenant.Init();
            ManagedTenant."Tenant ID" := TenantID;
            ManagedTenant."Tenant Name" := TenantName;
            ManagedTenant."Customer No." := CustomerNo;
            ManagedTenant."Last Sync DateTime" := CurrentDateTime;
            ManagedTenant.Active := true;
            ManagedTenant.Insert(true);
        end;
    end;

    /// <summary>
    /// Updates the last sync date/time for a tenant.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    procedure UpdateLastSyncDateTime(TenantID: Guid)
    var
        ManagedTenant: Record "Managed Tenant EV";
    begin
        ManagedTenant.SetRange("Tenant ID", TenantID);
        if ManagedTenant.FindFirst() then begin
            ManagedTenant."Last Sync DateTime" := CurrentDateTime;
            ManagedTenant.Modify(true);
        end;
    end;
}
