@isTest
public class Debtor_Invoice_6to12MonthController_Test {
@testSetup
    public static void Debtor_Invoice_6to12MonthController_Test(){
         Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Testing Account', 'Issuer', branchRecord.Id);
        accountRecord.Last_Debtor_Invoice_Date__c = date.newInstance(2022, 03, 14);
        insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Testing Contact', 'Yes', 'Account Contact', accountRecord.Id); 
        contactRecord.Debtor_Email__c = 'Yes';
        contactRecord.Contact_Debtor_Type__c = '1year'; 
        insert contactRecord; 
        
         Debtor_Invoice__c debtorInvoiceRecord = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord.Email_Already_Send__c = false;
        debtorInvoiceRecord.Invoice_Date__c = date.newInstance(2022, 03, 14);
        insert debtorInvoiceRecord;
        
        Debtor_Invoice__c debtorInvoiceRecord1 = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord1.Email_Already_Send__c = false;
        debtorInvoiceRecord1.Invoice_Date__c = date.newInstance(2022, 03, 14);
        insert debtorInvoiceRecord1;
        
        
        Debtor_Payment__c debtorpaymentRcord = ICRA_TestDataFactory.createDebtorPayment(accountRecord.id,debtorInvoiceRecord.id);
        
    }
    
      @isTest
    public Static void runBatchUnit(){
       Debtor_Invoice_6to12Months_Controller Debtor_Invoice_6to12Months = new Debtor_Invoice_6to12Months_Controller();  
        
         Debtor_Invoice_6to12Months.accountID = ([SELECT ID , Name FROM Account LIMIT 1 ]).size() > 0 ? ([SELECT ID , Name FROM Account LIMIT 1 ])[0].ID : null ;
        Debtor_Invoice_6to12Months.getDebtorInvoiceDetail();
       
    }   
        
        
    }