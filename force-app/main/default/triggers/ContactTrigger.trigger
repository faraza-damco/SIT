/**
* @description       : Contact Trigger
* @author            : Damco Group
* @Created on  		 : 02-03-2022
**/
trigger ContactTrigger on Contact (before update, after update) {
	if(Trigger.isUpdate){
        ContactTriggerHandler.validateActiveContacts(Trigger.new,Trigger.oldMap);
    }
}