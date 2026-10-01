trigger Billing_Address_Trigger on Billing_Address__c (before insert, before update) {
    Triggers_status__c tg_status= Triggers_status__c.getInstance();
    system.debug('Trigger Status Instance===>>'+tg_status);
    system.debug('Trigger Status===>>'+tg_status.Billing_Address__c);
    if (Trigger.isBefore && tg_status!=null && tg_status.Billing_Address__c) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Billing_Address_TriggerHandler.preventMultiplePrimaryAddr(Trigger.new);
        }
    }
}