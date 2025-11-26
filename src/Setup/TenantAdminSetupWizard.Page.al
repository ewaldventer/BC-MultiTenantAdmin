namespace EwaldVenter.TenantAdmin.Setup;

page 72002 "Tenant Admin Setup Wizard EV"
{
    ApplicationArea = All;
    Caption = 'Tenant Admin Setup Wizard';
    PageType = NavigatePage;
    SourceTable = "Tenant Admin Setup EV";

    layout
    {
        area(content)
        {
            group(Step1)
            {
                Visible = Step = Step::Welcome;
                group(Welcome)
                {
                    Caption = 'Welcome to Tenant Administration Extension';
                    InstructionalText = 'This wizard will guide you through the initial setup of the Tenant Administration Extension. You will need the following information:';

                    field(Prerequisite1; Prerequisite1Lbl)
                    {
                        Editable = false;
                        ShowCaption = false;
                    }
                    field(Prerequisite2; Prerequisite2Lbl)
                    {
                        Editable = false;
                        ShowCaption = false;
                    }
                    field(Prerequisite3; Prerequisite3Lbl)
                    {
                        Editable = false;
                        ShowCaption = false;
                    }
                }
            }

            group(Step2)
            {
                Visible = Step = Step::AzureAD;
                group(AzureADConfig)
                {
                    Caption = 'Azure AD Configuration';
                    InstructionalText = 'Enter your Azure AD App Registration details for Admin Center API authentication.';

                    field("Client ID"; Rec."Client ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure AD App Registration Application (client) ID.';
                    }
                }
            }

            group(Step3)
            {
                Visible = Step = Step::KeyVault;
                group(KeyVaultConfig)
                {
                    Caption = 'Azure Key Vault Configuration';
                    InstructionalText = 'Enter the Key Vault details where your authentication certificate is stored.';

                    field("Key Vault Name"; Rec."Key Vault Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the name of the Azure Key Vault.';
                    }
                    field("Certificate Name"; Rec."Certificate Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the name of the certificate in the Key Vault.';
                    }
                }
            }

            group(Step4)
            {
                Visible = Step = Step::TestConnection;
                group(TestConnectivity)
                {
                    Caption = 'Test Connection';
                    InstructionalText = 'Test connectivity to the Admin Center API (Phase 2 feature - placeholder).';

                    field(TestResult; TestResultText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Attention;
                    }
                }
            }

            group(Step5)
            {
                Visible = Step = Step::Finish;
                group(Complete)
                {
                    Caption = 'Setup Complete';
                    InstructionalText = 'The setup is now complete. You can now start managing your Business Central tenants.';

                    field(Summary; SummaryLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    FinishSetup();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        Step := Step::Welcome;
        EnableControls();

        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;

    var
        Step: Option Welcome,AzureAD,KeyVault,TestConnection,Finish;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        // TopBannerVisible: Boolean;
        TestResultText: Text;
        Prerequisite1Lbl: Label '• Azure AD App Registration Application (client) ID';
        Prerequisite2Lbl: Label '• Azure Key Vault name with authentication certificate';
        Prerequisite3Lbl: Label '• Certificate name in Key Vault';
        SummaryLbl: Label 'Click Finish to complete the setup and start using Tenant Administration.';

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Welcome:
                ShowWelcomeStep();
            Step::AzureAD:
                ShowAzureADStep();
            Step::KeyVault:
                ShowKeyVaultStep();
            Step::TestConnection:
                ShowTestConnectionStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure ShowWelcomeStep()
    begin
        BackEnabled := false;
        NextEnabled := true;
        FinishEnabled := false;
    end;

    local procedure ShowAzureADStep()
    begin
        BackEnabled := true;
        NextEnabled := not IsNullGuid(Rec."Client ID");
        FinishEnabled := false;
    end;

    local procedure ShowKeyVaultStep()
    begin
        BackEnabled := true;
        NextEnabled := (Rec."Key Vault Name" <> '') and (Rec."Certificate Name" <> '');
        FinishEnabled := false;
    end;

    local procedure ShowTestConnectionStep()
    begin
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;
        TestResultText := 'API connectivity test will be implemented in Phase 2.';
    end;

    local procedure ShowFinishStep()
    begin
        BackEnabled := true;
        NextEnabled := false;
        FinishEnabled := true;
    end;

    local procedure ResetControls()
    begin
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := true;
    end;

    local procedure LoadTopBanners()
    begin
        // TopBannerVisible := false;
    end;

    local procedure FinishSetup()
    var
        TenantAdminSetupMgt: Codeunit "Tenant Admin Setup Mgt. EV";
    begin
        Rec.Modify(true);
        TenantAdminSetupMgt.CompleteSetup();
        CurrPage.Close();
    end;
}
