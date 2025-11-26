namespace EwaldVenter.TenantAdmin.Permissions;

using EwaldVenter.TenantAdmin.Setup;
using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;
using EwaldVenter.TenantAdmin.Apps.AppSource;
using EwaldVenter.TenantAdmin.Apps.PTE;
using EwaldVenter.TenantAdmin.Company;
using EwaldVenter.TenantAdmin.User;
using EwaldVenter.TenantAdmin.RestClient;

permissionset 72901 "TENANT-ADMIN-USR EV"
{
    Assignable = true;
    Caption = 'Tenant Admin - User';
    IncludedPermissionSets = "TENANT-ADMIN-R EV";
    Permissions = // Setup
 tabledata "Tenant Admin Setup EV" = RM,
        tabledata "Tenant Admin Activities EV" = RM,
    // Core
        tabledata "Managed Tenant EV" = RMD,
    // Environment
        tabledata "Tenant Environment EV" = RMD,
        tabledata "Environment Operation Log EV" = RIMD,
    // AppSource
        tabledata "App Operation Log EV" = RIMD,
    // PTE
        tabledata "Per-Tenant Extension EV" = RMD,
        tabledata "Ext. Deployment Status EV" = RIMD,
    // Company
        tabledata "Environment Company EV" = RMD,
        tabledata "Automation Company EV" = RMD,
    // User
        tabledata "Environment User EV" = RMD,
        tabledata "Env. User Permission Set EV" = RMD,
        tabledata "Environment Security Group EV" = RMD,
        table "App Operation Log EV" = X,
        table "AppSource App EV" = X,
        table "Automation Company EV" = X,
        table "Environment Company EV" = X,
        table "Tenant Environment EV" = X,
        table "Environment Security Group EV" = X,
        table "Environment User EV" = X,
        table "Environment Operation Log EV" = X,
        table "Ext. Deployment Status EV" = X,
        table "Managed Tenant EV" = X,
        table "Per-Tenant Extension EV" = X,
        table "Tenant Admin Activities EV" = X,
        table "Tenant Admin Setup EV" = X,
        table "Env. User Permission Set EV" = X,
        codeunit "AppSource App API Mgt. EV" = X,
        codeunit "Company API Mgt. EV" = X,
        codeunit "Company Operations EV" = X,
        codeunit "Environment API Mgt. EV" = X,
        codeunit "Environment Operations EV" = X,
        codeunit "Managed Tenant Mgt. EV" = X,
        codeunit "PTE API Mgt. EV" = X,
        codeunit "PTE Operations EV" = X,
        codeunit "Tenant Admin Install EV" = X,
        codeunit "Tenant Admin Setup Mgt. EV" = X,
        codeunit "Tenant Admin Upgrade EV" = X,
        codeunit "User API Mgt. EV" = X,
        codeunit "User Operations EV" = X,
        page "App Operation Log EV" = X,
        page "AppSource App Card EV" = X,
        page "Environment Company Card EV" = X,
        page "Tenant Environment Card EV" = X,
        page "Env. Security Groups EV" = X,
        page "Environment User Card EV" = X,
        page "Environment Operation Log EV" = X,
        page "Ext. Deployment Status EV" = X,
        page "Managed Tenant Card EV" = X,
        page "Managed Tenant List EV" = X,
        page "Per-Tenant Extension Card EV" = X,
        page "Per-Tenant Extensions EV" = X,
        page "Tenant Admin Activities EV" = X,
        page "Tenant Admin Role Center EV" = X,
        page "Tenant Admin Setup EV" = X,
        page "Tenant Admin Setup Wizard EV" = X,
        page "Env. User Permission Sets EV" = X,
        tabledata "AppSource App EV" = RIMD,
        codeunit "Http Client Handler EV" = X,
        codeunit "Admin Center Rest Client EV" = X,
        page "AppSource App ListPart EV" = X,
        page "Autom. Company ListPart EV" = X,
        page "Env. Company ListPart EV" = X,
        page "Environment User ListPart EV" = X,
        page "Tenant Env. ListPart EV" = X,
        codeunit "Automation Rest Client EV" = X,
        tabledata "Environment Update EV" = RIMD,
        table "Environment Update EV" = X,
        page "Environment Updates EV" = X,
        page "Schedule Update Dialog EV" = X,
        page "Simple Input EV" = X;
}