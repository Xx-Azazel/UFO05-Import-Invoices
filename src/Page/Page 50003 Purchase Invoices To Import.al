namespace KeyFor.UFO05.ImportInvoices;

using KeyFor.UFO01.CustomDataLayer;
using Microsoft.Purchases.Document;
using System.Utilities;
using System.Security.AccessControl;

page 50003 "Purchase Invoices To Import"
{
    ApplicationArea = all;
    CaptionML = ENU = 'Purchase Invoices to Import', ITA = 'Fatture di Acquisto da Importare';
    PageType = List;
    SourceTable = "Purchase Invoice To Import";
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
                    ImportPurchaseInvoices: XmlPort "Import Purchase Invoices";
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
                    Txt001: TextConst ENU = 'Import Purchase Invoices csv', ITA = 'Importa Fatture di Acquisto csv';
                    Txt002: TextConst ENU = 'Import Filters', ITA = 'Filtri di Importazione';
                    CRLF: Text[2];
                begin
                    Clear(InputDialog);
                    if not InputDialog.RetrivePrimulaFilters(YearFilter, DateFilter, PrimulaImportTypeFilter, 1, Txt002) then
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

                    ImportPurchaseInvoices.SetSource(CleanIStream);
                    ImportPurchaseInvoices.SetParamFilters(YearFilter, DateFilter, PrimulaImportTypeFilter);
                    ImportPurchaseInvoices.Import();
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
                    PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
                begin
                    PurchaseInvoiceToImport.Reset();
                    CurrPage.SetSelectionFilter(PurchaseInvoiceToImport);

                    PurchaseInvoiceToImport.CopyFilters(Rec);

                    ImportInvoicesMgt.ProcessPurchaseInvoicesToImport(PurchaseInvoiceToImport);
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
                    PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
                    ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
                begin
                    PurchaseInvoiceToImport.Reset();
                    CurrPage.SetSelectionFilter(PurchaseInvoiceToImport);

                    ImportInvoicesMgt.DeleteFromPurchaseImportPerHeaders(PurchaseInvoiceToImport);
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
                        Purchase: Record "Purchase Header";
                        PurchaseLine: Record "Purchase Line";
                        Txt001: TextConst ENU = 'Magic done !', ITA = 'Magia fatta !';
                        ConfTxt001: TextConst ENU = 'This will delete all purchase invoices/credit notes.\Proceed ?', ITA = 'Questo eliminerà tutte le fatture di acquisto  /nota di credito.\Procedere ?';
                    begin
                        Purchase.Reset();
                        Purchase.SetRange("Document Type", Purchase."Document Type"::Invoice);
                        if Purchase.FindSet() then
                            repeat
                                PurchaseLine.Reset();
                                PurchaseLine.SetRange("Document Type", Purchase."Document Type");
                                PurchaseLine.SetRange("Document No.", Purchase."No.");
                                PurchaseLine.DeleteAll();

                                Purchase."Posting No." := '';
                                Purchase.delete;
                            until Purchase.Next() = 0;

                        Purchase.Reset();
                        Purchase.SetRange("Document Type", Purchase."Document Type"::"Credit Memo");
                        if Purchase.FindSet() then
                            repeat
                                PurchaseLine.Reset();
                                PurchaseLine.SetRange("Document Type", Purchase."Document Type");
                                PurchaseLine.SetRange("Document No.", Purchase."No.");
                                PurchaseLine.DeleteAll();

                                Purchase."Posting No." := '';
                                Purchase.delete;
                            until Purchase.Next() = 0;

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
