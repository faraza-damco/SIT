@isTest
public class ICRA_InvoiceLineRollUpHandler_Test {
    
    @isTest
    public static void rollupTest(){
        ICRA_TestDataFactory.loadCustomeSetting();
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id); 
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null);  
        List<Invoice_Line_Item__c> lineList = new List<Invoice_Line_Item__c>();
        lineList.add(ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id));
        ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        ICRA_InvoiceLineRollUpHandler invoiceLineRollUp = new ICRA_InvoiceLineRollUpHandler();
        invoiceLineRollUp.rollUpInvoiceLines(lineList);
        Delete lineList;
    }
    
    @isTest
    public static void rollupCancledTest(){
        ICRA_TestDataFactory.loadCustomeSetting();
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id); 
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null);
        invoiceRecord.Invoice_Status__c = Label.Invoice_Rollup_Filter; 
        List<Invoice_Line_Item__c> lineList = new List<Invoice_Line_Item__c>();
        lineList.add(ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id));
        ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        ICRA_InvoiceLineRollUpHandler invoiceLineRollUp = new ICRA_InvoiceLineRollUpHandler();
        invoiceLineRollUp.rollUpInvoiceLines(lineList);
        Update invoiceRecord;
        Update lineList;
        
        Invoice__c invoiceRecord_B  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null);
        Invoice_Line_Item__c line_B = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord_B.Id, opportunityRecord.Id);
        Invoice_Line_Item__c line_C = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord_B.Id, opportunityRecord.Id);
        line_B.Comments__c='TEst';
        Update invoiceRecord_B;
        DELETE line_B;
    }
    
}