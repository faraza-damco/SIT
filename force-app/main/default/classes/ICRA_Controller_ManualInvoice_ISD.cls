public class ICRA_Controller_ManualInvoice_ISD {
     public InvoicePage invoicePage{get;set;}

    // Check error on page
    public static Boolean isError{get;set;}

    public ICRA_Controller_ManualInvoice_ISD( ApexPages.StandardController controller){

        isError = false;
        invoicePage = new InvoicePage();
        Manual_Invoice__c manualInvoice = new Manual_Invoice__c(); 
       // List<Manual_Invoice_Line_Item__c> invoiceLineList = new List<Manual_Invoice_Line_Item__c>();

        try {           
       
            //get the current id of Invocie record.
            String manualInvoiceId = ''+ApexPages.currentPage().getParameters().get('id'); 

            // Check the invoice recordID is null or not.
            if(manualInvoiceId != 'null' && manualInvoiceId != '' && manualInvoiceId != null ){

                // SOQL query on invoice object where invoice recordId is equal to current record Id. 
                manualInvoice = [
                  
                    SELECT Account_ID__c, Address__c, Bill_No__c, CreatedDate, Created_Date__c, Customer_GSTIN__c, Customer_Name__c, Customer_PAN__c,
                    Customer_State__c, Customer_State_Code__c, Description_of_Service__c, IRN_Number__c, Invoice_Date__c, Invoice_Status__c, Location_of_Supplier__c, 
                    Particulars__c, Phone__c, Pincode__c, QR_Code__c, RecordType.Name, RecordType.DeveloperName, SAC_HSN__c, Service_Code_Formula__c, 
                    Supplier_GSTIN__c, Supplier_PAN__c, Supplier_State__c, Supplier_State_Code__c, Total_Advance_Taxable_Amount__c, Total_Base_Amount_Received__c, 
                    Total_CGST_Amount_Received__c, Total_CGST_Invoice_Amount__c, Total_IGST_Amount_Received__c, Total_IGST_Invoice_Amount__c, Total_Invoice_Amount__c,
                    Total_Invoice_Taxable_Amount__c, Total_SGST_Invoice_Amount__c, Total_SGST_Received_Amount__c,CurrencyIsoCode, 
                    Account_Name__r.Name, Account_Name__r.Id,Account_Name__r.Customer_Number__c,Account_Name__r.CFO__r.Name,Account_Name__r.Branch__r.Street__c,
                    Account_Name__r.Branch__r.Name, Account_Name__r.Branch__r.City__c, Account_Name__r.Branch__r.Country__c, Account_Name__r.Branch__r.State__c, 
                    Account_Name__r.Branch__r.Telephone__c, Account_Name__r.Branch__r.Zip_Postal_Code__c, Account_Name__r.Branch__r.Authorized_Signatory__r.Designation__c, 
                    Account_Name__r.Branch__r.Authorized_Signatory__r.Email, Account_Name__r.Branch__r.Authorized_Signatory__r.Name,
                    Contact_Name__r.Name, Contact_Name__r.Billing_Contact__c, Contact_Name__r.Designation__c,
                    Contact_Designation__c ,Total_Balance_Invoice_Taxable_Amount__c,Total_SGST_Balance_Amount__c,Address_ISD__c,Total_CGST_Balance_Amount__c,
                    Total_IGST_Balance_Amount__c,Total_Balance_Amount__c,Source_Branch__c,Source_Branch_City__c,Source_Branch_State__c,Source_Branch_State_Code__c,Supplier_PAN_ISD__c,Supplier_GSTIN_ISD__c,Description_of_Service_ISD__c,SAC_HSN_ISD__c,CGST__c,SGST__c,IGST__c,Branch__c,Branch_GSTIN_ISD__c,Branch_State_ISD__c,Branch_State_Code_ISD__c,Account_Classification__c,Branch__r.Name,
                    Source_Branch_Street__c,Source_Branch_Zip_Postal_Code__c,Source_Branch_Country__c
                    
                    FROM Manual_Invoice__c
                    WHERE iD=:manualInvoiceId
                    LIMIT 1
                ];  
            }  

            /**
             * Invoice record is null or not.
             * If invoice is not null then query on invoice line item where invoice_no is equal to invoice record Id.
             */
           /* if(manualInvoice != null){
                invoiceLineList = [
                       SELECT Account_Classification__c, Amount_Payable__c, Balance_Taxable_Amount__c, Base_Amount_Received__c, 
                       CGST_Advance_Amount_Received__c, CGST_Amount_Balance__c, CGST_Amount_on_Invoice__c, CGST_Rate_for_Amount_Received__c,
                        CGST_Rate_for_Invoice_Amount__c, Comment__c, CreatedDate, CurrencyIsoCode, Financial_Year__c, GST_Rate__c,
                         Gross_Amount_Received__c, IGST_Advance_Amount_Received__c, IGST_Amount_Balance__c, IGST_Amount_on_Invoice__c, 
                         IGST_Rate_for_Amount_Received__c, IGST_Rate_for_Invoice_Amount__c, Instruments__c, Invoice_Amount__c, 
                         Invoice_Status__c, Invoice_Taxable_Amount__c, LastActivityDate, Narration_for_Invoice__c, No_of_Days__c, 
                         No_of_Months__c, Particulars_of_Service__c, Period_of_Rating_Fees_From_Date__c, Period_of_Rating_Fees_To_Date__c, 
                         Id, SGST_UTGST_Advance_Amount_Received__c, SGST_UTGST_Amount_Balance__c, SGST_UTGST_Amount_on_Invoice__c, 
                         SGST_UTGST_Rate_for_Amount_Received__c, SGST_UTGST_Rate_for_Invoice_Amount__c, Total_Amount_Balance__c,
                          Total_Amount_Invoiced__c, Total_Amount_Received__c, Total_Invoice_Amount__c, Total_Invoice_Amount_WF__c 
                        FROM Manual_Invoice_Line_Item__c
                        WHERE Invoice_No__c =: manualInvoice.Id
                        LIMIT 50000
                    ];
            } */

            /**
             * Bank Account Setting is custom setting the hold the current account details.
             */
            Bank_Account_Setting__c [] bankAccountList = [
            SELECT Name, Account_Name__c,Bank_Address__c, Bank_Name__c, Current_Account_No__c, RTGS_IFSC__c 
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
            if(manualInvoice != null){
                invoicePage.manualInvoiceRecord = manualInvoice;
                //invoicePage.manualInvoiceLineItemList = invoiceLineList;
                invoicePage.bankAccountDetails = bankAccountList;
                invoicePage.invoiceFooter = invoiceFooter;
                //if(invoiceLineList.size()>4){
                  //  invoicePage.nextPgae = true;
               // }
           
              
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


        //Check the parrentId is null or not 
        if(parentId != null && parentId != '' && parentId != 'null' ){

            //creat page refference of Invocie PDF to get the PDF.
            PageReference pdf = new PageReference('/apex/ICRA_ManualInvoice_ISD_pdf?id='+parentId);

            // Get Invocie record. (Get assigne the file name )
            Manual_Invoice__c manualInvoiceRecord = [
                SELECT Id , Name, RecordType.Name, Bill_No__c 
                FROM Manual_Invoice__c 
                WHERE Id =: parentId
                LIMIT 1
            ]; 

            //If invoice record type is Credite note then file name is equal to Credit note number else Bill number.
            if(manualInvoiceRecord.RecordType.Name == 'OPE' || manualInvoiceRecord.RecordType.Name == 'Other Services' || manualInvoiceRecord.RecordType.Name == 'ISD' ){
                fileName = manualInvoiceRecord.Bill_No__c;
            }else{
                System.debug('Error while getting the Manual Invoice Record');
            } 


            // Creat content Version record to store and insert the PDF.
            ContentVersion contentVersionRecord = new ContentVersion();
            contentVersionRecord.ContentLocation = 'S';
            contentVersionRecord.PathOnClient =  fileName+todayDate+'.pdf';
            contentVersionRecord.Title = fileName+'-'+todayDate;

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
        return new PageReference('/apex/ICRA_ManualInvoice_ISD_pdf?id='+parentId);        
    }

    //Wrapper class for pdf page
    public class InvoicePage{

        public Manual_Invoice__c manualInvoiceRecord  {get;set;}
       // public List<Manual_Invoice_Line_Item__c> manualInvoiceLineItemList {get;set;}   
        public List<Bank_Account_Setting__c> bankAccountDetails {get;set;}
        public Map<String,Invoice_Static_Text__c> invoiceStaticTextMap{get;set;}
        public Invoice_Footer_Setting__c invoiceFooter {get;set;}
        public Boolean nextPgae{get;set;}

        public InvoicePage(){
            manualInvoiceRecord = new Manual_Invoice__c();
           // manualInvoiceLineItemList = new List<Manual_Invoice_Line_Item__c>();
            bankAccountDetails = new List<Bank_Account_Setting__c>();
            invoiceStaticTextMap = new  Map<String,Invoice_Static_Text__c>();
            invoiceFooter = new Invoice_Footer_Setting__c();
            nextPgae=false;
        }
    }


}