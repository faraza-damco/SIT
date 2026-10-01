@isTest
public class ICRA_UpdateInvoiceStatusBatch_Test {
 @testSetup
    public static void UpdateInvoiceStatusBatch(){
      
         Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Test Accont', 'Issuer', branchRecord.Id); 
        insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'Surveillance', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord.CloseDate = System.today();
        opportunityRecord.BD_Approve__c = true;
        //opportunityRecord.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord;
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'Proforma Invoice');
        insert invoiceRecord;
        
         
        
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
       
        
        
    }
    @isTest
    public static void runBatch(){
        Test.startTest();
        Database.executeBatch(new ICRA_UpdateInvoiceStatusBatch(),20);
        Test.stopTest();
    }
    
}