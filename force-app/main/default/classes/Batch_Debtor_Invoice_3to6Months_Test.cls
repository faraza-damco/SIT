@isTest
public class Batch_Debtor_Invoice_3to6Months_Test {
    
    @testSetup
    public static void DebtorInvoice3to6months(){
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Testing Account', 'Issuer', branchRecord.Id);
        accountRecord.Last_Debtor_Invoice_Date__c = date.newInstance(2021, 11, 20);
        insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Testing Contact', 'Yes', 'Account Contact', accountRecord.Id); 
        contactRecord.Debtor_Email__c = 'Yes';
        contactRecord.Contact_Debtor_Type__c = '180Days'; 
        insert contactRecord;
        
        Debtor_Invoice__c debtorInvoiceRecord = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord.Email_Already_Send__c = false;
        debtorInvoiceRecord.Invoice_Date__c = date.newInstance(2021, 11, 20);
        insert debtorInvoiceRecord;
        
        Debtor_Invoice__c debtorInvoiceRecord1 = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord1.Email_Already_Send__c = false;
        debtorInvoiceRecord1.Invoice_Date__c = date.newInstance(2021, 11, 20);
        insert debtorInvoiceRecord1;
        
        
        Debtor_Payment__c debtorpaymentRcord = ICRA_TestDataFactory.createDebtorPayment(accountRecord.id,debtorInvoiceRecord.id);
        
    }
    @isTest
    public static void runBatch(){
        Test.startTest();
        Database.executeBatch(new Batch_Debtor_Invoice_3to6Months(),20);
        Test.stopTest();
    }
}