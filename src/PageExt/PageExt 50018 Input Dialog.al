namespace KeyFor.UFO05.ImportInvoices;

using KeyFor.UFO01.CustomDataLayer;

pageextension 50018 "Input Dialog" extends "Input Dialog"
{
    layout
    {
        addfirst(Content)
        {
            group(ImportInvoices)
            {
                field(gYear; gYear)
                {
                    ApplicationArea = all;
                    CaptionML = ENU = 'Year', ITA = 'Anno';
                    Visible = gYearVisibility;
                    Enabled = gYearMandatory;
                }

                field(gDate; gFromDate)
                {
                    ApplicationArea = all;
                    CaptionML = ENU = 'From Date', ITA = 'Da Data';
                    Visible = gFromDateVisibility;
                }

                field(gPrimulaImportTypeOptions; gPrimulaImportTypeOptions)
                {
                    ApplicationArea = all;
                    CaptionML = ENU = 'Primula Import Type', ITA = 'Tipo Importazione Primula';
                    Visible = gPrimulaImportTypeVisibility;
                    Editable = gPrimulaImportTypeEditability;
                    Enabled = gPrimulaImportTypeEditability;
                }
            }
        }
    }

    var
        gYear: Integer;
        gFromDate: Date;
        gYearVisibility: Boolean;
        gYearMandatory: Boolean;
        gPrimulaImportTypeVisibility: Boolean;
        gPrimulaImportTypeEditability: Boolean;
        gFromDateVisibility: Boolean;
        gPrimulaImportTypeOptions: Option CLI,FOR;

    #region EXTERNALS

    [TryFunction]
    procedure RetrivePrimulaFilters(var pYear: Integer; var pFromDate: Date; var pPrimulaImportType: Code[10]; pPrimulaImportTypeOption: Option CLI,FOR; pPageCaption: Text)
    var
        ErrTxt001: TextConst ENU = 'Operation Cancelled', ITA = 'Operazione Annullata';
        ErrTxt002: TextConst ENU = 'Year is mandatory !', ITA = 'L'' anno è obbligatorio !';
    begin
        CurrPage.Caption := pPageCaption;

        gYear := WorkDate().Year;
        gYearVisibility := true;
        gYearMandatory := true;

        gFromDateVisibility := true;

        gPrimulaImportTypeOptions := pPrimulaImportTypeOption;
        gPrimulaImportTypeVisibility := true;
        gPrimulaImportTypeEditability := false;

        CurrPage.LookupMode(true);
        if CurrPage.RunModal() = Action::LookupOK then begin
            if gYear = 0 then
                Error(ErrTxt002);

            pYear := gYear;
            pFromDate := gFromDate;
            pPrimulaImportType := Format(gPrimulaImportTypeOptions);
        end else
            Error(ErrTxt001);
    end;

    #endregion EXTERNALS
}