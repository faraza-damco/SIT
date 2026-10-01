/**
* @description       : Opportunity Trigger
* @author            : Damco Group
* @Created on        : 02-03-2022
**/
trigger OpportunityTrigger on Opportunity (after insert, before update,after update) {
    Triggers_status__c tg_status= Triggers_status__c.getInstance();
    system.debug('Trigger Status Instance===>>'+tg_status);
    system.debug('Trigger Status===>>'+tg_status.OpportunityTrigger__c);
    if(tg_status!=null && tg_status.OpportunityTrigger__c){
        if(Trigger.isAfter && Trigger.isInsert){
            OpportunityTriggerHandler.createContactRoles(Trigger.new);
        }else if(Trigger.isBefore && Trigger.isUpdate){
            OpportunityTriggerHandler.validateNameonInvoice(Trigger.new,Trigger.oldMap);
            OpportunityTriggerHandler.lockStageOnBilledOppty(Trigger.new,Trigger.oldMap);
            OpportunityTriggerHandler.proposalContactRequired(Trigger.newMap,Trigger.oldMap);
            OpportunityTriggerHandler.changeMinimumASF(Trigger.newMap,Trigger.oldMap);
            OpportunityTriggerHandler.checkerRejectionReason(Trigger.new,Trigger.oldMap);
            // OpportunityValidations.restrictOpportunityUpdation(Trigger.new,Trigger.oldMap);       
        }
        else if(Trigger.isAfter && Trigger.isUpdate){
            OpportunityTriggerHandler.CreateApprovalRecords(Trigger.new,Trigger.oldMap);
        }
    }
}