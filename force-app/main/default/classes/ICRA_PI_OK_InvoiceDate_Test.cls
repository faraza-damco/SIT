@isTest
public class ICRA_PI_OK_InvoiceDate_Test {
    @isTest
    public static void PI_OK_InvoiceDate(){
        List<Opportunity> oppList = new List<Opportunity>();
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id);
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);   
        insert opportunityRecord;
        
        Opportunity opportunityRecord2 = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);   
        insert opportunityRecord2;
        
        oppList.add(opportunityRecord);
        oppList.add(opportunityRecord2);
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'Proforma Invoice'); 
        invoiceRecord.Invoice_Created_Date__c = system.today();
        insert invoiceRecord;
        
        Test.startTest();
        ICRA_PI_OK_InvoiceDate.ICRA_PI_OK_InvoiceDate(oppList);
        Test.stopTest();
    }

}