@isTest
public class ICRA_DebtorEmail1to3Months_Control_Test {
    @testSetup
    public static void ICRA_DebtorEmail1to3Months_Control_Test(){

        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Testing Account', 'Issuer', branchRecord.Id);
        accountRecord.Last_Debtor_Invoice_Date__c = date.newInstance(2021, 12, 01);
        insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Testing Contact', 'Yes', 'Account Contact', accountRecord.Id); 
        contactRecord.Debtor_Email__c = 'Yes';
        contactRecord.Contact_Debtor_Type__c = '90Days'; 
        insert contactRecord; 
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'Surveillance', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord.CloseDate = System.today();
        opportunityRecord.Last_Invoice_Date__c =  date.newInstance(2021, 12, 01);
        opportunityRecord.Total_Invoice_Amount_1__c = 15;
        opportunityRecord.Payment_Receipt_Base_Amount__c = 5;
        insert opportunityRecord;
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,null);
        invoiceRecord.Invoice_Created_Date__c = date.newInstance(2021, 12, 01);
        invoiceRecord.Contact_Name__c = contactRecord.Id;
        insert invoiceRecord;
        
        
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id); 
        
        Payment_Receipt__c paymentReceiptRecord = ICRA_TestDataFactory.createPaymentReceipt(opportunityRecord.Id,invoiceRecord.Id);
        Insert paymentReceiptRecord; 
        
        Debtor_Invoice__c debtorInvoiceRecord = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord.Email_Already_Send__c = false;
        debtorInvoiceRecord.Invoice_Date__c = date.newInstance(2021, 12, 01);
        insert debtorInvoiceRecord;
        
        Debtor_Invoice__c debtorInvoiceRecord1 = ICRA_TestDataFactory.createDebtorInvoiceRecord(accountRecord.id,10000);
        debtorInvoiceRecord1.Email_Already_Send__c = false;
        debtorInvoiceRecord1.Invoice_Date__c = date.newInstance(2021, 12, 01);
        insert debtorInvoiceRecord1;
        
        
        Debtor_Payment__c debtorpaymentRcord = ICRA_TestDataFactory.createDebtorPayment(accountRecord.id,debtorInvoiceRecord.id);
      }
     @isTest
    public Static void runBatchUnit(){
       
        ICRA_DebtorEmail_1to3_Months_Controller debtorEmail_1to3_Months = new ICRA_DebtorEmail_1to3_Months_Controller();
        debtorEmail_1to3_Months.accountID = ([SELECT ID , Name FROM Account LIMIT 1 ]).size() > 0 ? ([SELECT ID , Name FROM Account LIMIT 1 ])[0].ID : null ;
        debtorEmail_1to3_Months.getInvoiceDetail();
      
    }
    
}