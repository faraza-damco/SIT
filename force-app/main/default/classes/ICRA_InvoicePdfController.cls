/**
 * @description       : Class is used to genrate the invocie PDF and attached with invoice object.
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-18-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-31-2021   Ritesh Kumar                         Initial Version
 * 1.1   05-18-2021   Ritesh Kumar                         Added Field on Invocie SOQL (Opportunity_Name__r.Account.Customer_Number_New__c)
**/
public with sharing class ICRA_InvoicePdfController {
    
    //InvoicePage : Invoicepage is wrapper class that hold hold the information about invoice document
    public InvoicePage invoicePage{get;set;}

    // aggregateAmount hold the summarised inforamtion of invocie record. 
    public AggregateResult[] aggregateAmount {get;set;}

    // Check error on page
    public static Boolean isError{get;set;}

    public ICRA_InvoicePdfController(ApexPages.StandardController controller){

        isError = false;
        invoicePage = new InvoicePage();
        Invoice__c invoice = new Invoice__c(); 
        List<Invoice_Line_Item__c> invoiceLineList = new List<Invoice_Line_Item__c>();
        Integer TodaysAmount = 0;

        try {           
       
            //get the current id of Invocie record.
            String invoiceId = ''+ApexPages.currentPage().getParameters().get('id'); 

            // Check the invoice recordID is null or not.
            if(invoiceId != 'null' && invoiceId != '' && invoiceId != null ){

                // SOQL query on invoice object where invoice recordId is equal to current record Id. 
                invoice = [
                    SELECT Address__c, Amount__c, Bill_No__c,  Comments__c, RecordType.Name,Credit_Note_No__c,
                        Contact_Designation__c, Created_Date__c, Customer_GSTIN__c, Customer_Name__c, Customer_Pan__c, Customer_State__c, 
                        Description_of_Service__c, Email__c, IRN_Number__c, Instrument__c,  Invoice_Date__c, Name,  Location_of_Supplier__c, 
                        Opportunity_Name__r.RecordType.Name,Opportunity_Name__r.ASF_Final_Amount__c,Opportunity_Name__r.IRF_Final_Amount__c, 
                        Outstanding_Amount__c, Particulars__c, Phone__c, Pincode__c, QR_Code__c, Id, Service_Code__c, Status__c, Supplier_GSTIN__c, 
                        Supplier_PAN__c, Supplier_State__c, Supplier_State_Code__c, Tax_subject_to_reverse_charge__c, Total_Invoice_Amount__c,
                        Customer_State_Code__c,Contact_Name__r.Name,Contact_Name__r.Salutation,Opportunity_Name__r.Account.Branch__r.Name, Opportunity_Name__r.Subscription_Start_Date__c,
                        Opportunity_Name__r.Account.Branch__r.City__c, Opportunity_Name__r.Account.Branch__r.Country__c, Opportunity_Name__r.Subscription_End_Date__c,
                        Opportunity_Name__r.Account.Branch__r.State__c, Opportunity_Name__r.Account.Branch__r.Street__c, Opportunity_Name__r.Business_Segment__c,
                        Opportunity_Name__r.Account.Branch__r.Telephone__c, Opportunity_Name__r.Account.Branch__r.Zip_Postal_Code__c,
                        Opportunity_Name__r.Account.Branch__r.Authorized_Signatory__r.Designation__c, Opportunity_Name__r.Account.Branch__r.Authorized_Signatory__r.Email, 
                        Opportunity_Name__r.Account.Branch__r.Authorized_Signatory__r.Name,CurrencyIsoCode,SAC_HSN__c,Invoice_Status__c, Opportunity_Name__r.Account.Customer_Number__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Street__c, 
                        Opportunity_Name__r.Opp_ICRA_Branch__r.City__c, Opportunity_Name__r.Opp_ICRA_Branch__r.State__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Zip_Postal_Code__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Country__c, Opportunity_Name__r.Opp_ICRA_Branch__c,Opportunity_Name__r.Instrument_type_4__c, Account_Classification__c, Customer_Country__c
                    FROM Invoice__c
                    WHERE iD=:invoiceId
                    LIMIT 1
                ];  
            }  

            /**
             * Invoice record is null or not.
             * If invoice is not null then query on invoice line item where invoice_no is equal to invoice record Id.
             */
            if(invoice != null){
                invoiceLineList = [
                        SELECT Balance_Taxable_Amount__c, Taxable_Advance_Received_Amount__c, CGST_Amount_Balance__c, CGST_Rate_for_Invoice_Amount__c,
                            CGST_Amount_Recd_on_Invoice__c, CGST_Amount_on_Invoice__c, CGST_Rate_for_Amount_Recd__c, Comments__c, CreatedDate, GST_Rate__c, 
                            Gross_Amount_Received__c, IGST_Amount_Balance__c, IGST_Amount_Recd_on_Invoice__c, IGST_Amount_on_Invoice__c, Opportunity_Name__r.Instrument_Type_5__c,
                            IGST_Rate_for_Amount_Recd__c, Invoice_Amount__c, IGST_Rate_for_Invoice_Amount__c, Instruments__c, Name, Invoice_Taxable_Amount__c,
                            No_of_Days__c, Particulars_of_Service__c, Payable_Amount__c, Period_of_Rating_Fees_From_Date__c, Period_of_Rating_Fees_To_Date__c, Narration_for_Invoice__c,
                            Rated_Amount__c, Id, SGST_UTGST_Amount_Recd_on_Invoice__c, SGST_UTGST_Amount_Balance__c, SGST_UTGST_Amount_on_Invoice__c, Opportunity_Name__r.Subscription_Start_Date__c,
                            SGST_UTGST_Rate_for_Amount_Recd__c, SGST_UTGST_Rate_for_Invoice_Amount__c, Total_Amount_Balance__c, Total_Amount_for_Amount_Recd__c, 
                            Total_Amount_for_invoice_Amount__c, Total_Invoice_Amount_Copy__c ,CurrencyIsoCode ,Account_Classification__c,PR_Date__c,Opportunity_Name__r.Subscription_End_Date__c
                        FROM Invoice_Line_Item__c
                        WHERE Invoice_No__c =: invoice.Id
                        LIMIT 50000
                    ];
            } 

            /**
             * Bank Account Setting is custom setting the hold the current account details.
             */
            Bank_Account_Setting__c [] bankAccountList = [
            SELECT Name, Account_Name__c,Bank_Address__c, Bank_Name__c, Current_Account_No__c, RTGS_IFSC__c, RTGS_IFSC_Code__c
                FROM Bank_Account_Setting__c
                LIMIT 1
            ];

            /**
             * Invoice Footer Setting is custom setting the hold the invoice footer details.
             */
            Invoice_Footer_Setting__c invoiceFooter = [
                SELECT CIN__c, HelpDesk__c, Registered_Office__c, Telephone__c, Website__c, Email__c
                FROM Invoice_Footer_Setting__c 
                LIMIT 1
            ];    
            
            /**
             * Invoice Static Text is custom setting the hold the invoice static text description details.
             */        
            for (Invoice_Static_Text__c staticText : [SELECT Invoice_Type__c, Description_A__c, Description_B__c, Description_C__c FROM Invoice_Static_Text__c]) {
                invoicePage.invoiceStaticTextMap.put(staticText.Invoice_Type__c,staticText);
            }

            /**
             * Check invoice and invoice line item is null or not
             */
            if(invoice != null && (! invoiceLineList.isEmpty())){
                invoicePage.invoiceRecord = invoice;
                invoicePage.invoiceLineItemList = invoiceLineList;
                invoicePage.bankAccountDetails = bankAccountList;
                invoicePage.invoiceFooter = invoiceFooter;
                if(invoiceLineList.size()>4){
                    invoicePage.nextPgae = true;
                }
            aggregateAmount =[ 
                    SELECT  Invoice_No__c, SUM(Balance_Amounts_Taxable__c) BalanceAmount , 
                        SUM(Invoice_Taxable_Amount__c) InvoiceAmount, 
                        SUM(CGST_Amount_on_Invoice__c) CGSTInvoice, 
                        SUM(CGST_Amount_Recd_on_Invoice__c) CGSTRecdInvoice, 
                        SUM(CGST_Amount_Balance__c) CGSTBalance, 
                        SUM(SGST_UTGST_Amount_on_Invoice__c) SGSTInvoice, 
                        SUM(SGST_UTGST_Amount_Recd_on_Invoice__c) SGSTRecdInvoice, 
                        SUM(SGST_UTGST_Amount_Balance__c) SGSTAmountBalance, 
                        SUM(IGST_Amount_on_Invoice__c) IGSTAmountInvoice, 
                        SUM(IGST_Amount_Recd_on_Invoice__c) IGSTRecdInvoice, 
                        SUM(IGST_Amount_Balance__c) IGSTAmountBalance,
                        SUM(Total_Amount_for_Amount_Recd__c) TotalAmountAmountRecd, 
                        SUM(Total_Amount_Invoiced__c) TotalAmountinvoiceAmount, 
                        SUM(Total_Amount_Balance__c) TotalAmountBalance, 
                        SUM(Taxable_Advance_Received_Amount__c) AdvanceReceivedAmount, 
                        SUM(Amount_Payable__c) PayableAmount,
                        SUM(Gross_Amount_Received__c) amountReceived
                    FROM Invoice_Line_Item__c
                    WHERE Invoice_No__c =: invoice.Id
                    GROUP BY Invoice_No__c
                    LIMIT 1
                ];
              
            }else{
                isError = true;
            }
        }
        catch (Exception ex) {
            isError = true;
            System.debug('==== Exception ===='+ex);
        }   
    }

    /**
     * Method Name : SavePDF
     * Param : None
     * Description : Use to save the pdf file. (Attachetd the file to Invocie Object)
     * 
     */
    public PageReference  savePDF( ) {

        //Get the System current date
        DateTime todaysDate = System.today();
        String todayDate = todaysDate.format('yyyy-MM-dd');

        //Get the current record Id 
        String parentId = ApexPages.currentPage().getParameters().get('id');  
        String fileName = '';
        String clientName;

        //Check the parrentId is null or not 
        if(parentId != null && parentId != '' && parentId != 'null' ){

            //creat page refference of Invocie PDF to get the PDF.
            PageReference pdf = new PageReference('/apex/ICRA_Invoice_pdf?id='+parentId);

            // Get Invocie record. (Get assigne the file name )
            Invoice__c invoiceRecord = [
                SELECT Id , Name, RecordType.Name,Credit_Note_No__c, Bill_No__c, Opportunity_Name__r.Account.Name, Send_Confirmation_Email__c, Auto_Generated_Proforma_Invoice__c, Invoice_Status__c
                FROM Invoice__c 
                WHERE Id =: parentId
                LIMIT 1
            ]; 
            clientName= invoiceRecord.Opportunity_Name__r.Account.Name;
            //If invoice record type is Credite note then file name is equal to Credit note number else Bill number.
            if(invoiceRecord.RecordType.Name == 'Credit Note'){
                fileName = invoiceRecord.Credit_Note_No__c;
            }else{ 
                fileName =  invoiceRecord.Bill_No__c;
                if(!invoiceRecord.Send_Confirmation_Email__c && invoiceRecord.Auto_Generated_Proforma_Invoice__c == false && invoiceRecord.Invoice_Status__c == 'Proforma Invoice'){
                invoiceRecord.Send_Confirmation_Email__c = true;
                update invoiceRecord;
                }
            } 


            // Creat content Version record to store and insert the PDF.
            ContentVersion contentVersionRecord = new ContentVersion();
            contentVersionRecord.ContentLocation = 'S';
            contentVersionRecord.PathOnClient =  fileName+todayDate+'.pdf';
            contentVersionRecord.Title = fileName+'-'+clientName+'-'+todayDate;

            //Blod Hold the PDF file content (Binary)
            Blob body;
            try { 
                body = pdf.getContent();

            } catch (VisualforceException e) {
                body = Blob.valueOf('Error While Genrating file');
            }

            contentVersionRecord.VersionData =  body;

            // Insert the file
            insert contentVersionRecord;

            // Get the Information of currently inserted file (This is used to link the file with Invoice Object)
            Id contentVersionID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionRecord.Id].ContentDocumentId;

            //Creat refference to link the document (PDF file) to invoice object.
            ContentDocumentLink contentDocument = new ContentDocumentLink();
            // Document ID 
            contentDocument.ContentDocumentId = contentVersionID;
            //Record Id (Invoice Record id )
            contentDocument.LinkedEntityId = parentId;
            contentDocument.ShareType = 'V';  
            contentDocument.Visibility = 'AllUsers';
            
            //Link the file with related object 
            insert contentDocument;
        }

        //redirect to PDF file.
        return new PageReference('/apex/ICRA_Invoice_pdf?id='+parentId);        
    }

    //Wrapper class for pdf page
    public class InvoicePage{

        public Invoice__c invoiceRecord  {get;set;}
        public List<Invoice_Line_Item__c> invoiceLineItemList {get;set;}   
        public List<Bank_Account_Setting__c> bankAccountDetails {get;set;}
        public Map<String,Invoice_Static_Text__c> invoiceStaticTextMap{get;set;}
        public Invoice_Footer_Setting__c invoiceFooter {get;set;}
        public Boolean nextPgae{get;set;}

        public InvoicePage(){
            invoiceRecord = new Invoice__c();
            invoiceLineItemList = new List<Invoice_Line_Item__c>();
            bankAccountDetails = new List<Bank_Account_Setting__c>();
            invoiceStaticTextMap = new  Map<String,Invoice_Static_Text__c>();
            invoiceFooter = new Invoice_Footer_Setting__c();
            nextPgae=false;
        }
    }
}