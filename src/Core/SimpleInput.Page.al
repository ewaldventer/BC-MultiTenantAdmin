namespace EwaldVenter.TenantAdmin.Core;

page 72000 "Simple Input EV"
{
    Caption = 'Input';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(TextValueCtrl; TextVal)
            {
                ApplicationArea = All;
                CaptionClass = CaptionValue;
                Visible = IsText;
                ToolTip = 'Specifies the value of the TextVal field.';

                trigger OnValidate()
                begin
                    ClosePage();
                end;
            }
            field(IntValueCtrl; IntegerVal)
            {
                ApplicationArea = All;
                CaptionClass = CaptionValue;
                Visible = IsInteger;
                ToolTip = 'Specifies the value of the IntegerVal field.';

                trigger OnValidate()
                begin
                    ClosePage();
                end;
            }
            field(DecimalValueCtrl; DecimalVal)
            {
                ApplicationArea = All;
                CaptionClass = CaptionValue;
                Visible = IsDecimal;
                ToolTip = 'Specifies the value of the DecimalVal field.';

                trigger OnValidate()
                begin
                    ClosePage();
                end;
            }
            field(BoolValueCtrl; BoolVal)
            {
                ApplicationArea = All;
                CaptionClass = CaptionValue;
                Visible = IsBool;
                ToolTip = 'Specifies the value of the BoolVal field.';

                trigger OnValidate()
                begin
                    ClosePage();
                end;
            }
            field(DateValueCtrl; DateVal)
            {
                ApplicationArea = All;
                CaptionClass = CaptionValue;
                Visible = IsDate;
                ToolTip = 'Specifies the value of the DateVal field.';

                trigger OnValidate()
                begin
                    ClosePage();
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        ValidEntry := false;
    end;

    procedure SetCaptionValue(_NewCaptionValue: Text)
    begin
        CaptionValue := _NewCaptionValue;
    end;

    procedure SetNewValue(_NewValue: Variant)
    begin
        OriginalValue := _NewValue;
        case true of
            OriginalValue.IsBoolean:
                begin
                    BoolVal := _NewValue;
                    IsBool := true;
                end;
            OriginalValue.IsDate:
                begin
                    DateVal := _NewValue;
                    IsDate := true;
                end;
            OriginalValue.IsText,
            OriginalValue.IsCode:
                begin
                    TextVal := _NewValue;
                    IsText := true;
                end;
            OriginalValue.IsInteger:
                begin
                    IntegerVal := _NewValue;
                    IsInteger := true;
                end;
            OriginalValue.IsDecimal:
                begin
                    DecimalVal := _NewValue;
                    IsDecimal := true;
                end;
        end;
    end;

    procedure GetNewValue(): Variant
    begin
        case true of
            IsBool:
                exit(BoolVal);
            IsDate:
                exit(DateVal);
            IsText:
                exit(TextVal);
            IsInteger:
                exit(IntegerVal);
            IsDecimal:
                exit(DecimalVal);
        end;
    end;

    procedure ClosePage()
    var
        IsHandled: Boolean;
    begin
        ValidEntry := true;

        OnBeforeClosePage(IsHandled);
        if not IsHandled then
            CurrPage.Close(); // This causes the CloseAction parameter in OnQueryClosePage(CloseAction: Action) to be set to Action::Cancel

        /*
            OnValidate() of field executes, then OnQueryClosePage() of page executes, so there is no way of knowing if user clicked Ok or Cancel
        */
    end;

    procedure IsValidEntry(): Boolean
    begin
        exit(ValidEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeClosePage(var IsHandled: Boolean)
    begin
    end;

    var
        BoolVal: Boolean;
        IsBool, IsDate, IsInteger : Boolean;
        IsDecimal, IsText, ValidEntry : Boolean;
        DateVal: Date;
        DecimalVal: Decimal;
        IntegerVal: Integer;
        CaptionValue: Text;
        TextVal: Text;
        OriginalValue: Variant;
}
