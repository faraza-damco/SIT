@isTest
private class ICRA_Account_Update_DataOne_Test {

    @isTest
    static void testAccountUpdate1() {
        // Test data setup
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');

        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;

        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.ICRA_Branch__c=branchRecord.Id;
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
        Acc.OFAC_Check__c =true;
        Acc.Sector_L1__c ='Banks';
        Acc.Sector_L2__c ='Cooperative Bank';
        Acc.Sector__c ='Banks';
        Acc.Sector_L4__c ='Active';
        Acc.Sub_Sector__c ='Cooperative Bank';
        Acc.Orbis_ID__c ='1234567';
        acc.Line_of_Business__c='Finance and Banking';
        acc.Constitution_Type_Picklist__c='Other';
        acc.Branch__c =branchRecord.Id;
        Insert acc;

        // Billing_Address__c billingAddr = new Billing_Address__c();
        // billingAddr.Name = 'Damco Test 1';                     
        // billingAddr.Account_Name__c = Acc.Id;           
        // billingAddr.Billing_City__c = 'Mumbai';                 
        // billingAddr.BillingCountry__c = 'India';                  
        // billingAddr.BillingState__c = 'Maharashtra';                  
        // billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        // billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        // billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        // billingAddr.Is_Primary_Billing_Address__c = true;      
        // insert billingAddr;

        // Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        // opty.Instrument_type_1__c = 'Non Structured Finance';
        // opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        // opty.Instrument_type_3__c = 'Bank Loan Rating';
        // opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        // opty.Customer_Fee_Type__c = 'Non - Cap';
        // opty.StageName = 'L1 Meeting';
        // opty.Payment_Terms__c=30;
        // opty.Delayed_Payment_Interest_Rate__c=18;
        // opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        // opty.Commercial_Head__c=usrLH.Id;
        // opty.Mandate_ID__c = '232400999';
        // opty.Execution_Status_new__c = 'Initial Status';
        // insert opty;  

        ICRA_Account_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_Account_Update_DataOne.ResponseWrapper();

        // Create a sample request payload
        ICRA_Account_Update_Wrapper.Data testData = new ICRA_Account_Update_Wrapper.Data();
        testData.sectorL3 = 'Banks';
        testData.sectorL5 = 'Cooperative Bank';
        testData.sectorL1 = 'Updated Status';
        testData.sectorL2 = 'Updated Status';
        testData.sectorL4 = 'Updated Status';
        testData.bvd_id = '12345678';
        testData.orbis_id = '1234567';
        testData.sf_account_id = acc.Id;
        testData.accountName = 'Damtest';
        testData.group_name = 'Not Applicable';
        testData.phone = '7845125689';
        testData.website = 'damtest.com';
        testData.constitution_type = 'Test';
        testData.md_text = 'MD';
        testData.cfo_text = 'CFO';
        testData.pan_number = 'AAFCR5512V';
        testData.tan_number = 'ABCDEFGH14';
        testData.lei_number = '012300A0A0A0A0A0A000';
        testData.cin_number = 'U01234Az0123AaZ012341';
        testData.shippingCountry = 'India';
        testData.shippingStreet = 'Street';
        testData.shippingCity = 'Delhi';
        testData.shippingState = 'Delhi';
        testData.shippingPostalCode = '110011';

        ICRA_Account_Update_Wrapper testWrapper = new ICRA_Account_Update_Wrapper();
        testWrapper.data = new List<ICRA_Account_Update_Wrapper.Data>{testData};
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
        ICRA_Account_Update_DataOne.ResponseWrapper actualResponse = ICRA_Account_Update_DataOne.accountUpdate();
        ICRA_Account_Update_Wrapper.parse(jsonRequest);
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
    @isTest
    static void testAccountUpdate2() {
        // Test data setup      
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
         businessSector.ICRA_Branch__c=branchRecord.Id;
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
        Acc.OFAC_Check__c =true;
        //Acc.Related_Party__c ='';
        Acc.Sector_L1__c ='Banks';
        Acc.Sector_L2__c ='Cooperative Bank';
        Acc.Sector__c ='Banks';
        Acc.Sector_L4__c ='Active';
        Acc.Sub_Sector__c ='Cooperative Bank';
        Acc.Orbis_ID__c ='1234567';
        acc.Line_of_Business__c='Finance and Banking';
        acc.Constitution_Type_Picklist__c='Other';
         acc.Branch__c =branchRecord.Id;
        Insert acc;

        // Billing_Address__c billingAddr = new Billing_Address__c();
        // billingAddr.Name = 'Damco Test 1';                     
        // billingAddr.Account_Name__c = Acc.Id;           
        // billingAddr.Billing_City__c = 'Mumbai';                 
        // billingAddr.BillingCountry__c = 'India';                  
        // billingAddr.BillingState__c = 'Maharashtra';                  
        // billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        // billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        // billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        // billingAddr.Is_Primary_Billing_Address__c = true;      
        // insert billingAddr;

        // Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        // opty.Instrument_type_1__c = 'Non Structured Finance';
        // opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        // opty.Instrument_type_3__c = 'Bank Loan Rating';
        // opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        // opty.Customer_Fee_Type__c = 'Non - Cap';
        // opty.StageName = 'L1 Meeting';
        // opty.Payment_Terms__c=30;
        // opty.Delayed_Payment_Interest_Rate__c=18;
        // opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        // opty.Commercial_Head__c=usrLH.Id;
        // opty.Mandate_ID__c = '232400999';
        // opty.Execution_Status_new__c = 'Initial Status';
        // insert opty;  

        ICRA_Account_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_Account_Update_DataOne.ResponseWrapper();

        // Create a sample request payload
        ICRA_Account_Update_Wrapper.Data testData = new ICRA_Account_Update_Wrapper.Data();
        testData.sectorL3 = 'Banks';
        testData.sectorL5 = 'Cooperative Bank';
        testData.sectorL1 = 'Updated Status';
        testData.sectorL2 = 'Updated Status';
        testData.sectorL4 = 'Updated Status';
        testData.bvd_id = '12345678';
        testData.orbis_id = '1234567';
        testData.sf_account_id = '';
        testData.accountName = 'Damtest';
        testData.group_name = 'Not Applicable';
        testData.phone = '7845125689';
        testData.website = 'damtest.com';
        testData.constitution_type = 'Test';
        testData.md_text = 'MD';
        testData.cfo_text = 'CFO';
        testData.pan_number = 'AAFCR5512V';
        testData.tan_number = '';
        testData.lei_number = '012300A0A0A0A0A0A000';
        testData.cin_number = 'U01234Az0123AaZ012341';
        testData.shippingCountry = 'India';
        testData.shippingStreet = 'Street';
        testData.shippingCity = 'Delhi';
        testData.shippingState = 'Delhi';
        testData.shippingPostalCode = '110011';

        ICRA_Account_Update_Wrapper testWrapper = new ICRA_Account_Update_Wrapper();
        testWrapper.data = new List<ICRA_Account_Update_Wrapper.Data>{testData};
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
        ICRA_Account_Update_DataOne.ResponseWrapper actualResponse = ICRA_Account_Update_DataOne.accountUpdate();
        ICRA_Account_Update_Wrapper.parse(jsonRequest);
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
    @isTest
    static void testAccountUpdate3() {
        // Test data setup
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
        businessSector.ICRA_Branch__c=branchRecord.Id;
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
        Acc.OFAC_Check__c =true;
        //Acc.Related_Party__c ='';
        Acc.Sector_L1__c ='Banks';
        Acc.Sector_L2__c ='Cooperative Bank';
        Acc.Sector__c ='Banks';
        Acc.Sector_L4__c ='Active';
        Acc.Sub_Sector__c ='Cooperative Bank';
        Acc.Orbis_ID__c ='1234567';
        acc.Line_of_Business__c='Finance and Banking';
        acc.Constitution_Type_Picklist__c='Other';
        acc.Branch__c =branchRecord.Id;
        Insert acc;

        // Billing_Address__c billingAddr = new Billing_Address__c();
        // billingAddr.Name = 'Damco Test 1';                     
        // billingAddr.Account_Name__c = Acc.Id;           
        // billingAddr.Billing_City__c = 'Mumbai';                 
        // billingAddr.BillingCountry__c = 'India';                  
        // billingAddr.BillingState__c = 'Maharashtra';                  
        // billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        // billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        // billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        // billingAddr.Is_Primary_Billing_Address__c = true;      
        // insert billingAddr;

        // Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        // opty.Instrument_type_1__c = 'Non Structured Finance';
        // opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        // opty.Instrument_type_3__c = 'Bank Loan Rating';
        // opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        // opty.Customer_Fee_Type__c = 'Non - Cap';
        // opty.StageName = 'L1 Meeting';
        // opty.Payment_Terms__c=30;
        // opty.Delayed_Payment_Interest_Rate__c=18;
        // opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        // opty.Commercial_Head__c=usrLH.Id;
        // opty.Mandate_ID__c = '232400999';
        // opty.Execution_Status_new__c = 'Initial Status';
        // insert opty;  

        ICRA_Account_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_Account_Update_DataOne.ResponseWrapper();

        // Create a sample request payload
        ICRA_Account_Update_Wrapper.Data testData = new ICRA_Account_Update_Wrapper.Data();
        testData.sectorL3 = 'Banks';
        testData.sectorL5 = 'Cooperative Bank';
        testData.sectorL1 = 'Updated Status';
        testData.sectorL2 = 'Updated Status';
        testData.sectorL4 = 'Updated Status';
        testData.bvd_id = '12345678';
        testData.orbis_id = '1234567';
        testData.sf_account_id = '12asfegeg2221';
        testData.accountName = 'Damtest';
        testData.group_name = 'Not Applicable';
        testData.phone = '7845125689';
        testData.website = 'damtest.com';
        testData.constitution_type = 'Test';
        testData.md_text = 'MD';
        testData.cfo_text = 'CFO';
        testData.pan_number = 'AAFCR5512V';
        testData.tan_number = '';
        testData.lei_number = '012300A0A0A0A0A0A000';
        testData.cin_number = 'U01234Az0123AaZ012341';
        testData.shippingCountry = 'India';
        testData.shippingStreet = 'Street';
        testData.shippingCity = 'Delhi';
        testData.shippingState = 'Delhi';
        testData.shippingPostalCode = '110011';

        ICRA_Account_Update_Wrapper testWrapper = new ICRA_Account_Update_Wrapper();
        testWrapper.data = new List<ICRA_Account_Update_Wrapper.Data>{testData};
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
        ICRA_Account_Update_DataOne.ResponseWrapper actualResponse = ICRA_Account_Update_DataOne.accountUpdate();
        ICRA_Account_Update_Wrapper.parse(jsonRequest);
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
}