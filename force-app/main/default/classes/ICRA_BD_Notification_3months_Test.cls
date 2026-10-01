@isTest
public  with sharing class ICRA_BD_Notification_3months_Test {
    @isTest
    public static void BD_Notificatio_3months(){
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Testing');
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', branchRecord.Id);
        insert accountRecord;
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'New Business', accountRecord.Id); 
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh'; 
        opportunityRecord.Defer_Billing_or_Exit_Case__c = 'Yes';
        opportunityRecord.CloseDate = System.today();
        opportunityRecord.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord; 
        
        Opportunity opportunityRecord1 = ICRA_TestDataFactory.creatOpportunity('Testing Opportunity2', 'Surveillance', accountRecord.Id);
        opportunityRecord1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord1.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord1.CloseDate = System.today();
        opportunityRecord1.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord1;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');       
        
        
        Test.startTest();
        ICRA_BD_Notification_Before3months bd3months = new ICRA_BD_Notification_Before3months();
        ICRA_BD_Notification_Before3months.EmailNotification emailWrapper = new ICRA_BD_Notification_Before3months.EmailNotification();
        // bd3months.setEmailBody(recordOwner)  = opportunityRecord.Owner.Name;
        database.executeBatch(bd3months);
        Test.stopTest(); 
    }
    
}