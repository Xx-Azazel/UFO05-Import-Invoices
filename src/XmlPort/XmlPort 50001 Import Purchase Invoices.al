namespace KeyFor.UFO05.ImportInvoices;

using KeyFor.UFO01.CustomDataLayer;

xmlport 50001 "Import Purchase Invoices"
{
    CaptionML = ENU = 'Import Purchase Invoices', ITA = 'Importa Fatture di Acquisto';
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
            tableelement(TempPurchaseInvoiceToImport; "Purchase Invoice To Import")
            {
                SourceTableView = sorting("Entry No.");
                UseTemporary = true;
                AutoReplace = false;

                fieldattribute(Year; TempPurchaseInvoiceToImport.Year)
                {
                    Occurrence = Required;
                }

                fieldattribute(PostingDate; TempPurchaseInvoiceToImport."Posting Date")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaPostingNo; TempPurchaseInvoiceToImport."Primula Posting No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaPostingType; TempPurchaseInvoiceToImport."Primula Posting Type")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaAccountNo; TempPurchaseInvoiceToImport."Primula Account No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(PrimulaAccountDescription; TempPurchaseInvoiceToImport."Primula Account Description")
                {
                    Occurrence = Optional;
                }

                fieldattribute(ReasonCode; TempPurchaseInvoiceToImport."Reason Code")
                {
                    Occurrence = Required;
                }

                fieldattribute(ReasonDescription; TempPurchaseInvoiceToImport."Reason Description")
                {
                    Occurrence = Optional;
                }

                fieldattribute(Type; TempPurchaseInvoiceToImport.Type)
                {
                    Occurrence = Required;
                }

                fieldattribute(Amount; TempPurchaseInvoiceToImport.Amount)
                {
                    Occurrence = Optional;
                }

                fieldattribute(DocumentNo; TempPurchaseInvoiceToImport."Document No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(DocumentDate; TempPurchaseInvoiceToImport."Document Date")
                {
                    Occurrence = Required;
                }

                fieldattribute(VATProgressiveNo; TempPurchaseInvoiceToImport."VAT Progressive No.")
                {
                    Occurrence = Required;
                }

                fieldattribute(ActivityCode; TempPurchaseInvoiceToImport."Activity Code")
                {
                    Occurrence = Optional;
                }

                fieldattribute(VATCode; TempPurchaseInvoiceToImport."VAT Code")
                {
                    Occurrence = Required;
                }

                fieldattribute(VATDescription; TempPurchaseInvoiceToImport."VAT Description")
                {
                    Occurrence = Optional;
                }

                fieldattribute(VATTaxableAmount; TempPurchaseInvoiceToImport."VAT Taxable Amount")
                {
                    Occurrence = Optional;
                }

                fieldattribute(VATAmount; TempPurchaseInvoiceToImport."VAT Amount")
                {
                    Occurrence = Optional;
                }

                fieldattribute(AdditionalDescription; TempPurchaseInvoiceToImport."Additional Description")
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
                    TempPurchaseInvoiceToImport."Entry No." := 0;
                end;

                trigger OnAfterInsertRecord()
                var
                    SkipLine: Boolean;
                begin
                    SkipLine := false;

                    case true of
                        TempPurchaseInvoiceToImport.Year <> gYearFilter:
                            SkipLine := true;

                        TempPurchaseInvoiceToImport."Posting Date" < gDateFilter:
                            SkipLine := true;

                        TempPurchaseInvoiceToImport."Primula Posting Type" <> gPrimulaImportTypeFilter:
                            SkipLine := true;
                    end;

                    if not SkipLine then
                        InsertLineToArrangeFromBuffer();

                    TempPurchaseInvoiceToImport.Delete();
                end;
            }
        }
    }

    var
        gTempPurchaseInvoiceToImportToArrange: Record "Purchase Invoice To Import" temporary;
        gTempPurchaseInvoiceToImportToCheck: Record "Purchase Invoice To Import" temporary;
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
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
    begin
        if not Confirm(gConfTxt001, false, TempPurchaseInvoiceToImport.TableCaption) then
            Error('');

        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.DeleteAll();

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

        Clear(gTempPurchaseInvoiceToImportToArrange);
        gTempPurchaseInvoiceToImportToArrange := TempPurchaseInvoiceToImport;
        gTempPurchaseInvoiceToImportToArrange."Entry No." := gLastTempEntryNo;
        gTempPurchaseInvoiceToImportToArrange.Insert(true);

        TempVariant := gTempPurchaseInvoiceToImportToArrange;
        if not ImportInvoicesMgt.CheckIfImportedLineIsHeader(TempVariant, Database::"Purchase Invoice To Import") then begin
            gTempPurchaseInvoiceToImportToArrange := TempVariant;
            gTempPurchaseInvoiceToImportToArrange."Action Type" := gTempPurchaseInvoiceToImportToArrange."Action Type"::ERROR;
            gTempPurchaseInvoiceToImportToArrange."Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(gTempPurchaseInvoiceToImportToArrange."Error Message"));
        end else
            gTempPurchaseInvoiceToImportToArrange := TempVariant;

        gTempPurchaseInvoiceToImportToArrange.Modify(true);

        Clear(gTempPurchaseInvoiceToImportToCheck);
        gTempPurchaseInvoiceToImportToCheck := gTempPurchaseInvoiceToImportToArrange;
        gTempPurchaseInvoiceToImportToCheck.Insert(true);
    end;

    local procedure ProcessLinesToArrange()
    var
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        LastTempText: Text;
        CurrTempText: Text;
        NewEntryNo: Integer;
    begin
        OpenWindow(gTxt002);
        NewEntryNo := 0;

        gTempPurchaseInvoiceToImportToArrange.Reset();
        gTempPurchaseInvoiceToImportToArrange.SetCurrentKey("Entry No.", Header, "Document No.", "VAT Progressive No.");
        gTempPurchaseInvoiceToImportToArrange.SetRange(Header, false);
        if gTempPurchaseInvoiceToImportToArrange.FindSet() then
            repeat
                UpdateWindow(gTempPurchaseInvoiceToImportToArrange."Document No.");

                NewEntryNo += 1;
                CurrTempText := StrSubstNo('%1@%2', gTempPurchaseInvoiceToImportToArrange."Document No.", gTempPurchaseInvoiceToImportToArrange."VAT Progressive No.");

                if LastTempText <> CurrTempText then
                    AttachHeaderToLastLine(LastTempText, NewEntryNo);

                Clear(PurchaseInvoiceToImport);
                PurchaseInvoiceToImport := gTempPurchaseInvoiceToImportToArrange;
                PurchaseInvoiceToImport."Entry No." := NewEntryNo;
                PurchaseInvoiceToImport.Insert(true);

                AdjustLine(PurchaseInvoiceToImport);
                LastTempText := CurrTempText;
            until gTempPurchaseInvoiceToImportToArrange.Next() = 0;

        NewEntryNo += 1;
        AttachLastHeaderToLines(LastTempText, NewEntryNo);

        CloseWindow();
    end;

    local procedure AttachHeaderToLastLine(pTempText: Text; var pNewEntryNo: Integer)
    var
        ImpportInvoicesMgt: Codeunit "Import Invoices Mgt.";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        TempList: List of [Text];
    begin
        if pTempText = '' then
            exit;

        TempList := pTempText.Split('@');

        gTempPurchaseInvoiceToImportToCheck.Reset();
        gTempPurchaseInvoiceToImportToCheck.SetCurrentKey("Entry No.", Header, "Document No.", "VAT Progressive No.");
        gTempPurchaseInvoiceToImportToCheck.SetRange(Header, true);
        gTempPurchaseInvoiceToImportToCheck.SetRange("Document No.", TempList.Get(1));
        gTempPurchaseInvoiceToImportToCheck.SetRange("VAT Progressive No.", TempList.Get(2));
        if gTempPurchaseInvoiceToImportToCheck.FindFirst() then begin
            Clear(PurchaseInvoiceToImport);
            PurchaseInvoiceToImport := gTempPurchaseInvoiceToImportToCheck;
            PurchaseInvoiceToImport."Entry No." := pNewEntryNo;
            PurchaseInvoiceToImport.Insert(true);

            AdjustLine(PurchaseInvoiceToImport);

            ImpportInvoicesMgt.RetrivePurchaseLineImportInfo(PurchaseInvoiceToImport);
            ImpportInvoicesMgt.PropagatePurchaseHeaderImportInfoToLines(PurchaseInvoiceToImport);

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
        SalesInvoiceToImport.SetCurrentKey("Entry No.", Header, "Document No.", "VAT Progressive No.");
        SalesInvoiceToImport.SetRange(Header, true);
        SalesInvoiceToImport.SetRange("Document No.", TempList.Get(1));
        SalesInvoiceToImport.SetRange("VAT Progressive No.", TempList.Get(2));
        if SalesInvoiceToImport.IsEmpty then
            AttachHeaderToLastLine(pTempText, pNewEntryNo);
    end;

    local procedure AdjustLine(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
        ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
        TempVariant: Variant;
    begin
        TempVariant := pPurchaseInvoiceToImport;
        if not ImportInvoicesMgt.CheckImportedBCAccount(TempVariant, Database::"Purchase Invoice To Import", pPurchaseInvoiceToImport.Header) then begin
            pPurchaseInvoiceToImport := TempVariant;
            pPurchaseInvoiceToImport."Action Type" := pPurchaseInvoiceToImport."Action Type"::ERROR;
            pPurchaseInvoiceToImport."Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(pPurchaseInvoiceToImport."Error Message"));
        end else
            pPurchaseInvoiceToImport := TempVariant;

        Clear(TempVariant);
        TempVariant := pPurchaseInvoiceToImport;
        ImportInvoicesMgt.CheckEsistentBCDocument(TempVariant, Database::"Purchase Invoice To Import", pPurchaseInvoiceToImport.Header);
        pPurchaseInvoiceToImport := TempVariant;

        Clear(TempVariant);
        TempVariant := pPurchaseInvoiceToImport;
        ImportInvoicesMgt.FinalizeImportLine(TempVariant, Database::"Purchase Invoice To Import", pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::" ");
        pPurchaseInvoiceToImport := TempVariant;

        Clear(TempVariant);
        TempVariant := pPurchaseInvoiceToImport;
        ImportInvoicesMgt.CheckVATImportLines(TempVariant, Database::"Purchase Invoice To Import", pPurchaseInvoiceToImport.Header, pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::EXISTENT);
        pPurchaseInvoiceToImport := TempVariant;

        pPurchaseInvoiceToImport.Modify(true);
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
