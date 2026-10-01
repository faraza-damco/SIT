@isTest
public class SendBulkEmailTest {
      private static final String INVOICEROLE = 'Name on Invoice';

    static testMethod void positiveDataInsert1()
    {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Account Acc=TestFactory.getAccount('XYZ', false);
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Acc.PAN_Number__c = 'ABCDE1234A';
        Acc.TAN_Number__c = 'ABCD12345A';
        Acc.GST_Number__c = '06ABCDE1234AKZP';
        Acc.BillingState = 'Haryana';
        Acc.OFAC_Document_Received__c = true;
        insert Acc;
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
        
        Contact Contact1 =TestFactory.getContact(Acc.Id,'weqwe','dfsdf',true);
        Contact1.Billing_Contact__c='No';
        update Contact1;
        Contact Contact2 =TestFactory.getContact(Acc.Id,'dfdf','ddd',true);
         Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', Acc.Id); 
        Insert contactRecord;
        
        List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,1,1);
        Opp[0].Contact__c=Contact.Id;
        //Opp[0].stagename='Closed Won';
        Opp[0].Business_Segment__c='Rating';
        Opp[0].Instrument_type_1__c='Non Structured Finance';
        Opp[0].Instrument_type_2__c='Rating - Bank Loan Rating';
        Opp[0].Instrument_type_3__c='Bank Loan Rating';
        Opp[0].Instrument_type_4__c='Bank Loan Rating Enhancement';
        Opp[0].VoD_in_crore__c=150;
        
        Opp[0].ownerId=usrLH.Id;
        Opp[0].Mandate_Received_Date__c=system.today();
        Opp[0].IRF_Final_Amount__c=134;
        Opp[0].ASF_Final_Amount__c=156;
        Opp[0].Customer_Fee_Type__c = 'Non - Cap';
        Opp[0].Amount_To_Be_Billed__c = 134;
         Opp[0].OFAC_Approver__c = username.Id;
        Opp[0].OFAC_Approved__c = true;
        insert Opp;
        
          List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = Opp[0].Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        Opp[0].StageName = 'OFAC Initiation';
        update Opp;
        Opp[0].StageName = 'OFAC Approved';
        update Opp;
        Opp[0].Proposed_Rating_Fee__c = 100;
        Opp[0].Proposed_Surveillance_Fee__c = 100;
        Opp[0].StageName = 'Negotiation';
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update Opp;
            Opp[0].Pricing_Approved_by_Commercial_Head__c = true;
        Opp[0].Pricing_Approved_by_CEO__c = false;
        Opp[0].Pricing_Rejected_by_CEO__c = false;
        Opp[0].CH_Approval_Reject_Email_sent__c = false;
        update Opp;
        Opp[0].Pricing_Approved_by_CEO__c = true;
        update Opp;
        Opp[0].StageName = 'Discount Approved';
        update Opp;
        Opp[0].StageName = 'Closed Won';
        update Opp;
        
        ContentVersion cv=new Contentversion();
        cv.title='Disclosure of Lender Details - 4 June 2021';
        cv.PathOnClient ='Disclosure of Lender Details - 4 June 2021';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        SendBulkEmail SBE=new SendBulkEmail();
        
        SBE.sendMailNew();
    }
    static testMethod void positiveDataInsert2()
    {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];

        Account Acc=TestFactory.getAccount('XYZ', false);
        Acc.PAN_Number__c = 'ABCDE1234B';
        Acc.TAN_Number__c = 'ABCD12345B';
        Acc.GST_Number__c = '06ABCDE1234BKZP';
        Acc.BillingState = 'Haryana';
        Acc.OFAC_Document_Received__c = true;
        insert Acc;
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
         Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', Acc.Id); 
        Insert contactRecord;
        List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,1,1);
        //Opp[0].Contact__c=Contact.Id;
        Opp[0].VoD_in_crore__c=150;
        
        Opp[0].ownerId=usrLH.Id;
        
        Opp[0].IRF_Final_Amount__c=134;
        Opp[0].ASF_Final_Amount__c=156;
        Opp[0].Customer_Fee_Type__c = 'Non - Cap';
        Opp[0].Amount_To_Be_Billed__c = 134;
        Opp[0].OFAC_Approver__c = username.Id;
        Opp[0].OFAC_Approved__c = true;
        Opp[0].Mandate_Received_Date__c = system.today();
        insert Opp;
        
          List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = Opp[0].Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        Opp[0].StageName = 'OFAC Initiation';
        update Opp;
        Opp[0].StageName = 'OFAC Approved';
        update Opp;
        Opp[0].Proposed_Rating_Fee__c = 100;
        Opp[0].Proposed_Surveillance_Fee__c = 100;
        Opp[0].StageName = 'Negotiation';
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update Opp;
        Opp[0].StageName = 'Discount Approved';
        update Opp;
        Opp[0].StageName = 'Closed Won';
        update Opp;
        
        
        ContentVersion cv=new Contentversion();
        cv.title='Disclosure of Lender Details - 4 June 2021';
        cv.PathOnClient ='Disclosure of Lender Details - 4 June 2021';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        SendBulkEmail SBE=new SendBulkEmail();
        SBE.sendMailNew();
        
        
    }
}