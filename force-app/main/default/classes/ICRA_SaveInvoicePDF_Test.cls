@isTest
public class ICRA_SaveInvoicePDF_Test {
     @isTest
    public static void SaveInvoicePDF(){
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Test Accont', 'Issuer', branchRecord.Id); 
        insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'Surveillance', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord.CloseDate = System.today();
        //opportunityRecord.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord;
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'Proforma Invoice');
        insert invoiceRecord;
        
         Invoice__c invoiceRecord2  = ICRA_TestDataFactory.createInvoice('Credit Note',opportunityRecord.Id, invoiceRecord.Id,null);
         invoiceRecord2.Credit_Note_Type__c = 'Commercial';
         invoiceRecord2.Credit_Note_Created_Date__c = system.today();       
         insert invoiceRecord2;
        
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        Test.startTest();
        ICRA_SaveInvoicePDF.saveInvoice(invoiceRecord.Id);
        Database.executeBatch(new ICRA_SaveInvoicePDFBatch(),1);
        Test.stopTest();
    }
   
}