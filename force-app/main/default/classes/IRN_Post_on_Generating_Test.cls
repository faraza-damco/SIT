@isTest
public with sharing class IRN_Post_on_Generating_Test {
    private static final String INVOICEROLE = 'Name on Invoice';
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            PWC_Test_Response__mdt[] response1=[Select Response__c from PWC_Test_Response__mdt];
            String fullJson = response1[0].Response__c;
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockError implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            PWC_Test_Response__mdt[] responseError=[Select Error_Response__c from PWC_Test_Response__mdt];
            String fullJson = responseError[0].Error_Response__c;
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockCancel implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            PWC_Test_Response__mdt[] responseError=[Select Error_Response__c from PWC_Test_Response__mdt];
            String fullJson = '[{"pwc_response":{"Irn":"551d85c35c6691d10271a43f848ab9c27a10aa836a4fe045240bdad140a68f0b","status":700,"message":"PwC Authentication Passed, PwC Irn Cancel Schema Validation Passed, PwC Irn Cancellation Passed","validation_status":"Success","validation_remarks":{}},"cancel_response":{"data":{"nic_request_payload":{"Irn":"551d85c35c6691d10271a43f848ab9c27a10aa836a4fe045240bdad140a68f0b","CnlRsn":"1","CnlRem":"Wrong Entry"},"nic_document_status_created_date":"2020-06-27 20:24:38.725853","nic_gen_mode":"API","nic_response_created_date":"2020-06-27 20:24:40.610871","nic_response_status":"1","InfoDtls":null,"nic_response_plaintext_json":{"Irn":"551d85c35c6691d10271a43f848ab9c27a10aa836a4fe045240bdad140a68f0b","CancelDate":"2020-06-27 20:25:00"},"nic_status":"CNL"},"message":"IRN Cancelled","error":false}}]';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockCancelerror implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            PWC_Test_Response__mdt[] responseError=[Select Error_Response__c from PWC_Test_Response__mdt];
            String fullJson = '[{"pwc_response":{"Irn":"810e758aebc7d45c60bd4d9f10aca06cdc27bbce9cd4d77e1cdf72c4d9e663ad","status":701,"message":"Failed ","validation_status":"Error","validation_remarks":{"irn_schema_validation":[{"remark":"The field Gstin must match the regular expression  ","field_name":"BuyerDtls.Gstin","validation_status":"Error","field_value":"IHIBY7799","error_code":10000}]},"cancel_schema":{"irn_schema_validation":[{"remark":"The field Gstin must match the regular expression ","field_name":"BuyerDtls.Gstin","validation_status":"Error","field_value":"IHIBY7799","error_code":10000}]},"cancel_response":{"message":"Error","irn_schema_validation":[{"remark":"The field Gstin must match the regular expression ","field_name":"BuyerDtls.Gstin","validation_status":"Error","field_value":"IHIBY7799","error_code":10000}]}}}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockServerError implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"message": "Endpoint request timed out"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(504);
            return res;
        }
    }
    
    @isTest
    public static void GenerateIRNTest() {
        List<Invoice__c>invlist=new List<Invoice__c>();
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id;
        businessSector.ICRA_Branch__c=branchrecord.Id;
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true; 
        billingAddr.Tax_GST_Classification__c='SEZ';
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opportunityRecord;
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        invlist.add(invoiceRecord);
        if(invlist.size() > 0){
            update invlist;
        }
        SObject record = invoiceRecord.Id.getSObjectType().newSObject(invoiceRecord.Id);
        String objectType = String.valueOf(record.getSObjectType());
        IRN_Post_on_Generating.ObjectType = 'Invoice__c';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ApexPages.currentPage().getParameters().put('id', invoiceRecord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceRecord);
        IRN_Post_on_Generating staticMethod=new IRN_Post_on_Generating(sc);
        staticMethod.InvokeIRN(); 
        IRN_Post_on_Generating.getIRN(invoiceRecord.Id); 
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void GenerateIRNTestfailed() {
        List<Invoice__c>invlist=new List<Invoice__c>();
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;   
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.GST_Not_Applicable__c = true; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        
        
        insert opportunityRecord;
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        invlist.add(invoiceRecord);
        if(invlist.size() > 0){
            update invlist;
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ApexPages.currentPage().getParameters().put('id', invoiceRecord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceRecord);
        IRN_Post_on_Generating staticMethod=new IRN_Post_on_Generating(sc);
        staticMethod.InvokeIRN(); 
        
        IRN_Post_on_Generating.getIRN(invoiceRecord.Id); 
        Test.stopTest();
    }
    
    
    @isTest
    public static void GenerateIRNTest1() {
        List<Invoice__c>invlist=new List<Invoice__c>();
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        //accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingStreet = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;  
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity2', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';        
        
        insert opportunityRecord;
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        invlist.add(invoiceRecord);
        if(invlist.size() > 0){
            update invlist;
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockServerError());
        ApexPages.currentPage().getParameters().put('id', invoiceRecord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceRecord);
        IRN_Post_on_Generating staticMethod=new IRN_Post_on_Generating(sc);
        staticMethod.InvokeIRN(); 
        
        IRN_Post_on_Generating.getIRN(invoiceRecord.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void generateinvoice() {
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account3','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;  
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity3', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opportunityRecord;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,'Initiate Tax Invoice');
        invoiceRecord.IRN_Number__c = '551d85c35c6691d10271a43f848ab9c27a10aa836a4fe045240bdad140a68f0b';
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockCancel());
        //IRN_Post_on_Generating.getIRN(invoiceRecord.Id);
        PageReference testPage = Page.Cancel_IRN; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(invoiceRecord.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunityRecord); 
        IRN_Post_on_Generating ctr = new IRN_Post_on_Generating (sc); 
        ctr.CanecelIRN();
        
        Test.stopTest();
    }
    
    @isTest
    public static void generateinvoiceCalcel() {
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account3','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;  
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity3', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0;
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opportunityRecord;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        invoiceRecord.IRN_Number__c = '551d85c35c6691d10271a43f848ab9c27a10aa836a4fe045240bdad140a68f0b';
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        Manual_Invoice__c manualInvoiceRecord = ICRA_TestDataFactory.createManualInvoice('OPE', accountReccord.Id, contactRecord.Id,null,null);
        manualInvoiceRecord.Invoice_Created_Date__c=System.Today();
        update manualInvoiceRecord;
        
        Manual_Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoiceRecord.Id);
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockCancelerror());
        //IRN_Post_on_Generating.getIRN(invoiceRecord.Id);
        PageReference testPage = Page.Cancel_IRN; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(invoiceRecord.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunityRecord); 
        IRN_Post_on_Generating ctr = new IRN_Post_on_Generating (sc); 
        ctr.CanecelIRN();
        
        Test.stopTest();
    }
    
    @isTest
    public static void GenerateIRNTest_Manual() {
        List<Manual_Invoice__c> manInvlist= new List<Manual_Invoice__c>();
        Manual_Invoice__c manInv= new Manual_Invoice__c();
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true; 
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';        
        
        insert opportunityRecord;
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Manual_Invoice__c manualInvoiceRecord = ICRA_TestDataFactory.createManualInvoice('OPE', accountReccord.Id, contactRecord.Id,null,null);
        manualInvoiceRecord.Invoice_Created_Date__c=System.Today();
        manualInvoiceRecord.Invoice_Date__c=System.Today();
        manualInvoiceRecord.Invoice_Status__c='QR and IRN - Generated';
        update manualInvoiceRecord;
        manInv= manualInvoiceRecord;
        
        Manual_Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoiceRecord.Id);
        
        manInvlist.add(manInv);
        if(manInvlist.size() > 0){
            update manInvlist;
        }
        IRN_Post_on_Generating.ObjectType = 'Manual_Invoice__c';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ApexPages.currentPage().getParameters().put('id', manualInvoiceRecord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(manualInvoiceRecord);
        IRN_Post_on_Generating staticMethod=new IRN_Post_on_Generating(sc);
        staticMethod.InvokeIRN(); 
        
        IRN_Post_on_Generating.getIRN(manualInvoiceRecord.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void generateinvoiceCalcel_Manual() {
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account3','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;  
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity3', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opportunityRecord;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Manual_Invoice__c manualInvoiceRecord = ICRA_TestDataFactory.createManualInvoice('OPE', accountReccord.Id, contactRecord.Id,null,null);
        manualInvoiceRecord.Invoice_Created_Date__c=System.Today();
        manualInvoiceRecord.Invoice_Date__c = system.today();
        update manualInvoiceRecord;
        
        Manual_Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoiceRecord.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockCancelerror());
        //IRN_Post_on_Generating.getIRN(invoiceRecord.Id);
        PageReference testPage = Page.Cancel_IRN; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(manualInvoiceRecord.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunityRecord); 
        IRN_Post_on_Generating ctr = new IRN_Post_on_Generating (sc); 
        ctr.CanecelIRN();
        
        Test.stopTest();
    }
    
    @isTest
    public static void GenerateIRNTestfailed_Manual() {
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;   
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';        
        insert opportunityRecord;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Manual_Invoice__c manualInvoiceRecord = ICRA_TestDataFactory.createManualInvoice('OPE', accountReccord.Id, contactRecord.Id,null,null);
        manualInvoiceRecord.Invoice_Created_Date__c=System.Today();
        manualInvoiceRecord.Invoice_Date__c = system.today();
        manualInvoiceRecord.Invoice_Status__c='QR and IRN - Failed';
        update manualInvoiceRecord;
        
        Manual_Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoiceRecord.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock()); 
        ApexPages.currentPage().getParameters().put('id', manualInvoiceRecord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(manualInvoiceRecord);
        IRN_Post_on_Generating staticMethod=new IRN_Post_on_Generating(sc);
        staticMethod.InvokeIRN(); 
        
        IRN_Post_on_Generating.getIRN(manualInvoiceRecord.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void GenerateIRNTest1_Manual() {
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id;
        businessSector.ICRA_Branch__c=branchrecord.Id;
        insert businessSector;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity = 'Delhi';
        accountReccord.ShippingCountry = 'Turkey';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AABCU9603R';
        accountReccord.Constitution_Type_Picklist__c = 'Other';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'Turkey';                  
        //billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27ABCDE1234AKPV';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;    
        billingAddr.Tax_GST_Classification__c='SEZ';
        
        insert billingAddr;
        
        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity2', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord.ASF_Final_Amount__c = 0; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Other reasons';        
        insert opportunityRecord;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
                    try{
                        Insert optyConRoles;//Expecting No Email on Contact Error
                    }catch(Exception ex){
                        System.debug('%%%Exception- '+ex.getMessage());
                    }
        
        Manual_Invoice__c manualInvoiceRecord = ICRA_TestDataFactory.createManualInvoice('OPE', accountReccord.Id, contactRecord.Id,null,null);
        manualInvoiceRecord.Invoice_Created_Date__c=System.Today();
        manualInvoiceRecord.Invoice_Date__c = system.today();
        update manualInvoiceRecord;
        
        Manual_Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoiceRecord.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockServerError());
        ApexPages.currentPage().getParameters().put('id', manualInvoiceRecord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(manualInvoiceRecord);
        IRN_Post_on_Generating staticMethod=new IRN_Post_on_Generating(sc);
        staticMethod.InvokeIRN(); 
        
        IRN_Post_on_Generating.getIRN(manualInvoiceRecord.Id); 
        Test.stopTest();
    }
}