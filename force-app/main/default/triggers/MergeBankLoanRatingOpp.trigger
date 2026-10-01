trigger MergeBankLoanRatingOpp on Opportunity (after update) { 
    
    List<Opportunity> surveillancelist=new List<Opportunity>();
    List<Opportunity> UpdateList = new List<Opportunity>();    
    List<Opportunity> lstSur = new List<Opportunity>();
      List<Opportunity> existingSurv = new List<Opportunity>();
    
    
    if(Trigger.isUpdate){
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        List<Id> OpportunityL = new list<Id>(); 
        for(Opportunity opp: Trigger.new){
            if(opp.StageName =='Closed Won' && opp.Date_of_Non_Acceptance_of_Rating__c==null && (Trigger.oldmap.get(opp.Id).PR_Date__c == null && opp.PR_Date__c!=null || Trigger.oldmap.get(opp.Id).Date_of_Communication__c == null && opp.Date_of_Communication__c!=null || Trigger.oldmap.get(opp.Id).ASF_Final_Amount__c  <= 1 && opp.ASF_Final_Amount__c > 1) && opp.ASF_Final_Amount__c>1 && opp.Alignment_Logic__c=='12 Months'){
                System.debug('12 Months Logic');
                system.debug('RecursiveTriggerHandlerForServ.isFirstTime'+RecursiveTriggerHandlerForServ.isFirstTime);
                if(RecursiveTriggerHandlerForServ.isFirstTime){
                    RecursiveTriggerHandlerForServ.isFirstTime = false; 
                    system.debug('RecursiveTriggerHandler for false'+RecursiveTriggerHandlerForServ.isFirstTime);
                    surveillancelist.add(opp);
                } 
                if(surveillancelist.Size()>0 && AlreadySuvExist(opp).Size()==0){
                    System.Debug('Alignment Logic==>'+opp.Alignment_Logic__c);
                    MergeBankLoanRatingOppHelper.Generatesurveillance(surveillancelist);
                }  
            }
            else if(opp.StageName =='Closed Won' && opp.Date_of_Non_Acceptance_of_Rating__c==null && (Trigger.oldmap.get(opp.Id).PR_Date__c == null && opp.PR_Date__c!=null || Trigger.oldmap.get(opp.Id).Date_of_Communication__c == null && opp.Date_of_Communication__c!=null || Trigger.oldmap.get(opp.Id).ASF_Final_Amount__c  <= 1 && opp.ASF_Final_Amount__c > 1) && opp.ASF_Final_Amount__c>1 && opp.Alignment_Logic__c=='Financial Year'){
                System.debug('Financial Year Logic');
                if(RecursiveTriggerHandlerForServ.isFirstTime){
                    RecursiveTriggerHandlerForServ.isFirstTime = false;
                    surveillancelist.add(opp);
                }
                if(surveillancelist.Size()>0 && AlreadySuvExist(opp).Size()==0){
                    System.Debug('Alignment Logic==>'+opp.Alignment_Logic__c);
                    MergeMoneyMarketOppHelper.Generatesurveillance(surveillancelist); 
                }  
            }
        }  
    }
    public list<Opportunity> AlreadySuvExist(Opportunity opp)
    {
        return [select id from Opportunity where recordtype.name='Surveillance' and Parent_Opportunity__c=:opp.ID];
    }
}