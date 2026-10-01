public with sharing class Send_Review_MPRA_Doc_ExtensionClass {
    public string optyId    {get;set;}
    public string conId    {get;set;}
    public String controllerVariable { get; set; }
    //public String controllerEffectiveVariable { get; set; }
    public Boolean isMPRAChecked { get; set; }
    public Boolean isSOWChecked { get; set; }
    public Boolean sendmpraDoc { get; set; }
    public Boolean sendsowDoc { get; set; }
    public Send_Review_MPRA_Doc_ExtensionClass(ApexPages.StandardController stdController) {
        //this.optyId= stdController.getId();
        optyId= ApexPages.currentPage().getParameters().get('Id');
        List<OpportunityContactRole> optyConRoleList= [select id, OpportunityId, ContactId, Role FROM OpportunityContactRole where OpportunityId=:optyId AND Role='MPRA/SOW' ORDER BY CreatedDate DESC];
        if(!optyConRoleList.isEmpty()){
            //conRole= optyConRoleList[0].Role;
            List<Contact> conList= [select id, Name, firstName, lastName, Designation__c, Salutation from Contact where id=:optyConRoleList[0].ContactId ORDER BY CreatedDate DESC];
            if(!conList.isEmpty()){
                conId= conList[0].Id;
            }
        }
    }
    public void updateDates(){
        String docType = controllerVariable;
        system.debug('variable from VF paramName==>>'+docType);
        Opportunity opp= [select id, MPRA_Sent_Date__c, SOW_Effective_Date__c from opportunity where id=:optyId];
        if(opp.MPRA_Sent_Date__c==null && docType=='MPRADoc'){           //&& docType=='MPRADoc'
            opp.MPRA_Sent_Date__c=System.Today();
        }
        if(opp.SOW_Effective_Date__c==null && docType=='SowDoc'){          //&& docType=='SowDoc'
            opp.SOW_Effective_Date__c=System.Today();
        }
        update opp;
    }
    public void updateEffectiveDatesOnSend(){
        //String docType = controllerEffectiveVariable;
        system.debug('variable from VF MPRA==>>'+isMPRAChecked);
        system.debug('variable from VF SoW==>>'+isSOWChecked);
        Opportunity opp= [select id, MPRA_Sent_Date__c, SOW_Effective_Date__c from opportunity where id=:optyId];
        if(isMPRAChecked){   
            system.debug('MPRA_Date'+opp.MPRA_Sent_Date__c);        //&& docType=='MPRADoc'
            opp.MPRA_Sent_Date__c= System.Today();
            system.debug('MPRA_Date'+opp.MPRA_Sent_Date__c);
        }
        if(isSOWChecked){          //&& docType=='SowDoc'
            opp.SOW_Effective_Date__c= System.Today();
        }
        try{
            update opp;
        }catch(exception ex){
            system.debug('Exception:'+ex.getMessage());
        }
    }
}