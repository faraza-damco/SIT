global class ICRA_RevenueMilestoneServBatch implements Database.Batchable<sObject>{
    
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        String opportunityQuery = 'SELECT StageName, LastModifiedDate, Amount_To_Be_Billed__c, CurrencyIsoCode, RecordTypeId, Generate_Revenue_Milestone__c, ASF_Final_Amount__c, AccountId, Actual_Surveillance_Fee__c, Additional_Discount_Approved__c,  Already_Invoiced__c, Amount_Outstanding_In_Rs__c, IRF_Final_Amount__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, Is_Hold__c, Is_Revenue_Milestone__c, Last_Invoice_Date__c, Mandate_Type__c, PR_Date__c, Billing_End_date__c, Billing_Start_Date__c, Defer_Billing_or_Exit_Case__c, Expected_Deferred_Date__c, Customer_Fee_Type__c, VoD_in_crore__c, Line_of_Business__c, Comment__c, Id, Name, Reason__c, Subscription_End_Date__c, Subscription_Start_Date__c FROM Opportunity WHERE Generate_Revenue_Milestone__c = false ';
        return Database.getQueryLocator(opportunityQuery); 
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        System.debug('list size===='+opportunityList.size()+'======= execute ======='+opportunityList);
        List<Opportunity> opportunityTempList = new List<Opportunity>();
        Database.SaveResult [] resultList = ICRA_Revenue_Milestones.saveRevenueMilestone(opportunityList);
        Boolean isInsert = false;
        for(Database.SaveResult result : resultList){ 
            if(result.isSuccess()){
                isInsert = true;
            } 
        } 
        
        if(isInsert){           
            for(Opportunity record : opportunityList ){
                if(record.Generate_Revenue_Milestone__c == false){
                    record.Generate_Revenue_Milestone__c  = true;
                    opportunityTempList.add(record);
                }
            }
        }
        
        if(opportunityTempList.size() > 0){
            Update opportunityTempList;
        }
    }  
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Opportunity Batch Job is done ****  /' +BC); 
        
    }
}