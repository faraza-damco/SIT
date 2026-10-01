trigger InterBranch_Manual_Invoice on Manual_Invoice__c (before insert, before update) {
    Triggers_status__c tg_status= Triggers_status__c.getInstance();
    system.debug('Trigger Status Instance===>>'+tg_status);
    system.debug('Trigger Status===>>'+tg_status.InterBranch_Manual_Invoice__c);
    if((Trigger.isupdate|| Trigger.IsInsert) && Trigger.isBefore && tg_status!=null && tg_status.InterBranch_Manual_Invoice__c){
        InterBranch_Handler.generateBillingNumber(Trigger.new);
    }
}