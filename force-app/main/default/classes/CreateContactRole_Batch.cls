public class CreateContactRole_Batch implements Database.Batchable<SObject>{
    public string query;
    public Id accId;
    public string CLOSEDLOST = 'Closed Lost';
    public CreateContactRole_Batch(){
        query = 'SELECT Id,AccountId,StageName FROM Opportunity WHERE StageName !=: CLOSEDLOST';
    }
    public CreateContactRole_Batch(Id inId){
        accId = inId;
        query = 'SELECT Id,AccountId,StageName FROM Opportunity WHERE StageName !=: CLOSEDLOST AND AccountId =: accId';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        List<String> NONBILLED = new List<String>{'Proforma Invoice','QR and IRN - Failed','Canceled'};
        List<String> INVOICEROLES2 = new List<String>{'Name on Invoice','Kind Attn of Invoice'};
        Map<Opportunity,ID> optyAccouontMap = new Map<Opportunity,ID>();
        Map<Id,Id> oppOpcontacMap = new Map<Id,Id>();
        Map<Id,List<String>> optyConRolesMap = new Map<Id,List<String>>();
		for(OpportunityContactRole opCon : [SELECT Id,OpportunityId,Role,ContactId FROM OpportunityContactRole  WHERE OpportunityId =: oppList]){
            if(!optyConRolesMap.containsKey(opCon.OpportunityId)){
                optyConRolesMap.put(opCon.OpportunityId,new List<String>());
            }optyConRolesMap.get(opCon.OpportunityId).add(opCon.ContactId);
            if(INVOICEROLES2.contains(opCon.Role)){
            	oppOpcontacMap.put(opCon.OpportunityId,opCon.Id);
            }
		}
		Map<Id,Id> oppInvoiceMap = new Map<Id,Id>();
		//for(Invoice__c inv : [SELECT Id,Opportunity_Name__c FROM Invoice__c where Opportunity_Name__c =: oppList AND Invoice_Status__c NOT IN :NONBILLED]){
			//oppInvoiceMap.put(inv.Opportunity_Name__c,inv.Id);
		//}
        for(Opportunity opty : oppList){   
            if((!(oppOpcontacMap.size()>0) || !(oppOpcontacMap.containsKey(opty.Id)))){// && (!(oppInvoiceMap.size()>0) || !(oppInvoiceMap.containsKey(opty.Id)))){
                optyAccouontMap.put(opty,opty.AccountId);
            }
        }
        if(optyAccouontMap.keySet().size()>0){
            Map<Id,List<Contact>> accWithAllCon = new Map<Id,List<Contact>>();	
            Map<Id,List<Contact>> accWithBillingCon = new Map<Id,List<Contact>>();//FOR DEBUG
            //Map<Id,String> billingContactadded = new Map<Id,String>();
            //Fetch All Contacts related to the Accounts of live opportunity
            
            for(Contact con : [SELECT Id,Name,AccountId,Billing_Contact__c FROM Contact WHERE AccountId IN: optyAccouontMap.Values() AND Inactive__c = False AND Email!=null AND recordtype.Name = 'Account Contact' ORDER BY LastModifieddate DESC]){
                //FOR DEBUG Opportunity with multiple related Billing Contacts
                if(con.Billing_Contact__c == 'Yes'){
                    if(accWithBillingCon.containsKey(con.AccountId)){
                        accWithBillingCon.get(con.AccountId).add(con);
                    }else{
                        accWithBillingCon.put(con.AccountId,new List<Contact>{con});
                    }
                }
                
                if(accWithAllCon.containsKey(con.AccountId)){
                    accWithAllCon.get(con.AccountId).add(con);
                }else{
                    accWithAllCon.put(con.AccountId,new List<Contact>{con});
                }
            }
            List<OpportunityContactRole> optyContactRoleList = new List<OpportunityContactRole>();
            Set<Id> noValidConForOptyList = new Set<Id>();//FOR DEBUG
            Set<Id> multiNameOnInvoiceOptyList = new Set<Id>();//FOR DEBUG
            Set<Id> InvoiceRoles = new Set<Id>();//FOR DEBUG
            for(Opportunity opty : optyAccouontMap.KeySet()){
                if(accWithBillingCon.containsKey(opty.AccountId) && accWithBillingCon.get(opty.AccountId).size()>0){
                    if(accWithBillingCon.get(opty.AccountId).size()>1){
                        multiNameOnInvoiceOptyList.add(opty.Id);
                    }else{
                        if(accWithAllCon.containsKey(opty.AccountId) &&  accWithAllCon.get(opty.AccountId).size()>0){
                            for(Contact con : accWithAllCon.get(opty.AccountId)){
                                if(con.Billing_Contact__c == 'Yes' && (!(optyConRolesMap.size()>0) || !(optyConRolesMap.containsKey(opty.Id)) || (optyConRolesMap.size()>0 && optyConRolesMap.containsKey(opty.Id) && !optyConRolesMap.get(opty.Id).contains(con.Id)))){
                                    InvoiceRoles.add(opty.Id);
                                    optyContactRoleList.add(new OpportunityContactRole(
                                        ContactId = con.Id,
                                        OpportunityId = opty.Id,
                                        IsPrimary = true,
                                        Role = 'Name on Invoice'));
                                }else if(!(optyConRolesMap.size()>0) || !(optyConRolesMap.containsKey(opty.Id)) || (optyConRolesMap.size()>0 && optyConRolesMap.containsKey(opty.Id) && !optyConRolesMap.get(opty.Id).contains(con.Id))){
                                    optyContactRoleList.add(new OpportunityContactRole(
                                        ContactId = con.Id,
                                        OpportunityId = opty.Id,
                                        Role = 'Email Recipient'));
                                }
                            }
                        }else{
                            noValidConForOptyList.add(opty.Id);
                        }
                    }
                }else{
                    noValidConForOptyList.add(opty.Id);
                }
            }
            
            //System.debug('%%%LiveOpportunities'+optyAccouontMap.KeySet());
            //System.debug('%%%InvoiceRolesToCreateOn'+InvoiceRoles);
            //System.debug('%%%NOContactsWithEmailNActive'+noValidConForOptyList);
            //System.debug('%%%MultipleBillingContacts'+multiNameOnInvoiceOptyList);
            //System.debug('%%%RolesToCreateOn'+optyContactRoleList);
            
            System.debug('###LiveOpportunities'+optyAccouontMap.KeySet().size());
            System.debug('###InvoiceRolesToCreateOn'+InvoiceRoles.size());
            System.debug('###NOContactsWithEmailNActive'+noValidConForOptyList.size());
            System.debug('###MultipleBillingContacts'+multiNameOnInvoiceOptyList.size());
            System.debug('###RolesToCreateOn'+optyContactRoleList.size());
            
            if(optyContactRoleList.size()>0){
            	Database.SaveResult[] insertedImList = database.insert(optyContactRoleList, false);    
                for (Integer i = 0; i < insertedImList.size(); i++){
                    if(!insertedImList[i].isSuccess()){
						System.debug('@@@@@@@ERROR'+insertedImList[i].getErrors()[0].getMessage());
                    }
                }
            }            
            //create errorlog to get Ids of Opportunities with No valid contact & also the ones with multiple invoice contacts?
        }
        
        
    }
    
    public void finish(Database.BatchableContext BC){}
}