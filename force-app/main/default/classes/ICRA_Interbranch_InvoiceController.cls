public with sharing class ICRA_Interbranch_InvoiceController {
    public InvoicePage invoicePage{get;set;}
    public AggregateResult[] aggregateAmount {get;set;}
    public static Boolean isError{get;set;}
    public ICRA_Interbranch_InvoiceController(ApexPages.StandardController controller){
        isError = false;
        invoicePage = new InvoicePage();
        Manual_Invoice__c invoice = new Manual_Invoice__c();
        List<Manual_Invoice_Line_Item__c> invoiceLineList = new List<Manual_Invoice_Line_Item__c>();
        integer TodaysAmount = 0;
        System.debug(+TodaysAmount+'Today');
        try {
            String invoiceId = ''+ApexPages.currentPage().getParameters().get('id');
            if(invoiceId != 'null' || invoiceId != '' || invoiceId != null ){
                invoice = [ SELECT Amount__c,Bill_No_InterBranch__c, RecordType.Name,
                           Destination_Branch__r.City__c,Source_Branch_1__r.City__c,Source_Branch_1__r.State__c,
                           Destination_Branch__r.State__c,Source_Branch_1__r.Country__c,Destination_Branch__r.Country__c,
                           Source_Branch_1__r.Street__c,Destination_Branch__r.Street__c, Created_Date__c, Bill_No_InterBranch1__c,
                           Description_of_Service__c, Email__c, IRN_Number__c, Invoice_Date__c, Name,IGST_1__c,
                           Location_of_Supplier__c,Location_of_Destination__c,
                           Destination_Branch__r.State_Code__c,Source_Branch_1__r.State_Code__c,
                           Particulars__c, Phone__c, Pincode__c, QR_Code__c, Id,CGST_Amount__c,SGST_UTGST__c,
                           Tax_subject_to_reverse_charge__c, Total_Invoice_Amount__c,
                           Source_Branch_1__r.Telephone__c,Destination_Branch__r.Telephone__c,
                           Destination_Branch__r.Zip_Postal_Code__c,Source_Branch_1__r.Zip_Postal_Code__c,
                           Destination_Branch__r.GSTIN__c, Source_Branch_1__r.GSTIN__c,Source_Branch_1__r.PAN__c,
                           Source_Branch_1__r.Authorized_Signatory__r.Designation__c,
                           Source_Branch_1__r.Authorized_Signatory__r.Email,Destination_Branch__r.Authorized_Signatory__r.Email,
                           Rate__c,Total_Amount__c,Rate_1__c,Service_Code__c,Invoice_Created_Date__c,
                           Destination_Branch__r.Authorized_Signatory__r.Name,Source_Branch_1__r.Authorized_Signatory__r.Name,
                           CurrencyIsoCode,SAC_HSN__c,Invoice_status__c,CGST_Amount_on_Invoice_InterBranch__c,CGST_Amount_Received_InterBranch__c,CGST_Balance_Amount_InterBranch__c,CGST_Rate_for_Amount_Recd_InterBranch__c,
                           CGST_Rate_for_Invoice_Amount_InterBranch__c,IGST_Amount_on_Invoice_InterBranch__c,IGST_Amount_Received_InterBranch__c,IGST_Balance_Amount_InterBranch__c,IGST_Rate_for_Amount_ReceivedInterBranch__c,
                           IGST_Rate_for_Invoice_Amount_InterBranch__c,SGST_Amount_on_Invoice_InterBranch__c,SGST_Amount_Received_InterBranch__c,SGST_Balance_Amount_InterBranch__c,SGST_Rate_for_Amount_Recd_InterBranch__c,SGST_UTGST_Rate_on_invoice_InterBranch__c,
                           Balance_Amount_InterBranch__c,Total_Invoice_Amount_InterBranch__c,Total_Amount_Received_InterBranch__c,Total_Balance_Amount_InterBranch__c,Base_Amount_Received_Inter_Branch__c
                           
                           FROM Manual_Invoice__c WHERE iD=:invoiceId
                           LIMIT 1
                          ];
            }
            Invoice_Footer_Setting__c invoiceFooter = [
                SELECT CIN__c, HelpDesk__c, Registered_Office__c, Telephone__c, Website__c, Email__c
                FROM Invoice_Footer_Setting__c
                LIMIT 1
            ];
            for(Manual_Invoice_Static_Text__c staticText : [SELECT Invoice_Type__c,Description__c,Service_Code__c FROM Manual_Invoice_Static_Text__c]){
             invoicePage.manualInvoiceStaticTextMap.put(staticText.Invoice_Type__c,staticText);     
            }
            invoicePage.invoiceRecord = invoice;
            invoicePage.invoiceFooter = invoiceFooter;
            
            
        }
        catch (Exception ex) {
            isError = true;
            System.debug('==== Exception ===='+ex);
        }
    }
    public PageReference savePDF( ) 
    {
        DateTime todaysDate = System.today();
        String todayDate = todaysDate.format('yyyy-MM-dd');
        String parentId = ApexPages.currentPage().getParameters().get('id');
        String fileName = '';
        if(parentId != null && parentId != '' && parentId != 'null'){
        PageReference pdf = new PageReference('/apex/ICRA_InterBranch_Invoice?id='+parentId);
        
        
        Manual_Invoice__c invoiceRecord = [
            SELECT Id , Name, RecordType.Name, Bill_No_InterBranch__c
            FROM Manual_Invoice__c
            WHERE Id =: parentId
            LIMIT 1
        ]; 
            fileName = invoiceRecord.Bill_No_InterBranch__c;
            
         ContentVersion contentVersionRecord = new ContentVersion();
            contentVersionRecord.ContentLocation = 'S';
            contentVersionRecord.PathOnClient =  fileName+todayDate+'.pdf';
            contentVersionRecord.Title = fileName+'-'+todayDate;

            Blob body;
            try { 
                body = pdf.getContent();

            } catch (VisualforceException e) {
                body = Blob.valueOf('Error While Genrating file');
            }

            contentVersionRecord.VersionData =  body;

            insert contentVersionRecord;

            Id contentVersionID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionRecord.Id].ContentDocumentId;

            ContentDocumentLink contentDocument = new ContentDocumentLink();
            contentDocument.ContentDocumentId = contentVersionID;
            contentDocument.LinkedEntityId = parentId;
            contentDocument.ShareType = 'V';  
            contentDocument.Visibility = 'AllUsers';
            
            insert contentDocument;

        
        
        
        
        
        }
        return new PageReference('/apex/ICRA_InterBranch_Invoice?id='+parentId);
    }
    

    
    public class InvoicePage{
        
        public Manual_Invoice__c invoiceRecord {get;set;}
        public Invoice_Footer_Setting__c invoiceFooter {get;set;}
        public Map<String,Manual_Invoice_Static_Text__c> manualInvoiceStaticTextMap{get;set;}	
        public Boolean nextPgae{get;set;}
        
        public InvoicePage(){
            invoiceRecord = new Manual_Invoice__c();
            invoiceFooter = new Invoice_Footer_Setting__c();
            manualInvoiceStaticTextMap = new Map<String,Manual_Invoice_Static_Text__c>();
            nextPgae=false;
        }
    }
    
}