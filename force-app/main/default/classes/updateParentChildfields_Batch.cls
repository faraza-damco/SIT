global class updateParentChildfields_Batch Implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String opportunitySOQL ='';
        String recordtype = 'New Business';
        String closeWon = 'Closed Won';
        opportunitySOQL = 'SELECT Id,Name,Parent_Opportunity__c,CurrencyIsoCode,Debt_OR_Balance_Sheet_Size__c,VoD_in_crore__c,IRF_Final_Amount__c,IRF_Applied_Discount__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_Final_Amount__c,ASF_Applied_Discount__c,ASF_as_per_Agreement_BPS__c,Defer_Billing_or_Exit_Case__c,Amount_To_Be_Billed__c,Minimum_ASF__c,ASF_Agreement_with_Client__c,Amt_of_CAP_fee__c,OPE__c,RecordType.Name FROM Opportunity'; 
        opportunitySOQL += ' WHERE Parent_Opportunity__c = null AND RecordType.Name =: recordtype AND StageName =: closeWon AND PR_Date__c != null AND Is_QR_and_IRN_Generated__c = false';
        
        return Database.getQueryLocator(opportunitySOQL); 
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        Map<Id,Opportunity> parentOpp = new Map<Id,Opportunity>();
        List<Opportunity> updateOpp = new List<Opportunity>();
        for(Opportunity oppParent : opportunityList){
            
            parentOpp.put(oppParent.Id,oppParent);
        }
        system.debug('========parentOpp====='+parentOpp);
        for(Opportunity childOpp : [SELECT Id,Name,Parent_Opportunity__c,VoD_in_crore__c,CurrencyIsoCode,Debt_OR_Balance_Sheet_Size__c,IRF_Final_Amount__c,IRF_Applied_Discount__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_Final_Amount__c,ASF_Applied_Discount__c,ASF_as_per_Agreement_BPS__c,Amount_To_Be_Billed__c,Minimum_ASF__c,Defer_Billing_or_Exit_Case__c,ASF_Agreement_with_Client__c,Amt_of_CAP_fee__c,OPE__c,RecordType.Name 
                                    FROM Opportunity 
                                    WHERE 
                                    Parent_Opportunity__c IN: parentOpp.keySet() AND Is_QR_and_IRN_Generated__c = false AND Defer_Billing_or_Exit_Case__c = null AND RecordType.Name = 'Surveillance'
                                    ]){
                                        
                                        
                                        if(childOpp.Defer_Billing_or_Exit_Case__c == parentOpp.get(childOpp.Parent_Opportunity__c).Defer_Billing_or_Exit_Case__c){ //childOpp.Amount_To_Be_Billed__c != childOpp.ASF_Final_Amount__c
                                               
                                               childOpp.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
                                               //childOpp.Amount_To_Be_Billed__c = childOpp.ASF_Final_Amount__c;
                                               updateOpp.add(childOpp);
                                               system.debug('childOpp processed by the code ======'+childOpp);
                                           }
                                        
                                    }
        if(updateOpp.size() > 0){
            Database.update(updateOpp,false);
            system.debug('updateOpp list size ======'+updateOpp.size());
        }
    }
    global void finish(Database.BatchableContext BC){}
}