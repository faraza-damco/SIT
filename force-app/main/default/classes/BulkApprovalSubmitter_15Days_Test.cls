@isTest
public class BulkApprovalSubmitter_15Days_Test {

    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String PROPOSALPRIMARY_ROLE = 'Proposal Primary Contact';
    private static final String MPRA_ROLE = 'MPRA/SOW';
    private static final String MPRA_Sent = 'MPRA & SoW / Subscription Form Sent';
    private static final String EMAILROLE = 'Email Recipient';
    private static final String CONEMAIL = 'testcontactrole@abc.com';
    private static final String CONEMAIL2 = 'test@abcxyz.com';
    private static final String ISSUER = 'Issuer';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String FIRSTSTAGE = 'L1 Meeting';
    private static final String NEWBUSINESS = 'New Business'; 
    private static final String SURVEILLANCE = 'Surveillance'; 
    private static final String TESTNAME1 = 'ConRoleTest';   
    private static final String TESTNAME2 = 'TestNameRole';
    private static final String TESTNAME3 = 'TestRole';
    private static final String TESTNAME4 = 'NameRole';
    private static final String DESIGNATION = 'Asst Mngr';
    private static final String DESIGNATION2 = 'A M';
    private static final String EMAIL = 'test@testing.com';
    
    @testSetup
    static void setupTestData() {
        
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.OpportunityTrigger__c= true;
        tg_status.PromotorCompany__c= true;
        tg_status.Fee_Calculation__c= true;
        insert tg_status;

        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;

        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id;
        businessSector.ICRA_Branch__c = branchRecord.Id;
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, ISSUER, null); 
        acc.PAN_Number__c = 'AAFCR5512V';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.ofac_check__c =true;
        Acc.Account_Status__c ='Active';
        Acc.OFAC_Approval_Status__c ='Approved';
        Acc.Branch__c =branchRecord.Id;
        Acc.OFAC_Document_Received__c=true;
        Acc.Ofac_Approved__c=true;
        Acc.Constitution_Type_Picklist__c='other';
        Acc.Bypass__c=true;
        Insert acc;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;  
        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';
        insert billingAddr;

        // Acc.Billing_Address__c= billingAddr.Id;
        // update Acc;

        List<Contact> conList = new List<Contact>{TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME1,true),
                                                TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME2,true),
                                                TestFactory.getContact(acc.Id,TESTNAME2,TESTNAME1,true),
                                                TestFactory.getContact(acc.Id,TESTNAME2,TESTNAME2,true),
                                                TestFactory.getContact(acc.Id,TESTNAME3,TESTNAME3,true),
                                                TestFactory.getContact(acc.Id,TESTNAME4,TESTNAME4,true)};

            conList[0].Email = CONEMAIL;
            conList[0].Designation__c = DESIGNATION;
            conList[0].Account = acc;
            conList[1].Email = CONEMAIL;
            conList[1].Designation__c = DESIGNATION;
            conList[1].Account = acc;
            conList[2].Email = CONEMAIL2;
            conList[2].Designation__c = DESIGNATION2;
            conList[2].Account = acc;
            conList[3].Email = CONEMAIL;
            conList[3].Designation__c = DESIGNATION;
            conList[3].Account = acc;
            //conList[3].Inactive__c = true;
            conList[4].Designation__c = DESIGNATION;
            conList[4].Email = EMAIL;
            conList[4].Account = acc;
            conList[5].Email = EMAIL;
            conList[5].Designation__c = DESIGNATION;
            conList[5].Account = acc;
            update conList;

        Opportunity opt = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, SURVEILLANCE, acc.Id); 
        opt.Instrument_type_1__c = 'Non Structured Finance';
        opt.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opt.Instrument_type_3__c = 'Bank Loan Rating';
        opt.Instrument_type_4__c = 'Bank Loan Rating';
        opt.Customer_Fee_Type__c = 'Non - Cap';
        opt.StageName = 'L1 Meeting';
        opt.Mandate_Type__c = 'Fresh From Existing';
        //opt.Scheme_Trust_Name__c = 'Mutual Fund';
        opt.Bypass_Validation__c = true;
        opt.Billing_Start_Date__c = null;
        opt.Non_Cooperation_Withdrawal_Reason__c= '';
        opt.Reason__c='Hold';
        opt.Commercial_Head__c=usrLH.Id;
        insert opt;

      
    }

    @isTest
    static void testApproval_successful() {
        // Retrieve test Opportunity
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        // Call the invocable method
        List<Id> oppIds = new List<Id>{ opp.Id };
        BulkApprovalSubmitter_15Days.submitOpportunities(oppIds);
            
        Test.stopTest();
    }
}