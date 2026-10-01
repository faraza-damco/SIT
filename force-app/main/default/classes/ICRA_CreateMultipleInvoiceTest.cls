@isTest
public with sharing class ICRA_CreateMultipleInvoiceTest {
    @isTest
    public static void createmultipleinvoice(){
        List<Opportunity>optylist = new List<Opportunity>();
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branchRecord.Id); 
        Insert accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Contact 1', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Oppotunnity', 'Surveillance', accountRecord.Id);
        opportunityRecord.Total_Invoice_Amount_1__c = 0;
        opportunityRecord.CloseDate =  System.today();
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (Non-SF)';
        opportunityRecord.Instrument_type_3__c ='Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord.Instrument_type_4__c ='Commercial Paper';
        opportunityRecord.BD_Approve__c = true;
        insert opportunityRecord;
        
        
        Opportunity opportunityRecord2 = ICRA_TestDataFactory.creatOpportunity('Test 1', 'New Business', accountRecord.Id);
        opportunityRecord2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord2.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord2.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord2.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecord2.ASF_Final_Amount__c = 10; 
        opportunityRecord2.Invoice_Generation_Date__c = System.today();
        opportunityRecord2.Billing_Start_Date__c = System.today();
        opportunityRecord2.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord2.Defer_Billing_or_Exit_Case__c = ''; 
        
        insert opportunityRecord2;
        
          // BRL Opportunity
        Opportunity opportunityRecord_blr1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountRecord.Id);
        opportunityRecord_blr1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Billing_Start_Date__c = System.today() ;
        opportunityRecord_blr1.Billing_End_Date__c = System.today().addYears(1);
        Insert opportunityRecord_blr1;
        opportunityRecord2.PR_Date__c = System.today();
        Update opportunityRecord2;
        
        optylist.add(opportunityRecord);
        optylist.add(opportunityRecord2);
        optylist.add(opportunityRecord_blr1);
        
        Test.startTest();
        ICRA_CreateMultipleInvoice.filterAndCreateInvoice(optylist,'Surveillance-90');   
        ICRA_CreateMultipleInvoice.filterAndCreateInvoice(optylist,'New Business');   
        Test.stopTest();   
    } 
}