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
public inherited sharing class PopulateContactMIhandler {
    
    
    public static void isBeforeInsert(List<Manual_Invoice__c> invoiceList){ 
         System.debug('Invoice List ############### '+invoiceList.size());
        // MAP : Invoice Account Map is used to hold account id as key and value as Invoice List
        Map<Id, List<Manual_Invoice__c>> invoiceAccountMap = new Map<Id, List<Manual_Invoice__c>>(); 

        // Map account id with invoice
        for(Manual_Invoice__c invoiceRecord : invoiceList){ 
            if(invoiceRecord.Account_ID__c != null){
                if(invoiceAccountMap.containsKey(invoiceRecord.Account_ID__c)){
                    invoiceAccountMap.get(invoiceRecord.Account_ID__c).add(invoiceRecord);
                }else{                      
                    invoiceAccountMap.put(invoiceRecord.Account_ID__c, new List<Manual_Invoice__c>{invoiceRecord});
                }
            }
        } 
     System.debug('Account ID ####### '+invoiceAccountMap.keySet());
        //Tag the Contact on Invoice (Recent contact where Billing Contact is equal to Yes)
        for(Contact contactRecord : [SELECT Id, AccountId, Billing_Contact__c, Name, Email, Designation__c, CreatedDate
                                    FROM Contact  
                                    WHERE AccountId IN: invoiceAccountMap.keySet() AND Billing_Contact__c ='Yes'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 50000]
        ){
          if(contactRecord.AccountId != null){
            
              for(Manual_Invoice__c invoice : invoiceAccountMap.get(contactRecord.AccountId)){
               System.debug('Invoice before Assignmenet ######### '+invoice.Contact_Name__c);
                  invoice.Contact_Name__c = contactRecord.Id; 
                System.debug('Invoice After Assignmenet ######### '+invoice.Contact_Name__c);

             }
          }  

        }  
    }
}