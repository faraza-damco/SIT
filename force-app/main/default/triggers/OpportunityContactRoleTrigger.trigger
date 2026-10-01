/**
* @description       : OpportunityContactRole Trigger
* @author            : Damco Group
* @Created on        : 02-03-2022
**/
trigger OpportunityContactRoleTrigger on OpportunityContactRole (before insert, after insert, before update, after update, before delete, after delete) {
    //if(System.Label.Status != 'false'){
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
        if(Trigger.isBefore){
            OpportunityContactRoleTriggerHandler.validateBillingContacts(Trigger.new,Trigger.oldMap);
        }else if(Trigger.isAfter){
            OpportunityContactRoleTriggerHandler.rollOverOpportunities(Trigger.newMap,Trigger.oldMap);
        }
    }
 // }
}