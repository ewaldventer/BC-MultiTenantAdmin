namespace EwaldVenter.TenantAdmin.Company;

using EwaldVenter.TenantAdmin.RestClient;
using System.Text.Json;

codeunit 72811 "Company Operations EV"
{


    /// <summary>
    /// Creates a new company in the environment.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    procedure CreateCompany(TenantID: Guid; EnvironmentName: Text[100])
    begin
        // Phase 2: Implement actual API call to create company
        Message('Company creation will be implemented in Phase 2.\Tenant ID: %1\Environment: %2', TenantID, EnvironmentName);
    end;

    /// <summary>
    /// Deletes a company from the environment.
    /// Phase 2: This will implement actual API calls.
    /// </summary>
    procedure DeleteCompany(var BCCompany: Record "Environment Company EV")
    begin
        // Phase 2: Implement actual API call to delete company
        Message('Company deletion will be implemented in Phase 2.\Company: %1', BCCompany."Company Name");
    end;
}
