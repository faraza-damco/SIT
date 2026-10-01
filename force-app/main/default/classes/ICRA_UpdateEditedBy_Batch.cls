//This Batch class is used to Bypass records in "New Update all Rolling Opp when Parent Opp is updated" Flow.


global class ICRA_UpdateEditedBy_Batch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String toBeBilled = 'To Be Billed';
        //String clientStatus = 'Live'; 
        //String recordType = 'Surveillance';
        //String AccountName = 'TATA Test Account';
        //Date updateDate = system.today();
        //and Account.name=:AccountName
        String editby = 'Edited By Batch';
        String soqlquery = 'SELECT ASF_Final_Amount__c,Start_Change__c,Edited_By_Batch_UI__c,Account.name,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c, AccountId, Amount_To_Be_Billed__c, Batch_is_Running__c, BD_Approve__c, Billing_End_date__c, Billing_Start_Date__c, Billing_Year_FY__c, CloseDate, Client_Status__c, Defer_Billing_or_Exit_Case__c, IRF_Final_Amount__c, Id, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, Is_Date_Alignment_Done__c, Name, PR_Date__c, Parent_Opportunity__c, RecordTypeId, RecordType.Name,Rolling_and_Date_Alignmnet__c, StageName, Total_Invoice_Amount_1__c, VoD_in_crore__c, Change_in_start_Date__c,Opportunity_Batch_Process__c FROM Opportunity' ;
        soqlquery +=' WHERE Billing_Start_Date__c != null AND (Edited_By_Batch_UI__c =: editby OR Edited_By_Batch_UI__c = null)  AND Billing_End_date__c != null AND ( ASF_Final_Amount__c >0  OR IRF_Final_Amount__c > 0 )  AND Defer_Billing_or_Exit_Case__c =:toBeBilled and LastModifiedDate = today ORDER BY Name DESC '; //AND Skip_Date_Alignment__c = true AND RecordType.Name = :recordType 
        System.debug('Get query' +soqlquery); 
        return Database.getQueryLocator(soqlquery); 
        
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){ 
       List<Opportunity> updateOppRecordList = new List<Opportunity>();
        for(Opportunity oppRecord : opportunityList){
            oppRecord.Edited_By_Batch_UI__c = 'Edited By UI';
            updateOppRecordList.add(oppRecord);
        }
    
        Update updateOppRecordList;
    }
    global void finish(Database.BatchableContext BC ){
        System.debug('======= BC =======:  '+BC);
    }
    
}