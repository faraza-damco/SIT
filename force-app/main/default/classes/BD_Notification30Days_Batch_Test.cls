@isTest
public with sharing class BD_Notification30Days_Batch_Test {
    @isTest
    public static void isDataSetup(){
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        insert accountRecord;
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);
        opportunityRecord.CloseDate = System.today().addDays(30);
       
        insert opportunityRecord;
               // User tuser = TestFactory.createTestUser('','System Administrator','Name','Testing','Test Manager');
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        System.debug('Opportunity Record' +opportunityRecord);
        Test.startTest();
        BD_Notification_Batch_Execution_30Days bd30 = new BD_Notification_Batch_Execution_30Days();
        // EmailTemplate[] emailTemplate = new EmailTemplate[]();
        
        database.executeBatch(bd30);
        Test.stopTest(); 
    }
    //
    /* public static void BDNotification30DaysTest(){
Test.startTest();
BD_Notification_Batch_Execution_30Days bd30 = new BD_Notification_Batch_Execution_30Days();
// EmailTemplate[] emailTemplate = new EmailTemplate[]();

database.executeBatch(bd30);
Test.stopTest();
}*/
}