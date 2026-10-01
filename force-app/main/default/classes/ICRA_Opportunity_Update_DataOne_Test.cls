@isTest
private class ICRA_Opportunity_Update_DataOne_Test {

    @isTest
    static void testOpportunityUpdate1() {
        // Test data setup
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
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME1', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	//acc.GST_Number__c = '24AAACI0218B1ZG';
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
        //Acc.Related_Party__c ='';
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
        insert billingAddr;

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Commercial_Head__c=usrLH.Id;
        opty.Mandate_ID__c = '232400999';
        opty.Execution_Status_new__c = 'Initial Status';
        //opty.Date_of_Communication__c = System.Today();
        opty.Date_of_Non_Acceptance_of_Rating__c = Date.newInstance(2024, 3, 4);
        opty.Analyst__c = 'Analyst';
        opty.Sector_Head__c = 'Sector_Head';
        opty.Co_Analyst__c = 'Co_Analyst';
        opty.Group_Head__c = 'Group_Head';
        opty.Quality_Analyst__c = 'LCG';
        opty.Rated_Entity__c = acc.Id;
        opty.Billing_Start_Date__c = null;
        opty.Billing_End_date__c = null;
        insert opty;  

        ICRA_Opportunity_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_Opportunity_Update_DataOne.ResponseWrapper();

        // Create a sample request payload
        ICRA_Opportunity_Update_Wrapper.Data testData = new ICRA_Opportunity_Update_Wrapper.Data();
        testData.mandate_Id = '232400999';
        testData.sow_status = 'Updated Status';
        //testData.ratedEntity_BvD_ID = 'Rated BvD Id';
        testData.ratedEntity = acc.Id;
        //testData.pan_number = '';
        //testData.street = 'Street';
        //testData.city = 'Delhi';
        //testData.state = 'Delhi';
        //testData.country = 'India';
        //testData.postalCode = '110011';
        testData.pr_date = '';
        testData.date_of_communication = String.valueOf(System.today());
        testData.date_of_non_acceptance_of_rating = String.valueOf(System.today());
        testData.analyst = 'Analyst';
        testData.sector_head = 'Sector Head';
        testData.co_analyst = 'Co Analyst';
        testData.group_head = 'Group Head';
        testData.quality_analyst = 'Execution team';

        ICRA_Opportunity_Update_Wrapper testWrapper = new ICRA_Opportunity_Update_Wrapper();
        testWrapper.data = new List<ICRA_Opportunity_Update_Wrapper.Data>{testData};
        String jsonRequest = JSON.serialize(testWrapper);

        // Set up the mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OpportunityUpdate';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);

        // Call the method being tested
        Test.startTest();
        ICRA_Opportunity_Update_DataOne.ResponseWrapper actualResponse = ICRA_Opportunity_Update_DataOne.opportunityUpdate();
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
    @isTest
    static void testOpportunityUpdate2() {
        // Test data setup
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
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME1', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	//acc.GST_Number__c = '24AAACI0218B1ZG';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Account_Status__c ='Active';
        Acc.ofac_check__c =true;
        //Acc.Related_Party__c ='';
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
        insert billingAddr;

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Commercial_Head__c=usrLH.Id;
        opty.Mandate_ID__c = '232400999';
        opty.Execution_Status_new__c = 'Initial Status';
        opty.Rated_Entity__c = acc.Id;
        opty.Billing_Start_Date__c = null;
        opty.Billing_End_date__c = null;
        insert opty;  

        ICRA_Opportunity_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_Opportunity_Update_DataOne.ResponseWrapper();

        // Create a sample request payload
        ICRA_Opportunity_Update_Wrapper.Data testData = new ICRA_Opportunity_Update_Wrapper.Data();
        testData.mandate_Id = '000000900';
        testData.sow_status = 'Updated Status';
        testData.ratedEntity_BvD_ID = 'Rated BvD Id';
        testData.ratedEntity = acc.Id;
        testData.pan_number = '';
        testData.street = 'Street';
        testData.city = 'Delhi';
        testData.state = 'Delhi';
        testData.country = 'India';
        testData.postalCode = '110011';
        testData.pr_date = '';
        testData.date_of_communication = String.valueOf(System.today());
        testData.date_of_non_acceptance_of_rating = String.valueOf(System.today());
        testData.analyst = 'Analyst';
        testData.sector_head = 'Sector Head';
        testData.co_analyst = 'Co Analyst';
        testData.group_head = 'Group Head';
        testData.quality_analyst = 'Execution team';

        ICRA_Opportunity_Update_Wrapper testWrapper = new ICRA_Opportunity_Update_Wrapper();
        testWrapper.data = new List<ICRA_Opportunity_Update_Wrapper.Data>{testData};
        String jsonRequest = JSON.serialize(testWrapper);

        // Set up the mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OpportunityUpdate';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);

        // Call the method being tested
        Test.startTest();
        ICRA_Opportunity_Update_DataOne.ResponseWrapper actualResponse = ICRA_Opportunity_Update_DataOne.opportunityUpdate();
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
    @isTest
    static void testOpportunityUpdate3() {
        // Test data setup
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
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME1', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	//acc.GST_Number__c = '24AAACI0218B1ZG';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Account_Status__c ='Active';
        Acc.ofac_check__c =true;
        //Acc.Related_Party__c ='';
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
        insert billingAddr;

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Commercial_Head__c=usrLH.Id;
        opty.Mandate_ID__c = '232400999';
        opty.Execution_Status_new__c = 'Initial Status';
        opty.Rated_Entity__c = acc.Id;
        opty.Billing_Start_Date__c = null;
        opty.Billing_End_date__c = null;
        insert opty;  

        ICRA_Opportunity_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_Opportunity_Update_DataOne.ResponseWrapper();

        // Create a sample request payload
        ICRA_Opportunity_Update_Wrapper.Data testData = new ICRA_Opportunity_Update_Wrapper.Data();
        testData.mandate_Id = '';
        testData.sow_status = 'Updated Status';
        testData.ratedEntity_BvD_ID = 'Rated BvD Id';
        testData.ratedEntity = acc.Id;
        testData.pan_number = '';
        testData.street = 'Street';
        testData.city = 'Delhi';
        testData.state = 'Delhi';
        testData.country = 'India';
        testData.postalCode = '110011';
        testData.pr_date = '';
        testData.date_of_communication = String.valueOf(System.today());
        testData.date_of_non_acceptance_of_rating = String.valueOf(System.today());
        testData.analyst = 'Analyst';
        testData.sector_head = 'Sector Head';
        testData.co_analyst = 'Co Analyst';
        testData.group_head = 'Group Head';
        testData.quality_analyst = 'Execution team';
        testData.workItemNumber = 'WorkItem No';

        ICRA_Opportunity_Update_Wrapper testWrapper = new ICRA_Opportunity_Update_Wrapper();
        testWrapper.data = new List<ICRA_Opportunity_Update_Wrapper.Data>{testData};
        String jsonRequest = JSON.serialize(testWrapper);

        // Set up the mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OpportunityUpdate';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);

        // Call the method being tested
        Test.startTest();
        ICRA_Opportunity_Update_DataOne.ResponseWrapper actualResponse = ICRA_Opportunity_Update_DataOne.opportunityUpdate();
        ICRA_Opportunity_Update_Wrapper.parse(jsonRequest);
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
}