/*
=====================================================================================================
>  Requirement          :  "Creating Controller for Record type Credit Note, Application-ICRA"

>  Developer Team       :   DAMCO_ICRA.
>  Developer Name       :   ABDUL MUQHEEM

>  Created Date         :   February 01, 2021
>  Completed Date       :   February 

>  Modified Date        :   -------
>  Modified By          :   -------
>  Modified Description :   -------
======================================================================================================
*/

public with sharing class ICRA_Controller_CreditNote 
{
    public InvPage invPage{get;set;}
    public ICRA_Controller_CreditNote(ApexPages.StandardController controller){
        invPage = new InvPage();
        Invoice__c Inv = new Invoice__c(); 
        String invoiceId = ''+ApexPages.currentPage().getParameters().get('id');
        
        
        Inv = [SELECT Id, Address__c, Amount__c, Bill_No__c, CGST_Amount_on_Credit_Note__c, CGST_Rate_for_Invoice_Amount__c, Contact_Designation__c, 
               Created_Date__c, Credit_Note__c, Credit_Note_Discount__c, Credit_Note_No__c, Credit_Note_Type__c, Opportunity_Name__r.Business_Segment__c,
               CurrencyIsoCode, Customer_GSTIN__c, Customer_Name__c, Customer_Pan__c, Customer_State__c, Customer_State_Code__c, Email__c, GST_Amount__c, 
               IGST_Amount_on_Credit_Note__c, IGST_Rate_for_Invoice_Amount__c, IRN_Number__c, Opportunity_Name__r.Account.Branch__r.Branch_Code__c,
               Opportunity_Name__r.Account.Branch__r.City__c, Opportunity_Name__r.Account.Branch__r.Country__c, Opportunity_Name__r.Account.Branch__r.CreatedDate, 
               Opportunity_Name__r.Account.Branch__r.CurrencyIsoCode, Opportunity_Name__r.Account.Branch__r.GSTIN__c, Opportunity_Name__r.Account.Branch__r.PAN__c, 
               Opportunity_Name__r.Account.Branch__r.State__c, Opportunity_Name__r.Account.Branch__r.Street__c, Opportunity_Name__r.Account.Branch__r.State_Code__c, Opportunity_Name__r.Narration_for_Invoice__c,
               Opportunity_Name__r.Account.Branch__r.Telephone__c, Opportunity_Name__r.Account.Branch__r.Zip_Postal_Code__c, SAC_HSN__c,Opportunity_Name__r.Instrument_Type_5__c,
               Opportunity_Name__r.Account.Branch__r.Authorized_Signatory__r.Name, Opportunity_Name__r.Account.Branch__r.Authorized_Signatory__r.Designation__c, Opportunity_Name__r.RecordType.Name,
               Opportunity_Name__r.Account.Branch__r.Authorized_Signatory__r.Email ,Location_of_Supplier__c, Supplier_State__c, Supplier_State_Code__c, Supplier_GSTIN__c,Description_of_Service__c, 
               Service_Code__c, Tax_subject_to_reverse_charge__c, Supplier_PAN__c, Invoice_Amount__c, Invoice_No__c, Invoice_Date__c, Instrument__c, Total_Invoice_Amount__c, Revised_agreed_amount__c, 
               Reason_for_Credit_Note__c,QR_Code__c, SGST_UTGST_Amount_on_Credit_Note__c, Total_Credit_Amount__c, Contact_Name__r.Name, Invoice_No__r.Bill_No__c, SGST_UTGST_Rate_for_Invoice_Amount__c,
               Opportunity_Name__r.Account.Customer_Number__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Street__c, Opportunity_Name__r.Opp_ICRA_Branch__r.City__c, Opportunity_Name__r.Opp_ICRA_Branch__r.State__c, 
               Opportunity_Name__r.Opp_ICRA_Branch__r.Zip_Postal_Code__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Country__c, Opportunity_Name__r.Opp_ICRA_Branch__c, Opportunity_Name__r.Instrument_type_4__c
               FROM Invoice__c
               WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        
        system.debug('Value of Credit Note Are'+Inv.Contact_Designation__c);
        system.debug('Value of Credit Note Are'+Inv.Contact_Name__r.Name);
        List<Bank_Account_Setting__c> bankAccountList = [
            SELECT Account_Name__c, Bank_Address__c, Bank_Name__c, Current_Account_No__c, RTGS_IFSC__c, RTGS_IFSC_Code__c 
            FROM Bank_Account_Setting__c
            LIMIT 2
        ];
        
        Invoice_Footer_Setting__c invoiceFooter = [
            SELECT CIN__c, HelpDesk__c, Registered_Office__c, Telephone__c, Website__c, Email__c
            FROM Invoice_Footer_Setting__c 
            LIMIT 1
        ]; 
        
        InvPage.invoiceFooter = invoiceFooter;
        InvPage.bankAccountDetails = bankAccountList;
        invPage.invRecord = Inv;
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
            PageReference pdf = new PageReference('/apex/ICRA_Creditnote_PDF?id='+parentId);
            
            // Get Invocie record. (Get assigne the file name )
            Invoice__c invoiceRecord = [
                SELECT Id , Name, RecordType.Name,Credit_Note_No__c, Bill_No__c, Opportunity_Name__r.Account.Name 
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
            } 
            
            // Creat content Version record to store and insert the PDF.
            ContentVersion contentVersionRecord = new ContentVersion();
            contentVersionRecord.ContentLocation = 'S';  
            contentVersionRecord.PathOnClient =  fileName+todayDate+'.pdf';
            contentVersionRecord.Title = fileName+'-'+clientName+'-'+todayDate ; 
            
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
        return new PageReference('/apex/ICRA_Creditnote_PDF?id='+parentId);        
    }
    
    
    public class InvPage
    {
        public Invoice__c invRecord  {get;set;}
        public List<Bank_Account_Setting__c> bankAccountDetails {get;set;}
        public Invoice_Footer_Setting__c invoiceFooter {get;set;}
        
        public InvPage(){
            invRecord = new Invoice__c();
            bankAccountDetails = new List<Bank_Account_Setting__c>();
            invoiceFooter = new Invoice_Footer_Setting__c();
        }
    }
}