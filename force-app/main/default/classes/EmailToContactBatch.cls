global class EmailToContactBatch implements Database.Batchable<sObject> {
    global List<Contact> ConList {get;set;}
    
    global Map<Id,List<string>> accountccemails=new Map<Id,List<string>>();
    
    global EmailToContactBatch(List<Contact> ContacctList,Map<Id,List<string>> Mapaccountccemails)
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
        ContentVersion cv=[SELECT title, PathOnClient, FileType,versiondata FROM contentversion where   title='Disclosure of Lender Details - 4 June 2021'];
        
        system.debug('scope '+scope);
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        for(Contact objContact :(List<contact>) scope) {
            Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
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
                b1=cv.versiondata;
            }
            
            //Prepare SendToEmail List          
            List<String> lstSendToEmails = new List<String>();
            if(objContact.Email != null) {
                lstSendToEmails.add(objContact.Email);
            }
            objEmail.setToAddresses(lstSendToEmails);
            //Prepare CCEmailList
            List<String> lstCCToEmails = new List<String>();
            if(objContact.Email != null) {
                
                     lstCCToEmails=accountccemails.get(objContact.AccountID);
             
               
            }
            attach.setFileName('Addendum to publish the name of the banker and amount of loan PG.pdf');
            attach.setBody(b);
            attach2.setFileName('Disclosure of Lender Details.pdf');
            attach2.setBody(b1);
            objEmail.setCcAddresses(lstCCToEmails);
            
            System.debug('lstSendToEmails '+lstSendToEmails);
            System.debug('lstCCToEmails '+lstCCToEmails);
            System.debug('objContact.account.Owner.email '+objContact.account.Owner.email);
            // Set From Email Address
            //objEmail.setOrgWideEmailAddressId(objContact.account.Owner.email);
            // Step 3: Set who the email is sent from
            objEmail.setReplyTo(objContact.account.Owner.email);
            objEmail.setSenderDisplayName(objContact.account.Owner.Name);
            //Set Email Subject
            objEmail.setSubject('Request for consent to publish the name of the banker(s) and the details of credit facilities rated in the press release');
            
            //Set Email Template
            //objEmail.setTemplateId('Email Template Id');
            
            //Set Email Body
            String body = 'Dear Contact,please ready to contact if you have any issues';
            String htmlBody = BulkMailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Contact.Account}', objContact.Account.Owner.Name);
            
            //objEmail.setHtmlBody(body);
            objEmail.setTemplateId(BulkMailTemplate.Id); 
            objEmail.setTargetObjectId(objContact.Id);
            objEmail.setHtmlBody(htmlBody);
            //objEmail.setPlainTextBody(BulkMailTemplate.Body);
            
            
            objEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach,attach2});
            
            lstEmails.add(objEmail);
        }
        if(!Test.isRunningTest()) {
            try { 
                //    Messaging.SendEmailResult[] results ;
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmails);
                // To Check whether Email is sent or not,We update processed field of each contact.
                
                List<Email_Log__c> ELList=new  List<Email_Log__c>();
                
                for(Messaging.SendEmailResult result: results) {
                    system.debug('results '+result);
                    
                    if (result.isSuccess()) {
                        //Do something for success
                    }  else {
                        // Operation failed, so get all errors                
                        for(Messaging.SendEmailError err : result.getErrors()) {
                            Email_Log__c EL=new Email_Log__c();
                            EL.Message__C=err.getMessage();
                            ELList.add(EL);
                        }
                    }
                    
                }
            
                insert ELList ;
   
                
            }catch(Exception e)  
            {  
                System.Debug(e.getMessage());  
            }  
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}