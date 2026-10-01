@isTest
public  with sharing class ICRA_ProformaInvoiceGenerationBatchTest {
    @isTest
    public static void ProformaInvoiceGenerationTest(){
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branchRecord.Id); 
        Insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Contact 1', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Oppotunnity', 'Surveillance', accountRecord.Id);
        opportunityRecord.Total_Invoice_Amount_1__c = 0;
        opportunityRecord.CloseDate =  System.today().addDays(-5); 
        opportunityRecord.Instrument_type_1__c = 'Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c = 'Asset Backed Security';
        opportunityRecord.Instrument_type_4__c = 'Assignee Payout';  
        opportunityRecord.Batch_is_Running__c = true;
        opportunityRecord.Commercial_Head__c = System.UserInfo.getUserId(); 
        opportunityRecord.BD_Approve__c = true;
        insert opportunityRecord;

        Test.startTest();
        ICRA_ProformaInvoiceGenrationBatch testbatch = new ICRA_ProformaInvoiceGenrationBatch();
        Database.executeBatch(testbatch);     
        Test.stopTest();   
    }  
}