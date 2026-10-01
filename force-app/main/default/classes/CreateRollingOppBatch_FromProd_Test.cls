@isTest
public with sharing class CreateRollingOppBatch_FromProd_Test { 
      private static final String INVOICEROLE = 'Name on Invoice';
    @testSetup
    public static void CreateRollingOpportunityBatchTest() {
        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Pune');
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;

        Business_Sector__c businessSector = new Business_Sector__c(); 
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        businessSector.ICRA_Branch__c = branch.Id; 
        insert businessSector;

        Business_Sector__c businessSector1 = new Business_Sector__c(); 
        businessSector1.Name = 'Infrastructure';
        businessSector1.Business_Head__c =  usrLH.Id; 
        businessSector1.OFAC_Approver__c = usrLH.Id; 
        businessSector1.Opportunity_Checker__c = usrLH.Id; 
        businessSector1.ICRA_Branch__c = branchrecord.Id; 
        insert businessSector1;
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Damco Test','Issuer',branchrecord.Id);
        accountReccord.Group_Name__c = 'testGroup';
        accountReccord.Branch__c = branch.Id;
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.PAN_Number__c = 'AAFCR5512V';
        accountReccord.TAN_Number__c = 'DELC06851F';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.ofac_check__c =true;
        accountReccord.Account_Status__c ='Active';
        accountReccord.Constitution_Type_Picklist__c ='Other';
        Insert accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branch.Id);
        accountReccord1.Group_Name__c = 'test';
        accountReccord1.Business_Sector__c = businessSector1.Id;
        accountReccord1.Branch__c = branchrecord.Id;
        accountReccord1.PAN_Number__c = 'AAFCR5512D';
        accountReccord1.TAN_Number__c = 'DELC06851G';
        accountReccord1.ShippingCity ='Delhi';
        accountReccord1.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord1.ShippingPostalCode ='110001';
        accountReccord1.ShippingState ='Delhi';
        accountReccord1.ShippingCountry ='India';
        accountReccord1.ofac_check__c =true;
        accountReccord1.Account_Status__c ='Active';
        accountReccord1.Constitution_Type_Picklist__c ='Other';
        Insert accountReccord1;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';      
        insert billingAddr;

        Billing_Address__c billingAddr1 = new Billing_Address__c();
        billingAddr1.Name = 'Damco Test 1';                     
        billingAddr1.Account_Name__c = accountReccord1.Id;           
        billingAddr1.Billing_City__c = 'Mumbai';                 
        billingAddr1.BillingCountry__c = 'India';                  
        billingAddr1.BillingState__c = 'Maharashtra';                  
        billingAddr1.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr1.GSTN__c = '27AAFCR5512D1ZP';               
        billingAddr1.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr1.Is_Primary_Billing_Address__c = true;      
        billingAddr1.Tax_GST_Classification__c = 'Non-SEZ';      
        insert billingAddr1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
        Test.startTest(); 
        // BRL Opportunity
        Opportunity opportunityRecord_blr = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord.Id);
        opportunityRecord_blr.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr.Client_Status__c = 'Live';
        opportunityRecord_blr.Alignment_Logic__c = '12 Months';
        opportunityList.add(opportunityRecord_blr);
        
        // BRL Opportunity
        Opportunity opportunityRecord_blr1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 2', 'Surveillance', accountReccord.Id);
        opportunityRecord_blr1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Billing_Start_Date__c = System.today().addDays(-100);
        opportunityRecord_blr1.Billing_End_Date__c = System.today().addDays(-100).addYears(1);
        opportunityRecord_blr1.Client_Status__c = 'Live';
        opportunityRecord_blr1.Alignment_Logic__c = '12 Months';
        opportunityRecord_blr1.Non_Cooperation_Withdrawal_Reason__c = 'Others';
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
        Opportunity opportunityRecord_mm = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 3', 'Surveillance', accountReccord.Id);
        opportunityRecord_mm.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mm.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mm.Instrument_type_3__c = 'Bonds';
        opportunityRecord_mm.Instrument_type_4__c = 'Bonds';  
        opportunityRecord_mm.Billing_Start_Date__c = System.today().addDays(-50);
        opportunityRecord_mm.Billing_End_Date__c = System.today().addDays(-50).addYears(1);
        opportunityRecord_mm.Client_Status__c = 'Live';
        opportunityRecord_mm.Alignment_Logic__c = '12 Months';
        opportunityRecord_mm.Mandate_ID__c = '141500001';
        opportunityRecord_mm.Rollover_Check__c = true;
        opportunityRecord_mm.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        //opportunityList.add(opportunityRecord_mm);
        insert opportunityRecord_mm;
        
         Opportunity opportunityRecord_mm2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 4', 'Surveillance', accountReccord.Id);
        opportunityRecord_mm2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mm2.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mm2.Instrument_type_3__c = 'Bonds';
        opportunityRecord_mm2.Instrument_type_4__c = 'Bonds';  
        opportunityRecord_mm2.Billing_Start_Date__c = Date.newInstance(2021,09,01);   
        opportunityRecord_mm2.Billing_End_Date__c = date.newInstance(2021, 12 ,01);
        opportunityRecord_mm2.Change_in_start_Date__c  =  false;
        opportunityRecord_mm2.Rollover_Check__c  =  true;
        opportunityRecord_mm2.Client_Status__c = 'Live';
        opportunityRecord_mm2.Mandate_ID__c = '141500002';
        opportunityRecord_mm2.Alignment_Logic__c = '12 Months';
        opportunityRecord_mm2.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        //opportunityList.add(opportunityRecord_mm2);
        insert opportunityRecord_mm2;
        
        // MM Opportunity
        Opportunity opportunityRecord_mm1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 5', 'Surveillance', accountReccord.Id);
        opportunityRecord_mm1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mm1.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mm1.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord_mm1.Instrument_type_4__c = 'Commercial Paper';  
        opportunityRecord_mm1.Billing_Start_Date__c = System.today().addDays(-50);
        opportunityRecord_mm1.Billing_End_Date__c = System.today().addDays(-50).addYears(1);
        opportunityRecord_mm1.Client_Status__c = 'Live';
        opportunityRecord_mm1.Mandate_ID__c = '141500003';
        opportunityRecord_mm1.Alignment_Logic__c = '12 Months';
        opportunityRecord_mm1.Rollover_Check__c  =  true;
        opportunityRecord_mm1.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        //opportunityList.add(opportunityRecord_mm1);
        insert opportunityRecord_mm1;
        
        //MF Opportunity
        Opportunity opportunityRecord_mf = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 6', 'Surveillance', accountReccord.Id);
        opportunityRecord_mf.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mf.Instrument_type_2__c = 'Others';
        opportunityRecord_mf.Instrument_type_3__c = 'Mutual Fund';
        opportunityRecord_mf.Instrument_type_4__c = 'Mutual Fund Rating'; 
        opportunityRecord_mf.Billing_Start_Date__c = System.today().addDays(-200);
        opportunityRecord_mf.Billing_End_Date__c = System.today().addDays(-200).addYears(1);
        opportunityRecord_mf.Client_Status__c = 'Live';
        opportunityRecord_mf.Mandate_ID__c = '141500004';
        opportunityRecord_mf.Alignment_Logic__c = 'Financial Year';
        opportunityRecord_mf.Rollover_Check__c  =  true;
        opportunityRecord_mf.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        //opportunityList.add(opportunityRecord_mf);
        insert opportunityRecord_mf;
        
        //MF Opportunity
        Opportunity opportunityRecord_mf1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 7', 'Surveillance', accountReccord.Id);
        opportunityRecord_mf1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mf1.Instrument_type_2__c = 'Others';
        opportunityRecord_mf1.Instrument_type_3__c = 'Others';
        opportunityRecord_mf1.Instrument_type_4__c = 'Issuer Rating'; 
        opportunityRecord_mf1.Billing_Start_Date__c = System.today().addYears(-1);
        opportunityRecord_mf1.Billing_End_Date__c = System.today();
        opportunityRecord_mf1.Client_Status__c = 'Live';
        opportunityRecord_mf1.Mandate_ID__c = '141500005';
        opportunityRecord_mf1.Alignment_Logic__c = 'Financial Year';
        //opportunityList.add(opportunityRecord_mf1); 
        opportunityRecord_mf1.Rollover_Check__c  =  true;
        opportunityRecord_mf1.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        insert opportunityRecord_mf1;
        
        // SF MM Opportunity
        Opportunity opportunityRecord_smf = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 8', 'Surveillance', accountReccord.Id);
        opportunityRecord_smf.Instrument_type_1__c = 'Structured Finance';
        opportunityRecord_smf.Instrument_type_2__c = 'Rating - Money Market (SF)';
        opportunityRecord_smf.Instrument_type_3__c = 'Asset Backed Security';
        opportunityRecord_smf.Instrument_type_4__c = 'Assignee Payout'; 
        opportunityRecord_mf1.Billing_Start_Date__c = System.today().addYears(1).addDays(100);
        opportunityRecord_mf1.Billing_End_Date__c = System.today().addYears(1).addDays(100).addyears(1);
        opportunityRecord_mf1.Client_Status__c = 'Live';
        opportunityRecord_mf1.Mandate_ID__c = '141500006';
        opportunityRecord_mf1.Alignment_Logic__c = 'Financial Year';
        //opportunityList.add(opportunityRecord_smf); 
        opportunityRecord_smf.Rollover_Check__c  =  true;
        opportunityRecord_smf.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        insert opportunityRecord_smf;
        
        //MF Opportunity
        Opportunity opportunityRecord_mf2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 9', 'Surveillance', accountReccord.Id);
        opportunityRecord_mf2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mf2.Instrument_type_2__c = 'Others';
        opportunityRecord_mf2.Instrument_type_3__c = 'Others';
        opportunityRecord_mf2.Instrument_type_4__c = 'Issuer Rating'; 
        opportunityRecord_mf2.Billing_Start_Date__c = System.today();
        opportunityRecord_mf2.BD_Approve__c = true;
        opportunityRecord_mf2.Billing_End_Date__c = System.today().addYears(1);
        opportunityRecord_mf2.Client_Status__c = 'Live';
        opportunityRecord_mf2.Mandate_ID__c = '141500007';
        opportunityRecord_mf2.Alignment_Logic__c = 'Financial Year';
        //opportunityList.add(opportunityRecord_mf2); 
        //insert opportunityRecord_mf2;

        Opportunity IPO_Monitoring_Opty = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL 9', 'Surveillance', accountReccord.Id);
        IPO_Monitoring_Opty.Instrument_type_1__c = 'Non Structured Finance';
        IPO_Monitoring_Opty.Instrument_type_2__c = 'Others';
        IPO_Monitoring_Opty.Instrument_type_3__c = 'Others';
        IPO_Monitoring_Opty.Instrument_type_4__c = 'Monitoring Activity'; 
        IPO_Monitoring_Opty.Billing_Duration__c = 'Quarterly';
        IPO_Monitoring_Opty.BD_Approve__c = true;
        IPO_Monitoring_Opty.Client_Status__c = 'Live';
        IPO_Monitoring_Opty.Mandate_ID__c = '141500008';
        IPO_Monitoring_Opty.Defer_Billing_or_Exit_Case__c = 'Already Billed';
        IPO_Monitoring_Opty.Fund_Utilization__c = false;
        IPO_Monitoring_Opty.IPO_Surveillance_Created__c = false;
        IPO_Monitoring_Opty.StageName = 'Closed Won';
        IPO_Monitoring_Opty.Rollover_Check__c  =  true;
        IPO_Monitoring_Opty.Bypass_Validation__c  =  true;
        IPO_Monitoring_Opty.Billing_Start_Date__c = System.today();
        IPO_Monitoring_Opty.Revised_Billing_End_Date__c = System.today().addDays(14);
        IPO_Monitoring_Opty.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        insert IPO_Monitoring_Opty;
        //update IPO_Monitoring_Opty;
        Test.stopTest();
    }
    
    @isTest
    public static void createRollingUnit(){
        Account acc= [Select Id, Name, account_status__c from account where name='Damco Test'];
        Opportunity opportunityRecord_ro= [Select Id, name from opportunity where name='Test Opportunity BRL 7'];
        opportunityRecord_ro.ASF_Final_Amount__c = 100000;
        opportunityRecord_ro.Rolling_and_Date_Alignmnet__c = false;
        Update opportunityRecord_ro;
        Test.startTest(); 
        Database.executeBatch(new CreateRollingOpportunityBatch_FromProd(acc.name, opportunityRecord_ro.Id),50);
        Test.stopTest();
    }

    @isTest
    public static void createRollingUnit2(){
        Account accN= [Select Id, Name, account_status__c from account where name='Damco Test'];
        Opportunity opportunityRecord_roo= [Select Id, name from opportunity where name='Test Opportunity BRL 6'];
        opportunityRecord_roo.ASF_Final_Amount__c = 100000;
        opportunityRecord_roo.Rolling_and_Date_Alignmnet__c = false;
        Update opportunityRecord_roo;
        Test.startTest(); 
        Database.executeBatch(new CreateRollingOpportunityBatch_FromProd(accN.name, opportunityRecord_roo.Id),50);
        Test.stopTest();
    }
    
    @isTest
    public static void createRollingUnit3(){
        Account accNam= [Select Id, Name, account_status__c from account where name='Damco Test'];
        Opportunity opportunityRecord_rool= [Select Id, name from opportunity where name='Test Opportunity BRL 2'];
        opportunityRecord_rool.ASF_Final_Amount__c = 100000;
        opportunityRecord_rool.Rolling_and_Date_Alignmnet__c = false;
        opportunityRecord_rool.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        Update opportunityRecord_rool;
        Test.startTest(); 
        Database.executeBatch(new CreateRollingOpportunityBatch_FromProd(accNam.name, opportunityRecord_rool.Id),50);
        Test.stopTest();
    }

    @isTest
    public static void dateAlignmentUnit(){
        Test.startTest(); 
        Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch(),51); 
        Test.stopTest();
    }
    
    
    /*@isTest
    public static void proformaInvoiceGenrationUnit(){
        Test.startTest();  
        Database.executeBatch(new ICRA_ProformaInvoiceGenrationBatch(),10);
        Test.stopTest();
    }*
    
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
    
  /*  @isTest
    public static void UpdateInvoiceStatusSchedule() {
		Test.StartTest();
		ICRA_UpdateInvoiceStatusScheduler testsched = new ICRA_UpdateInvoiceStatusScheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	}*/
    
    @isTest
    public static void dateAlignmentSchedule() {
		Test.StartTest();
		ICRA_OpportunityDateAlignmentSchedule testsched = new ICRA_OpportunityDateAlignmentSchedule();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	}

    @isTest
    public static void alreadyBilledOpty(){
        Test.StartTest();
		//InvokeBatch_AlreadyBilledOpty testsched = new InvokeBatch_AlreadyBilledOpty();
        InvokeBatch_AlreadyBilledOpty.invokeBatch();
		Test.stopTest();
    }

}