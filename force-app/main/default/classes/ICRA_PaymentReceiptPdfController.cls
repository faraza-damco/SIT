/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-26-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-04-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class ICRA_PaymentReceiptPdfController {
    
    public PaymentReceipt paymentReceiptPage{get;set;}
    public Boolean isError {get;set;}

    public ICRA_PaymentReceiptPdfController (ApexPages.StandardController controller){
        paymentReceiptPage = new PaymentReceipt();
        isError = false;

        try {            
       
            //Get current Record ID 
            String recordId = ''+ApexPages.currentPage().getParameters().get('id');

            if(recordId != 'null' && recordId != '' && recordId != null ){
                paymentReceiptPage.paymentReceiptRecord = [
                    SELECT Address__c, Base_Fee_Amount__c, CGST_Payable__c, Company_Name__c, Created_Date__c, Date_of_Cheque_DD__c, Date_of_Transfer_Receipt__c, 
                        Email_ID__c, Fee_Amount__c, Financial_Year__c, GST_No__c, Gross_Amount__c, IGST_Payable__c, IGST_Realisable__c, Is_Advance__c, 
                        Name_of_Drawee_Bank__c, Net_Amount__c, Opportunity__r.Account.Name, Payment_Method__c, PAN_No__c, Name, Phone_No__c, SGST_UTGST_Payable__c, 
                        SGST_UTGST_Realisable__c, TAN_No__c, Tax_at_source_deducted_by_client_TDS__c, Transaction_Reference_Number__c, Service_Code__c,
                        Opportunity__r.Account.Branch__r.Branch_Code__c, Opportunity__r.Account.Branch__r.Name, Opportunity__r.Account.Branch__r.City__c, 
                        Opportunity__r.Account.Branch__r.Country__c, Opportunity__r.Account.Branch__r.GSTIN__c, Opportunity__r.Account.Branch__r.PAN__c, 
                        Opportunity__r.Account.Branch__r.Id, Opportunity__r.Account.Branch__r.State__c, Opportunity__r.Account.Branch__r.State_Code__c, Opportunity__r.Narration_for_Invoice__c,
                        Opportunity__r.Account.Branch__r.Street__c, Opportunity__r.Account.Branch__r.Zip_Postal_Code__c, CurrencyIsoCode, Total_Taxable_Amount__c,
                        Opportunity__r.Account.Branch__r.Telephone__c , Opportunity__r.AccountId, Customer_State__c,Customer_State_Code__c,Customer_GSTIN__c,Receipt_No__c,
                        CGST_Rate__c, IGST_Rate__c, SGST_Rate__c, Opportunity__r.Account.Branch__r.Authorized_Signatory__r.Designation__c, Opportunity_Record_Type__c,
                        Opportunity__r.Account.Branch__r.Authorized_Signatory__r.Email, Opportunity__r.Account.Branch__r.Authorized_Signatory__r.Name,SAC_HSN__c, Receipt_Voucher_Number__c,
                   Opportunity__r.Instrument_type_4__c,Opportunity__r.Business_Segment__c,Opportunity__r.Recordtype.Name FROM Payment_Receipt__c 
                    WHERE id =: recordId
                    LIMIT 1
                ];
            }

            //if Account id is not equal to null then fetch the account related contact where billing contact is Yes (Recent created).
            if(paymentReceiptPage.paymentReceiptRecord.Opportunity__r.AccountId != null){
                
                paymentReceiptPage.contactRecord = [
                    SELECT Phone, Account.Id, Designation__c, Department, Name, Billing_Contact__c 
                    FROM Contact
                    WHERE  Account.Id =: paymentReceiptPage.paymentReceiptRecord.Opportunity__r.AccountId 
                        AND Billing_Contact__c ='Yes' 
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
            }


            /**
             * Bank Account Setting is custom setting the hold the current account details.
             */
            paymentReceiptPage.bankAccountDetails = [
                SELECT Bank_Address__c, Bank_Name__c, Current_Account_No__c, RTGS_IFSC__c 
                FROM Bank_Account_Setting__c
                LIMIT 2
            ];


            /**
             * Invoice Footer Setting is custom setting the hold the invoice footer details.
             */
            paymentReceiptPage.invoiceFooter = [
                SELECT CIN__c, HelpDesk__c, Registered_Office__c, Telephone__c, Website__c, Email__c
                FROM Invoice_Footer_Setting__c 
                LIMIT 1
            ];

            // if Payment or contact record is null then update the isEoor flag to show error on page 
            if(paymentReceiptPage.paymentReceiptRecord != null && paymentReceiptPage.contactRecord != null){
                isError =  false;
            }else{
                isError = true;
            }
        }catch (Exception ex) {
            isError = true;
            System.debug('========= Exception==========: '+ex);
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

        //Check the parrentId is null or not 
        if(parentId != null && parentId != '' && parentId != 'null' ){

            //creat page refference of Payment Receipt PDF to get the PDF.
            PageReference pdf = new PageReference('/apex/ICRA_PaymentReceipt_pdf?id='+parentId);
            
            // Get Payment Receipt record. (Get assigne the file name )
            Payment_Receipt__c PaymentReceipt = [
                SELECT Id , Name 
                FROM Payment_Receipt__c 
                WHERE Id =: parentId
                LIMIT 1
            ];  

            fileName =  PaymentReceipt.Name;

            // Creat content Version record to store and insert the PDF.
            ContentVersion contentVersionRecord = new ContentVersion();
            contentVersionRecord.ContentLocation = 'S';  
            contentVersionRecord.PathOnClient =  fileName+todayDate+'.pdf';
            contentVersionRecord.Title = fileName+'-'+todayDate ;


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
        return new PageReference('/apex/ICRA_PaymentReceipt_pdf?id='+parentId);        
    }

      

     //Wrapper class for pdf page
    public class PaymentReceipt{
       public Payment_Receipt__c  paymentReceiptRecord  {get;set;} 
       public List<Bank_Account_Setting__c> bankAccountDetails {get;set;} 
       public Contact contactRecord {get;set;}
       public Invoice_Footer_Setting__c invoiceFooter {get;set;}

       public PaymentReceipt(){
           paymentReceiptRecord = new Payment_Receipt__c();  
           bankAccountDetails = new List<Bank_Account_Setting__c>();    
           contactRecord = new Contact();      
           invoiceFooter = new Invoice_Footer_Setting__c();
       }       
    }   
}