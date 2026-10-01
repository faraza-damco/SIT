public with sharing class ICRA_Proposal_new_ExtensionClass {
    public string optyId    {get;set;}
    public string salutation    {get;set;}
    public string firstName    {get;set;}
    public string lastName    {get;set;}
    public string name    {get;set;}
    public string designation    {get;set;}
    public ICRA_Proposal_new_ExtensionClass(ApexPages.StandardController stdController) {
        //this.optyId= stdController.getId();
        optyId= ApexPages.currentPage().getParameters().get('Id');
        system.debug(optyId);
        List<OpportunityContactRole> optyConRoleList= [select id, OpportunityId, ContactId, Role FROM OpportunityContactRole where OpportunityId=:optyId AND Role='Proposal Primary Contact' ORDER BY CreatedDate DESC];
        if(!optyConRoleList.isEmpty()){
            //conRole= optyConRoleList[0].Role;
            List<Contact> conList= [select id, Name, firstName, lastName, Designation__c, Salutation from Contact where id=:optyConRoleList[0].ContactId ORDER BY CreatedDate DESC];
            if(!conList.isEmpty()){
                name= conList[0].Name;
                firstName= conList[0].firstName;
                lastName= conList[0].lastName;
                designation= conList[0].Designation__c;
                salutation= conList[0].Salutation;
            }
        }
    }
}