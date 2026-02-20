namespace KeyFor.UFO05.ImportInvoices;

using KeyFor.UFO01.CustomDataLayer;
using Microsoft.Sales.Document;
using System.Utilities;

page 50002 "Sales Invoices To Import"
{
    ApplicationArea = all;
    CaptionML = ENU = 'Sales Invoices to Import', ITA = 'Fatture di Vendita da Importare';
    PageType = List;
    SourceTable = "Sales Invoice To Import";
    UsageCategory = Administration;
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = true;
    LinksAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                }

                field(Header; Rec.Header)
                {
                    ApplicationArea = all;
                }

                field("BC Document Created"; Rec."BC Document Created")
                {
                    ApplicationArea = all;
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = all;
                }

                field("Primula Posting No."; Rec."Primula Posting No.")
                {
                    ApplicationArea = all;
                }

                field("Primula Posting Type"; Rec."Primula Posting Type")
                {
                    ApplicationArea = all;
                }

                field("Primula Account No."; Rec."Primula Account No.")
                {
                    ApplicationArea = all;
                }

                field("Primula Account Description"; Rec."Primula Account Description")
                {
                    ApplicationArea = all;
                }

                field("BC Account No."; Rec."BC Account No.")
                {
                    ApplicationArea = all;
                }

                field("BC Account Dimension"; Rec."BC Account Dimension")
                {
                    ApplicationArea = all;
                }

                // field("BC Account Name"; Rec."BC Account Name")
                // {
                //     ApplicationArea = all;
                // }

                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = all;
                }

                field("Reason Description"; Rec."Reason Description")
                {
                    ApplicationArea = all;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = all;
                }

                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = all;
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = all;
                }

                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = all;
                }

                field("VAT Progressive No."; Rec."VAT Progressive No.")
                {
                    ApplicationArea = all;
                }

                field("Activity Code"; Rec."Activity Code")
                {
                    ApplicationArea = all;
                }

                field("VAT Code"; Rec."VAT Code")
                {
                    ApplicationArea = all;
                }

                field("VAT Description"; Rec."VAT Description")
                {
                    ApplicationArea = all;
                }

                field("VAT taxable amount"; Rec."VAT taxable Amount")
                {
                    ApplicationArea = all;
                }

                field("Additional Description"; Rec."Additional Description")
                {
                    ApplicationArea = all;
                }

                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = all;
                }

                field("BC Document No."; Rec."BC Document No.")
                {
                    ApplicationArea = all;
                }

                field("BC Posted Document No."; Rec."BC Posted Document No.")
                {
                    ApplicationArea = all;
                }

                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Import from File', ITA = 'Importa da File';
                Image = Import;

                trigger OnAction()
                var
                    CleanedBlob: Codeunit "Temp Blob";
                    InputDialog: Page "Input Dialog";
                    ImportSalesInvoices: XmlPort "Import Sales Invoices";
                    DateFilter: Date;
                    RawLine: Text;
                    CleanedLine: Text;
                    FileName: Text;
                    PrimulaImportTypeFilter: Code[10];
                    I: Integer;
                    CharCode: Integer;
                    YearFilter: Integer;
                    CurrentChar: Char;
                    IStream: InStream;
                    OStream: OutStream;
                    CleanIStream: InStream;
                    IsFirstLine: Boolean;
                    Txt001: TextConst ENU = 'Import Sales Invoices csv', ITA = 'Importa Fatture di Vendita csv';
                    Txt002: TextConst ENU = 'Import Filters', ITA = 'Filtri di Importazione';
                    CRLF: Text[2];
                begin
                    Clear(InputDialog);
                    if not InputDialog.RetrivePrimulaFilters(YearFilter, DateFilter, PrimulaImportTypeFilter, 0, Txt002) then
                        Error(GetLastErrorText);

                    if not UploadIntoStream(Txt001, '', '', FileName, IStream) then
                        exit;

                    CRLF[1] := 13;
                    CRLF[2] := 10;

                    CleanedBlob.CreateOutStream(OStream, TextEncoding::MSDos);

                    IsFirstLine := true;
                    while not IStream.EOS do begin
                        IStream.ReadText(RawLine);

                        CleanedLine := '';
                        for i := 1 to StrLen(RawLine) do begin
                            CurrentChar := RawLine[i];
                            CharCode := CurrentChar;

                            if (CharCode >= 32) or (CharCode = 9) then
                                CleanedLine += Format(CurrentChar);
                        end;

                        if IsFirstLine then
                            IsFirstLine := false
                        else
                            OStream.WriteText(CRLF);

                        OStream.WriteText(CleanedLine);
                    end;

                    CleanedBlob.CreateInStream(CleanIStream, TextEncoding::MSDos);

                    ImportSalesInvoices.SetSource(CleanIStream);
                    ImportSalesInvoices.SetParamFilters(YearFilter, DateFilter, PrimulaImportTypeFilter);
                    ImportSalesInvoices.Import();
                    CurrPage.Update(false);
                end;
            }

            action(ProcessInvoices)
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Process Invoices to Import', ITA = 'Elabora Fatture da Importare';
                Image = Process;

                trigger OnAction()
                var
                    ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
                    SalesInvoiceToImport: Record "Sales Invoice To Import";
                begin
                    SalesInvoiceToImport.Reset();
                    CurrPage.SetSelectionFilter(SalesInvoiceToImport);

                    SalesInvoiceToImport.CopyFilters(Rec);

                    ImportInvoicesMgt.ProcessSalesInvoicesToImport(SalesInvoiceToImport);
                    CurrPage.Update(false);
                end;
            }

            action(DeleteDataPerHeader)
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Delete Data per Header', ITA = 'Elimina Dati per Intestazione';
                Image = Delete;

                trigger OnAction()
                var
                    SalesInvoiceToImport: Record "Sales Invoice To Import";
                    ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
                begin
                    SalesInvoiceToImport.Reset();
                    CurrPage.SetSelectionFilter(SalesInvoiceToImport);

                    ImportInvoicesMgt.DeleteFromSalesImportPerHeaders(SalesInvoiceToImport);
                    CurrPage.Update(true);
                end;
            }

            group(Documents)
            {
                action(ShowBCDocument)
                {
                    ApplicationArea = all;
                    CaptionML = ENU = 'Show BC Document', ITA = 'Mostra Documento BC';
                    Image = Document;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                    begin
                        Rec.OpenBCDocument();
                    end;
                }

                action(ShowBCPostedDocument)
                {
                    ApplicationArea = all;
                    CaptionML = ENU = 'Show BC Posted Document', ITA = 'Mostra Documento Registrato BC';
                    Image = PostedOrder;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                    begin
                        Rec.OpenBCPostedDocument();
                    end;
                }
            }

            group(KF)
            {
                action(Magic)
                {
                    ApplicationArea = all;
                    CaptionML = ENU = 'Magic', ITA = 'Magia';
                    Image = SuggestField;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        SalesLine: Record "Sales Line";
                        Txt001: TextConst ENU = 'Magic done !', ITA = 'Magia fatta !';
                        ConfTxt001: TextConst ENU = 'This will delete all sales invoices/credit notes.\Proceed ?', ITA = 'Questo eliminerà tutte le fatture di vendita/nota di credito.\Procedere ?';
                    begin
                        SalesHeader.Reset();
                        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                        if SalesHeader.FindSet() then
                            repeat
                                SalesLine.Reset();
                                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                SalesLine.SetRange("Document No.", SalesHeader."No.");
                                SalesLine.DeleteAll();

                                SalesHeader."Posting No." := '';
                                SalesHeader.delete;
                            until SalesHeader.Next() = 0;

                        SalesHeader.Reset();
                        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
                        if SalesHeader.FindSet() then
                            repeat
                                SalesLine.Reset();
                                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                SalesLine.SetRange("Document No.", SalesHeader."No.");
                                SalesLine.DeleteAll();

                                SalesHeader."Posting No." := '';
                                SalesHeader.delete;
                            until SalesHeader.Next() = 0;

                        Message(Txt001);
                    end;
                }
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Import_Promoted; Import)
                { }

                actionref(ProcessInvoices_Promoted; ProcessInvoices)
                {
                }

                actionref(DeleteDataPerHeader_Promoted; DeleteDataPerHeader)
                {
                }
            }

            group(Category_Category5)
            {
                CaptionML = ENU = 'Documents', ITA = 'Documenti';

                actionref(ShowBCDocument_Promoted; ShowBCDocument)
                { }

                actionref(ShowBCPostedDocument_Promoted; ShowBCPostedDocument)
                { }
            }
        }
    }
}
