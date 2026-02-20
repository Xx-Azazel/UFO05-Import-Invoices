namespace KeyFor.UFO05.ImportInvoices;

using KeyFor.UFO01.CustomDataLayer;

xmlport 50000 "Import Sales Invoices"
{
    CaptionML = ENU = 'Import Sales Invoices', ITA = 'Importa Fatture di Vendita';
    Direction = Import;
    FormatEvaluate = Legacy;
    Format = VariableText;
    TextEncoding = MSDOS;
    FieldSeparator = ';';
    TableSeparator = '<NewLine>';

    schema
    {
        textelement(Root)
        {
            tableelement(TempSalesInvoiceToImport; "Sales Invoice To Import")
            {
                SourceTableView = sorting("Entry No.");
                UseTemporary = true;
                AutoReplace = false;

                fieldattribute(Year; TempSalesInvoiceToImport.Year)
                {
                    Occurrence = Required;
                }

                fieldattribute(PostingDate; TempSalesInvoiceToImport."Posting Date")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaPostingNo; TempSalesInvoiceToImport."Primula Posting No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaPostingType; TempSalesInvoiceToImport."Primula Posting Type")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaAccountNo; TempSalesInvoiceToImport."Primula Account No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaAccountDescription; TempSalesInvoiceToImport."Primula Account Description")
                {
                    Occurrence = Optional;
                }

                fieldattribute(ReasonCode; TempSalesInvoiceToImport."Reason Code")
                {
                    Occurrence = Required;
                }

                fieldattribute(ReasonDescription; TempSalesInvoiceToImport."Reason Description")
                {
                    Occurrence = Optional;
                }

                fieldattribute(Type; TempSalesInvoiceToImport.Type)
                {
                    Occurrence = Required;
                }

                fieldattribute(Amount; TempSalesInvoiceToImport.Amount)
                {
                    Occurrence = Optional;
                }

                fieldattribute(DocumentNo; TempSalesInvoiceToImport."Document No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(DocumentDate; TempSalesInvoiceToImport."Document Date")
                {
                    Occurrence = Required;
                }

                fieldattribute(VATProgressiveNo; TempSalesInvoiceToImport."VAT Progressive No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(ActivityCode; TempSalesInvoiceToImport."Activity Code")
                {
                    Occurrence = Optional;
                }

                fieldattribute(VATCode; TempSalesInvoiceToImport."VAT Code")
                {
                    Occurrence = Required;
                }

                fieldattribute(VATDescription; TempSalesInvoiceToImport."VAT Description")
                {
                    Occurrence = Optional;
                }

                fieldattribute(VATTaxableAmount; TempSalesInvoiceToImport."VAT Taxable Amount")
                {
                    Occurrence = Optional;
                }

                fieldattribute(VATAmount; TempSalesInvoiceToImport."VAT Amount")
                {
                    Occurrence = Optional;
                }

                fieldattribute(AdditionalDescription; TempSalesInvoiceToImport."Additional Description")
                {
                    Occurrence = Optional;
                }

                trigger OnAfterInitRecord()
                var
                begin
                    gLineNo += 1;

                    if not gFirstLineProcessed then begin
                        gFirstLineProcessed := true;
                        currXMLport.Skip();
                    end;

                    UpdateWindow(Format(gLineNo));
                end;

                trigger OnBeforeInsertRecord()
                var
                begin
                    TempSalesInvoiceToImport."Entry No." := 0;
                end;

                trigger OnAfterInsertRecord()
                var
                    SkipLine: Boolean;
                begin
                    SkipLine := false;

                    case true of
                        TempSalesInvoiceToImport.Year <> gYearFilter:
                            SkipLine := true;

                        TempSalesInvoiceToImport."Posting Date" < gDateFilter:
                            SkipLine := true;

                        TempSalesInvoiceToImport."Primula Posting Type" <> gPrimulaImportTypeFilter:
                            SkipLine := true;
                    end;

                    if not SkipLine then
                        InsertLineToArrangeFromBuffer();

                    TempSalesInvoiceToImport.Delete();
                end;
            }
        }
    }

    var
        gTempSalesInvoiceToImportToArrange: Record "Sales Invoice To Import" temporary;
        gTempSalesInvoiceToImportToCheck: Record "Sales Invoice To Import" temporary;
        gDateFilter: Date;
        gLineNo: Integer;
        gYearFilter: Integer;
        gLastTempEntryNo: Integer;
        gPrimulaImportTypeFilter: Code[10];
        gFirstLineProcessed: Boolean;
        gWindow: Dialog;
        gConfTxt001: TextConst ENU = 'This will delete all the existing "%1" records.\ Do you want to proceed ?', ITA = 'Questa operazione eliminerà tutti i record "%1" esistenti.\Si desidera procedere ?';
        gTxt001: TextConst ENU = 'Importing Lines...\###1#######', ITA = 'Importazione righe...\###1#######';
        gTxt002: TextConst ENU = 'Rearranging Documents...\###1#######', ITA = 'Riorganizzazione documenti...\###1#######';

    #region TRIGGERS

    trigger OnPreXmlPort()
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
    begin
        if not Confirm(gConfTxt001, false, TempSalesInvoiceToImport.TableCaption) then
            Error('');

        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.DeleteAll();

        OpenWindow(gTxt001);
    end;

    trigger OnPostXmlPort()
    var
    begin
        CloseWindow();

        ProcessLinesToArrange();
    end;

    #endregion TRIGGERS

    #region EXTERNALS

    procedure SetParamFilters(pYearFilter: Integer; pDateFilter: Date; pPrimulaImportTypeFilter: Code[10])
    var
    begin
        gYearFilter := pYearFilter;
        gDateFilter := pDateFilter;
        gPrimulaImportTypeFilter := pPrimulaImportTypeFilter;
    end;

    #endregion EXTERNALS

    #region LOCALS

    local procedure InsertLineToArrangeFromBuffer()
    var
        ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
        TempVariant: Variant;
    begin
        gLastTempEntryNo += 1;

        Clear(gTempSalesInvoiceToImportToArrange);
        gTempSalesInvoiceToImportToArrange := TempSalesInvoiceToImport;
        gTempSalesInvoiceToImportToArrange."Entry No." := gLastTempEntryNo;
        gTempSalesInvoiceToImportToArrange.Insert(true);

        TempVariant := gTempSalesInvoiceToImportToArrange;
        if not ImportInvoicesMgt.CheckIfImportedLineIsHeader(TempVariant, Database::"Sales Invoice To Import") then begin
            gTempSalesInvoiceToImportToArrange := TempVariant;
            gTempSalesInvoiceToImportToArrange."Action Type" := gTempSalesInvoiceToImportToArrange."Action Type"::ERROR;
            gTempSalesInvoiceToImportToArrange."Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(gTempSalesInvoiceToImportToArrange."Error Message"));
        end else
            gTempSalesInvoiceToImportToArrange := TempVariant;

        gTempSalesInvoiceToImportToArrange.Modify(true);

        Clear(gTempSalesInvoiceToImportToCheck);
        gTempSalesInvoiceToImportToCheck := gTempSalesInvoiceToImportToArrange;
        gTempSalesInvoiceToImportToCheck.Insert(true);
    end;

    local procedure ProcessLinesToArrange()
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        LastTempText: Text;
        CurrTempText: Text;
        NewEntryNo: Integer;
    begin
        OpenWindow(gTxt002);
        NewEntryNo := 0;

        gTempSalesInvoiceToImportToArrange.Reset();
        gTempSalesInvoiceToImportToArrange.SetCurrentKey("Entry No.", Header, "Primula Posting No.", "Document No.", "VAT Progressive No.");
        gTempSalesInvoiceToImportToArrange.SetRange(Header, false);
        if gTempSalesInvoiceToImportToArrange.FindSet() then
            repeat
                UpdateWindow(gTempSalesInvoiceToImportToArrange."Document No.");

                NewEntryNo += 1;
                CurrTempText := StrSubstNo('%1@%2@%3', gTempSalesInvoiceToImportToArrange."Primula Posting No.", gTempSalesInvoiceToImportToArrange."Document No.", gTempSalesInvoiceToImportToArrange."VAT Progressive No.");

                if LastTempText <> CurrTempText then
                    AttachHeaderToLastLine(LastTempText, NewEntryNo);

                Clear(SalesInvoiceToImport);
                SalesInvoiceToImport := gTempSalesInvoiceToImportToArrange;
                SalesInvoiceToImport."Entry No." := NewEntryNo;
                SalesInvoiceToImport.Insert(true);

                AdjustLine(SalesInvoiceToImport);
                LastTempText := CurrTempText;
            until gTempSalesInvoiceToImportToArrange.Next() = 0;

        NewEntryNo += 1;
        AttachLastHeaderToLines(LastTempText, NewEntryNo);

        CloseWindow();
    end;

    local procedure AttachHeaderToLastLine(pTempText: Text; var pNewEntryNo: Integer)
    var
        ImpportInvoicesMgt: Codeunit "Import Invoices Mgt.";
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        TempList: List of [Text];
    begin
        if pTempText = '' then
            exit;

        TempList := pTempText.Split('@');

        gTempSalesInvoiceToImportToCheck.Reset();
        gTempSalesInvoiceToImportToCheck.SetCurrentKey("Entry No.", Header, "Primula Posting No.", "Document Date", "VAT Progressive No.");
        gTempSalesInvoiceToImportToCheck.SetRange(Header, true);
        gTempSalesInvoiceToImportToCheck.SetRange("Primula Posting No.", TempList.Get(1));
        gTempSalesInvoiceToImportToCheck.SetRange("Document No.", TempList.Get(2));
        gTempSalesInvoiceToImportToCheck.SetRange("VAT Progressive No.", TempList.Get(3));
        if gTempSalesInvoiceToImportToCheck.FindFirst() then begin
            Clear(SalesInvoiceToImport);
            SalesInvoiceToImport := gTempSalesInvoiceToImportToCheck;
            SalesInvoiceToImport."Entry No." := pNewEntryNo;
            SalesInvoiceToImport.Insert(true);

            AdjustLine(SalesInvoiceToImport);

            ImpportInvoicesMgt.RetriveSalesLineImportInfo(SalesInvoiceToImport);
            ImpportInvoicesMgt.PropagateSalesHeaderImportInfoToLines(SalesInvoiceToImport);

            pNewEntryNo += 1;
        end;
    end;

    local procedure AttachLastHeaderToLines(pTempText: Text; pNewEntryNo: Integer)
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        TempList: List of [Text];
    begin
        if pTempText = '' then
            exit;

        TempList := pTempText.Split('@');

        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetCurrentKey("Entry No.", Header, "Primula Posting No.", "Document No.", "VAT Progressive No.");
        SalesInvoiceToImport.SetRange(Header, true);
        SalesInvoiceToImport.SetRange("Primula Posting No.", TempList.Get(1));
        SalesInvoiceToImport.SetRange("Document No.", TempList.Get(2));
        SalesInvoiceToImport.SetRange("VAT Progressive No.", TempList.Get(3));
        if SalesInvoiceToImport.IsEmpty then
            AttachHeaderToLastLine(pTempText, pNewEntryNo);
    end;

    local procedure AdjustLine(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
        ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
        TempVariant: Variant;
    begin
        TempVariant := pSalesInvoiceToImport;
        if not ImportInvoicesMgt.CheckImportedBCAccount(TempVariant, Database::"Sales Invoice To Import", pSalesInvoiceToImport.Header) then begin
            pSalesInvoiceToImport := TempVariant;
            pSalesInvoiceToImport."Action Type" := pSalesInvoiceToImport."Action Type"::ERROR;
            pSalesInvoiceToImport."Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(pSalesInvoiceToImport."Error Message"));
        end else
            pSalesInvoiceToImport := TempVariant;

        Clear(TempVariant);
        TempVariant := pSalesInvoiceToImport;
        ImportInvoicesMgt.CheckEsistentBCDocument(TempVariant, Database::"Sales Invoice To Import", pSalesInvoiceToImport.Header);
        pSalesInvoiceToImport := TempVariant;

        Clear(TempVariant);
        TempVariant := pSalesInvoiceToImport;
        ImportInvoicesMgt.FinalizeImportLine(TempVariant, Database::"Sales Invoice To Import", pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::" ");
        pSalesInvoiceToImport := TempVariant;

        Clear(TempVariant);
        TempVariant := pSalesInvoiceToImport;
        ImportInvoicesMgt.CheckVATImportLines(TempVariant, Database::"Sales Invoice To Import", pSalesInvoiceToImport.Header, pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::EXISTENT);
        pSalesInvoiceToImport := TempVariant;

        pSalesInvoiceToImport.Modify(true);
    end;

    #endregion LOCALS

    #region GUI

    local procedure OpenWindow(pVar: Variant)
    var
    begin
        if GuiAllowed then
            gWindow.Open(pVar);
    end;

    local procedure UpdateWindow(pVar: Variant)
    var
    begin
        if GuiAllowed then
            gWindow.Update(1, pVar);
    end;

    local procedure CloseWindow()
    var
    begin
        if GuiAllowed then
            gWindow.Close();
    end;

    #endregion GUI
}
