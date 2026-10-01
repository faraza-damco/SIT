trigger PromotorCompanyTrigger on Account (before insert, before update) {
    Triggers_status__c tg_status= Triggers_status__c.getInstance();
    system.debug('Trigger Status Instance===>>'+tg_status);
    system.debug('Trigger Status===>>'+tg_status.PromotorCompany__c);
    if(tg_status!=null && tg_status.PromotorCompany__c){
            if(Trigger.isBefore && Trigger.isInsert){
                PromotorCompaniesList.PromotorCompanyTriggerHandler_Insert(Trigger.new);   
            }else if(Trigger.isBefore && Trigger.isUpdate){
                PromotorCompaniesList.PromotorCompanyTriggerHandler_Update(Trigger.new, Trigger.oldMap);  
                PromotorCompaniesList.beforeUpdate(Trigger.new);  
            }
    }
}