@isTest
public class CreateContactRole_Batch_Test {
    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String EMAILROLE = 'Email Recipient';
    private static final String CONEMAIL = 'testcontactrole@abc.com';
    private static final String ISSUER = 'Issuer';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String FIRSTSTAGE = 'L1 Meeting';
    private static final String NEWBUSINESS = 'New Business';
    private static final String TESTNAME1 = 'ConRoleTest';
    private static final String TESTNAME2 = 'TestNameRole';

    @isTest
    public static void createContactRole_Batch_Test(){
        
        Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, ISSUER, null); 
        acc.PAN_Number__c = 'AAACI0218B';
       	acc.GST_Number__c = '24AAACI0218B1ZG';
        Insert acc;
        List<Contact> conList = new List<Contact>{TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME1,true),
            										TestFactory.getContact(acc.Id,TESTNAME2,TESTNAME1,true)};
        conList[0].Email = CONEMAIL;
        conList[1].Email = CONEMAIL;
         conList[0].Billing_Contact__c = 'Yes';
        Update conList;
        Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, NEWBUSINESS, acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        insert opty; 
        
        Test.startTest();
        Database.executeBatch(new CreateContactRole_Batch(),50);
        Test.stopTest();
        
    }
}