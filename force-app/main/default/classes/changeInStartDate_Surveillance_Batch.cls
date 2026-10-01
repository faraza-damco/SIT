public class changeInStartDate_Surveillance_Batch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordtype = 'Surveillance';
        String soqlquery = 'SELECT ASF_Final_Amount__c,Parent_Opportunity__r.skip_date_Alignment__c,Start_Change__c,Edited_By_Batch_UI__c,Account.name,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c, AccountId, Amount_To_Be_Billed__c, Batch_is_Running__c, BD_Approve__c, Billing_End_date__c, Billing_Start_Date__c, Billing_Year_FY__c, CloseDate, Client_Status__c, Defer_Billing_or_Exit_Case__c, IRF_Final_Amount__c, Id, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, Is_Date_Alignment_Done__c, Name, PR_Date__c, Parent_Opportunity__c, RecordTypeId, RecordType.Name,Rolling_and_Date_Alignmnet__c, StageName, Total_Invoice_Amount_1__c, VoD_in_crore__c, Change_in_start_Date__c,Opportunity_Batch_Process__c FROM Opportunity' ;
        soqlquery +=' WHERE  Parent_Opportunity__r.RecordType.Name =: recordtype AND Change_in_Start_Date__c = false'; //AND Skip_Date_Alignment__c = true
        System.debug('Get query' +soqlquery); 
        return Database.getQueryLocator(soqlquery); 
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){ 
        /*List<Opportunity> upOpp = new List<Opportunity>();
for(Opportunity opp : opportunityList){
opp.is_date_alignment_done__c = false;
upopp.add(opp);
}
update upopp;*/
        Set<Id> parentId = new Set<Id>();
        List<Opportunity> getDetail = new List<Opportunity>();
        for(Opportunity parentOpp : [SELECT Id,Name,Parent_Opportunity__c,RecordType.Name FROM Opportunity WHERE Parent_Opportunity__c = null AND RecordType.Name = 'Surveillance']){
            parentId.add(parentOpp.Id);
        }
        
        for(Opportunity childOpp : [SELECT Id,Name,Change_in_Start_Date__c,Parent_Opportunity__c,Billing_Start_Date__c FROM Opportunity 
                                    WHERE Parent_Opportunity__c IN: parentId AND
                                    Parent_Opportunity__r.RecordType.Name = 'Surveillance'	AND					
                                    Change_in_Start_Date__c = false  order by Billing_Start_Date__c asc])
        {
            childOpp.Change_in_Start_Date__c = true;
            getDetail.add(childOpp);
        }
        Database.update(getDetail,false);
        system.debug('getDetail  '+getDetail.size());
        
        
        
        
    }
    public void finish(Database.BatchableContext BC ){
        System.debug('======= BC =======:  '+BC);
        
    }
}