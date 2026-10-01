@isTest
public class ChangeInStartDate_Batch_Test {
    private static final String INVOICEROLE = 'Name on Invoice';
    @isTest
    public static void updateEditedTest(){
        
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        Insert accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branchrecord.Id);
        Insert accountReccord1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
         Opportunity opportunityRecord_mfotherse2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity mfotherss2', 'New Business', accountReccord.Id);
        opportunityRecord_mfotherse2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mfotherse2.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mfotherse2.Instrument_type_3__c = 'Fixed Deposits';
        opportunityRecord_mfotherse2.Instrument_type_4__c = 'Fixed Deposits';
        opportunityRecord_mfotherse2.Billing_Start_Date__c = System.today();
        opportunityRecord_mfotherse2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);
        opportunityRecord_mfotherse2.Rolling_and_Date_Alignmnet__c = false;
        opportunityRecord_mfotherse2.ASF_Final_Amount__c = 1000;
        opportunityRecord_mfotherse2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_mfotherse2.Change_in_start_Date__c = false;
        opportunityRecord_mfotherse2.Edited_By_Batch_UI__c = 'Edited By Batch';
        opportunityRecord_mfotherse2.StageName = 'L1 Meeting';
        opportunityRecord_mfotherse2.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord_mfotherse2.OFAC_Approver__c = username.Id;
        opportunityRecord_mfotherse2.OFAC_Approved__c = true;
        
        Insert opportunityRecord_mfotherse2;
        map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_mfotherse2.Id]){
            parentopp.put(oppparent.id,oppparent);
            
        }
        List<OpportunityContactRole> optyConRolesmfo2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_mfotherse2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRolesmfo2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
        
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'OFAC Initiation';
        update  parentopp.get(opportunityRecord_mfotherse2.Id);
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'OFAC Approved';
        update  parentopp.get(opportunityRecord_mfotherse2.Id);
        parentopp.get(opportunityRecord_mfotherse2.Id).Proposed_Rating_Fee__c = 100;
        parentopp.get(opportunityRecord_mfotherse2.Id).Proposed_Surveillance_Fee__c = 100;
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'Negotiation';
        update  parentopp.get(opportunityRecord_mfotherse2.Id);
        
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'Discount Approved';
        update parentopp.get(opportunityRecord_mfotherse2.Id);
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'Closed Won';
        update parentopp.get(opportunityRecord_mfotherse2.Id);
        parentopp.get(opportunityRecord_mfotherse2.Id).PR_Date__c = System.today();
        update parentopp.get(opportunityRecord_mfotherse2.Id);
        
        Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        date smallestDate4o = date.newInstance(2023,12,31);
        List<opportunity> childOppList3 = new List<opportunity>();
        List<opportunity> childOppList44 = new List<opportunity>();
        integer i= 0;
        Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = opportunityRecord_mfotherse2.Billing_Start_Date__c.addDays(1).addYears(1);
                        newRecord.Billing_End_Date__c = smallestDate4o.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_mfotherse2.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
                        newRecord.Instrument_type_3__c = 'Fixed Deposits';
                        newRecord.Instrument_type_4__c = 'Fixed Deposits';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                        newRecord.StageName = 'Closed Won';
                        newRecord.Business_Segment__c = 'Rating';
                        newRecord.VoD_in_crore__c = 100;
                        newRecord.Amount_To_Be_Billed__c = 100;
                        newRecord.Actual_Surveillance_Fee__c = 100;
                        //newRecord.Start_Change__c = true;
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList3.add(newRecord);
        }
        Insert childOppList3;
       
         map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_mfotherse2.Id,childOppList3);
        system.debug('parent id'+opportunityRecord_mfotherse2.Id);
        for(Opportunity opp : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             Parent_Opportunity__c =: parentopp.get(opportunityRecord_mfotherse2.Id).Id]){
                                            childOppList44.add(opp);     
            
        }
        
        for(Opportunity opp : childOppList3){
           childOppList44.add(opp);
        }
        
         childmap.put(opportunityRecord_mfotherse2.Id,childOppList44);
        // Database.executeBatch(new ICRA_UpdateEditedBy_Batch(),51);
        Test.startTest();
       /* ICRA_UpdateEditedBy_Scheduler schedulercalled = new ICRA_UpdateEditedBy_Scheduler();
          
         String chron = '0 0 23 * * ?';        
         String jobid = System.schedule('testScheduledApex', chron, schedulercalled); */
        
        Database.executeBatch(new ChangeInStartDate_Batch(),100);
        Test.stopTest();
    }
}