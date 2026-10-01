public class ChangeInStartDate_Batch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String recordtype = 'New Business';
        String soqlquery = 'select id,name,(select id,name from Opportunities__r where parent_opportunity__c != null AND parent_opportunity__r.Recordtype.Name =: recordType AND Change_in_start_date__c = true ORDER BY Billing_start_date__c asc LIMIT 1) FROM Opportunity';
        
        //String soqlquery =  'select id,name,Change_in_start_date__c,parent_opportunity__c,parent_opportunity__r.RecordType.Name from Opportunity'; 
        //soqlquery +=' where parent_opportunity__c != null AND parent_opportunity__r.Recordtype.Name =: recordType AND Change_in_start_date__c = false ORDER BY Billing_start_date__c asc';
       
         soqlquery +=' WHERE RecordType.Name =: recordtype'; 
        System.debug('Get query' +soqlquery); 
        return Database.getQueryLocator(soqlquery); 
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){ 
        List<Opportunity> updateOpp = new List<Opportunity>();
        List<Opportunity> updateOpp2 = new List<Opportunity>();
        
        for(Opportunity opp : opportunityList){
            if(opp.Opportunities__r.size() > 0){
                Opportunity op=opp.Opportunities__r;
                updateOpp.add(op);
            }
            
        }
        
       // system.debug('Size of List'+updateOpp.size());
        
        for(Opportunity opprecord : updateOpp){
            opprecord.change_in_start_date__c = false;
            updateOpp2.add(opprecord);
        }
       /* for(Opportunity opprecord : opportunityList){
            opprecord.change_in_start_date__c = true;
            updateOpp2.add(opprecord);
        }*/
        
        if(updateOpp2.size() > 0){
           // Database.update(updateOpp2,false) ;
           update updateOpp2;
        }
    }
    public void finish(Database.BatchableContext BC ){
        System.debug('======= BC =======:  '+BC);
    }
    
    
}