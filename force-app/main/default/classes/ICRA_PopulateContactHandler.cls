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
public inherited sharing class ICRA_PopulateContactHandler { 
    private static final List<String> NONBILLED = new List<String>{'Proforma Invoice','QR and IRN - Failed','Canceled'};
        private static final String INVOICEROLE = 'Name on Invoice';
    private static final String ERROR = 'There is no contact which is mapped as Name on Invoice';
    Public Static Boolean isPopultateContact = true;
    public static void isBeforeInsert(List<Invoice__c> invoiceList){ 
        //Modified on: 02-03-22
        Set<Id> opportunityIds = new Set<Id>();
        for(Invoice__c invoiceRec : invoiceList){
            if(invoiceRec.Opportunity_Name__c!=null){
                opportunityIds.add(invoiceRec.Opportunity_Name__c);
            }
        }
        if(opportunityIds.size()>0){
            Map<Id,Id> opptyBillingContactMap = new Map<Id,Id>();
            String emailRecipients;
            for(OpportunityContactRole opContactRole : [SELECT Id,OpportunityId,ContactId,Contact.Email,Role
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId IN :opportunityIds
                                                        ORDER BY LastModifiedDate ASC]){
                                                            if(INVOICEROLE.equalsIgnoreCase(opContactRole.Role)){
                                                                opptyBillingContactMap.put(opContactRole.OpportunityId,opContactRole.ContactId);
                                                            }
                                                        }
            for(Invoice__c invoiceRec : invoiceList){
                if(opptyBillingContactMap.size()>0 && opptyBillingContactMap.containsKey(invoiceRec.Opportunity_Name__c)){
                    invoiceRec.Contact_Name__c = opptyBillingContactMap.get(invoiceRec.Opportunity_Name__c);
                }else if(!(opptyBillingContactMap.size()>0) || (invoiceRec.Opportunity_Name__c!=null && !opptyBillingContactMap.containsKey(invoiceRec.Opportunity_Name__c))){
                    invoiceRec.addError(ERROR);
                }
            }        
        }
    } 
    /*************************** DEPRECATED ****************************************
* @Method Name       : createContactRoles
* @description       : To clone Opportunity Contact Roles into Rollong opportunities
******************************** DEPRECATED *****************************************/
    /*public static void createContactRoles(List<Invoice__c> invoiceList,Map<Id,Invoice__c> oldInvoiceMap){
        try{
            Set<Id> optyIds = new Set<Id>();
            for(Invoice__c inv : invoiceList){
                if(inv.Opportunity_Name__c!=null && !NONBILLED.contains(inv.Invoice_Status__c) && (oldInvoiceMap==null || inv.Invoice_Status__c != oldInvoiceMap.get(inv.Id).Invoice_Status__c)){
                    optyIds.add(inv.Opportunity_Name__c);
                }
            }
            if(optyIds.size()>0){
                Map<Id,Id> parentOptyIds = new Map<Id,Id>();
                for(Opportunity inOpty : [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Id IN :optyIds ORDER BY Name]){
                    if(inOpty.Parent_Opportunity__c!=null){
                        parentOptyIds.put(inOpty.Parent_Opportunity__c,inOpty.Id);
                    }else{
                        parentOptyIds.put(inOpty.Id,inOpty.Id);
                    }
                }
                Map<Id,Id> parentChildMap = new Map<Id,Id>();
                for(Opportunity opty :[SELECT Id,Parent_Opportunity__c,
                                       (SELECT Id,Role FROM OpportunityContactRoles) 
                                       FROM Opportunity WHERE Parent_Opportunity__c IN :parentOptyIds.keySet() ORDER BY Closedate]){
                    if(!parentChildMap.containsKey(parentOptyIds.get(opty.Parent_Opportunity__c)) && !optyIds.contains(opty.Id) && !(opty.OpportunityContactRoles.size()>0)){
                        parentChildMap.put(parentOptyIds.get(opty.Parent_Opportunity__c),opty.Id);
                    }
                }
                if(parentChildMap.size()>0){
                    List<OpportunityContactRole> optyConRolesToInsert = new List<OpportunityContactRole>();
                    for(OpportunityContactRole optyContactRole : [SELECT Id,Role,ContactId,OpportunityId,Opportunity.Child_Opportunity__c,IsPrimary 
                                                                  FROM OpportunityContactRole 
                                                                  WHERE OpportunityId IN :optyIds])
                    {
                        if(parentChildMap.containskey(optyContactRole.OpportunityId)){
                            OpportunityContactRole tempRole = optyContactRole.clone(false,false,false,false);
                            //tempRole.OpportunityId = optyContactRole.Opportunity.Child_Opportunity__c;
                            tempRole.OpportunityId = parentChildMap.get(optyContactRole.OpportunityId);
                            optyConRolesToInsert.add(tempRole);
                        }
                    }
                    if(optyConRolesToInsert.size()>0){
                        Database.Insert(optyConRolesToInsert,false);
                    }
                }
            }
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }*/
}