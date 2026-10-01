/**
* @description       : Utility class for OpportunityContactRoleTrigger
* @author            : Damco Group
* @Created on  		 : 02-03-2022
**/
public class OpportunityContactRoleTriggerHandler {
    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String PROPOSALPRIMARY_ROLE = 'Proposal Primary Contact';
    private static final String MPRA_ROLE = 'MPRA/SOW';
    private static final String EMAILRECP = 'Email Recipient';
    private static final String MULTIERROR = 'One opportunity can not have two “Name on Invoice” role';
    private static final String MULTIERROR_PRIMARY = 'One opportunity can not have two “Proposal Primary Contact” role';
    private static final String MULTIERROR_MPRA = 'One opportunity can not have two “MPRA/SOW” role';
    private static final String EMAILERROR = 'Missing Email on Contact';
    private static final String ACCOUNTERROR = 'Contact does not belong to parent Account';
    //private static final String BILLTOERROR = 'Contact does not belong to the \'Bill To\' Account';
    private static final String INACTERROR = 'Inactive Contacts cannot be added as Contact Role';
    private static final String DUPERROR = 'Duplicate Contacts are not allowed';
    private static final String NOCONERROR = 'Closed Won Opportunity must have a Name on Invoice Contact Role';
    private static final String BILLEDERROR = 'Cannot edit Roles on Billed Opportunities';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String NEWLINE = '\n';
    private static final List<String> NONBILLED = new List<String>{'Proforma Invoice','QR and IRN - Failed','Canceled'};
    
/**
* @Method Name       : validateBillingContacts
* @description       : To prevent multiple contact roles on same opportunity with 'Name on Invoice' role
**/
    public static void validateBillingContacts(List<OpportunityContactRole> newContactRoles,Map<Id,OpportunityContactRole> oldContactRoles){ 
        Map<Id,List<OpportunityContactRole>> optyInvoiceContacts = new Map<Id,List<OpportunityContactRole>>();
        Map<Id,List<OpportunityContactRole>> optyPrimaryContacts = new Map<Id,List<OpportunityContactRole>>();
        Map<Id,List<OpportunityContactRole>> optyMPRAContacts = new Map<Id,List<OpportunityContactRole>>();
        Set<Id> closedOpporIds = new Set<Id>();
        Set<Id> billedOpty = new Set<Id>();
        Set<Id> duplicateContact = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Id> optyAccountMap = new Map<Id,Id>();
        //Map<Id,Id> optyBillToMap = new Map<Id,Id>();
        Map<Id,List<Id>> optyContactMap = new Map<Id,List<Id>>();
        Map<String, Set<String>> mapContactRoles = new Map<String, Set<String>>();
        if(newContactRoles!=null){
            List<Id> contacts = new List<Id>();
            for(OpportunityContactRole conRole : newContactRoles){
                
                if(INVOICEROLE.equalsIgnoreCase(conRole.Role) && (oldContactRoles==null || !INVOICEROLE.equalsIgnoreCase(oldContactRoles.get(conRole.Id).Role))){
                    if(optyInvoiceContacts.containsKey(conRole.OpportunityId)){
                        optyInvoiceContacts.get(conRole.OpportunityId).add(conRole);
                    }else{
                        optyInvoiceContacts.put(conRole.OpportunityId,new List<OpportunityContactRole>{conRole});
                    }
                }    
                if(PROPOSALPRIMARY_ROLE.equalsIgnoreCase(conRole.Role) && (oldContactRoles==null || !PROPOSALPRIMARY_ROLE.equalsIgnoreCase(oldContactRoles.get(conRole.Id).Role))){
                    if(optyPrimaryContacts.containsKey(conRole.OpportunityId)){
                        optyPrimaryContacts.get(conRole.OpportunityId).add(conRole);
                    }else{
                        optyPrimaryContacts.put(conRole.OpportunityId,new List<OpportunityContactRole>{conRole});
                    }
                }  
                if(MPRA_ROLE.equalsIgnoreCase(conRole.Role) && (oldContactRoles==null || !MPRA_ROLE.equalsIgnoreCase(oldContactRoles.get(conRole.Id).Role))){
                    if(optyMPRAContacts.containsKey(conRole.OpportunityId)){
                        optyMPRAContacts.get(conRole.OpportunityId).add(conRole);
                    }else{
                        optyMPRAContacts.put(conRole.OpportunityId,new List<OpportunityContactRole>{conRole});
                    }
                }  
                contactIds.add(conRole.ContactId);
                //To prevent adding duplicates
                if(optyContactMap.containsKey(conRole.OpportunityId)){
                    contacts = optyContactMap.get(conRole.OpportunityId);
                        if(contacts.contains(conRole.ContactId)){
                            duplicateContact.add(conRole.ContactId);
                        }
                    optyContactMap.get(conRole.OpportunityId).add(conRole.ContactId);
                }else{
                    optyContactMap.put(conRole.OpportunityId,new List<Id>{conRole.ContactId});
                }
                system.debug(duplicateContact);
            }
            for(Opportunity opty : [SELECT Id,AccountId,StageName,Bill_To__c,(SELECT ID,Role,OpportunityId,ContactId,IsPrimary FROM OpportunityContactRoles) 
                                    FROM Opportunity 
                                    WHERE Id IN : optyContactMap.keySet()])
            {
                if(opty.OpportunityContactRoles.size()>0){
                    for(OpportunityContactRole contRole : opty.OpportunityContactRoles){
                        if(INVOICEROLE.equalsIgnoreCase(contRole.Role) && optyInvoiceContacts.containsKey(opty.Id) && !optyInvoiceContacts.get(opty.Id).contains(contRole) && (oldContactRoles==null || !oldContactRoles.containsKey(contRole.Id))){
                            optyInvoiceContacts.get(opty.Id).add(contRole);
                        }
                        if(PROPOSALPRIMARY_ROLE.equalsIgnoreCase(contRole.Role) && optyPrimaryContacts.containsKey(opty.Id) && !optyPrimaryContacts.get(opty.Id).contains(contRole) && (oldContactRoles==null || !oldContactRoles.containsKey(contRole.Id))){
                            optyPrimaryContacts.get(opty.Id).add(contRole);
                        }
                        if(MPRA_ROLE.equalsIgnoreCase(contRole.Role) && optyMPRAContacts.containsKey(opty.Id) && !optyMPRAContacts.get(opty.Id).contains(contRole) && (oldContactRoles==null || !oldContactRoles.containsKey(contRole.Id))){
                            optyMPRAContacts.get(opty.Id).add(contRole);
                        }
                        //To prevent adding duplicates
                        contacts = optyContactMap.get(contRole.OpportunityId);
                        if((duplicateContact==null || !duplicateContact.contains(contRole.ContactId)) && contacts.contains(contRole.ContactId) && (oldContactRoles==null || !oldContactRoles.containsKey(contRole.Id)) ){
                            duplicateContact.add(contRole.ContactId);
                        }
                    }
                }
                if(opty.StageName == CLOSEDSTAGE){
                    closedOpporIds.add(opty.Id);
                }
                optyAccountMap.put(opty.Id,opty.AccountId);
                //optyBillToMap.put(opty.Id,opty.Bill_To__c);
            }
            if(closedOpporIds.size()>0){
                for(Invoice__c inv : [SELECT Id,Opportunity_Name__c FROM Invoice__c where Opportunity_Name__c IN :closedOpporIds AND Invoice_Status__c NOT IN :NONBILLED]){
                    billedOpty.add(inv.Opportunity_Name__c);
                }
            }
        }
        system.debug(duplicateContact+'**************');
        system.debug(optyContactMap.keySet()+'**************');
        for(OpportunityContactRole CR:[select id, ContactId, Role, OpportunityId from OpportunityContactRole where ContactId IN: duplicateContact AND OpportunityId IN:optyContactMap.keySet()]){
            if(!mapContactRoles.containsKey(CR.ContactId)){
                mapContactRoles.put(CR.ContactId, new Set<String>());
            }
            mapContactRoles.get(CR.ContactId).add(CR.Role);
        }
        if(Trigger.isDelete){
            for(OpportunityContactRole conRole : [Select Id,Opportunity.StageName,OpportunityId from OpportunityContactRole where Id IN :oldContactRoles.keySet() AND Opportunity.StageName = :CLOSEDSTAGE]){
                closedOpporIds.add(conRole.OpportunityId);
            }
            if(closedOpporIds.size()>0){
                for(Invoice__c inv : [SELECT Id,Opportunity_Name__c FROM Invoice__c where Opportunity_Name__c IN :closedOpporIds AND Invoice_Status__c NOT IN :NONBILLED]){
                    billedOpty.add(inv.Opportunity_Name__c);
                }
            }
            for(OpportunityContactRole conRole : oldContactRoles.values()){
                //if(billedOpty.size()>0 && billedOpty.contains(conRole.OpportunityId)){
                    //conRole.addError(BILLEDERROR);
                //}else 
                if(INVOICEROLE.equalsIgnoreCase(conRole.Role) && closedOpporIds.contains(conRole.OpportunityId)){
                    conRole.addError(NOCONERROR);
                }
            } 
        }else{
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,Email,AccountId,Inactive__c FROM Contact WHERE Id IN :contactIds]);
            String ErrorStr;
            for(OpportunityContactRole conRole : newContactRoles){
                ErrorStr = '';
                if(contactMap.containsKey(conRole.ContactId)){
                    /*if(optyAccountMap.containsKey(conRole.OpportunityId) && (INVOICEROLE.equalsIgnoreCase(conRole.Role) && contactMap.get(conRole.ContactId).AccountId != optyBillToMap.get(conRole.OpportunityId))){
                        ErrorStr = BILLTOERROR;
                    }*/
                    if(/*optyAccountMap.containsKey(conRole.OpportunityId) && (!INVOICEROLE.equalsIgnoreCase(conRole.Role) && contactMap.get(conRole.ContactId).AccountId != optyAccountMap.get(conRole.OpportunityId))*/optyAccountMap.containsKey(conRole.OpportunityId) && contactMap.get(conRole.ContactId).AccountId != optyAccountMap.get(conRole.OpportunityId)){
                        ErrorStr = ACCOUNTERROR;
                    }
                    if(contactMap.get(conRole.ContactId).InActive__c){
                        ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + INACTERROR:INACTERROR;
                    }
                    if(contactMap.get(conRole.ContactId).Email == null && (conRole.Role!='MPRA/SOW' && conRole.Role!='Proposal Primary Contact')){
                        ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + EMAILERROR:EMAILERROR;
                    }  
                }
                if(optyInvoiceContacts.size()>0 && optyInvoiceContacts.containsKey(conRole.OpportunityId) && optyInvoiceContacts.get(conRole.OpportunityId).size()>1){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + MULTIERROR:MULTIERROR;
                }
                if(optyPrimaryContacts.size()>0 && optyPrimaryContacts.containsKey(conRole.OpportunityId) && optyPrimaryContacts.get(conRole.OpportunityId).size()>1){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + MULTIERROR_PRIMARY:MULTIERROR_PRIMARY;
                }
                if(optyMPRAContacts.size()>0 && optyMPRAContacts.containsKey(conRole.OpportunityId) && optyMPRAContacts.get(conRole.OpportunityId).size()>1){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + MULTIERROR_MPRA:MULTIERROR_MPRA;
                    
                }
                system.debug(mapContactRoles.get(conRole.contactId)+'*-*-*-*-*--*-'+conRole.Role);
                //system.debug('Compare Ids=====>>>'+contactMap.get(conRole.ContactId).AccountId+'*-*-*-*-*--*-'+optyAccountMap.get(conRole.OpportunityId));
                if(duplicateContact.contains(conRole.ContactId) && mapContactRoles.get(conRole.contactId).Contains(INVOICEROLE) && conRole.Role==EMAILRECP){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + DUPERROR:DUPERROR;
                }
                if(duplicateContact.contains(conRole.ContactId) && mapContactRoles.get(conRole.contactId).Contains(EMAILRECP) && conRole.Role==INVOICEROLE){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + DUPERROR:DUPERROR;
                }
                /*if(duplicateContact.contains(conRole.ContactId) && (conRole.Role!='MPRA/SOW' && conRole.Role!='Proposal Primary Contact' && conRole.Role!='Name on Invoice')){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + DUPERROR:DUPERROR;
                }*/
                if(Trigger.isUpdate && closedOpporIds.contains(conRole.OpportunityId) && !INVOICEROLE.equalsIgnoreCase(conRole.Role) && INVOICEROLE.equalsIgnoreCase(oldContactRoles.get(conRole.Id).Role) && (!(optyInvoiceContacts.size()>0) || !optyInvoiceContacts.containsKey(conRole.OpportunityId))){
                    ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + NOCONERROR:NOCONERROR;
                } 
                //if(billedOpty.size()>0 && billedOpty.contains(conRole.OpportunityId)){
                    //ErrorStr = String.isNotBlank(ErrorStr)?ErrorStr + NEWLINE + BILLEDERROR:BILLEDERROR;
                //}
                if(String.isNotBlank(ErrorStr)) conRole.addError(ErrorStr);
            }
        }
    }
