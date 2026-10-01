/**
* @description       : Helper class Contact Trigger
* @author            : Damco Group
* @Created on  		 : 02-03-2022
**/
public class ContactTriggerHandler {
	private static final String ERROR = 'It can not be deactivated as this contact has been mapped as “Name on Invoice” role in opportunity - “';
    private static final String ERRORCONTD = '”. Please change the contact role first then deactivate.';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String FIELDNAME = 'Inactive__c';
    private static final String INVOICEROLE = 'Name on Invoice';
/**
* @Method Name       : validateActiveContacts
* @description       : To validate an active contact on account with a proper email address during a contact is getting inactivated 
						inorder to have a opportunity contact role used for invoice generation
**/
	public static void validateActiveContacts(List<Contact> contactList,Map<Id,Contact> oldContacts){ 
        Set<Id> inactiveConIds = new Set<Id>();
        for(Contact con: contactList){
            if(con.Inactive__c && !oldContacts.get(con.Id).Inactive__c){
                inactiveConIds.add(con.Id);
            }
        }
        if(inactiveConIds.size()>0){
            if(Trigger.isAfter){
                Map<Id,List<OpportunityContactRole>> closedOptyMap = new Map<Id,List<OpportunityContactRole>>();
                List<OpportunityContactRole> contactRolesToDelete = new List<OpportunityContactRole>();
                for(OpportunityContactRole opContactRole : [SELECT Id,ContactId,OpportunityId,Opportunity.StageName
                                                            FROM OpportunityContactRole 
                                                            WHERE ContactId IN :inactiveConIds])
                {
                    if(!CLOSEDSTAGE.equalsIgnoreCase(opContactRole.Opportunity.StageName)){
                    	contactRolesToDelete.add(opContactRole);                         
                    }
                }
                if(contactRolesToDelete.size()>0){
                	deleteContactRoles(contactRolesToDelete);                    
                }
            }else{
                Map<Id,Set<String>> errOptyMap = new Map<Id,Set<String>>();
                for(OpportunityContactRole orc : [SELECT Id,ContactId,OpportunityId,Opportunity.Name FROM OpportunityContactRole 
                                                  WHERE ContactID IN :inactiveConIds 
                                                  AND ROLE = :INVOICEROLE 
                                                  AND Opportunity.StageNAme = :CLOSEDSTAGE]){
                    if(errOptyMap.containsKey(orc.ContactId)){
                        errOptyMap.get(orc.ContactId).add(orc.Opportunity.Name);                
                    }else{
                        errOptyMap.put(orc.ContactId,new Set<String>{orc.Opportunity.Name});
                    }
                }
                if(errOptyMap.size()>0){
                    for(Contact con: contactList){
                        if(inactiveConIds.contains(con.Id) && errOptyMap.containsKey(con.Id)){
                            con.addError(FIELDNAME,ERROR + String.join(new List<String>(errOptyMap.get(con.Id)), ',') + ERRORCONTD);
                        }
                    }
                }
            }
        }
    }
    /**
* @Method Name       : deleteContactRoles
* @description       : To delete Contact Roles when related contact is inactive
**/
    public static void deleteContactRoles(List<OpportunityContactRole> contactRoleList){
        Database.DeleteResult[] drList = Database.delete(contactRoleList, false);
        for(Database.DeleteResult dr : drList) {
            if (!dr.isSuccess()) {
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('OpportunityContactRole fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}