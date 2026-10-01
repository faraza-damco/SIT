public class MPRA_SOW_BillingContact {

    public Contact BillingContactDetails {get;set;}
    public Contact oppContact {get;set;}
    public Contact oppContactName {get;set;}
    public Contact oppContactEmailReceipient {get;set;}
    public Branch__c branchGurgaon {get;set;}
    public MPRA_SOW_BillingContact(ApexPages.StandardController controller){
        String OppId = ''+ApexPages.currentPage().getParameters().get('id'); 
        if(OppId != 'null' && OppId != '' && OppId != null ){
          Opportunity opp= [select id, accountid from Opportunity where id=:OppId limit 1 ];
           
          Contact[] Con=[select id,name,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,Designation__c,Billing_Contact__c,Department,Email	 from contact where accountid=:opp.AccountId and Billing_Contact__c	='Yes'  ];
          if(Con.Size()>0)
          {
               BillingContactDetails=Con[0];
          }
          List<OpportunityContactRole> optyConRole= [select Id, Role, ContactId, OpportunityId from opportunityContactRole where OpportunityId=:OppId /*AND Role='MPRA/SOW' LIMIT 1*/]; 
          if(optyConRole.size()>0){
            for(OpportunityContactRole conRole : optyConRole){
              if(conRole.Role=='MPRA/SOW'){
                Contact cont= [Select Id, Salutation, FirstName, LastName, Designation__c, Email,MobilePhone from Contact where Id=:conRole.ContactId LIMIT 1];
                oppContact=Cont;
              }
              if(conRole.Role=='Name on Invoice'){
                Contact contName= [Select Id, Salutation, FirstName, LastName, Designation__c, Email,MobilePhone from Contact where Id=:conRole.ContactId LIMIT 1];
                oppContactName=contName;
              }
              if(conRole.Role=='Email Recipient'){
                Contact contName= [Select Id, Salutation, FirstName, LastName, Designation__c, Email,MobilePhone from Contact where Id=:conRole.ContactId LIMIT 1];
                oppContactEmailReceipient=contName;
              }
            }
          }
          Branch__c branch=[select id, name,Street__c,City__c,Country__c,State__c,Zip_Postal_Code__c,PAN__c,GSTIN__c from Branch__c where name='Gurgaon' LIMIT 1];
          branchGurgaon=branch;
        }
        
    }
}