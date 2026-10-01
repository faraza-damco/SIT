/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-22-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   03-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger ICRA_InvoiceLineRollUp on Invoice_Line_Item__c (after Insert, after Update ,after delete) {
    
    //Get trigger information from metadata 
    Trigger_Setting__mdt [] triggerSetting = [
        SELECT Tigger_Name__c, Active__c 
        FROM Trigger_Setting__mdt 
        WHERE Tigger_Name__c = 'ICRA_InvoiceLineRollUp' 
        LIMIT 1 
    ];
    if(!triggerSetting.isEmpty()){ 
        
        //Check the tigger is active or not 
        if(triggerSetting[0].Active__c){
            System.debug('############ ICRA_InvoiceLineRollUpHandler : Start ############');
            
            if(Trigger.isAfter){
                
                if(Trigger.isInsert || Trigger.isUpdate ){ 
                    
                    if(ICRA_InvoiceLineRollUpHandler.firstRun){ 
                        
                        new ICRA_InvoiceLineRollUpHandler().rollUpInvoiceLines(Trigger.New); 
                        ICRA_InvoiceLineRollUpHandler.firstRun = false;
                    }
                    
                    System.debug('############ ICRA_InvoiceLineRollUpHandler : End ############');
                    
                }else if(Trigger.isDelete){
                    
                    if(ICRA_InvoiceLineRollUpHandler.firstRun){ 
                        
                        new ICRA_InvoiceLineRollUpHandler().rollUpInvoiceLines(Trigger.Old); 
                        ICRA_InvoiceLineRollUpHandler.firstRun = false;
                    }  
                    
                    System.debug('############ ICRA_InvoiceLineRollUpHandler : End ############');
                }
            }         
        }else{
            
            System.debug('############ ICRA_InvoiceLineRollUpHandler : Not Active ############');
        }
    } else{
		System.debug('############ ICRA_InvoiceLineRollUpHandler : Not Active, Check Trigger Setting( Custom Metadate) ############');
    }
}