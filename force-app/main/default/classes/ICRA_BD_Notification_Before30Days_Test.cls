@isTest
public class ICRA_BD_Notification_Before30Days_Test {
    
    @IsTest
    public static void isDataSetup(){
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
        opportunityRecord.CloseDate = System.today().addDays(2);
        opportunityRecord.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord;
        
        Opportunity opportunityRecord1 = ICRA_TestDataFactory.creatOpportunity('Testing Opportunity2', 'Surveillance', accountRecord.Id);
        opportunityRecord1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord1.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord1.CloseDate = System.today();
        opportunityRecord1.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord1;
        
        
         Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id); 
                Invoice_Line_Item__c invoiceLineRecord_B =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord1.Id); 

    System.debug('==Opp object='+opportunityRecord);
     Test.startTest();  
        
        Database.executeBatch(new ICRA_BD_Notification_Before30Days(),50);
        Test.stopTest();
    }
    
}