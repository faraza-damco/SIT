@isTest
public class CreateInvoiceByNameonInvoice_Test {
   // private static final String INVOICEROLE = 'Name on Invoice';
 @isTest
    public static void createmultipleinvoice(){
        String INVOICEROLE = 'Name on Invoice';
        List<Id>optylist = new List<Id>();
        List<Id>optylist2 = new List<Id>();
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
        opportunityRecord.StageName = 'Closed Won';
       // insert opportunityRecord;
        
        
        Opportunity opportunityRecord2 = ICRA_TestDataFactory.creatOpportunity('Test 1', 'New Business', accountRecord.Id);
        opportunityRecord2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord2.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord2.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord2.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecord2.ASF_Final_Amount__c = 1000; 
        
        opportunityRecord2.Invoice_Generation_Date__c = System.today();
        opportunityRecord2.Billing_Start_Date__c = System.today();
        opportunityRecord2.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord2.Defer_Billing_or_Exit_Case__c = ''; 
        
        opportunityRecord2.StageName = 'L1 Meeting';
        opportunityRecord2.Customer_Fee_Type__c = 'Non - Cap';

        Insert opportunityRecord2;
        
        
          // BRL Opportunity
        Opportunity opportunityRecord_blr1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountRecord.Id);
        opportunityRecord_blr1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr1.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_blr1.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord_blr1.Instrument_type_4__c = 'Various Debt Instruments';
        opportunityRecord_blr1.Billing_Start_Date__c = System.today() ;
        opportunityRecord_blr1.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord_blr1.StageName = 'Closed Won';
        Insert opportunityRecord_blr1;
        opportunityRecord_blr1.PR_Date__c = System.today();
        
        Update opportunityRecord_blr1;
        
        optylist.add(opportunityRecord_blr1.Id);
        optylist2.add(opportunityRecord2.Id);
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_blr1.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
        List<OpportunityContactRole> optyConRoles2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
       opportunityRecord2.Proposed_Rating_Fee__c = 100;
        opportunityRecord2.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord2.StageName = 'Negotiation';
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord2;
        opportunityRecord2.StageName = 'Discount Approved';
        update opportunityRecord2;
        opportunityRecord2.StageName = 'Closed Won';
        update opportunityRecord2;
        
        Test.startTest();
        CreateInvoiceByNameonInvoice.filterAndCreateInvoice(optylist); 
        CreateInvoiceByNameonInvoice.filterAndCreateInvoice(optylist2); 
        //CreateInvoiceByNameonInvoice.filterAndCreateInvoice(optylist);   
        Test.stopTest();   
    } 
}