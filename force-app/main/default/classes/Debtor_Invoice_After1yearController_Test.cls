@isTest
public class Debtor_Invoice_After1yearController_Test {
@testSetup
    public static void Debtor_Invoice_After1yearController_Test(){
        
         Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Testing Account', 'Issuer', branchRecord.Id);
        accountRecord.Last_Debtor_Invoice_Date__c = date.newInstance(2022, 09, 30);
        insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Testing Contact', 'Yes', 'Account Contact', accountRecord.Id); 
        contactRecord.Debtor_Email__c = 'Yes';
        contactRecord.Contact_Debtor_Type__c = 'After 1year'; 
        insert contactRecord; 
        
         Debtor_Invoice__c debtorInvoiceRecord = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord.Email_Already_Send__c = false;
        debtorInvoiceRecord.Invoice_Date__c = date.newInstance(2022, 09, 30);
        insert debtorInvoiceRecord;
        
        Debtor_Invoice__c debtorInvoiceRecord1 = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord1.Email_Already_Send__c = false;
        debtorInvoiceRecord1.Invoice_Date__c = date.newInstance(2022, 09, 30);
        insert debtorInvoiceRecord1;
        
        
        Debtor_Payment__c debtorpaymentRcord = ICRA_TestDataFactory.createDebtorPayment(accountRecord.id,debtorInvoiceRecord.id);
        
    }
    
      @isTest
    public Static void runBatchUnit(){
         
        Debtor_Invoice_After1year_Controller Invoice_After1year = new Debtor_Invoice_After1year_Controller();
        Invoice_After1year.accountID = ([SELECT ID , Name FROM Account LIMIT 1 ]).size() > 0 ? ([SELECT ID , Name FROM Account LIMIT 1 ])[0].ID : null ;
        Invoice_After1year.getDebtorInvoiceDetail();
        
    }
    }