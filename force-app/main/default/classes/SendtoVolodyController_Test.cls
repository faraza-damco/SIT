@isTest
public class SendtoVolodyController_Test {
 
   
    public class TokenMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Set-Cookie', 'sessionid=test123; path=/');
            res.setStatusCode(200);
            res.setBody('{"access_token":"dummy_access_token"}');
            return res;
        }
    }

    
    public class AgreementMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '[{"label":"Agreement A"},{"label":"Agreement B"}]'
            );
            return res;
        }
    }

    
    public class ContractMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();

            if(req.getEndpoint().contains('/login_token')) {
                res.setStatusCode(200);
                res.setHeader('Set-Cookie', 'sessionid=test123; path=/');
                res.setBody('{"access_token":"dummy_access_token"}');
            }
            else if(req.getEndpoint().contains('/crm_contract')) {
                res.setStatusCode(200);
                res.setBody(
                    '{"clm_reference_id":"12345","clm_document_link":"https://test.com/doc"}'
                );
            }

            return res;
        }
    }

   
    public class ContractStatusMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();

            if(req.getEndpoint().contains('/login_token')) {
                res.setStatusCode(200);
                res.setHeader('Set-Cookie', 'sessionid=test123; path=/');
                res.setBody('{"access_token":"dummy_access_token"}');
            }
            else if(req.getEndpoint().contains('/contract_status')) {
                res.setStatusCode(200);
                res.setBody('{"status":"Completed"}');
            }

            return res;
        }
    }

   
    @testSetup
    static void setupData() {

        Volody_Details__c vd = new Volody_Details__c(
            Name = 'Test',
            Endpoint__c = 'https://testurl.com',
            UserName__c = 'test@test.com',
            Password__c = 'password'
        );
        insert vd;
            Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;  

      Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
            
            Business_Sector__c businessSector = new Business_Sector__c();
            businessSector.Name = 'Infrastructure';
            businessSector.Business_Head__c =  usrLH.Id; 
            businessSector.OFAC_Approver__c = usrLH.Id; 
            businessSector.Opportunity_Checker__c = usrLH.Id;
            businessSector.ICRA_Branch__c = branchRecord.Id;
            insert businessSector;
            
            Account acc =  ICRA_TestDataFactory.CreateAccount('ConRoleTest', 'Issuer', null); 
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
            
         
        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('ConRoleTest', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Others';
        opty.Instrument_type_3__c = 'Mutual Fund';
        opty.Instrument_type_4__c = 'Mutual Fund Rating';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='Other';
        opty.Other__c=5;
        opty.Commercial_Head__c=usrLH.Id;
        opty.ASF_Agreement_with_Client__c='In BPS';
        opty.Minimum_ASF__c=100;
        opty.Scheme_Trust_Name__c='Pika';
        opty.Bill_To__c=acc.Id;
        opty.Bypass_Validation__c=true;
        opty.Billing_Start_Date__c = null;
        opty.Defer_Billing_or_Exit_Case__c = '';
        opty.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opty; 
                 }

    
    @isTest
    static void testGetOppFields() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        String result = SendtoVolodyCompController.getOppFields(
            opp.Id
        );

        Test.stopTest();

        System.assertNotEquals(null, result);
    }

   
    @isTest
    static void testGetTokenForVolody() {

        Test.setMock(HttpCalloutMock.class, new TokenMock());

        Test.startTest();

        SendtoVolodyCompController.volodyWrapper wrapperObj =
            SendtoVolodyCompController.getTokenForVolody();

        Test.stopTest();

        System.assertEquals('dummy_access_token', wrapperObj.accessToken);
    }

   
    @isTest
    static void testGetAgreementType() {

        Test.setMock(HttpCalloutMock.class, new AgreementMock());

        Test.startTest();

        List<Object> agreements =
            SendtoVolodyCompController.getAgreementType();

        Test.stopTest();

        System.assertEquals(2, agreements.size());
    }

    
    @isTest
    static void testCreateCrmContract() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new ContractMock());

        Test.startTest();

        String result = SendtoVolodyCompController.createCrmContract(
            opp.Id,
            'Test Agreement'
        );

        Test.stopTest();

        System.assertEquals('Success', result);

        Opportunity updatedOpp = [
            SELECT Contract_ID__c, Contract_Link__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertNotEquals(null, updatedOpp.Contract_ID__c);
    }

   
    @isTest
    static void testGetContractStatusAPI() {

        Test.setMock(HttpCalloutMock.class, new ContractStatusMock());

        Test.startTest();

        SendtoVolodyCompController.getContractStatusAPI();

        Test.stopTest();

        System.assert(true);
    }
}