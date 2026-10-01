@isTest
public class ICRA_OppDateAlignmentBatch_TB_Test {
  private static final String INVOICEROLE = 'Name on Invoice';
    @isTest
    public static void dateAlignOpportunityTest_BLR() {
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
        
        
        
        // BRL Opportunity
        Opportunity opportunityRecord_blr1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BRL', 'Surveillance', accountReccord.Id);
        opportunityRecord_blr1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr1.Billing_Start_Date__c = System.today();
        opportunityRecord_blr1.Billing_End_Date__c = System.today().addDays(-1).addYears(1);
        opportunityRecord_blr1.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_blr1.ASF_Final_Amount__c = 1000;
        opportunityRecord_blr1.Is_Date_Alignment_Done__c = false;
        opportunityRecord_blr1.Change_in_start_Date__c = false;
        opportunityRecord_blr1.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //opportunityRecord_blr1.Edited_By_Batch_UI__c = 'Edited By Batch';
        String ids = opportunityRecord_blr1.Id;
        
         opportunityList.add(opportunityRecord_blr1);
        
       
        Insert opportunityList;
        map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_blr1.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
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
        
       
        
        system.debug('batch process ===='+opportunityRecord_blr1.Opportunity_Batch_Process__c);
        List<Opportunity> childOppList = new List<Opportunity>();
        
        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDateblr = date.newInstance(2023, 07,22);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
        integer i= 0;
        Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDateblr.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDateblr.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_blr1.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
                        newRecord.Instrument_type_3__c = 'Bank Loan Rating';
                        newRecord.Instrument_type_4__c = 'Bank Loan Rating';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
         //Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
         map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_blr1.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDateblr);
       
