/*********************************************************************************************
ClassName -   PricingApprovalMandatesTest
Description - Test calss for code coverage of PricingApprovalMandates Batch,Scheduler & Controller
*********************************************************************************************/
@isTest(SeeAllData=false)
private class PricingApprovalMandatesTest {
    private static final String NEWBUSINESS = 'New Business';
    private static final String TESTNAME1 = 'Pricing Test';
    private static final String TESTEMAIL = 'testPricing@abc.com';
    private static final String ICGSTR = 'ICG';
    private static final String SECGSTR = 'SECG';
//Test setup
    @testSetup 
    static void testSetup(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //create branch
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;
        Branch__c B=TestFactory.generateBranch('Mumbai');
        // create Account
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.ICRA_Branch__c=B.id;
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector;
        Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, 'Issuer', null); 
        acc.Classification__c = SECGSTR;
        acc.PAN_Number__c = 'AAACI0218B';
        //acc.GST_Number__c = '24AAACI0218B1ZG';
        acc.Branch__c=B.id;
        acc.Group_Name__c = 'N/a';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Ofac_check__c=true;
        Acc.Account_Status__c ='Active';
        acc.Related_Party__c='No';
        Acc.OFAC_Document_Received__c=true;
        Acc.Customer_Fee_Type__c='Non - Cap';
        Acc.Constitution_Type_Picklist__c='Other';
        upsert acc;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAACI0218B1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;     
        billingAddr.Tax_GST_Classification__c='Non-Sez';
        insert billingAddr;

        Contact con = TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME1,true); 
        //Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, 'New Business', acc.Id);
        List<Opportunity> opty = TestFactory.generateOppsForAccount(acc.Id,10000,1);
        opty[0].Pricing_Auto_Approved__c = true;
        opty[0].Customer_Fee_Type__c = 'Non - Cap';
        opty[0].StageName = 'L1 Meeting';
        upsert opty;
        insert new List<Commercial_Head_Details__c>{new Commercial_Head_Details__c(Name = 'ICG',Email__c = 'test1@abc.zxc'),
            										new Commercial_Head_Details__c(Name = 'SECG',Email__c = 'test2@abc.zxc')};
    }
//Test method
    static testMethod void validateSECGApproval() {
        Test.startTest();
        String chron = '0 0 23 * * ?';
        Opportunity opty = [Select Id from Opportunity limit 1];
        PricingApprovalMandatesBatch batch = new PricingApprovalMandatesBatch(new Set<Id>{opty.Id});
        Database.executebatch(batch,200);

        PricingApprovalMandatesScheduler testSche = new PricingApprovalMandatesScheduler();
        String jobId = system.schedule('Test status Check', chron, testsche );
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        Test.stopTest();
        System.assertEquals(chron,ct.CronExpression); 
    }
//Test method
    static testMethod void validateICGApproval() {
        Test.startTest();
        List<Account> acc = [SELECT Id,Classification__c FROM Account Limit 1];
        acc[0].Classification__c = ICGSTR;
        upsert acc;
        PricingApprovalMandatesBatch batch = new PricingApprovalMandatesBatch();
        Database.executebatch(batch,200);
        Test.stopTest();
        System.assertEquals(acc.size(),1); 
    }
//Test method
	static testMethod void validateController() {
        Test.startTest();
        List<Account> acc = [SELECT Id,Classification__c FROM Account Limit 1];
        PricingApprovalMandatesController.approvMandates(acc[0].Classification__c+'/'+System.Today().month()+'/'+System.Today().year());
        Opportunity opp = [Select Id,StageName,Pricing_Not_Auto_Approved__c from Opportunity Limit 1];
        opp.StageName = 'Negotiation';
        opp.Pricing_Not_Auto_Approved__c = true;
        update opp;
        manualPricingApprovalController.getOpportunity(null);
        manualPricingApprovalController.resetApproval(opp.Id);
        manualPricingApprovalController.updateApprovalFields(opp.Id);
        try{
        manualPricingApprovalController.invokeApprovalProcess(opp.Id);            
        }catch(Exception ex){
            System.debug('$$$$$'+ex.getMessage());
        }
        Test.stopTest();
        System.assertEquals(acc.size(),1); 
	}
}