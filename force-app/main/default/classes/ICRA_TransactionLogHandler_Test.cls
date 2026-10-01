@isTest
public with sharing class ICRA_TransactionLogHandler_Test { 
    @testSetup
    static void setupData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
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
        businessSector.ICRA_Branch__c = branchrecord.Id; 
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('ConRoleTest', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	acc.Branch__c = branchrecord.Id; 
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.ofac_check__c =true;
        Acc.Account_Status__c ='Active';
        Acc.Constitution_Type_Picklist__c ='Other';
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

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'Surveillance', acc.Id); 
        opty.Non_Cooperation_Withdrawal_Reason__c='Others';
        insert opty;  
    }

    @isTest
    static void testAddAndSaveLogs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        ICRA_TransactionLogHandler.addLog('ICRA_CreateRollover_T_Logic', opp.Id, null, 'Insert Operation', 'This is a test error message');
        Test.startTest();
        ICRA_TransactionLogHandler.saveLogs();
        Test.stopTest();

        Transaction_Log__c logRec = [SELECT Id, Batch_Process__c, Opportunity__c, Operation__c, Error_Message__c, Status__c FROM Transaction_Log__c LIMIT 1];

        System.assertEquals('ICRA_CreateRollover_T_Logic', logRec.Batch_Process__c, 'Batch Name should match');
        System.assertEquals(opp.Id, logRec.Opportunity__c, 'Opportunity should match');
        System.assertEquals('Insert Operation', logRec.Operation__c, 'Operation should match');
        System.assertEquals('This is a test error message', logRec.Error_Message__c, 'Error message should match');
        System.assertEquals('Failed', logRec.Status__c, 'Status should be Failed');
    }

    @isTest
    static void testNoLogs() {
        Test.startTest();
        ICRA_TransactionLogHandler.saveLogs(); 
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Transaction_Log__c], 'No logs should be created');
    }
}