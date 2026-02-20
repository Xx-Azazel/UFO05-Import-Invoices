namespace KeyFor.UFO01.CustomDataLayer;

using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using KeyFor.UFO05.ImportInvoices;

table 50001 "Sales Invoice To Import"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Sales Invoice to Import', ITA = 'Fattura di Vendita da Importare';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Entry No.', ITA = 'Nr. Movimento';
            Editable = false;
        }

        field(5; Year; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Year', ITA = 'Anno';
        }

        field(10; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Posting Date', ITA = 'Data Registrazione';
            Editable = false;
        }

        field(12; "Primula Posting No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Primula Posting No.', ITA = 'Nr. Registrazione Primula';
            Editable = false;
        }

        field(15; "Primula Posting Type"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Primula Posting Type', ITA = 'Tipo Registrazione Primula';
            Editable = false;
        }

        field(20; "Primula Account No."; Text[30])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Primula Account No.', ITA = 'Nr. Conto Primula';
            Editable = false;
        }

        field(22; "Primula Account Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Primula Account Description', ITA = 'Descrizione Conto Primula';
            Editable = false;
        }

        field(25; "BC Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'BC Account No.', ITA = 'Nr. Conto BC';
            Editable = false;
        }

        // field(27; "BC Account Name"; Text[100])
        // {
        //     CaptionML = ENU = 'BC Account Name', ITA = 'Nome Conto BC';
        //     Editable = false;
        //     FieldClass = FlowField;
        //     CalcFormula = lookup("Primula - BC Account Link"."BC Account Name" where("Primula Account No." = field("Primula Account No.")));
        // }

        field(26; "BC Account Dimension"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'BC Account Dimension', ITA = 'Dimensione Conto BC';
            Editable = false;
        }

        field(30; "Reason Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Reason Code', ITA = 'Codice Causale';
            Editable = false;
        }

        field(32; "Reason Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Reason Description', ITA = 'Descrizione Causale';
            Editable = false;
        }

        field(35; "Type"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Type', ITA = 'Tipo';
            Editable = false;
        }

        field(40; "Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Amount', ITA = 'Importo';
            Editable = false;
        }

        field(50; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Document No.', ITA = 'Nr. Documento';
            Editable = false;
        }

        field(52; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Document Date', ITA = 'Data Documento';
            Editable = false;
        }

        field(55; "VAT Progressive No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'VAT Progressive No.', ITA = 'Nr. Progressivo IVA';
            Editable = false;
        }

        field(60; "Activity Code"; Code[5])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Activity Code', ITA = 'Codice Attività';
            Editable = false;
        }

        field(65; "VAT Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'VAT Code', ITA = 'Codice IVA';
            Editable = false;
        }

        field(67; "VAT Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'VAT Description', ITA = 'Descrizione IVA';
            Editable = false;
        }

        field(70; "VAT taxable Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'VAT Taxable Amount', ITA = 'Imponibile IVA';
            Editable = false;
        }

        field(72; "VAT Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Amount Including VAT', ITA = 'Importo Inclusa IVA';
            Editable = false;
        }

        field(100; "Additional Description"; Text[250])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Additional Description', ITA = 'Descrizione Aggiuntiva';
            Editable = false;
        }

        field(500; "Action Type"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Action Type', ITA = 'Tipo Azione';
            OptionMembers = " ",CREATE,CHECK,"CHECK WITHOLDING TAX",EXISTENT,ERROR;
            OptionCaptionML = ENU = ' ,CREATE,CHECK,CHECK WITHOLDING TAX,EXISTENT,ERROR', ITA = ' ,CREA,CONTROLLA,CONTROLLA RITENUTA,ESISTENTE,ERRORE';
            Editable = false;
        }

        field(510; "BC Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'BC Document No.', ITA = 'Nr. Documento BC';
            Editable = false;
        }

        field(520; "BC Posted Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'BC Posted Document No.', ITA = 'Nr. Documento Registrato BC';
            Editable = false;
        }

        field(750; "Error Message"; Text[250])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Error Message', ITA = 'Messaggio di Errore';
            Editable = false;
        }

        field(1000; Header; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Header', ITA = 'Intestazione';
            Editable = false;
        }

        field(1001; "BC Document Created"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'BC Document Created', ITA = 'Documento BC Creato';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    #region TRIGGERS

    trigger OnInsert()
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
    begin
        if Rec."Entry No." = 0 then begin
            SalesInvoiceToImport.Reset();
            if SalesInvoiceToImport.FindLast() then;

            Rec."Entry No." := SalesInvoiceToImport."Entry No." + 1;
        end;
    end;

    trigger OnDelete()
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
    begin
        if Rec.Header then begin
            SalesInvoiceToImport.Reset();
            SalesInvoiceToImport.SetCurrentKey("Entry No.", "Primula Posting No.", "Document No.", "VAT Progressive No.");
            SalesInvoiceToImport.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
            SalesInvoiceToImport.SetRange("Primula Posting No.", Rec."Primula Posting No.");
            SalesInvoiceToImport.SetRange("Document No.", Rec."Document No.");
            SalesInvoiceToImport.SetRange("VAT Progressive No.", Rec."VAT Progressive No.");
            SalesInvoiceToImport.SetRange(Header, false);
            if not SalesInvoiceToImport.IsEmpty then
                SalesInvoiceToImport.DeleteAll();
        end;
    end;

    #endregion TRIGGERS

    #region EXTERNALS

    procedure OpenBCDocument()
    var
        ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
    begin
        ImportInvoicesMgt.OpenImportedBCDocument(Rec."Reason Code", Rec."BC Document No.");
    end;

    procedure OpenBCPostedDocument()
    var
        ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
    begin
        ImportInvoicesMgt.OpenImportedBCPostedDocument(Rec."Reason Code", Rec."BC Posted Document No.");
    end;

    procedure RetriveBCReasonCode(): Code[10]
    var
        ImportInvoicesMgt: Codeunit "Import Invoices Mgt.";
    begin
        exit(ImportInvoicesMgt.RetriveReasonCode(Rec."Reason Code"));
    end;

    procedure GenerateBCPostingNo(): Code[20]
    var
        ImportInvoiceMgt: Codeunit "Import Invoices Mgt.";
    begin
        exit(ImportInvoiceMgt.GeneratePostingNo(Rec."Reason Code", Rec."Activity Code", Rec."VAT Progressive No."));
    end;

    #endregion EXTERNALS
}