        //brl2
          Opportunity opportunityRecord_blr2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity BLR 222', 'Surveillance', accountReccord.Id);
        opportunityRecord_blr2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_blr2.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord_blr2.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord_blr2.Instrument_type_4__c = 'Bank Loan Rating';
        opportunityRecord_blr2.Billing_Start_Date__c = System.today();
        opportunityRecord_blr2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);
        opportunityRecord_blr2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_blr2.ASF_Final_Amount__c = 1000;
        opportunityRecord_blr2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_blr2.Change_in_start_Date__c = false;
        opportunityRecord_blr2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //opportunityRecord_blr2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //String ids = opportunityRecord_cp1.Id;
        
       //  opportunityList.add(opportunityRecord_cp1);
        
       
        Insert opportunityRecord_blr2;
      //  map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_blr2.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRolesblr2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_blr2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRolesblr2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
       
        
        system.debug('batch process ===='+opportunityRecord_blr2.Opportunity_Batch_Process__c);
       // List<Opportunity> childOppList = new List<Opportunity>();
       
        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDate2 = date.newInstance(2023, 07,22);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
       // integer i= 0;
       // Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDate2.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDate2.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_blr2.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
                        newRecord.Instrument_type_3__c = 'Bank Loan Rating';
                        newRecord.Instrument_type_4__c = 'Bank Loan Rating';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
        // Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
        // map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_blr2.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDate2);
       
       
       //cp opp 
        
          Opportunity opportunityRecord_cp1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity CP', 'Surveillance', accountReccord.Id);
        opportunityRecord_cp1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_cp1.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_cp1.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord_cp1.Instrument_type_4__c = 'Commercial Paper';
        opportunityRecord_cp1.Billing_Start_Date__c = System.today();
        opportunityRecord_cp1.Billing_End_Date__c = System.today().addDays(-1).addYears(1);
        opportunityRecord_cp1.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_cp1.ASF_Final_Amount__c = 1000;
        opportunityRecord_cp1.Is_Date_Alignment_Done__c = false;
        opportunityRecord_cp1.Change_in_start_Date__c = false;
        opportunityRecord_cp1.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //opportunityRecord_cp1.Edited_By_Batch_UI__c = 'Edited By Batch';
        //String ids = opportunityRecord_cp1.Id;
        
       //  opportunityList.add(opportunityRecord_cp1);
        
       
        Insert opportunityRecord_cp1;
      //  map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_cp1.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRolescp = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_cp1.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRolescp;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
       
        
        system.debug('batch process ===='+opportunityRecord_cp1.Opportunity_Batch_Process__c);
       // List<Opportunity> childOppList = new List<Opportunity>();
       
       // Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDateblr2 = date.newInstance(2023, 07,22);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
       // integer i= 0;
       // Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDateblr2.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDateblr2.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_cp1.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
                        newRecord.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
                        newRecord.Instrument_type_4__c = 'Commercial Paper';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
        // Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
        // map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_cp1.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDateblr2);
       
        // cp2
         Opportunity opportunityRecord_cp2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity CP 2', 'Surveillance', accountReccord.Id);
        opportunityRecord_cp2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_cp2.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_cp2.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord_cp2.Instrument_type_4__c = 'Commercial Paper';
        opportunityRecord_cp2.Billing_Start_Date__c = System.today();
        opportunityRecord_cp2.Billing_End_Date__c = System.today().addDays(-1).addYears(1);
        opportunityRecord_cp2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_cp2.ASF_Final_Amount__c = 1000;
        opportunityRecord_cp2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_cp2.Change_in_start_Date__c = false;
        opportunityRecord_cp2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //opportunityRecord_cp2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //String ids = opportunityRecord_cp1.Id;
        
       //  opportunityList.add(opportunityRecord_cp1);
        
       
        Insert opportunityRecord_cp2;
      //  map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_cp2.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRolescp2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_cp2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRolescp2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
       
        
        system.debug('batch process ===='+opportunityRecord_cp2.Opportunity_Batch_Process__c);
       // List<Opportunity> childOppList = new List<Opportunity>();
       
       // Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDateblr3 = date.newInstance(2023, 07,26);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
       // integer i= 0;
       // Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDateblr3.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDateblr3.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_cp2.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
                        newRecord.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
                        newRecord.Instrument_type_4__c = 'Commercial Paper';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                       newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
        // Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
        // map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_cp2.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDateblr3);
       
        //cp3
         Opportunity opportunityRecord_cp3 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity CP 2', 'Surveillance', accountReccord.Id);
        opportunityRecord_cp3.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_cp3.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_cp3.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord_cp3.Instrument_type_4__c = 'Commercial Paper';
        opportunityRecord_cp3.Billing_Start_Date__c = System.today();
        opportunityRecord_cp3.Billing_End_Date__c = System.today().addDays(-1).addYears(1);
        opportunityRecord_cp3.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_cp3.ASF_Final_Amount__c = 1000;
        opportunityRecord_cp3.Is_Date_Alignment_Done__c = false;
        opportunityRecord_cp3.Change_in_start_Date__c = false;
        opportunityRecord_cp3.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //opportunityRecord_cp3.Edited_By_Batch_UI__c = 'Edited By Batch';
        //String ids = opportunityRecord_cp1.Id;
        
       //  opportunityList.add(opportunityRecord_cp1);
        
       
        Insert opportunityRecord_cp3;
      //  map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_cp3.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRolescp3 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_cp3.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRolescp3;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
       
        
        system.debug('batch process ===='+opportunityRecord_cp3.Opportunity_Batch_Process__c);
       // List<Opportunity> childOppList = new List<Opportunity>();
       
        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDatecp4 = date.newInstance(2023, 07,28);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
       // integer i= 0;
       // Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDatecp4.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDatecp4.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_cp3.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
                        newRecord.Instrument_type_3__c = 'Commercial Paper/Certificate of Deposit/Short-term Debt';
                        newRecord.Instrument_type_4__c = 'Commercial Paper';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                      newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
        // Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
        // map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_cp3.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDatecp4);
       
        
        Opportunity opportunityRecord_other = ICRA_TestDataFactory.creatOpportunity('Test Opportunity other', 'Surveillance', accountReccord.Id);
        opportunityRecord_other.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_other.Instrument_type_2__c = 'Others';
        opportunityRecord_other.Instrument_type_3__c = 'Others';
        opportunityRecord_other.Instrument_type_4__c = 'Issuer Rating';
        opportunityRecord_other.Billing_Start_Date__c = System.today();
        opportunityRecord_other.Billing_End_Date__c = System.today().addDays(-1).addYears(1);
        opportunityRecord_other.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_other.ASF_Final_Amount__c = 1000;
        opportunityRecord_other.Is_Date_Alignment_Done__c = false;
        opportunityRecord_other.Change_in_start_Date__c = false;
        opportunityRecord_other.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
       
        //opportunityRecord_other.Edited_By_Batch_UI__c = 'Edited By Batch';
        //String ids = opportunityRecord_other.Id;
        
         opportunityList.add(opportunityRecord_other);
        
       
        Insert opportunityRecord_other;
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_other.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRoleso = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_other.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
       
        
        system.debug('batch process ===='+opportunityRecord_blr1.Opportunity_Batch_Process__c);
        //List<Opportunity> childOppList = new List<Opportunity>();

        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDate3 = date.newInstance(2023, 07,22);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
       // integer i= 0;
       // Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDate3.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDate3.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_other.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Others';
                        newRecord.Instrument_type_3__c = 'Others';
                        newRecord.Instrument_type_4__c = 'Issuer Rating';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
        //  Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
       //  map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_other.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDate3);
        
        //other-other 2
        Opportunity opportunityRecord_other2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity other22', 'New Business', accountReccord.Id);
        opportunityRecord_other2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_other2.Instrument_type_2__c = 'Others';
        opportunityRecord_other2.Instrument_type_3__c = 'Others';
        opportunityRecord_other2.Instrument_type_4__c = 'Issuer Rating';
        opportunityRecord_other2.Billing_Start_Date__c = System.today();
        opportunityRecord_other2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);
        opportunityRecord_other2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_other2.ASF_Final_Amount__c = 1000;
        opportunityRecord_other2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_other2.Change_in_start_Date__c = false;
        //opportunityRecord_other2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //opportunityRecord_other2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //String ids = opportunityRecord_other.Id;
        
        // opportunityList.add(opportunityRecord_other2);
        
        opportunityRecord_other2.StageName = 'L1 Meeting';
        opportunityRecord_other2.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord_other2.OFAC_Approver__c = username.Id;
        opportunityRecord_other2.OFAC_Approved__c = true;
        Insert opportunityRecord_other2;
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_other2.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_other2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        parentopp.get(opportunityRecord_other2.Id).StageName = 'OFAC Initiation';
        update  parentopp.get(opportunityRecord_other2.Id);
        parentopp.get(opportunityRecord_other2.Id).StageName = 'OFAC Approved';
        update  parentopp.get(opportunityRecord_other2.Id);
        opportunityRecord_other2.Proposed_Rating_Fee__c = 100;
        opportunityRecord_other2.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord_other2.StageName = 'Negotiation';
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord_other2;
        opportunityRecord_other2.StageName = 'Discount Approved';
        update opportunityRecord_other2;
        opportunityRecord_other2.StageName = 'Closed Won';
        update opportunityRecord_other2;
        system.debug('Stage of opportunityRecord_other2 ==== '+opportunityRecord_other2.StageName);
        system.debug('batch process ===='+opportunityRecord_other2.Opportunity_Batch_Process__c);
        //List<Opportunity> childOppList = new List<Opportunity>();

        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDate3o = date.newInstance(2023, 07,22);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       
       // integer i= 0;
       // Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = smallestDate3o.addDays(1);
                        newRecord.Billing_End_Date__c = smallestDate3o.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_other2.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        newRecord.Instrument_type_1__c = 'Non Structured Finance';
                        newRecord.Instrument_type_2__c = 'Others';
                        newRecord.Instrument_type_3__c = 'Others';
                        newRecord.Instrument_type_4__c = 'Issuer Rating';
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.AccountId = accountReccord.Id;
                        newRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                        newRecord.RecordTypeId = survId;
                        newRecord.ASF_Final_Amount__c = 1000;
                         newRecord.IRF_Final_Amount__c = 1000;
                       newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList.add(newRecord);
        }
        system.debug('childOppList =='+childOppList.size());
        //  Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
       //  map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
         childmap.put(opportunityRecord_other2.Id,childOppList);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDate3o);
        //ICRA_DatealighnmentHelper.UpdateonChieldRecoreds(childOppList,smallestDate3o);
        
        Opportunity opportunityRecord_mfotherse = ICRA_TestDataFactory.creatOpportunity('Test Opportunity mfotherss', 'Surveillance', accountReccord.Id);
        opportunityRecord_mfotherse.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_mfotherse.Instrument_type_2__c = 'Rating - Money Market (Non-SF)';
        opportunityRecord_mfotherse.Instrument_type_3__c = 'Fixed Deposits';
        opportunityRecord_mfotherse.Instrument_type_4__c = 'Fixed Deposits';
        opportunityRecord_mfotherse.Billing_Start_Date__c = System.today();
        opportunityRecord_mfotherse.Billing_End_Date__c = System.today().addDays(-1).addYears(1);
        opportunityRecord_mfotherse.Rolling_and_Date_Alignmnet__c = false;
        opportunityRecord_mfotherse.ASF_Final_Amount__c = 1000;
        opportunityRecord_mfotherse.Is_Date_Alignment_Done__c = false;
        opportunityRecord_mfotherse.Edited_By_Batch_UI__c = 'Edited By Batch';
        //opportunityRecord_mfotherse.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
      //  String ids = opportunityRecord_mfotherss.Id;
        
        // opportunityList.add(opportunityRecord_mfotherse);
        
       
        Insert opportunityRecord_mfotherse;
        system.debug('opportunityRecord_mfotherss Inserted===='+opportunityRecord_mfotherse);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Parent_Opportunity__r.Skip_Date_Alignment__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_mfotherse.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
        }
        List<OpportunityContactRole> optyConRolesmfo = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_mfotherse.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRolesmfo;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
       
        
        system.debug('batch process ===='+opportunityRecord_mfotherse.Opportunity_Batch_Process__c);
       // List<Opportunity> childOppList = new List<Opportunity>();
        
        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
         date smallestDate4 = date.newInstance(2023,07,22);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        
        
        system.debug('parentopp =='+parentopp);
       List<opportunity> childOppList2 = new List<opportunity>();
        List<opportunity> childOppList33 = new List<opportunity>();
       // integer i= 0;
      //  Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
        for(i=0;i<5;i++){
            Opportunity newRecord = new Opportunity();
           
                        newRecord.Billing_Start_Date__c = opportunityRecord_mfotherse.Billing_Start_Date__c.addYears(1);
                        newRecord.Billing_End_Date__c = date.newInstance(2023,03,31);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_End_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = opportunityRecord_mfotherse.Id;
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
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList2.add(newRecord);
            system.debug('Entered in for loop of child=== '+newRecord.Opportunity_Batch_Process__c);
            system.debug('Size of list==='+childOppList2.size());
        }
        try{
           insert childOppList2; 
        }
        catch(Exception e){
            system.debug('Exception=== '+e.getMessage());
        }
        
        system.debug('childOppList =='+childOppList2.size());
        //Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
        // map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_mfotherse.Id,childOppList2);
        system.debug('parent id'+opportunityRecord_mfotherse.Id);
        for(Opportunity opp : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Parent_Opportunity__r.Skip_Date_Alignment__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             Parent_Opportunity__c =: parentopp.get(opportunityRecord_mfotherse.Id).Id]){
                                            childOppList2.add(opp);     
            system.debug('childOppList2 inside=== '+childOppList2);
        }
        for(Opportunity opp : childOppList2){
            system.debug('opp batch process== '+opp.Opportunity_Batch_Process__c );
            system.debug('opp Instrument4== '+opp.Instrument_type_4__c );
            childOppList33.add(opp);
        }
        //insert childOppList33;
        system.debug('childOppList33 == '+childOppList33.size());
        for(Opportunity opp33 :childOppList33){
           system.debug('childOppList33 == '+opp33.Opportunity_Batch_Process__c); 
        }
        childmap.put(opportunityRecord_mfotherse.Id,childOppList33);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDate4);
        ICRA_DatealighnmentHelper.UpdateonChieldRecoreds(childOppList33,smallestDate4);
       //mf 
       Test.startTest();
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
       // opportunityRecord_mfotherse2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        opportunityRecord_mfotherse2.StageName = 'L1 Meeting';
        opportunityRecord_mfotherse2.Customer_Fee_Type__c = 'Non - Cap';
         opportunityRecord_mfotherse2.OFAC_Approver__c = username.Id;
        opportunityRecord_mfotherse2.OFAC_Approved__c = true;
        //opportunityRecord_mfotherse2.Edited_By_Batch_UI__c = 'Edited By Batch';
      //  String ids = opportunityRecord_mfotherss.Id;
        
        // opportunityList.add(opportunityRecord_mfotherse);
        
       
        Insert opportunityRecord_mfotherse2;
        system.debug('opportunityRecord_mfotherss Inserted===='+opportunityRecord_mfotherse2);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        for(Opportunity oppparent : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             id=: opportunityRecord_mfotherse2.Id]){
            parentopp.put(oppparent.id,oppparent);
            system.debug('batch process ===='+oppparent.Opportunity_Batch_Process__c);
            system.debug('batch process Instrument_type_1__c===='+oppparent.Instrument_type_1__c);
            system.debug('batch process Instrument_type_2__c===='+oppparent.Instrument_type_2__c);
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
        
        //opportunityRecord_mfotherse2.Proposed_Rating_Fee__c = 100;
        //opportunityRecord_mfotherse2.Proposed_Surveillance_Fee__c = 100;
        //
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'Negotiation';
        update  parentopp.get(opportunityRecord_mfotherse2.Id);
        //opportunityRecord_mfotherse2.StageName = 'Negotiation';
        //update opportunityRecord_mfotherse2;
        
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'Discount Approved';
        update parentopp.get(opportunityRecord_mfotherse2.Id);
        //opportunityRecord_mfotherse2.StageName = 'Discount Approved';
        //update opportunityRecord_mfotherse2;
        //opportunityRecord_mfotherse2.StageName = 'Closed Won';
        //update opportunityRecord_mfotherse2;
        parentopp.get(opportunityRecord_mfotherse2.Id).StageName = 'Closed Won';
        update parentopp.get(opportunityRecord_mfotherse2.Id);
        parentopp.get(opportunityRecord_mfotherse2.Id).PR_Date__c = System.today();
        update parentopp.get(opportunityRecord_mfotherse2.Id);
        
       // system.debug('batch process ===='+opportunityRecord_mfotherse2.Opportunity_Batch_Process__c);
        system.debug('batch process ===='+parentopp.get(opportunityRecord_mfotherse2.Id).StageName);
       // List<Opportunity> childOppList = new List<Opportunity>();
        
        //Database.executeBatch(new ICRA_CreateRollingOpportunityBatch(),50);
        
       //  date smallestDate4o = date.newInstance(2023,07,31);
       // map<id,Opportunity> parentopp = new map<id,Opportunity>();
        date smallestDate4o = date.newInstance(2023,12,31);
        
        system.debug('parentopp =='+parentopp);
       List<opportunity> childOppList3 = new List<opportunity>();
        List<opportunity> childOppList44 = new List<opportunity>();
       // integer i= 0;
      //  Id survId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Surveillance').getRecordTypeId();
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
                        newRecord.Start_Change__c = true;
                        newRecord.Edited_By_Batch_UI__c = 'Edited By Batch';
                       childOppList3.add(newRecord);
        }
        Insert childOppList3;
        system.debug('childOppList =='+childOppList.size());
        Database.executeBatch(new ICRA_OpportunityDateAlignmentBatch_TB(),51);
        // map<id,List<Opportunity>> childmap = new map<id,List<Opportunity>>();
        childmap.put(opportunityRecord_mfotherse2.Id,childOppList3);
        system.debug('parent id'+opportunityRecord_mfotherse2.Id);
        for(Opportunity opp : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Parent_Opportunity__r.Skip_Date_Alignment__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE 
                                             Parent_Opportunity__c =: parentopp.get(opportunityRecord_mfotherse2.Id).Id]){
                                            childOppList44.add(opp);     
            system.debug('childOppList2 inside=== '+childOppList3);
        }
        
        for(Opportunity opp : childOppList3){
            system.debug('opp batch process== '+opp.Opportunity_Batch_Process__c );
            system.debug('opp Instrument4== '+opp.Instrument_type_4__c );
            childOppList44.add(opp);
        }
        
        system.debug('childOppList2 == '+childOppList3.size());
        childmap.put(opportunityRecord_mfotherse2.Id,childOppList44);
        ICRA_DatealighnmentHelper.UpdateDate(parentopp,childmap,smallestDate4o);
        ICRA_DatealighnmentHelper.UpdateonChieldRecoreds(childOppList44,smallestDate4o);
       //Database.executeBatch(new ICRA_UpdateEditedBy_Batch(),51);
        test.stopTest();
    }
   
  
   
}