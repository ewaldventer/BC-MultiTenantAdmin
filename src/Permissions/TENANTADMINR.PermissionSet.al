namespace EwaldVenter.TenantAdmin.Permissions;

using EwaldVenter.TenantAdmin.Setup;
using EwaldVenter.TenantAdmin.Core;
using EwaldVenter.TenantAdmin.Environment;
using EwaldVenter.TenantAdmin.Apps.AppSource;
using EwaldVenter.TenantAdmin.Apps.PTE;
using EwaldVenter.TenantAdmin.Company;
using EwaldVenter.TenantAdmin.User;
using EwaldVenter.TenantAdmin.RestClient;

permissionset 72900 "TENANT-ADMIN-R EV"
{
    Assignable = true;
    Caption = 'Tenant Admin - Read';
    Permissions = // Setup
 tabledata "Tenant Admin Setup EV" = R,
        tabledata "Tenant Admin Activities EV" = R,
    // Core
        tabledata "Managed Tenant EV" = R,
    // Environment
        tabledata "Tenant Environment EV" = R,
        tabledata "Environment Operation Log EV" = R,
    // AppSource"Tenant Environment EV"
        tabledata "AppSource App EV" = R,
        tabledata "App Operation Log EV" = R,
    // PTE
        tabledata "Per-Tenant Extension EV" = R,
        tabledata "Ext. Deployment Status EV" = R,
    // Company
        tabledata "Environment Company EV" = R,
        tabledata "Automation Company EV" = R,
    // User
        tabledata "Environment User EV" = R,
        tabledata "Env. User Permission Set EV" = R,
        tabledata "Environment Security Group EV" = R,
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