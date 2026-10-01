global class EmailToContactAttachmentBatch implements Database.Batchable<sObject> {
    
    global List<Contact> ConList {get;set;}
    
    global Map<Id,Set<string>> accountccemails=new Map<Id,Set<string>>();
    
    global EmailToContactAttachmentBatch(List<Contact> ContacctList,Map<Id,Set<string>> Mapaccountccemails)
    {
        this.ConList=ContacctList;
        this.accountccemails=Mapaccountccemails;
    }
    global List<Contact> start(Database.BatchableContext BC) {
        
        // this.EmailTemplateName=BulkMailTemplate;
        return ConList;
        
    }
    
    global void execute(Database.BatchableContext BC, Sobject[] scope ) {
        EmailTemplate BulkMailTemplate = [select Id,Name,Subject,body,HtmlValue from EmailTemplate where DeveloperName = 'BulkEmailTemplateHTML']; 
        //ContentVersion cv=[SELECT title, PathOnClient, FileType,versiondata FROM contentversion where   title='Disclosure of Lender Details - 4 June 2021'];
        List<Attachment> Attachmentlist=new  List<Attachment>();
        Set<Id> ContactIds=new Set<Id>();
        OrgWideEmailAddress owa =[select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        system.debug('scope '+scope);
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        for(Contact objContact :(List<contact>) scope) {
            system.debug('objContact '+objContact);
            ContactIds.add(objContact.Id);
            PageReference pref = page.Addendum;
            pref.getParameters().put('Id',objContact.Id);
            pref.setRedirect(true);
            Blob b; 
            Blob b1;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
                b1= blob.valueOf('Unit.Test');
            } else {
                b = pref.getContent();
                // b1=cv.versiondata;
            }
            
            //Prepare SendToEmail List          
            List<String> lstSendToEmails = new List<String>();
            if(objContact.Email != null) {
                lstSendToEmails.add(objContact.Email);
            }
            
            
            Set<String> lstCCToEmails = new Set<String>();
            if(objContact.Email != null) {
                lstCCToEmails=accountccemails.get(objContact.AccountID);
            }
            Attachment attachs = new Attachment();
            attachs.Body = b;
            attachs.Name = 'Addendumto publish the name of the banker and amount of loan PG'+'.pdf';
            attachs.IsPrivate = false;
            attachs.contentType = 'application/pdf';
            attachs.ParentId = objContact.Id;
            Attachmentlist.add(attachs);
            
        }
        try { 
            if(!Attachmentlist.IsEmpty())
            {
                insert Attachmentlist;
            }
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            List<contact> conlist=new List<contact>();
            for(contact objContact:[select id,AccountID,(select id from Attachments where name='Addendumto publish the name of the banker and amount of loan PG.pdf' order by createddate desc limit 1 ) from contact where id in :ContactIds])
            {
                if(!objContact.Attachments.isEmpty())
                {
                    if(accountccemails.get(objContact.AccountID)!=null)
                    {
                        Set<string> cclist=accountccemails.get(objContact.AccountID);
                        List<String> listdata = new List<String>(cclist);
                        objContact.NonBillingContacts__c =string.join(listdata,',');
                    }
                    
                    objContact.FileURL__c=baseUrl+'/servlet/servlet.FileDownload?file='+objContact.Attachments[0].Id+'&operationContext=S1'; 
                }
                conlist.add(objContact);
            }
            if(!conlist.IsEmpty())
            {
                update conlist;
            }
            
        }catch(Exception e)  
        {  
            System.Debug(e.getMessage());  
        }  
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}