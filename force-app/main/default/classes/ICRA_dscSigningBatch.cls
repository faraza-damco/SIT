global class ICRA_dscSigningBatch Implements Database.Batchable<sObject>{ 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> statusSet = new Set<String>();
        statusSet.add('Proforma Invoice');
        statusSet.add('QR-IRN-Generated');
        String InvSOQL = 'SELECT Id, Name FROM Invoice__c WHERE Invoice_Status__c=:statusSet AND Invoice_Created_Date__c = TODAY' ;
        
        return Database.getQueryLocator(InvSOQL); 
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> InvList){
        if(InvList !=null && InvList.size()>0){
            for(Invoice__c ev:InvList){
                ICRA_dscSigning.SignedDoc(ev.id); 
            }
        }
    } 
    
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Opportunity Batch Job is done ****  /' +BC); 
    }
}