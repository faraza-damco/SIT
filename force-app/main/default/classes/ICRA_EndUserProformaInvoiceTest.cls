@isTest
public class ICRA_EndUserProformaInvoiceTest {
    @isTest
    public static void EndUserProformaInvoiceTest(){
         Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Test Accont', 'Issuer', branchRecord.Id); 
        insert accountRecord;
        
        System.debug('===== accountRecord ==='+accountRecord);
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        System.debug('===== contactRecord ==='+contactRecord);
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'Surveillance', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord.CloseDate = System.today();
        opportunityRecord.Proforma_Invoice_ok__c = True;
        opportunityRecord.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord;
        
        System.debug('=== opportunityRecord==='+opportunityRecord);
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'Proforma Invoice');
        invoiceRecord.Invoice_Created_Date__c = date.newInstance(2021, 12, 05);
        insert invoiceRecord;
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id); 
        System.debug('==== invoiceRecord ====='+invoiceRecord);
        System.debug('==== invoiceRecord ====='+invoiceRecord.Invoice_Status__c);
        ICRA_SaveInvoicePDF.saveInvoice(invoiceRecord.Id);
        Test.startTest();
        database.executeBatch(new ICRA_EndUserProformaInvoice_Notification(),200);
        Test.stopTest();
        
    }

}