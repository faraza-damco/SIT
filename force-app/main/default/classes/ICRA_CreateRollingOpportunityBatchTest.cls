@isTest
public with sharing class ICRA_CreateRollingOpportunityBatchTest { 
     private static final String INVOICEROLE = 'Name on Invoice';
    @testSetup
    public static void CreateRollingOpportunityBatchTest() {
        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Damco Test','Issuer',branchrecord.Id);
        Insert accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branchrecord.Id);
        Insert accountReccord1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
        
        // BRL Opportunity
        Opportunity opportunityRecord_blr = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord.Id);
        opportunityRecord_blr.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_blr);
        
        // BRL Opportunity
        Opportunity opportunityRecord_blr1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord.Id);
        opportunityRecord_blr1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Billing_Start_Date__c = System.today().addDays(-100);
        opportunityRecord_blr1.Billing_End_Date__c = System.today().addDays(-100).addYears(1);
        opportunityRecord_blr1.Client_Status__c = 'Live';
        Insert opportunityRecord_blr1;
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
        
        //opportunityList.add(opportunityRecord_blr1);
        
        // MM Opportunity
        Opportunity opportunityRecord_mm = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_mm.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mm.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mm.Instrument_type_3__c = 'Bonds';
        opportunityRecord_mm.Instrument_type_4__c = 'Bonds';  
        opportunityRecord_mm.Billing_Start_Date__c = System.today().addDays(-50);
        opportunityRecord_mm.Billing_End_Date__c = System.today().addDays(-50).addYears(1);
        opportunityRecord_mm.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_mm);
        
         Opportunity opportunityRecord_mm2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_mm2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mm2.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mm2.Instrument_type_3__c = 'Bonds';
        opportunityRecord_mm2.Instrument_type_4__c = 'Bonds';  
        opportunityRecord_mm2.Billing_Start_Date__c = Date.newInstance(2021,09,01);   
        opportunityRecord_mm2.Billing_End_Date__c = date.newInstance(2021, 12 ,01);
        opportunityRecord_mm2.Change_in_start_Date__c  =  false;
        opportunityRecord_mm2.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_mm2);
        
        // MM Opportunity
        Opportunity opportunityRecord_mm1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_mm1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mm1.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mm1.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord_mm1.Instrument_type_4__c = 'Commercial Paper';  
        opportunityRecord_mm1.Billing_Start_Date__c = System.today().addDays(-50);
        opportunityRecord_mm1.Billing_End_Date__c = System.today().addDays(-50).addYears(1);
        opportunityRecord_mm1.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_mm1);
        
        //MF Opportunity
        Opportunity opportunityRecord_mf = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_mf.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mf.Instrument_type_2__c = 'Others';
        opportunityRecord_mf.Instrument_type_3__c = 'Mutual Fund';
        opportunityRecord_mf.Instrument_type_4__c = 'Mutual Fund Rating'; 
        opportunityRecord_mf.Billing_Start_Date__c = System.today().addDays(-200);
        opportunityRecord_mf.Billing_End_Date__c = System.today().addDays(-200).addYears(1);
        opportunityRecord_mf.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_mf);
        
        //MF Opportunity
        Opportunity opportunityRecord_mf1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_mf1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mf1.Instrument_type_2__c = 'Others';
        opportunityRecord_mf1.Instrument_type_3__c = 'Others';
        opportunityRecord_mf1.Instrument_type_4__c = 'Issuer Rating'; 
        opportunityRecord_mf1.Billing_Start_Date__c = System.today().addYears(-1);
        opportunityRecord_mf1.Billing_End_Date__c = System.today();
        opportunityRecord_mf1.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_mf1); 
        
        // SF MM Opportunity
        Opportunity opportunityRecord_smf = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_smf.Instrument_type_1__c = 'Structured Finance';
        opportunityRecord_smf.Instrument_type_2__c = 'Rating - Money Market (SF)';
        opportunityRecord_smf.Instrument_type_3__c = 'Asset Backed Security';
        opportunityRecord_smf.Instrument_type_4__c = 'Assignee Payout'; 
        opportunityRecord_mf1.Billing_Start_Date__c = System.today().addYears(1).addDays(100);
        opportunityRecord_mf1.Billing_End_Date__c = System.today().addYears(1).addDays(100).addyears(1);
        opportunityRecord_mf1.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_smf); 
        
        //MF Opportunity
        Opportunity opportunityRecord_mf2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord1.Id);
        opportunityRecord_mf2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mf2.Instrument_type_2__c = 'Others';
        opportunityRecord_mf2.Instrument_type_3__c = 'Others';
        opportunityRecord_mf2.Instrument_type_4__c = 'Issuer Rating'; 
        opportunityRecord_mf2.Billing_Start_Date__c = System.today();
        opportunityRecord_mf2.BD_Approve__c = true;
        opportunityRecord_mf2.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord_mf2.Client_Status__c = 'Live';
        opportunityList.add(opportunityRecord_mf2); 
        
        Insert opportunityList;
        
        
    }
    
    @isTest
    public static void createRollingUnit(){
        Test.startTest(); 
        Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        Test.stopTest();
    }
    
   /* @isTest
    public static void dateAlignmentUnit(){
        Test.startTest(); 
        Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch(),51); 
        Test.stopTest();
    }
    
    
    @isTest
    public static void proformaInvoiceGenrationUnit(){
        Test.startTest();  
        Database.executeBatch(new ICRA_ProformaInvoiceGenrationBatch(),10);
        Test.stopTest();
    }
    
    @isTest
    public static void invoiceGenrationUnit(){
        Test.startTest();  
        Database.executeBatch(new ICRA_InvoiceGenrationBatch(),2); 
        Test.stopTest();
    }//
    
    @isTest
    public static void updateInvoiceStatusUnit(){
        Test.startTest();  
        Database.executeBatch(new ICRA_UpdateInvoiceStatusBatch(),2); 
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateInvoiceStatusSchedule() {
		Test.StartTest();
		ICRA_UpdateInvoiceStatusScheduler testsched = new ICRA_UpdateInvoiceStatusScheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	}
    
    @isTest
    public static void dateAlignmentSchedule() {
		Test.StartTest();
		ICRA_OpportunityDateAlignmentSchedule testsched = new ICRA_OpportunityDateAlignmentSchedule();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	} */
}