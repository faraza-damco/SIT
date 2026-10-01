global class updateSharingSettingfield_Batch Implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String opportunitySOQL ='';
        opportunitySOQL = 'SELECT id, Name, Owner.Name, BranchFormula__c,Branch__c,BD_Team_Classification__c,BD_Team_Classification_Formula__c FROM Opportunity';
        opportunitySOQL += ' WHERE BranchFormula__c = null OR BD_Team_Classification_Formula__c = null';
        
        return Database.getQueryLocator(opportunitySOQL); 
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        List<Opportunity> oppList = new List<Opportunity>();

        for(Opportunity opp : opportunityList){
            opp.BranchFormula__c = opp.Branch__c;
            opp.BD_Team_Classification_Formula__c = opp.BD_Team_Classification__c;
            system.debug('Opp '+opp.Name);
            oppList.add(opp);
        }
        system.debug('oppList '+oppList.size());
        if(oppList.size() > 0){
            Database.update(oppList,false);
        }
    }
    global void finish(Database.BatchableContext BC){}
}