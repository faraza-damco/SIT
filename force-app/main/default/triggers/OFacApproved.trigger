trigger OFacApproved on Opportunity (before insert, after update,before update) {
    Triggers_status__c tg_status= Triggers_status__c.getInstance();
    system.debug('Trigger Status Instance===>>'+tg_status);
    system.debug('Trigger Status===>>'+tg_status.OpportunityTrigger__c);
        if(tg_status!=null && tg_status.OFAC_Trigger__c){
        if(Trigger.isInsert){
                list<id>  accountIds = new list<id>();    
                for(opportunity opp:trigger.new){
                    accountIds.add(opp.accountId);
                System.debug('@@@1'+opp.accountId);  
                }
                
                map<id,account> accs = new map<id,account>([select id,OFAC_Approved__c,OFAC_Document_Received__c,Account_Status__c,OFAC_Check__c from account where id IN:accountIds]);
                for(Opportunity opp: Trigger.new){
                    if(accs.get(opp.AccountId).OFAC_Approved__c==true)
                    {
                        opp.OFAC_Approved__c=true;
                        
                    }
                }
        }
        
        for(Opportunity opp: Trigger.new){
            if(Trigger.isUpdate){
                if(Trigger.isbefore){
                    if(Trigger.oldmap.get(opp.Id).StageName !='Closed Won' && opp.StageName =='Closed Won' ){
                        opp.Opportunity_Original_Owner__c =opp.OwnerId;
                    }
                }
                if(Trigger.isafter){
                    System.debug('Trigger.oldmap.get(opp.Id).OFAC_Approved__c '+Trigger.oldmap.get(opp.Id).OFAC_Approved__c);
                    System.debug('opp.OFAC_Approved__c '+opp.OFAC_Approved__c);
                    if(Trigger.oldmap.get(opp.Id).OFAC_Approved__c==false && opp.OFAC_Approved__c ==true){
                            if(OFacApproved_Recursion.isFirstTime){
                            OFacApproved_Recursion.isFirstTime = false; 
                            System.debug('update '+Trigger.oldmap.get(opp.Id).OFAC_Approved__c);
                            Account acc = [SELECT Id, OFAC_Approved__c, OFAC_Document_Received__c, OFAC_Check__c, Account_Status__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
                            acc.OFAC_Approved__c=true;
                            if(acc.OFAC_Document_Received__c==true){
                                acc.OFAC_Check__c=true;
                                acc.Account_Status__c='Active';
                            }
                            update acc;
                        }
                    } 
                }
                
            }
        }
    }
}