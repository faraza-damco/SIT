@isTest
    private class ICRA_BillingAddress_Update_DataOne_Test {
    
        @isTest
        static void testBillingAddressUpdate1() {
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
            Acc.Sector_L1__c ='Banks';
            Acc.Sector_L2__c ='Cooperative Bank';
            Acc.Sector__c ='Banks';
            Acc.Sector_L4__c ='Active';
            Acc.Sub_Sector__c ='Cooperative Bank';
            Acc.Orbis_ID__c ='1234567';
            acc.Line_of_Business__c='Finance and Banking';
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
    
            ICRA_BillingAddress_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_BillingAddress_Update_DataOne.ResponseWrapper();
    
            // Create a sample request payload
            ICRA_BillingAddress_Update_Wrapper.Data testData = new ICRA_BillingAddress_Update_Wrapper.Data();
            testData.billingStreet = 'Haryana';
            testData.billingCity = 'Sukteri';
            testData.billingCountry = 'India';
            testData.billingState = 'Haryana';
            testData.billingPostalCode = '160101';
            testData.gstn = '06AAFCR5512VKZP';
            testData.bvdId = 'bvdID';
            testData.billingAddress_ID = billingAddr.Id;
            testData.billingcurrency = 'INR';
    
            ICRA_BillingAddress_Update_Wrapper testWrapper = new ICRA_BillingAddress_Update_Wrapper();
            testWrapper.data = new List<ICRA_BillingAddress_Update_Wrapper.Data>{testData};
            String jsonRequest = JSON.serialize(testWrapper);
    
            // Set up the mock request
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/BillingAddressUpdate';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            RestContext.request.requestBody = Blob.valueOf(jsonRequest);
    
            // Call the method being tested
            Test.startTest();
            ICRA_BillingAddress_Update_DataOne.ResponseWrapper actualResponse = ICRA_BillingAddress_Update_DataOne.billingAddressUpdate();
            ICRA_BillingAddress_Update_Wrapper.parse(jsonRequest);
            Test.stopTest();
    
            // Assert the expected response message
            //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
        }
        
        @isTest
        static void testBillingAddressUpdate2() {
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
            //Acc.Related_Party__c ='';
            Acc.Sector_L1__c ='Banks';
            Acc.Sector_L2__c ='Cooperative Bank';
            Acc.Sector__c ='Banks';
            Acc.Sector_L4__c ='Active';
            Acc.Sub_Sector__c ='Cooperative Bank';
            Acc.Orbis_ID__c ='1234567';
            acc.Line_of_Business__c='Finance and Banking';
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
    
            ICRA_BillingAddress_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_BillingAddress_Update_DataOne.ResponseWrapper();
    
            // Create a sample request payload
            ICRA_BillingAddress_Update_Wrapper.Data testData = new ICRA_BillingAddress_Update_Wrapper.Data();
            testData.billingStreet = 'Haryana';
            testData.billingCity = 'Sukteri';
            testData.billingCountry = 'India';
            testData.billingState = 'Haryana';
            testData.billingPostalCode = '160101';
            testData.gstn = '06AAFCR5512VKZP';
            testData.bvdId = 'bvdID';
            testData.billingAddress_ID ='';
            testData.billingcurrency = 'INR';
    
            ICRA_BillingAddress_Update_Wrapper testWrapper = new ICRA_BillingAddress_Update_Wrapper();
            testWrapper.data = new List<ICRA_BillingAddress_Update_Wrapper.Data>{testData};
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
            ICRA_BillingAddress_Update_DataOne.ResponseWrapper actualResponse = ICRA_BillingAddress_Update_DataOne.billingAddressUpdate();
            ICRA_BillingAddress_Update_Wrapper.parse(jsonRequest);
            Test.stopTest();
    
            // Assert the expected response message
            //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
        }
        @isTest
        static void testBillingAddressUpdate3() {
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
            //Acc.Related_Party__c ='';
            Acc.Sector_L1__c ='Banks';
            Acc.Sector_L2__c ='Cooperative Bank';
            Acc.Sector__c ='Banks';
            Acc.Sector_L4__c ='Active';
            Acc.Sub_Sector__c ='Cooperative Bank';
            Acc.Orbis_ID__c ='1234567';
            acc.Line_of_Business__c='Finance and Banking';
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
    
            ICRA_BillingAddress_Update_DataOne.ResponseWrapper expectedResponse = new ICRA_BillingAddress_Update_DataOne.ResponseWrapper();
    
            // Create a sample request payload
            ICRA_BillingAddress_Update_Wrapper.Data testData = new ICRA_BillingAddress_Update_Wrapper.Data();
            testData.billingStreet = 'Haryana';
            testData.billingCity = 'Sukteri';
            testData.billingCountry = 'India';
            testData.billingState = 'Haryana';
            testData.billingPostalCode = '160101';
            testData.gstn = '06AAFCR5512VKZP';
            testData.bvdId = 'bvdID';
            testData.billingAddress_ID = 'a1213115a15dsfsf';
            testData.billingcurrency = 'INR';
    
            ICRA_BillingAddress_Update_Wrapper testWrapper = new ICRA_BillingAddress_Update_Wrapper();
            testWrapper.data = new List<ICRA_BillingAddress_Update_Wrapper.Data>{testData};
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
            ICRA_BillingAddress_Update_DataOne.ResponseWrapper actualResponse = ICRA_BillingAddress_Update_DataOne.billingAddressUpdate();
            ICRA_BillingAddress_Update_Wrapper.parse(jsonRequest);
            Test.stopTest();
    
            // Assert the expected response message
            //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
        }
    }