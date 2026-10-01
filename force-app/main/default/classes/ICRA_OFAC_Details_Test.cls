@isTest
Public class ICRA_OFAC_Details_Test {

    public class MockOFACResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            String resp= '{"req_ack_Id":"OFAC20348516736","resp_code":"S","resp_message":"OFAC check request completed successfully.","ofac_status":"NOMATCH","batchId":"342691544","ofac_moody_last_updated_date":"2024-08-23T02:51:58.8935841","access_token":"U9Pr-f3nD5zdtYsrqECtcA1QxI2cTehJsU12iHK8kNWTRBsDj","token_type":"bearer","expires_in":60000}';
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(resp);
            return res;
        }
    }

    public class AuthMock2 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            String resp = '{"access_token":"U9Pr-f3nD5zdtYsrqECtcA1QxI2cTehJsU12iHK8kNWTRBsDj","token_type":"bearer","expires_in":60000}';
            res.setBody(resp);
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    static void setup() {
        // Insert necessary test data
        OFAC_Details__c ofacDetails = new OFAC_Details__c();
        ofacDetails.End_Point__c = 'https://test.in/api/token/generate';
        ofacDetails.Content_Type__c = 'application/x-www-form-urlencoded';
        ofacDetails.Body__c = 'username=sfdc&password=sfdc@d1&grant_type=password';
        ofacDetails.OFAC_End_Point__c = 'https://test.in/api/company/check-ofac-status';
        insert ofacDetails;

        RecordType issuerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Issuer' LIMIT 1];
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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

        Account acc =  ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5514P';
        acc.Group_Name__c = 'testDamco1';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Account_Status__c ='OFAC Pending';
        Acc.Branch__c =branchRecord.Id;
        Acc.OFAC_Status__c ='';
        Insert acc;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5514P1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;
    }

    @isTest
    static void testICRA_OFAC_Details() {
        Test.setMock(HttpCalloutMock.class, new MockOFACResponse());
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Id> accIds = new List<Id>{ testAccount.Id };
        Test.startTest();
        ICRA_OFAC_Details.ICRA_OFAC_Details(accIds);
        Test.stopTest();

        // Assertions
        Account updatedAccount = [SELECT OFAC_Check__c, OFAC_Status__c, Account_Status__c FROM Account WHERE Id =: testAccount.Id];
        System.assertEquals('NOMATCH', updatedAccount.OFAC_Status__c, 'OFAC Status should be NOMATCH');
        System.assertEquals('Active', updatedAccount.Account_Status__c, 'Account Status should be Active');
        System.assertNotEquals('OFAC Pending', updatedAccount.Account_Status__c, 'Account status should have changed from OFAC Pending');
    }

    public  class OFAC_Response{
        public string req_ack_Id;
        public string resp_code;
        public string resp_message;
        public string ofac_status;
        public string batchId;
        public string ofac_moody_last_updated_date;
    }
}