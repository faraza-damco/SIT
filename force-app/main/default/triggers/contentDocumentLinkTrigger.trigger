trigger contentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    Map<Id,Id> cdAccMap = new Map<Id,Id>();
    List<ContentDocumentLink> cdlList = trigger.new;
    //cdlList = Trigger.isInsert?(List<ContentDocumentLink>)Trigger.New:(List<ContentDocumentLink>)Trigger.Old;
    for(ContentDocumentLink cdL : cdlList){
        if(String.valueOf(cdL.LinkedEntityId).startsWith('001')){
            System.debug('====>>>'+cdL.ContentDocument.Title);
            cdAccMap.put(cdL.ContentDocumentId,cdL.LinkedEntityId);//FileId,AccountId
        }
    }
    if(cdAccMap.size()>0){
        Set<Id> accIds = new Set<Id>();
        //String ofacFile= '%ofac%';
        for(ContentDocument cd : [Select Id,Title from ContentDocument where Id in:cdAccMap.keySet()]){
            If(cd.Title.containsIgnoreCase('OFAC')){
                accIds.add(cdAccMap.get(cd.Id)); 
            }
        }
        if(accIds.size()>0){
            List<Account> toUpdate = new List<Account>();
            for(Account acc : [Select Id,OFAC_Document_Received__c,Account_Status__c,Ofac_Approved__c,OFAC_Check__c from Account where Id In: accIds]){
                acc.OFAC_Document_Received__c = true;
                if(acc.Ofac_Approved__c==true){
                    acc.OFAC_Check__c=true;
                    acc.Account_Status__c = 'Active';
                }
                toUpdate.add(acc);
            }
            update toUpdate; 
        }
    }
}