@isTest
public with sharing class ICRA_dscSigningBatchTest {
@isTest
    public static void dscSigningBatchTest() {
        List<Invoice__c>invlist=new List<Invoice__c>();

        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branchRecord.Id);
        insert accountRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'New Business', accountRecord.Id);
         opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1);
        insert opportunityRecord;
        Invoice__c invoiceRecord1 = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'Proforma Invoice');
        Invoice__c invoiceRecord2 = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'QR-IRN-Generated');
        

        invlist.add(invoiceRecord1);
        invlist.add(invoiceRecord2);
        
        insert invlist;

        Test.startTest();
        ICRA_dscSigningBatch testbatch=new ICRA_dscSigningBatch();
        Database.executeBatch(testbatch);
        Test.stopTest();
    }
}