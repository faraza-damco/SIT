@isTest
public with sharing class ICRA_Revenue_Milestones_Test {
    
    @TestSetup
    public static void dataRevenueMilestone(){ 
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test','Issuer',branchrecord.Id); 
        Insert accountReccord;
        
        Opportunity opportunityRecordnew = ICRA_TestDataFactory.creatOpportunity('Test 1', 'New Business', accountReccord.Id);
        opportunityRecordnew.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecordnew.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecordnew.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecordnew.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecordnew.ASF_Final_Amount__c = 0; 
        opportunityRecordnew.Defer_Billing_or_Exit_Case__c = 'Yes';
        insert opportunityRecordnew;  
        opportunityRecordnew.PR_Date__c = System.today();
        Update opportunityRecordnew; 
        
        Opportunity opportunityRecordsf = ICRA_TestDataFactory.creatOpportunity('Test 2', 'Surveillance', accountReccord.Id);
        opportunityRecordsf.Instrument_type_1__c = 'Structured Finance';
        opportunityRecordsf.Instrument_type_2__c = 'Rating - Money Market (SF)';
        opportunityRecordsf.Instrument_type_3__c = 'Asset Backed Security';
        opportunityRecordsf.Instrument_type_4__c = 'Assignee Payout';  
        opportunityRecordsf.Batch_is_Running__c = true;
        opportunityRecordsf.Commercial_Head__c = System.UserInfo.getUserId(); 
        Insert opportunityRecordsf;
        
        Opportunity opportunityRecordBonds = ICRA_TestDataFactory.creatOpportunity('Test 3', 'Surveillance', accountReccord.Id);
        opportunityRecordBonds.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecordBonds.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecordBonds.Instrument_type_3__c = 'Bonds';
        opportunityRecordBonds.Instrument_type_4__c = 'Bonds';  
        opportunityRecordBonds.Batch_is_Running__c = true;
        opportunityRecordBonds.Commercial_Head__c = System.UserInfo.getUserId(); 
        Insert opportunityRecordBonds;
        
        Opportunity opportunityRecordcp = ICRA_TestDataFactory.creatOpportunity('Test 4', 'Surveillance', accountReccord.Id);
        opportunityRecordcp.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecordcp.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecordcp.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecordcp.Instrument_type_4__c = 'Certificate of Deposit';  
        opportunityRecordcp.Batch_is_Running__c = true;
        opportunityRecordcp.Commercial_Head__c = System.UserInfo.getUserId(); 
        Insert opportunityRecordcp;
        
        Opportunity opportunityRecordOthers = ICRA_TestDataFactory.creatOpportunity('Test 5', 'Surveillance', accountReccord.Id);
        opportunityRecordOthers.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecordOthers.Instrument_type_2__c = 'Others';
        opportunityRecordOthers.Instrument_type_3__c = 'Others';
        opportunityRecordOthers.Instrument_type_4__c = 'Issuer Rating';  
        opportunityRecordOthers.Batch_is_Running__c = true;
        opportunityRecordOthers.Commercial_Head__c = System.UserInfo.getUserId(); 
        Insert opportunityRecordOthers;
        
        Opportunity opportunityRecordmf = ICRA_TestDataFactory.creatOpportunity('Test 6', 'Surveillance', accountReccord.Id);
        opportunityRecordmf.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecordmf.Instrument_type_2__c = 'Others';
        opportunityRecordmf.Instrument_type_3__c = 'Mutual Fund';
        opportunityRecordmf.Instrument_type_4__c = 'Mutual Fund Rating';  
        opportunityRecordmf.Batch_is_Running__c = true;
        opportunityRecordmf.Commercial_Head__c = System.UserInfo.getUserId(); 
        Insert opportunityRecordmf;
        
        
        
    }
    
    @isTest
    public static void saveRevenueMilestone(){ 
        Test.startTest();
        List<Opportunity> opportunityList = [SELECT Id,StageName,Amount_To_Be_Billed__c,Customer_Fee_Type__c,Is_Revenue_Milestone__c,Defer_Billing_or_Exit_Case__c, CurrencyIsoCode,Name,RecordTypeId, RecordType.Name,Billing_Start_Date__c,Billing_End_Date__c, Commercial_Head__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, ASF_Final_Amount__c, AccountId, CloseDate, IRF_Final_Amount__c, Is_Hold__c FROM Opportunity];
        ICRA_Revenue_Milestones.createRevenueMilestone(opportunityList);
        Test.stopTest();
    }
    
    
    @isTest
    public static void holdRevenueMilestone(){ 
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Opportunity opportunityRecord :[SELECT Id,StageName,Amount_To_Be_Billed__c,Customer_Fee_Type__c,Is_Revenue_Milestone__c,Defer_Billing_or_Exit_Case__c, CurrencyIsoCode,Name,RecordTypeId, RecordType.Name,Billing_Start_Date__c,Billing_End_Date__c, Commercial_Head__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, ASF_Final_Amount__c, AccountId, CloseDate, IRF_Final_Amount__c, Is_Hold__c FROM Opportunity WHERE Recordtype.Name = 'Surveillance']){
            opportunityRecord.Defer_Billing_or_Exit_Case__c = 'Deferred (Unbilled)'; 
            opportunityRecord.Reason__c= 'Deferred';
            opportunityRecord.Hold_Up_Untill__c= System.today().addDays(10);
        } 
        Update opportunityList; 
        Test.startTest();
        ICRA_Revenue_Milestones.createRevenueMilestone(opportunityList);
        Test.stopTest();
    }
    
        @isTest
    public static void billedRevenueMilestone(){ 
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Opportunity opportunityRecord :[SELECT Id,StageName,Amount_To_Be_Billed__c,Customer_Fee_Type__c,Is_Revenue_Milestone__c,Defer_Billing_or_Exit_Case__c, CurrencyIsoCode,Name,RecordTypeId, RecordType.Name,Billing_Start_Date__c,Billing_End_Date__c, Commercial_Head__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, ASF_Final_Amount__c, AccountId, CloseDate, IRF_Final_Amount__c, Is_Hold__c FROM Opportunity WHERE Recordtype.Name = 'Surveillance']){
            opportunityRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed'; 
        } 
        Update opportunityList; 
        
        Test.startTest();
        ICRA_Revenue_Milestones.createRevenueMilestone(opportunityList);
        Test.stopTest();
    }
    
        @isTest
    public static void deferredMilestone(){ 
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test 122','Issuer',branchrecord.Id); 
        Insert accountReccord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test 123', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';  
        opportunityRecord.Batch_is_Running__c = true;
        opportunityRecord.Commercial_Head__c = System.UserInfo.getUserId();
        
        Insert opportunityRecord;
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='Deferred (Unbilled)';
        opportunityRecord.Reason__c= 'Deferred';
        Update opportunityRecord;
        
        Test.startTest(); 
        ICRA_Revenue_Milestones.saveRevenueMilestone(new List<Opportunity> {opportunityRecord});
        
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        opportunityRecord.Reason__c= '';
        Update opportunityRecord;
        
        ICRA_Revenue_Milestones.saveRevenueMilestone(new List<Opportunity> {opportunityRecord});
        ICRA_Revenue_Milestones.shiftofunbilledtoBilled( opportunityRecord, 'cap');
        ICRA_Revenue_Milestones.creatRevenueMilestoneMonthWise( opportunityRecord, 'cap');
        ICRA_Revenue_Milestones.toBeBilledRevenueMilestone(opportunityRecord,'Deferred (Unbilled) - To Be Billed',opportunityRecord.Customer_Fee_Type__c);
        
        Test.stopTest();
    }
    
    @isTest
    public static void holdMilestone(){ 
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test 5','Issuer',branchrecord.Id); 
        Insert accountReccord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test 34', 'Surveillance', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating';  
        opportunityRecord.Batch_is_Running__c = true;
        opportunityRecord.Commercial_Head__c = System.UserInfo.getUserId(); 
        
        Insert opportunityRecord;
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='Hold (Uncertain)';
        opportunityRecord.Reason__c= 'Hold';
        opportunityRecord.Hold_Up_Untill__c= System.today().addDays(10);
        Update opportunityRecord;
        Test.startTest(); 
        ICRA_Revenue_Milestones.saveRevenueMilestone(new List<Opportunity> {opportunityRecord});
        
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        opportunityRecord.Reason__c= '';
        Update opportunityRecord;
        ICRA_Revenue_Milestones.saveRevenueMilestone(new List<Opportunity> {opportunityRecord});
        Test.stopTest();
    }
    
    @isTest
    public static void saveNewRevenueMilestone(){ 
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test 7','Issuer',branchrecord.Id); 
        Insert accountReccord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test 2', 'New Business', accountReccord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecord.ASF_Final_Amount__c = 0;
        opportunityRecord.Defer_Billing_or_Exit_Case__c = 'Yes'; 
        
        insert opportunityRecord;  
        Test.startTest(); 
        ICRA_Revenue_Milestones.saveRevenueMilestone(new List<Opportunity> {opportunityRecord}); 
        Test.stopTest();
    } 
}