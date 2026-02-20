namespace KeyFor.UFO05.ImportInvoices;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Purchases.Vendor;
using KeyFor.UFO01.CustomDataLayer;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;

codeunit 50001 "Import Invoices Mgt."
{
    trigger OnRun()
    var
    begin
    end;

    var
        gReasonCodeForCHECK: Label 'VAT-CHECK';
        gReaasonCodeDescriptionForCHECK: TextConst ENU = 'VAT Check from Primula file import', ITA = 'Controllo IVA da importazione file Primula';
        gReasonCodeForCHECKErrorTxt: TextConst ENU = 'Reason Code is not valid !\Check VAT before posting.', ITA = 'Il Codice Causale non è valido !\Verificare l''IVA prima della contabilizzazione.';

    #region EVENTS SUBSCRIBERS

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostInvoice, '', false, false)]
    local procedure C80_OnBeforePostInvoice(var SalesHeader: Record "Sales Header")
    var
    begin
        if SalesHeader."Reason Code" = gReasonCodeForCHECK then
            Error(gReasonCodeForCHECKErrorTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostInvoice, '', false, false)]
    local procedure C90_OnBeforePostInvoice(var PurchHeader: Record "Purchase Header")
    var
    begin
        if PurchHeader."Reason Code" = gReasonCodeForCHECK then
            Error(gReasonCodeForCHECKErrorTxt);
    end;

    #endregion EVENTS SUBSCRIBERS

    #region EXTERNALS 

    #region MISCELLANEOUS

    procedure OpenImportedBCDocument(pReasonCode: Code[10]; pDocumentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        case pReasonCode of
            '201':
                begin
                    SalesHeader.Reset();
                    if not SalesHeader.Get(SalesHeader."Document Type"::Invoice, pDocumentNo) then
                        exit;

                    Page.Run(Page::"Sales Invoice", SalesHeader);
                end;

            '202':
                begin
                    SalesHeader.Reset();
                    if not SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", pDocumentNo) then
                        exit;

                    Page.Run(Page::"Sales Credit Memo", SalesHeader);
                end;

            '301', '305', '307', '310', '385', '386', '387':
                begin
                    PurchaseHeader.Reset();
                    if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, pDocumentNo) then
                        exit;

                    Page.Run(Page::"Purchase Invoice", PurchaseHeader);
                end;


            '302', '306', '308', '311', '382', '381', '383':
                begin
                    PurchaseHeader.Reset();
                    if not PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", pDocumentNo) then
                        exit;

                    Page.Run(Page::"Purchase Credit Memo", PurchaseHeader);
                end;
        end;
    end;

    procedure OpenImportedBCPostedDocument(pReasonCode: Code[10]; pDocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        case pReasonCode of
            '201':
                begin
                    SalesInvoiceHeader.Reset();
                    if not SalesInvoiceHeader.Get(pDocumentNo) then
                        exit;

                    Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                end;

            '202':
                begin
                    SalesCrMemoHeader.Reset();
                    if not SalesCrMemoHeader.Get(pDocumentNo) then
                        exit;

                    Page.Run(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;

            '301', '305', '307', '310', '385', '386', '387':
                begin
                    PurchInvHeader.Reset();
                    if not PurchInvHeader.Get(pDocumentNo) then
                        exit;

                    Page.Run(Page::"Posted Purchase Invoice", PurchInvHeader);
                end;

            '302', '306', '308', '311', '382', '381', '383':
                begin
                    PurchCrMemoHdr.Reset();
                    if not PurchCrMemoHdr.Get(pDocumentNo) then
                        exit;

                    Page.Run(Page::"Posted Purchase Credit Memo", PurchCrMemoHdr);
                end;
        end;
    end;

    procedure RetriveReasonCode(pImportedReasonCode: Code[10]): Code[10]
    var
    begin
        case pImportedReasonCode of
            '201':
                exit('V-201');

            '202':
                exit('V-202');

            '301':
                exit('A-301');

            '302':
                exit('A-302');

            '305', '385':
                exit('A-305');

            '306', '382':
                exit('A-306');

            '307', '387':
                exit('A-307');

            '308', '381':
                exit('A-308');

            '310', '386':
                exit('A-310');

            '311', '383':
                exit('A-311');
        end;
    end;

    procedure GeneratePostingNo(pReasonCode: Code[10]; pActivityCode: Code[10]; pVATProgressiveNo: Code[10]): Code[20]
    var
        BCPostingNo: Code[20];
    begin
        case pReasonCode of
            '201', '202':
                case pActivityCode of
                    '0':
                        BCPostingNo := StrSubstNo('VI-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));

                    '2':
                        BCPostingNo := StrSubstNo('VC-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));

                    '5':
                        BCPostingNo := StrSubstNo('VX-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));
                end;

            '301', '302', '305', '306', '382', '385':
                case pActivityCode of
                    '0':
                        BCPostingNo := StrSubstNo('AI-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));

                    '1':
                        BCPostingNo := StrSubstNo('AC-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));
                end;

            '307', '308', '387', '381':
                case pActivityCode of
                    '3':
                        BCPostingNo := StrSubstNo('AIR-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));
                end;

            '310', '311', '386', '383':
                case pActivityCode of
                    '6':
                        BCPostingNo := StrSubstNo('AXR-%1', StrSubstNo(pVATProgressiveNo).PadLeft(5, '0'));
                end;
        end;

        exit(BCPostingNo);
    end;

    procedure DeleteFromSalesImportPerHeaders(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
    begin
        pSalesInvoiceToImport.SetRange(Header, true);
        if pSalesInvoiceToImport.FindSet() then
            repeat
                pSalesInvoiceToImport.Delete(true);
            until pSalesInvoiceToImport.Next() = 0;
    end;

    procedure DeleteFromPurchaseImportPerHeaders(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
    begin
        pPurchaseInvoiceToImport.SetRange(Header, true);
        if pPurchaseInvoiceToImport.FindSet() then
            repeat
                pPurchaseInvoiceToImport.Delete(true);
            until pPurchaseInvoiceToImport.Next() = 0;
    end;

    #endregion MISCELLANEOUS

    #region IMPORT

    [TryFunction]
    procedure CheckIfImportedLineIsHeader(var pVariantRec: Variant; pTableNo: Integer)
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if not pVariantRec.IsRecord then
            exit;

        case pTableNo of
            Database::"Sales Invoice To Import":
                begin
                    SalesInvoiceToImport := pVariantRec;
                    if CopyStr(SalesInvoiceToImport."Primula Account No.", 1, 1) <> 'C' then
                        exit;

                    SalesInvoiceToImport.Header := true;
                    pVariantRec := SalesInvoiceToImport;

                    Customer.Reset();
                    Customer.Get(SalesInvoiceToImport."Primula Account No.");
                    SalesInvoiceToImport."BC Account No." := Customer."No.";
                    pVariantRec := SalesInvoiceToImport;
                end;

            Database::"Purchase Invoice To Import":
                begin
                    PurchaseInvoiceToImport := pVariantRec;
                    if CopyStr(PurchaseInvoiceToImport."Primula Account No.", 1, 1) <> 'F' then
                        exit;

                    PurchaseInvoiceToImport.Header := true;
                    pVariantRec := PurchaseInvoiceToImport;

                    Vendor.Reset();
                    Vendor.Get(PurchaseInvoiceToImport."Primula Account No.");
                    if Vendor."Withholding Tax Code" <> '' then
                        PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX";

                    PurchaseInvoiceToImport."BC Account No." := Vendor."No.";
                    pVariantRec := PurchaseInvoiceToImport;
                end;
        end;
    end;

    [TryFunction]
    procedure CheckImportedBCAccount(var pVariantRec: Variant; pTableNo: Integer; pIsHeader: Boolean)
    var
        PrimulaBCAccountLink: Record "Primula - BC Account Link";
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
    begin
        if not pVariantRec.IsRecord then
            exit;

        if pIsHeader then
            exit;

        case pTableNo of
            Database::"Sales Invoice To Import":
                begin
                    SalesInvoiceToImport := pVariantRec;

                    PrimulaBCAccountLink.Reset();
                    PrimulaBCAccountLink.Get(SalesInvoiceToImport."Primula Account No.");

                    SalesInvoiceToImport."BC Account No." := PrimulaBCAccountLink."BC Account No.";
                    SalesInvoiceToImport."BC Account Dimension" := PrimulaBCAccountLink."Dimension Code CdC";
                    pVariantRec := SalesInvoiceToImport;
                end;

            Database::"Purchase Invoice To Import":
                begin
                    PurchaseInvoiceToImport := pVariantRec;

                    PrimulaBCAccountLink.Reset();
                    PrimulaBCAccountLink.Get(PurchaseInvoiceToImport."Primula Account No.");

                    PurchaseInvoiceToImport."BC Account No." := PrimulaBCAccountLink."BC Account No.";
                    PurchaseInvoiceToImport."BC Account Dimension" := PrimulaBCAccountLink."Dimension Code CdC";
                    pVariantRec := PurchaseInvoiceToImport;
                end;
        end;
    end;

    procedure CheckEsistentBCDocument(var pVariantRec: Variant; pTableNo: Integer; pIsHeader: Boolean)
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PostingNo: Code[20];
    begin
        if not pVariantRec.IsRecord then
            exit;

        if not pIsHeader then
            exit;

        case pTableNo of
            Database::"Sales Invoice To Import":
                begin
                    SalesInvoiceToImport := pVariantRec;
                    PostingNo := SalesInvoiceToImport.GenerateBCPostingNo();

                    case SalesInvoiceToImport."Reason Code" of
                        '201':
                            begin
                                SalesHeader.Reset();
                                SalesHeader.SetCurrentKey("Document Type", "Posting No.");
                                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                                SalesHeader.SetRange("Posting No.", PostingNo);
                                if SalesHeader.FindFirst() then begin
                                    SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::EXISTENT;
                                    SalesInvoiceToImport."BC Document No." := SalesHeader."No.";
                                end;

                                SalesInvoiceHeader.Reset();
                                if SalesInvoiceHeader.Get(PostingNo) then begin
                                    SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::EXISTENT;
                                    SalesInvoiceToImport."BC Posted Document No." := SalesInvoiceHeader."No.";
                                end;

                                pVariantRec := SalesInvoiceToImport;
                            end;

                        '202':
                            begin
                                SalesHeader.Reset();
                                SalesHeader.SetCurrentKey("Document Type", "Posting No.");
                                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
                                SalesHeader.SetRange("Posting No.", PostingNo);
                                if SalesHeader.FindFirst() then begin
                                    SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::EXISTENT;
                                    SalesInvoiceToImport."BC Document No." := SalesHeader."No.";
                                end;

                                SalesCrMemoHeader.Reset();
                                if SalesCrMemoHeader.Get(PostingNo) then begin
                                    SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::EXISTENT;
                                    SalesInvoiceToImport."BC Posted Document No." := SalesCrMemoHeader."No.";
                                end;

                                pVariantRec := SalesInvoiceToImport;
                            end;
                    end;
                end;

            Database::"Purchase Invoice To Import":
                begin
                    PurchaseInvoiceToImport := pVariantRec;
                    PostingNo := PurchaseInvoiceToImport.GenerateBCPostingNo();

                    case PurchaseInvoiceToImport."Reason Code" of
                        '301', '305', '307', '310', '385', '386', '387':
                            begin
                                PurchaseHeader.Reset();
                                PurchaseHeader.SetCurrentKey("Document Type", "Posting No.");
                                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
                                PurchaseHeader.SetRange("Posting No.", PostingNo);
                                if PurchaseHeader.FindFirst() then begin
                                    PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::EXISTENT;
                                    PurchaseInvoiceToImport."BC Document No." := PurchaseHeader."No.";
                                end;

                                PurchInvHeader.Reset();
                                if PurchInvHeader.Get(PostingNo) then begin
                                    PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::EXISTENT;
                                    PurchaseInvoiceToImport."BC Posted Document No." := PurchInvHeader."No.";
                                end;

                                pVariantRec := PurchaseInvoiceToImport;
                            end;

                        '302', '306', '308', '311', '382', '381', '383':
                            begin
                                PurchaseHeader.Reset();
                                PurchaseHeader.SetCurrentKey("Document Type", "Posting No.");
                                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
                                PurchaseHeader.SetRange("Posting No.", PostingNo);
                                if PurchaseHeader.FindFirst() then begin
                                    PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::EXISTENT;
                                    PurchaseInvoiceToImport."BC Document No." := PurchaseHeader."No.";
                                end;

                                PurchCrMemoHdr.Reset();
                                if PurchCrMemoHdr.Get(PostingNo) then begin
                                    PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::EXISTENT;
                                    PurchaseInvoiceToImport."BC Posted Document No." := PurchCrMemoHdr."No.";
                                end;

                                pVariantRec := PurchaseInvoiceToImport;
                            end;
                    end;
                end;
        end;
    end;

    procedure FinalizeImportLine(var pVariantRec: Variant; pTableNo: Integer; pActionTypeEmpty: Boolean)
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
    begin
        if not pActionTypeEmpty then
            exit;

        case pTableNo of
            Database::"Sales Invoice To Import":
                begin
                    SalesInvoiceToImport := pVariantRec;
                    SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::CREATE;
                    pVariantRec := SalesInvoiceToImport;
                end;

            Database::"Purchase Invoice To Import":
                begin
                    PurchaseInvoiceToImport := pVariantRec;
                    PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::CREATE;
                    pVariantRec := PurchaseInvoiceToImport;
                end;
        end;
    end;

    [TryFunction]
    procedure CheckVATImportLines(var pVariantRec: Variant; pTableNo: Integer; pIsHeader: Boolean; pExistentActionType: Boolean)
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        SalesInvoiceToImport2: Record "Sales Invoice To Import";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        PurchaseInvoiceToImport2: Record "Purchase Invoice To Import";
        VATPostingSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATCode: Code[20];
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if not pIsHeader then
            exit;

        if pExistentActionType then
            exit;

        case pTableNo of
            Database::"Sales Invoice To Import":
                begin
                    SalesInvoiceToImport := pVariantRec;

                    SalesInvoiceToImport2.Reset();
                    SalesInvoiceToImport2.SetCurrentKey("Entry No.", "Primula Posting No.", "Document No.", "VAT Progressive No.");
                    SalesInvoiceToImport2.SetFilter("Entry No.", '<>%1', SalesInvoiceToImport."Entry No.");
                    SalesInvoiceToImport2.SetRange("Primula Posting No.", SalesInvoiceToImport."Primula Posting No.");
                    SalesInvoiceToImport2.SetRange("Document No.", SalesInvoiceToImport."Document No.");
                    SalesInvoiceToImport2.SetRange("VAT Progressive No.", SalesInvoiceToImport."VAT Progressive No.");
                    SalesInvoiceToImport2.SetFilter("Primula Account No.", '%1|%2', '0206002', '0206001');
                    if SalesInvoiceToImport2.Count > 1 then
                        SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::CHECK
                    else
                        if SalesInvoiceToImport2.Count = 1 then begin
                            SalesInvoiceToImport2.FindFirst();
                            VATProductPostingGroup.Get(SalesInvoiceToImport2."VAT Code");

                            Customer.Reset();
                            if Customer.Get(SalesInvoiceToImport."Primula Account No.") then begin
                                VATPostingSetup.Reset();
                                VATPostingSetup.Get(Customer."VAT Bus. Posting Group", '22');

                                if VATPostingSetup."VAT Identifier" <> SalesInvoiceToImport2."VAT Code" then
                                    SalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type"::CHECK;
                            end;
                        end;

                    pVariantRec := SalesInvoiceToImport;
                end;

            Database::"Purchase Invoice To Import":
                begin
                    PurchaseInvoiceToImport := pVariantRec;

                    PurchaseInvoiceToImport2.Reset();
                    PurchaseInvoiceToImport2.SetCurrentKey("Entry No.", "Document No.", "VAT Progressive No.");
                    PurchaseInvoiceToImport2.SetFilter("Entry No.", '<>%1', PurchaseInvoiceToImport."Entry No.");
                    PurchaseInvoiceToImport2.SetRange("Document No.", PurchaseInvoiceToImport."Document No.");
                    PurchaseInvoiceToImport2.SetRange("VAT Progressive No.", PurchaseInvoiceToImport."VAT Progressive No.");
                    PurchaseInvoiceToImport2.SetFilter("Primula Account No.", '%1|%2', '0206002', '0206001');
                    if PurchaseInvoiceToImport2.Count > 1 then
                        PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::CHECK
                    else
                        if PurchaseInvoiceToImport2.Count = 1 then begin
                            PurchaseInvoiceToImport2.FindFirst();
                            VATProductPostingGroup.Get(PurchaseInvoiceToImport2."VAT Code");

                            Vendor.Reset();
                            if Vendor.Get(PurchaseInvoiceToImport."Primula Account No.") then begin
                                VATPostingSetup.Reset();
                                VATPostingSetup.Get(Vendor."VAT Bus. Posting Group", '22');

                                if VATPostingSetup."VAT Identifier" <> PurchaseInvoiceToImport2."VAT Code" then
                                    PurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type"::CHECK;
                            end;
                        end;
                end;
        end;
    end;

    procedure RetriveSalesLineImportInfo(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        ErrTxt001: TextConst ENU = 'Lines in error', ITA = 'Righe in errore';
        ErrTxt002: TextConst ENU = 'Lines to check', ITA = 'Righe da controllare';
    begin
        if not pSalesInvoiceToImport.Header then
            exit;

        if pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::ERROR then
            exit;

        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetCurrentKey("Entry No.", "Primula Posting No.", "Document No.", "VAT Progressive No.");
        SalesInvoiceToImport.SetFilter("Entry No.", '<>%1', pSalesInvoiceToImport."Entry No.");
        SalesInvoiceToImport.SetRange("Primula Posting No.", pSalesInvoiceToImport."Primula Posting No.");
        SalesInvoiceToImport.SetRange("Document No.", pSalesInvoiceToImport."Document No.");
        SalesInvoiceToImport.SetRange("VAT Progressive No.", pSalesInvoiceToImport."VAT Progressive No.");
        SalesInvoiceToImport.SetRange(Header, false);
        if SalesInvoiceToImport.FindSet() then
            repeat
                if (pSalesInvoiceToImport."Action Type" in [pSalesInvoiceToImport."Action Type"::CHECK, pSalesInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX"]) and (SalesInvoiceToImport."Action Type" <> SalesInvoiceToImport."Action Type"::ERROR) then
                    continue;

                if pSalesInvoiceToImport."Action Type" in [pSalesInvoiceToImport."Action Type"::" ", pSalesInvoiceToImport."Action Type"::CREATE] then begin
                    pSalesInvoiceToImport."Action Type" := SalesInvoiceToImport."Action Type";

                    if pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::ERROR then
                        pSalesInvoiceToImport."Error Message" := ErrTxt001;

                    if pSalesInvoiceToImport."Action Type" in [pSalesInvoiceToImport."Action Type"::CHECK, pSalesInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX"] then
                        pSalesInvoiceToImport."Error Message" := ErrTxt002;

                    pSalesInvoiceToImport.Modify(true);
                end;
            until SalesInvoiceToImport.Next() = 0;
    end;

    procedure PropagateSalesHeaderImportInfoToLines(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
    begin
        if not pSalesInvoiceToImport.Header then
            exit;

        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetCurrentKey("Entry No.", "Primula Posting No.", "Document No.", "VAT Progressive No.");
        SalesInvoiceToImport.SetFilter("Entry No.", '<>%1', pSalesInvoiceToImport."Entry No.");
        SalesInvoiceToImport.SetRange("Primula Posting No.", pSalesInvoiceToImport."Primula Posting No.");
        SalesInvoiceToImport.SetRange("Document No.", pSalesInvoiceToImport."Document No.");
        SalesInvoiceToImport.SetRange("VAT Progressive No.", pSalesInvoiceToImport."VAT Progressive No.");
        if SalesInvoiceToImport.FindSet() then
            repeat
                SalesInvoiceToImport."BC Document Created" := pSalesInvoiceToImport."BC Document Created";

                if SalesInvoiceToImport."Action Type" = SalesInvoiceToImport."Action Type"::CHECK then begin
                    if pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::ERROR then
                        SalesInvoiceToImport."Action Type" := pSalesInvoiceToImport."Action Type";
                end else
                    SalesInvoiceToImport."Action Type" := pSalesInvoiceToImport."Action Type";

                SalesInvoiceToImport."BC Document No." := pSalesInvoiceToImport."BC Document No.";
                SalesInvoiceToImport."BC Posted Document No." := pSalesInvoiceToImport."BC Posted Document No.";
                SalesInvoiceToImport.Modify(true);
            until SalesInvoiceToImport.Next() = 0;
    end;

    procedure RetrivePurchaseLineImportInfo(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        ErrTxt001: TextConst ENU = 'Lines in error', ITA = 'Righe in errore';
        ErrTxt002: TextConst ENU = 'Lines to check', ITA = 'Righe da controllare';
    begin
        if not pPurchaseInvoiceToImport.Header then
            exit;

        if pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::ERROR then
            exit;

        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.SetCurrentKey("Entry No.", "Document No.", "VAT Progressive No.");
        PurchaseInvoiceToImport.SetFilter("Entry No.", '<>%1', pPurchaseInvoiceToImport."Entry No.");
        PurchaseInvoiceToImport.SetRange("Document No.", pPurchaseInvoiceToImport."Document No.");
        PurchaseInvoiceToImport.SetRange("VAT Progressive No.", pPurchaseInvoiceToImport."VAT Progressive No.");
        PurchaseInvoiceToImport.SetRange(Header, false);
        if PurchaseInvoiceToImport.FindSet() then
            repeat
                if (pPurchaseInvoiceToImport."Action Type" in [pPurchaseInvoiceToImport."Action Type"::CHECK, pPurchaseInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX"]) and (PurchaseInvoiceToImport."Action Type" <> PurchaseInvoiceToImport."Action Type"::ERROR) then
                    continue;

                if pPurchaseInvoiceToImport."Action Type" in [pPurchaseInvoiceToImport."Action Type"::" ", pPurchaseInvoiceToImport."Action Type"::CREATE] then begin
                    pPurchaseInvoiceToImport."Action Type" := PurchaseInvoiceToImport."Action Type";

                    if pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::ERROR then
                        pPurchaseInvoiceToImport."Error Message" := ErrTxt001;

                    if pPurchaseInvoiceToImport."Action Type" in [pPurchaseInvoiceToImport."Action Type"::CHECK, pPurchaseInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX"] then
                        pPurchaseInvoiceToImport."Error Message" := ErrTxt002;

                    pPurchaseInvoiceToImport.Modify(true);
                end;
            until PurchaseInvoiceToImport.Next() = 0;
    end;

    procedure PropagatePurchaseHeaderImportInfoToLines(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
    begin
        if not pPurchaseInvoiceToImport.Header then
            exit;

        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.SetCurrentKey("Entry No.", "Document No.", "VAT Progressive No.");
        PurchaseInvoiceToImport.SetFilter("Entry No.", '<>%1', pPurchaseInvoiceToImport."Entry No.");
        PurchaseInvoiceToImport.SetRange("Document No.", pPurchaseInvoiceToImport."Document No.");
        PurchaseInvoiceToImport.SetRange("VAT Progressive No.", pPurchaseInvoiceToImport."VAT Progressive No.");
        if PurchaseInvoiceToImport.FindSet() then
            repeat
                PurchaseInvoiceToImport."BC Document Created" := pPurchaseInvoiceToImport."BC Document Created";

                if PurchaseInvoiceToImport."Action Type" = PurchaseInvoiceToImport."Action Type"::CHECK then begin
                    if pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::ERROR then
                        PurchaseInvoiceToImport."Action Type" := pPurchaseInvoiceToImport."Action Type";
                end else
                    PurchaseInvoiceToImport."Action Type" := pPurchaseInvoiceToImport."Action Type";

                PurchaseInvoiceToImport."BC Document No." := pPurchaseInvoiceToImport."BC Document No.";
                PurchaseInvoiceToImport."BC Posted Document No." := pPurchaseInvoiceToImport."BC Posted Document No.";
                PurchaseInvoiceToImport.Modify(true);
            until PurchaseInvoiceToImport.Next() = 0;
    end;

    #endregion IMPORT

    #region PROCESSING IMPORT

    procedure ProcessSalesInvoicesToImport(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        Window: Dialog;
        Txt001: TextConst ENU = 'Processing Primula Sales Invoices...\No. ###1########', ITA = 'Elaborazione Fatture di Vendita Primula...\Nr. ###1########';
    begin
        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetView(pSalesInvoiceToImport.GetView());
        if pSalesInvoiceToImport.MarkedOnly() then begin
            pSalesInvoiceToImport.FindSet();

            repeat
                SalesInvoiceToImport.Get(pSalesInvoiceToImport.RecordId);
                SalesInvoiceToImport.Mark(true);
            until pSalesInvoiceToImport.Next() = 0;

            SalesInvoiceToImport.MarkedOnly(true);
        end;

        SalesInvoiceToImport.SetRange(Header, true);
        SalesInvoiceToImport.SetRange("BC Document Created", false);
        SalesInvoiceToImport.SetFilter("Action Type", '%1|%2|%3', SalesInvoiceToImport."Action Type"::CREATE, SalesInvoiceToImport."Action Type"::CHECK, SalesInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX");
        if SalesInvoiceToImport.FindSet(true) then begin
            if GuiAllowed then
                Window.Open(Txt001);

            repeat
                if GuiAllowed then
                    Window.Update(1, Format(SalesInvoiceToImport."Document No."));

                ProcessSalesHeader(SalesInvoiceToImport);
                SalesInvoiceToImport.Modify(true);

                PropagateSalesHeaderImportInfoToLines(SalesInvoiceToImport);
            until SalesInvoiceToImport.Next() = 0;

            if GuiAllowed then
                Window.Close();
        end;

        CleanUpImportedSalesInvoices(pSalesInvoiceToImport);
    end;

    procedure CleanUpImportedSalesInvoices(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        Window: Dialog;
        Txt001: TextConst ENU = 'Cleaning up Primula Sales Invoices...\No. ###1########', ITA = 'Pulizia Fatture di Vendita Primula...\Nr. ###1########';
    begin
        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetView(pSalesInvoiceToImport.GetView());
        if pSalesInvoiceToImport.MarkedOnly() then begin
            pSalesInvoiceToImport.FindSet();

            repeat
                SalesInvoiceToImport.Get(pSalesInvoiceToImport.RecordId);
                SalesInvoiceToImport.Mark(true);
            until pSalesInvoiceToImport.Next() = 0;

            SalesInvoiceToImport.MarkedOnly(true);
        end;

        SalesInvoiceToImport.SetRange("BC Document Created", true);
        SalesInvoiceToImport.SetRange("Action Type", SalesInvoiceToImport."Action Type"::CREATE);
        if SalesInvoiceToImport.FindSet() then begin
            if GuiAllowed then
                Window.Open(Txt001);

            repeat
                if GuiAllowed then
                    Window.Update(1, Format(SalesInvoiceToImport."Document No."));

                SalesInvoiceToImport.Delete(true);
            until SalesInvoiceToImport.Next() = 0;

            if GuiAllowed then
                Window.Close();
        end;

        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetView(pSalesInvoiceToImport.GetView());
        if pSalesInvoiceToImport.MarkedOnly() then begin
            pSalesInvoiceToImport.FindSet();

            repeat
                SalesInvoiceToImport.Get(pSalesInvoiceToImport.RecordId);
                SalesInvoiceToImport.Mark(true);
            until pSalesInvoiceToImport.Next() = 0;

            SalesInvoiceToImport.MarkedOnly(true);
        end;

        SalesInvoiceToImport.SetFilter("Reason Code", '<>%1&<>%2', '201', '202');
        SalesInvoiceToImport.SetFilter("Action Type", '%1|%2', SalesInvoiceToImport."Action Type"::CREATE, SalesInvoiceToImport."Action Type"::EXISTENT);
        if SalesInvoiceToImport.FindSet() then begin
            if GuiAllowed then
                Window.Open(Txt001);

            repeat
                if GuiAllowed then
                    Window.Update(1, Format(SalesInvoiceToImport."Document No."));

                SalesInvoiceToImport.Delete(true);
            until SalesInvoiceToImport.Next() = 0;

            if GuiAllowed then
                Window.Close();
        end;
    end;

    local procedure ProcessSalesHeader(var pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
        SalesHeader: Record "Sales Header";
        SalesDocumentType: Enum "Sales Document Type";
        ReasonCode: Code[10];
    begin
        case pSalesInvoiceToImport."Reason Code" of
            '201':
                SalesDocumentType := SalesDocumentType::Invoice;

            '202':
                SalesDocumentType := SalesDocumentType::"Credit Memo";

            else
                exit;
        end;

        ReasonCode := '';
        if pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::CHECK then
            ReasonCode := GenerateCHECKReasonCode()
        else
            ReasonCode := pSalesInvoiceToImport.RetriveBCReasonCode();

        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesDocumentType);
        SalesHeader.Validate("Sell-to Customer No.", pSalesInvoiceToImport."BC Account No.");
        SalesHeader."Posting Date" := pSalesInvoiceToImport."Posting Date";
        SalesHeader.Validate("Reason Code", ReasonCode);
        SalesHeader.Validate("External Document No.", pSalesInvoiceToImport."VAT Progressive No.");
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.");
        SalesHeader."Document Date" := pSalesInvoiceToImport."Document Date";
        SalesHeader."Operation Occurred Date" := pSalesInvoiceToImport."Posting Date";
        SalesHeader."VAT Reporting Date" := pSalesInvoiceToImport."Posting Date";
        SalesHeader."Order Date" := pSalesInvoiceToImport."Posting Date";
        SalesHeader.Validate("Posting No.", pSalesInvoiceToImport.GenerateBCPostingNo());
        SalesHeader.Modify(true);

        ProcessSalesLines(pSalesInvoiceToImport, SalesHeader);

        pSalesInvoiceToImport."BC Document Created" := true;
        pSalesInvoiceToImport."BC Document No." := SalesHeader."No.";
    end;

    local procedure ProcessSalesLines(var pSalesInvoiceToImport: Record "Sales Invoice To Import"; var pSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceToImport: Record "Sales Invoice To Import";
        NewLineNo: Integer;
    begin
        SalesInvoiceToImport.Reset();
        SalesInvoiceToImport.SetCurrentKey("Entry No.", "Primula Posting No.", "Document No.", "VAT Progressive No.");
        SalesInvoiceToImport.SetRange("Primula Posting No.", pSalesInvoiceToImport."Primula Posting No.");
        SalesInvoiceToImport.SetRange("Document No.", pSalesInvoiceToImport."Document No.");
        SalesInvoiceToImport.SetRange("VAT Progressive No.", pSalesInvoiceToImport."VAT Progressive No.");
        SalesInvoiceToImport.SetRange(Header, false);
        SalesInvoiceToImport.SetFilter("Action Type", '%1|%2|%3', SalesInvoiceToImport."Action Type"::CREATE, SalesInvoiceToImport."Action Type"::CHECK, SalesInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX");
        SalesInvoiceToImport.SetFilter("Primula Account No.", '<>%1&<>%2', '0206002', '0206001');
        if SalesInvoiceToImport.FindSet() then
            repeat
                NewLineNo += 10000;

                Clear(SalesLine);
                SalesLine.Init();
                SalesLine.Validate("Document Type", pSalesHeader."Document Type");
                SalesLine.Validate("Document No.", pSalesHeader."No.");
                SalesLine."Line No." := NewLineNo;
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                SalesLine.Validate("No.", SalesInvoiceToImport."BC Account No.");
                if SalesInvoiceToImport."BC Account Dimension" <> '' then
                    SalesLine.Validate("Shortcut Dimension 1 Code", SalesInvoiceToImport."BC Account Dimension");

                SalesLine.Validate(Quantity, 1);
                SalesLine.Validate("Unit Price", SalesInvoiceToImport.Amount);
                SalesLine.Insert(true);

                AddCommentToSalesHeader(pSalesHeader, SalesInvoiceToImport);
            until SalesInvoiceToImport.Next() = 0;

        SalesInvoiceToImport.SetFilter("Primula Account No.", '0206002|0206001');
        if SalesInvoiceToImport.Count = 1 then begin
            SalesInvoiceToImport.FindFirst();

            SalesLine.Reset();
            SalesLine.SetRange("Document Type", pSalesHeader."Document Type");
            SalesLine.SetRange("Document No.", pSalesHeader."No.");
            if SalesLine.FindSet() then
                repeat
                    SalesLine.Validate("VAT Prod. Posting Group", SalesInvoiceToImport."VAT Code");
                    SalesLine.Modify(true);
                until SalesLine.Next() = 0;

            if pSalesInvoiceToImport."Action Type" = pSalesInvoiceToImport."Action Type"::CHECK then
                pSalesInvoiceToImport."Action Type" := pSalesInvoiceToImport."Action Type"::CREATE;

            pSalesHeader.Validate("Reason Code", pSalesInvoiceToImport.RetriveBCReasonCode());
            pSalesHeader.Modify(true);
        end;
    end;

    procedure ProcessPurchaseInvoicesToImport(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        Window: Dialog;
        Txt001: TextConst ENU = 'Processing Primula Purchase Invoices...\No. ###1########', ITA = 'Elaborazione Fatture di Acquisto Primula...\Nr. ###1########';
    begin
        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.SetView(pPurchaseInvoiceToImport.GetView());
        if pPurchaseInvoiceToImport.MarkedOnly() then begin
            pPurchaseInvoiceToImport.FindSet();

            repeat
                PurchaseInvoiceToImport.Get(pPurchaseInvoiceToImport.RecordId);
                PurchaseInvoiceToImport.Mark(true);
            until pPurchaseInvoiceToImport.Next() = 0;

            PurchaseInvoiceToImport.MarkedOnly(true);
        end;

        PurchaseInvoiceToImport.SetRange(Header, true);
        PurchaseInvoiceToImport.SetRange("BC Document Created", false);
        PurchaseInvoiceToImport.SetFilter("Action Type", '%1|%2|%3', PurchaseInvoiceToImport."Action Type"::CREATE, PurchaseInvoiceToImport."Action Type"::CHECK, PurchaseInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX");
        if PurchaseInvoiceToImport.FindSet(true) then begin
            if GuiAllowed then
                Window.Open(Txt001);

            repeat
                if GuiAllowed then
                    Window.Update(1, Format(PurchaseInvoiceToImport."Document No."));

                ProcessPurchaseHeader(PurchaseInvoiceToImport);
                PurchaseInvoiceToImport.Modify(true);

                PropagatePurchaseHeaderImportInfoToLines(PurchaseInvoiceToImport);
            until PurchaseInvoiceToImport.Next() = 0;

            if GuiAllowed then
                Window.Close();
        end;

        CleanUpImportedPurchaseInvoices(pPurchaseInvoiceToImport);
    end;

    procedure CleanUpImportedPurchaseInvoices(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        Window: Dialog;
        Txt001: TextConst ENU = 'Cleaning up Primula Purchase Invoices...\No. ###1########', ITA = 'Pulizia Fatture di Acquisto Primula...\Nr. ###1########';
    begin
        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.SetView(pPurchaseInvoiceToImport.GetView());
        if pPurchaseInvoiceToImport.MarkedOnly() then begin
            pPurchaseInvoiceToImport.FindSet();

            repeat
                PurchaseInvoiceToImport.Get(pPurchaseInvoiceToImport.RecordId);
                PurchaseInvoiceToImport.Mark(true);
            until pPurchaseInvoiceToImport.Next() = 0;

            PurchaseInvoiceToImport.MarkedOnly(true);
        end;

        PurchaseInvoiceToImport.SetRange("BC Document Created", true);
        PurchaseInvoiceToImport.SetRange("Action Type", PurchaseInvoiceToImport."Action Type"::CREATE);
        if PurchaseInvoiceToImport.FindSet() then begin
            if GuiAllowed then
                Window.Open(Txt001);

            repeat
                if GuiAllowed then
                    Window.Update(1, Format(PurchaseInvoiceToImport."Document No."));

                PurchaseInvoiceToImport.Delete(true);
            until PurchaseInvoiceToImport.Next() = 0;

            if GuiAllowed then
                Window.Close();
        end;

        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.SetView(pPurchaseInvoiceToImport.GetView());
        if pPurchaseInvoiceToImport.MarkedOnly() then begin
            pPurchaseInvoiceToImport.FindSet();

            repeat
                PurchaseInvoiceToImport.Get(pPurchaseInvoiceToImport.RecordId);
                PurchaseInvoiceToImport.Mark(true);
            until pPurchaseInvoiceToImport.Next() = 0;

            PurchaseInvoiceToImport.MarkedOnly(true);
        end;

        PurchaseInvoiceToImport.SetFilter("Reason Code", '<>%1&<>%2', '201', '202');
        PurchaseInvoiceToImport.SetFilter("Action Type", '%1|%2', PurchaseInvoiceToImport."Action Type"::CREATE, PurchaseInvoiceToImport."Action Type"::EXISTENT);
        if PurchaseInvoiceToImport.FindSet() then begin
            if GuiAllowed then
                Window.Open(Txt001);

            repeat
                if GuiAllowed then
                    Window.Update(1, Format(PurchaseInvoiceToImport."Document No."));

                PurchaseInvoiceToImport.Delete(true);
            until PurchaseInvoiceToImport.Next() = 0;

            if GuiAllowed then
                Window.Close();
        end;
    end;

    local procedure ProcessPurchaseHeader(var pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseDocumentType: Enum "Purchase Document Type";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        ReasonCode: Code[10];
    begin
        case pPurchaseInvoiceToImport."Reason Code" of
            '301', '305', '307', '310', '385', '386', '387':
                PurchaseDocumentType := PurchaseDocumentType::Invoice;

            '302', '306', '308', '311', '382', '381', '383':
                PurchaseDocumentType := PurchaseDocumentType::"Credit Memo";

            else
                exit;
        end;

        ReasonCode := '';
        if pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::CHECK then
            ReasonCode := GenerateCHECKReasonCode()
        else
            ReasonCode := pPurchaseInvoiceToImport.RetriveBCReasonCode();

        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseDocumentType);
        PurchaseHeader.Validate("Buy-from Vendor No.", pPurchaseInvoiceToImport."BC Account No.");
        PurchaseHeader."Posting Date" := pPurchaseInvoiceToImport."Posting Date";
        PurchaseHeader.Validate("Reason Code", ReasonCode);

        if PurchaseDocumentType = PurchaseDocumentType::Invoice then
            PurchaseHeader.Validate("Vendor Invoice No.", pPurchaseInvoiceToImport."Document No.")
        else
            if PurchaseDocumentType = PurchaseDocumentType::"Credit Memo" then
                PurchaseHeader.Validate("Vendor Cr. Memo No.", pPurchaseInvoiceToImport."Document No.");

        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.");

        if pPurchaseInvoiceToImport."Reason Code" in ['307', '311', '383', '387'] then begin
            VATBusinessPostingGroup.Reset();
            VATBusinessPostingGroup.Get(PurchaseHeader."VAT Bus. Posting Group");

            PurchaseHeader.Validate("Operation Type", VATBusinessPostingGroup."Default P. Reverse Oper. Type");
        end;

        PurchaseHeader."Document Date" := pPurchaseInvoiceToImport."Document Date";
        PurchaseHeader."Order Date" := pPurchaseInvoiceToImport."Posting Date";
        PurchaseHeader."Operation Occurred Date" := pPurchaseInvoiceToImport."Posting Date";
        PurchaseHeader."VAT Reporting Date" := pPurchaseInvoiceToImport."Posting Date";
        PurchaseHeader.Validate("Posting No.", pPurchaseInvoiceToImport.GenerateBCPostingNo());
        PurchaseHeader.Validate("Check Total", pPurchaseInvoiceToImport.Amount);
        PurchaseHeader.Modify(true);

        ProcessPurchaseLines(pPurchaseInvoiceToImport, PurchaseHeader);

        pPurchaseInvoiceToImport."BC Document Created" := true;
        pPurchaseInvoiceToImport."BC Document No." := PurchaseHeader."No.";
    end;

    local procedure ProcessPurchaseLines(pPurchaseInvoiceToImport: Record "Purchase Invoice To Import"; var pPurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceToImport: Record "Purchase Invoice To Import";
        NewLineNo: Integer;
    begin
        PurchaseInvoiceToImport.Reset();
        PurchaseInvoiceToImport.SetCurrentKey("Entry No.", "Document No.", "VAT Progressive No.");
        PurchaseInvoiceToImport.SetRange("Document No.", pPurchaseInvoiceToImport."Document No.");
        PurchaseInvoiceToImport.SetRange("VAT Progressive No.", pPurchaseInvoiceToImport."VAT Progressive No.");
        PurchaseInvoiceToImport.SetRange(Header, false);
        PurchaseInvoiceToImport.SetFilter("Action Type", '%1|%2|%3', PurchaseInvoiceToImport."Action Type"::CREATE, PurchaseInvoiceToImport."Action Type"::CHECK, PurchaseInvoiceToImport."Action Type"::"CHECK WITHOLDING TAX");
        PurchaseInvoiceToImport.SetFilter("Primula Account No.", '<>%1&<>%2', '0206002', '0206001');
        if PurchaseInvoiceToImport.FindSet() then
            repeat
                NewLineNo += 10000;

                Clear(PurchaseLine);
                PurchaseLine.Init();
                PurchaseLine.Validate("Document Type", pPurchaseHeader."Document Type");
                PurchaseLine.Validate("Document No.", pPurchaseHeader."No.");
                PurchaseLine."Line No." := NewLineNo;
                PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
                PurchaseLine.Validate("No.", PurchaseInvoiceToImport."BC Account No.");
                if PurchaseInvoiceToImport."BC Account Dimension" <> '' then
                    PurchaseLine.Validate("Shortcut Dimension 1 Code", PurchaseInvoiceToImport."BC Account Dimension");

                PurchaseLine.Validate(Quantity, 1);
                PurchaseLine.Validate("Direct Unit Cost", PurchaseInvoiceToImport.Amount);
                PurchaseLine.Insert(true);

                AddCommentToPurchaseHeader(pPurchaseHeader, PurchaseInvoiceToImport);
            until PurchaseInvoiceToImport.Next() = 0;

        PurchaseInvoiceToImport.SetFilter("Primula Account No.", '0206002|0206001');
        if PurchaseInvoiceToImport.Count = 1 then begin
            PurchaseInvoiceToImport.FindFirst();

            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", pPurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", pPurchaseHeader."No.");
            if PurchaseLine.FindSet() then
                repeat
                    PurchaseLine.Validate("VAT Prod. Posting Group", PurchaseInvoiceToImport."VAT Code");
                    PurchaseLine.Modify(true);
                until PurchaseLine.Next() = 0;

            if pPurchaseInvoiceToImport."Action Type" = pPurchaseInvoiceToImport."Action Type"::CHECK then
                pPurchaseInvoiceToImport."Action Type" := pPurchaseInvoiceToImport."Action Type"::CREATE;

            pPurchaseHeader.Validate("Reason Code", pPurchaseInvoiceToImport.RetriveBCReasonCode());
            pPurchaseHeader.Modify(true);
        end;
    end;

    local procedure GenerateCHECKReasonCode(): Code[10]
    var
        ReasonCode: Record "Reason Code";
    begin
        ReasonCode.Reset();
        if not ReasonCode.Get(gReasonCodeForCHECK) then begin
            ReasonCode.Init();
            ReasonCode.Code := gReasonCodeForCHECK;
            ReasonCode.Description := gReaasonCodeDescriptionForCHECK;
            ReasonCode.Insert(true);
        end;

        exit(ReasonCode.Code);
    end;

    local procedure AddCommentToSalesHeader(var pSalesHeader: Record "Sales Header"; pSalesInvoiceToImport: Record "Sales Invoice To Import")
    var
    begin
        pSalesHeader."Posting Description" := CopyStr(StrSubstNo('%1 %2', pSalesHeader."Posting Date", pSalesInvoiceToImport."Additional Description"), 1, MaxStrLen(pSalesHeader."Posting Description"));
    end;

    local procedure AddCommentToPurchaseHeader(pPurchaseHeader: Record "Purchase Header"; pPurchaseInvoiceToImport: Record "Purchase Invoice To Import")
    var
    begin
        pPurchaseHeader."Posting Description" := CopyStr(StrSubstNo('%1 %2', pPurchaseHeader."Posting Date", pPurchaseInvoiceToImport."Additional Description"), 1, MaxStrLen(pPurchaseHeader."Posting Description"));
    end;

    #endregion PROCESSING IMPORT

    #endregion EXTERNALS
}
