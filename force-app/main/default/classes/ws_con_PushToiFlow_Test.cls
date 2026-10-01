@isTest
public with sharing class ws_con_PushToiFlow_Test {
    public ws_con_PushToiFlow_Test() {

    }

    private class DscMock1 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            string resp2 ='{"resp_code":"S","resp_message":null}';
            res.setBody(resp2);
            res.setStatus('OK');
            res.setStatusCode(500);
            return res;
        }
    }

    @isTest
    public static void dscSigningTest1() {
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector;


        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'Group';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Status__c ='Active';
        accountRecord.Volume_of_Debt_Category__c ='100-250';
        accountRecord.Classification__c ='ICG';
        accountRecord.Constitution_Type__c ='Constitution';
        accountRecord.Account_Classification__c ='';
        Insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c ='Asset Backed Security';
        opportunityRecord.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRecord.Scheme_Trust_Name__c ='Mutual Fund Rating';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c ='MPRA/SoW';
        opportunityRecord.Mandate_Type__c ='Fresh From Fresh';
        opportunityRecord.CurrencyIsoCode ='INR';
        opportunityRecord.MPRA_Sent_Date__c =System.today();
        opportunityRecord.iFlow_Response__c ='{"resp_code":"S","resp_message":"No changes found to be pushed into iFlow!"}';
        opportunityRecord.is_special__c =false;
        opportunityRecord.Rated_Entity__c =null;
        Insert opportunityRecord; 

        ws_con_PushToiFlow.pushToiFlow(opportunityRecord.Id);

    }

    @isTest
    public static void dscSigningTest2() {
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector;


        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'N/A';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'XXXXX4512L';
        accountRecord.TAN_Number__c = '';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Status__c ='Active';
        accountRecord.Volume_of_Debt_Category__c ='';
        accountRecord.Classification__c ='';
        accountRecord.Constitution_Type__c ='';
        Insert accountRecord;
        accountRecord.PAN_Number__c = '';
        update accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        billingAddr.BillingState__c = '';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c ='Asset Backed Security';
        opportunityRecord.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRecord.Scheme_Trust_Name__c ='Mutual Fund Rating';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c ='';
        opportunityRecord.GST_Not_Applicable__c =false;
        opportunityRecord.PAN_not_applicable__c =true;
        opportunityRecord.TAN_not_applicable__c =false;
        opportunityRecord.is_Special__c =false;
        Insert opportunityRecord; 
        
        ws_con_PushToiFlow.pushToiFlow(opportunityRecord.Id);

    }

   @isTest
    public static void dscSigningTest3() {
    Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
    usrLH.MobilePhone='1234567890';
    usrLH.Branch__c='Gurugram';
    usrLH.Designation__c='VP';
    usrLH.City='Gurugram';
    update usrLH;
    Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
    Business_Sector__c businessSector = new Business_Sector__c();
    businessSector.Name = 'Infrastructure';
    businessSector.Business_Head__c =  usrLH.Id; 
    businessSector.OFAC_Approver__c = usrLH.Id; 
    businessSector.Opportunity_Checker__c = usrLH.Id; 
    insert businessSector;


    Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
    accountRecord.Group_Name__c = 'testGroup';
    accountRecord.Business_Sector__c = businessSector.Id;
    accountRecord.PAN_Number__c = 'AAFCR5512V';
    accountRecord.TAN_Number__c = 'DELC06851F';
    accountRecord.ShippingCity ='Delhi';
    accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
    accountRecord.ShippingPostalCode ='110001';
    accountRecord.ShippingState ='Delhi';
    accountRecord.ShippingCountry ='India';
    accountRecord.Account_Status__c ='Active';
    accountRecord.Volume_of_Debt_Category__c ='100-250';
    accountRecord.Classification__c ='ICG';
    accountRecord.Constitution_Type__c ='Constitution';
    Insert accountRecord;

    Billing_Address__c billingAddr = new Billing_Address__c();
    billingAddr.Name = 'Damco Test 1';                     
    billingAddr.Account_Name__c = accountRecord.Id;           
    billingAddr.Billing_City__c = 'Mumbai';                 
    billingAddr.BillingCountry__c = 'India';                  
    billingAddr.BillingState__c = 'Maharashtra';                  
    billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
    billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
    billingAddr.Billing_Zip_Postal_Code__c = '554410';        
    billingAddr.Is_Primary_Billing_Address__c = true;      
    insert billingAddr;

    Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
    Insert contactRecord;
    
    Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
    opportunityRecord.Instrument_type_1__c ='Structured Finance';
    opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
    opportunityRecord.Instrument_type_3__c ='Asset Backed Security';
    opportunityRecord.Instrument_type_4__c ='Pass Through Certificates';
    opportunityRecord.Scheme_Trust_Name__c ='Mutual Fund Rating';
    opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
    opportunityRecord.StageName = 'L1 Meeting';
    opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
    opportunityRecord.CloseDate = System.Today();
    opportunityRecord.Mandate_Received_Date__c =System.today()-1;
    opportunityRecord.MPRA_SoW_Reference_Number_iflow__c ='MPRA/SoW';
    opportunityRecord.Mandate_Type__c ='Fresh From Fresh';
    opportunityRecord.CurrencyIsoCode ='INR';
    opportunityRecord.MPRA_Sent_Date__c =System.today();
    opportunityRecord.iFlow_Response__c ='{"resp_code":"F","resp_message":"No changes found to be pushed into iFlow!"}';
    opportunityRecord.is_special__c =true;
    Insert opportunityRecord; 

    ws_con_PushToiFlow.pushToiFlow(opportunityRecord.Id);

    }

    @isTest
    public static void dscSigningTest4() {

        Integer iFlowTimer= Integer.valueOf(System.Label.Manual_Push_Timer);
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector;


        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'testGroup';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Status__c ='Active';
        accountRecord.Volume_of_Debt_Category__c ='100-250';
        accountRecord.Classification__c ='ICG';
        accountRecord.Constitution_Type__c ='Constitution';
        Insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c ='Asset Backed Security';
        opportunityRecord.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRecord.Scheme_Trust_Name__c ='Mutual Fund Rating';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c ='MPRA/SoW';
        opportunityRecord.Mandate_Type__c ='Fresh From Fresh';
        opportunityRecord.CurrencyIsoCode ='INR';
        opportunityRecord.MPRA_Sent_Date__c =System.today();
        opportunityRecord.iFlow_Response__c ='"resp_code":"S","resp_message":null';
        opportunityRecord.iFlow_Successful_Push_Time__c =System.now().addMinutes(-5);
        opportunityRecord.is_special__c =false;
        Insert opportunityRecord; 

        ws_con_PushToiFlow.pushToiFlow(opportunityRecord.Id);
    }
}