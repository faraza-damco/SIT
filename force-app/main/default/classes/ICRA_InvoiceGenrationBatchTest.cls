@isTest
public with sharing class ICRA_InvoiceGenrationBatchTest {
    @isTest
    public static void InvoiceGenrationBatchTest() {

        List<Opportunity>optylist=new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        insert accountReccord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'New Business', accountReccord.Id);
        opportunityRecord.Invoice_Generation_Date__c = system.today().addDays(-5);
        opportunityRecord.Total_Invoice_Amount_1__c = 0;
        opportunityRecord.Defer_Billing_or_Exit_Case__c = 'Yes';
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh'; 
        optylist.add(opportunityRecord);
        insert optylist;
        
         Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,null);

        
        Test.startTest();
        ICRA_InvoiceGenrationBatch testbatch = new ICRA_InvoiceGenrationBatch();
        Database.executeBatch(testbatch);
        Test.stopTest();
    }
}