/**
* @Method Name       : rollOverOpportunities
* @description       : To copy contact roles to surveillance opportunities
**/
    public static void rollOverOpportunities(Map<Id,OpportunityContactRole> newContactRoles,Map<Id,OpportunityContactRole> oldContactRoles){ 
        try{
            List<OpportunityContactRole> optyConRolesToUpsert = new List<OpportunityContactRole>();
            Map<Id,List<OpportunityContactRole>> toUpdateInvoice = new Map<Id,List<OpportunityContactRole>>();
            Map<Id,Id> parentChildMap = new Map<Id,Id>();

            if(Trigger.isUpdate || Trigger.isDelete){
                Set<Id> childOptyIds = new Set<Id>();
                Map<Id,Id> parentOptyIds = new Map<Id,Id>();
                Map<Id,Id> childParentMap = new Map<Id,Id>();
                Map<Id,List<OpportunityContactRole>> parentOCRMap = new Map<Id,List<OpportunityContactRole>>(getOptyContactRoleMap(oldContactRoles));
                //Get parent opportunity & rolling over opportunity ids in a map
                for(Opportunity childOpty: [SELECT Id,Parent_Opportunity__c,Defer_Billing_or_Exit_Case__c,
                                            (SELECT Id FROM Invoices__r WHERE Invoice_Status__c IN : NONBILLED) 
                                            FROM Opportunity 
                                            WHERE Parent_Opportunity__c IN :parentOCRMap.keySet() AND Defer_Billing_or_Exit_Case__c!='Already Billed']){
                        childParentMap.put(childOpty.Id,childOpty.Parent_Opportunity__c);
                }
                Map<Id,OpportunityContactRole> toUpdateOrDelete = new Map<Id,OpportunityContactRole>();
                for(OpportunityContactRole childOCR : [SELECT Id,ContactId,OpportunityId,Opportunity.Parent_Opportunity__c,Role,IsPrimary 
                                                           FROM OpportunityContactRole 
                                                           WHERE OpportunityId In :childParentMap.keySet()]){
					for(OpportunityContactRole oldParentOCR : parentOCRMap.get(childParentMap.get(childOCR.OpportunityId))){
                        if(childOCR.ContactId==oldParentOCR.ContactId && childOCR.Role==oldParentOCR.Role && childOCR.IsPrimary==oldParentOCR.IsPrimary){
                            if(Trigger.isUpdate){
                                childOCR.ContactId = newContactRoles.get(oldParentOCR.Id).ContactId;
                                childOCR.Role = newContactRoles.get(oldParentOCR.Id).Role;
                                childOCR.IsPrimary = newContactRoles.get(oldParentOCR.Id).IsPrimary;
                            }
                            toUpdateOrDelete.put(childOCR.Id,childOCR);
                        }
                	}
                }           
                Map<Id,OpportunityContactRole> allOpportunitiesMap = new Map<Id,OpportunityContactRole>();//To Fetch & Update existing invoices of both parent & child opportunities
                if(Trigger.isDelete){
                    if(toUpdateOrDelete.size()>0){
                        allOpportunitiesMap.putAll(toUpdateOrDelete);
                        ContactTriggerHandler.deleteContactRoles(toUpdateOrDelete.values());
                    }
                    allOpportunitiesMap.putAll(oldContactRoles);
                    updateInvoice(getOptyContactRoleMap(allOpportunitiesMap));
                }else{
                    if(toUpdateOrDelete.size()>0){
                        allOpportunitiesMap.putAll(toUpdateOrDelete);
                    	optyConRolesToUpsert.addAll(toUpdateOrDelete.values());
                    }
                    allOpportunitiesMap.putAll(newContactRoles);
                    toUpdateInvoice = getOptyContactRoleMap(allOpportunitiesMap);
                }

            }else{
                toUpdateInvoice = getOptyContactRoleMap(newContactRoles);//To Fetch & Update existing invoices of parent opportunities
                //Roll over child opportunities
                for(Opportunity childOpty: [SELECT Id,Parent_Opportunity__c,Defer_Billing_or_Exit_Case__c,(SELECT Id FROM Invoices__r WHERE Invoice_Status__c IN : NONBILLED) 
                                            FROM Opportunity 
                                            WHERE Parent_Opportunity__c IN :toUpdateInvoice.keySet() AND Defer_Billing_or_Exit_Case__c!='Already Billed']){
                        for(OpportunityContactRole parentNewRole : toUpdateInvoice.get(childOpty.Parent_Opportunity__c)){
                            OpportunityContactRole tempRole = parentNewRole.clone(false,false,false,false);
                            tempRole.OpportunityId = childOpty.Id;
                            tempRole.Rollover_Check__c = true;
                            optyConRolesToUpsert.add(tempRole);
                        } 
                }
                /*for(Opportunity parentOpty: [Select Id,Child_Opportunity__c,(SELECT Id FROM Invoices__r WHERE Invoice_Status__c IN : NONBILLED) from Opportunity WHERE Id IN :toUpdateInvoice.keySet()]){
                  	if(parentOpty.Child_Opportunity__c!=null && parentOpty.Invoices__r.size()>0){
                        parentChildMap.put(parentOpty.Child_Opportunity__c,parentOpty.Id);
                    }
                }
                Map<Id,List<OpportunityContactRole>> optyConRoleMap = new Map<Id,List<OpportunityContactRole>>(toUpdateInvoice);
                if(parentChildMap.size()>0){
                    for(Opportunity opty : [SELECT Id,Parent_Opportunity__c FROM Opportunity 
                                        WHERE Id IN : parentChildMap.keySet()])
                    {
                        for(OpportunityContactRole parentNewRole : optyConRoleMap.get(parentChildMap.get(opty.Id))){
                            OpportunityContactRole tempRole = parentNewRole.clone(false,false,false,false);
                            tempRole.OpportunityId = opty.Id;
                            optyConRolesToUpsert.add(tempRole);
                        }
                        //To Fetch & Update existing invoices of child opportunities
                        toUpdateInvoice.put(opty.Id,optyConRoleMap.get(parentChildMap.get(opty.Id)));
                    }
                }*/
            }
            if(optyConRolesToUpsert.size()>0){
                Database.upsert(optyConRolesToUpsert,false);
            }
            if(toUpdateInvoice.size()>0){
                updateInvoice(toUpdateInvoice);
            }
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }

/**
* @Method Name       : updateInvoice
* @description       : To update Contact Name on Invoice when Opportunity Contact Roles are updated for parent opportunities
**/
    public static void updateInvoice(Map<Id,List<OpportunityContactRole>> optyIdContactRoleMap){ 
        try{
            List<Invoice__c> invList = new List<Invoice__c>();
            for(Invoice__c inv : [SELECT Id,Contact_Name__c,Opportunity_Name__c FROM Invoice__c WHERE Opportunity_Name__c IN : optyIdContactRoleMap.keySet() AND Invoice_Status__c IN : NONBILLED]){
                for(OpportunityContactRole conRole : optyIdContactRoleMap.get(inv.Opportunity_Name__c)){
                    if(INVOICEROLE.equalsIgnoreCase(conRole.Role)){
                        inv.Contact_Name__c = Trigger.isDelete? null: conRole.ContactId;
                    }
                }
                invList.add(inv);
            }
            if(invList.size()>0){
                Database.update(invList,false);
            }
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }
/**
* @Method Name       : getOptyContactRoleMap
* @description       : To get Map<Id,OpportunityContactRole> to send as parameter to updateInvoice method
**/
public static Map<Id,List<OpportunityContactRole>> getOptyContactRoleMap(Map<Id,OpportunityContactRole> oppoConMap){ 
    Map<Id,List<OpportunityContactRole>> optyRoleMap = new Map<Id,List<OpportunityContactRole>>();
    for(OpportunityContactRole ocr : oppoConMap.Values()){
        if(optyRoleMap.containsKey(ocr.OpportunityId)){
            optyRoleMap.get(ocr.OpportunityID).add(ocr);
        }else{
            optyRoleMap.put(ocr.OpportunityID,new List<OpportunityContactRole>{ocr});
        }
    }
    return optyRoleMap;
}
}