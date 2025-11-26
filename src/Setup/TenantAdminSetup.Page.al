namespace EwaldVenter.TenantAdmin.Setup;

using EwaldVenter.TenantAdmin.Setup;

page 72001 "Tenant Admin Setup EV"
{
    ApplicationArea = All;
    Caption = 'Tenant Admin Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Tenant Admin Setup EV";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("API Version"; Rec."API Version")
                {
                    ToolTip = 'Specifies the value of the API Version field.', Comment = '%';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure AD App Registration Application (client) ID for Admin Center API authentication.';
                }
                field("Certificate No."; Rec."Certificate No.")
                {
                    ToolTip = 'Specifies the value of the Certificate No. field.', Comment = '%';
                }
                // field("Key Vault Name"; Rec."Key Vault Name")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the name of the Azure Key Vault containing the authentication certificate.';
                // }
                // field("Certificate Name"; Rec."Certificate Name")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the name of the certificate in the Azure Key Vault.';
                // }
            }
            group(Status)
            {
                Caption = 'Status';

                field("Setup Completed"; Rec."Setup Completed")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Modified DateTime"; Rec."Last Modified DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunSetupWizard)
            {
                ApplicationArea = All;
                Caption = 'Run Setup Wizard';
                Image = Setup;
                ToolTip = 'Opens the setup wizard to guide you through the initial configuration.';

                trigger OnAction()
                var
                    TenantAdminSetupMgt: Codeunit "Tenant Admin Setup Mgt. EV";
                begin
                    TenantAdminSetupMgt.RunSetupWizard();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(RunSetupWizard_Promoted; RunSetupWizard)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
