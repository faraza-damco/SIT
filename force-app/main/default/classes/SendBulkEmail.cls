public class SendBulkEmail {
    
    public String selectedConactList {get;set;}
    public String Error {get;set;}
    
    
    
    public SendBulkEmail(){
        Error='';
        if(Test.isRunningTest())
        {
            selectedConactList=system.label.BulkEmailQuery;
        }
       // selectedConactList=system.label.BulkEmailQuery;
        //  getdata();
        // selectedConactList=System.label.BulkEmailQuery.substringAfter('where');
    }
    
    
    public void sendMailNew()   
    {
        List<Opportunity> opplist=new List<Opportunity>();
        
        string userQuery =selectedConactList;
        try
        {
            Database.Query(userQuery + ' LIMIT 0');
        }
        catch(QueryException ex)
        {
            system.debug('');
            Error=' Your query is incorrect please input valid query.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 
                                                       Error));
            return;
            //Error handling
        }
        
        
        system.debug('userQuery '+userQuery);        
        opplist=Database.query(userQuery);
        
        //SELECT Id,Accountid FROM opportunity where (RecordType.name='New Business' and stageName='Closed Won' ) or (RecordType.name='Surveillance')
        //find a list of contacts with birthdays today  
        Set<Id> AccountIds=new Set<Id>();
        for(Opportunity op:opplist)
        {
            AccountIds.add(op.Accountid);
        }
        Map<Id,set<string>> accountccemails=new Map<Id,set<string>>();
        //Accountid=:AccountIds and
        Contact[] cblling = [SELECT Id,Salutation,LastName, Name,email,Account.owner.email,Account.owner.Name,owner.Name FROM Contact where Accountid=:AccountIds and  Billing_Contact__c='Yes' and email!='' ];
        Contact[] cnonbilling = [SELECT Id,AccountId,Account.owner.email,Account.owner.Name ,Name,email,owner.Name,Account.Classification__c FROM Contact Where Accountid=:AccountIds  and  email!='' ];  
		system.debug('cnonbilling '+cnonbilling);

        for(Contact c:cnonbilling)
        {
             system.debug('c '+c);
            if(accountccemails.containskey(c.AccountId))
            {
                
                system.debug('c.AccountId '+c.AccountId);
                system.debug('c.email '+c.email);
                set<string> emaillist=accountccemails.get(c.AccountId);
                  system.debug('emaillist before '+emaillist);
                emaillist.add(c.email);
                  system.debug('emaillist after '+emaillist);
                accountccemails.put(c.AccountId,emaillist);
                
            }
            else
            {
                if(c.Account.Classification__c=='SECG')
                {
                    accountccemails.put(c.AccountId, new set<string>{c.email,c.Account.owner.email,System.label.L_Shivakumar} );
                }
                else
                {
                    accountccemails.put(c.AccountId, new set<string>{c.email,c.Account.owner.email,System.label.L_Shivakumar} );
                }
                
            }
        }
        system.debug('cblling '+cblling);
        system.debug('accountccemails '+accountccemails);
       // EmailToContactBatch ECB=new EmailToContactBatch(cblling,accountccemails);
        //Database.executeBatch(ECB, 10);
        EmailToContactAttachmentBatch ECB=new EmailToContactAttachmentBatch(cblling,accountccemails);
        Database.executeBatch(ECB, 200);
        // 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 
                                                   'Email Sent Sucessfully'));
        
        
    }
    /* public void sendMail()   
{  
//define variables 
string query=System.label.BulkEmailQuery;      

String BulkEmailTemplateName = System.label.BulkEmailTemplate;  
String debugMessage;  
String[] toAddresses;  
List<Id> BulkMailIdsList = getBulkEmailAddresses(query);  

//Set the templates  
EmailTemplate BulkMailTemplate = [select Id,Name,Subject,body from EmailTemplate where DeveloperName = :BulkEmailTemplateName];  
if(BulkMailTemplate != null && BulkMailIdsList.isEmpty() == false)  
{  

Messaging.MassEmailMessage BulkMail = new Messaging.MassEmailMessage();  

BulkMail.setTargetObjectIds(BulkMailIdsList);  
BulkMail.setTemplateId(BulkMailTemplate.Id);  

BulkMail.setUseSignature(false);  
BulkMail.setSaveAsActivity(true);  

// Send the email  
try {  
Messaging.SendEmailResult[] mrs=   Messaging.sendEmail(new Messaging.MassEmailMessage[] { BulkMail });  
for (Messaging.SendEmailResult mr : mrs) 
{
if (mr.isSuccess()) {
//Do something for success
}  else {
// Operation failed, so get all errors                
for(Messaging.SendEmailError err : mr.getErrors()) {
System.debug('The following error has occurred.');                    
System.debug(err.getStatusCode() + ': ' + err.getMessage());
System.debug('fields that affected this error: ' + err.getFields());
}
}
}
}catch(Exception e)  
{  
System.Debug(e);  
}  

}  
else  
{  
System.Debug(' Either an email template could not be found, or no Contact ');  
}//end if  

}//end sendMail()   
*/
    
    
    
    
}