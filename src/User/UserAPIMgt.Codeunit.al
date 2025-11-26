namespace EwaldVenter.TenantAdmin.User;

codeunit 72860 "User API Mgt. EV"
{
    /// <summary>
    /// Refreshes user data from the Admin Center API.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    /// <param name="TenantID">The Azure AD Tenant ID.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    procedure RefreshUsers(TenantID: Guid; EnvironmentName: Text[100])
    begin
        // Phase 2: Implement actual API call to Admin Center API
        Message('User refresh will be implemented in Phase 2.\Tenant ID: %1\Environment: %2', TenantID, EnvironmentName);

        UpdateLastSyncDateTime(TenantID, EnvironmentName);
    end;

    local procedure UpdateLastSyncDateTime(TenantID: Guid; EnvironmentName: Text[100])
    var
        BCUser: Record "Environment User EV";
    begin
        BCUser.SetRange("Tenant ID", TenantID);
        BCUser.SetRange("Environment Name", EnvironmentName);
        if BCUser.FindSet() then
            repeat
                BCUser."Last Sync DateTime" := CurrentDateTime;
                BCUser.Modify(true);
            until BCUser.Next() = 0;
    end;

    /// <summary>
    /// Creates or updates a user record.
    /// </summary>
    procedure CreateOrUpdateUser(TenantID: Guid; EnvironmentName: Text[100]; UserSecurityID: Guid; UserName: Text[50]; FullName: Text[100]; Email: Text[250]; State: Option)
    var
        BCUser: Record "Environment User EV";
    begin
        BCUser.SetRange("Tenant ID", TenantID);
        BCUser.SetRange("Environment Name", EnvironmentName);
        BCUser.SetRange("User Security ID", UserSecurityID);
        if BCUser.FindFirst() then begin
            BCUser."User Name" := UserName;
            BCUser."Full Name" := FullName;
            BCUser.Email := Email;
            BCUser.State := State;
            BCUser."Last Sync DateTime" := CurrentDateTime;
            BCUser.Modify(true);
        end else begin
            BCUser.Init();
            BCUser."Tenant ID" := TenantID;
            BCUser."Environment Name" := EnvironmentName;
            BCUser."User Security ID" := UserSecurityID;
            BCUser."User Name" := UserName;
            BCUser."Full Name" := FullName;
            BCUser.Email := Email;
            BCUser.State := State;
            BCUser."Last Sync DateTime" := CurrentDateTime;
            BCUser.Insert(true);
        end;
    end;
}
