/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger PopulateContactMI on Manual_Invoice__c (Before Insert, Before Update) {

    //Get trigger information from metadata 
    Trigger_Setting__mdt [] triggerSetting = [
        SELECT Tigger_Name__c, Active__c 
        FROM Trigger_Setting__mdt 
        WHERE Tigger_Name__c = 'PopulateContactMI' 
        LIMIT 1 
    ];

    // check the list is empty or not
    if(!triggerSetting.isEmpty()){

        //Check the tigger is active or not 
        if(triggerSetting[0].Active__c){
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                   PopulateContactMIhandler.isBeforeInsert(Trigger.new);
                }
            } 
        }       
    }

}