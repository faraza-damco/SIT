@isTest
public with sharing class ICRA_GenerateIRNTest {
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
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        Insert accountReccord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity', 'Surveillance', accountReccord.Id);
         opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        
        
        insert opportunityRecord;
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        invlist.add(invoiceRecord);
        if(invlist.size() > 0){
        update invlist;
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ICRA_GenerateIRN.InvokeIRN(invlist);
        Test.stopTest();
    }
    
    @isTest
    public static void BatchTest() {
        List<Invoice__c>invlist=new List<Invoice__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account1','Issuer',branchrecord.Id);
        Insert accountReccord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Testing Contact','Yes','Account Contact',accountReccord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity1', 'Surveillance', accountReccord.Id);
          opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord.ASF_Final_Amount__c = 0; 
        insert opportunityRecord;
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,'Tax Invoice');
        invoiceRecord.Invoice_Created_Date__c = system.today();
        invoiceRecord.Contact_Name__c = contactRecord.Id;
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        invlist.add(invoiceRecord);
       if(invlist.size() > 0){
        update invlist;
       }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ICRA_GenerateIRNandQRBatch testbatch = new ICRA_GenerateIRNandQRBatch();
        Database.executeBatch(testbatch,1);
        Test.stopTest();
    }
    
    @isTest
    public static void GenerateIRNTest1() {
        List<Invoice__c>invlist=new List<Invoice__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        Insert accountReccord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity2', 'Surveillance', accountReccord.Id);
         opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord.ASF_Final_Amount__c = 0; 
        
        
        insert opportunityRecord;
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        invlist.add(invoiceRecord);
        if(invlist.size() > 0){
        update invlist;
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockServerError());
        ICRA_GenerateIRN.InvokeIRN(invlist);
        Test.stopTest();
    }
    
    @isTest
    public static void generateinvoice() {
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account3','Issuer',branchrecord.Id);
        Insert accountReccord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunnity3', 'Surveillance', accountReccord.Id);
         opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.Billing_End_Date__c = System.today().addYears(1); 
        opportunityRecord.ASF_Final_Amount__c = 0; 
        insert opportunityRecord;
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;
        Invoice_Line_Item__c invl = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockError());
        ICRA_GenerateIRN.getIRN(invoiceRecord.Id,invoiceRecord.Bill_No__c);
        ICRA_GenerateIRN.updateInvoice(invoiceRecord.IRN_Number__c,invoiceRecord.Id, null, invoiceRecord.Invoice_Status__c);
        Test.stopTest();
    }
}