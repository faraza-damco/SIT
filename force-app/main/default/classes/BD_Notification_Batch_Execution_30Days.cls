global class BD_Notification_Batch_Execution_30Days implements Database.Batchable<sObject>{
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String OpportunityQuery = 'SELECT Id, Name, OwnerId, Owner.email,Bill_Date__c, Owner.Name FROM Opportunity  WHERE  CloseDate = NEXT_N_DAYS:30 AND BD_Approve__c = false';
        return Database.getQueryLocator(OpportunityQuery);  
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> OpportunityList){
        EmailTemplate[] emailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'BD_Email_Next_Month_VF' LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        Map<Id,EmailNotification> emailNotificationMap = new map<Id,EmailNotification>(); 
        for(Opportunity opportunityRecord : OpportunityList){ 
            EmailNotification temp = new EmailNotification();
            temp.recordOwnerName = opportunityRecord.Owner.Name; 
            temp.sendTo = opportunityRecord.Owner.Email;
            temp.targetObjectId = opportunityRecord.OwnerId;
            if(emailTemplate.size() > 0){
                temp.templateName = emailTemplate[0].Id;
            }
            
            emailNotificationMap.put(opportunityRecord.OwnerId, temp); 
        }
        
        if(emailNotificationMap.values().size() > 0){
            for(EmailNotification email : emailNotificationMap.values()){
                Messaging.SingleEmailMessage email_record = new Messaging.SingleEmailMessage();
                email_record.setTargetObjectId(email.targetObjectId);
                email_record.setTemplateID(email.templateName); 
                email_record.setHtmlBody(emailTemplate[0].Body);
                email_record.setToAddresses(new List<String> {email.sendTo});
                email_record.setSaveAsActivity(false);
                emailList.add(email_record);
            }
        }
        
        Messaging.sendEmail(emailList); 
        
    }  
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Opportunity Batch Job is done ****  /' +BC);
        
        
    }
    
      
    public class EmailNotification{ 
        String targetObjectId = ''; 
        String templateName = '';
        String recordOwnerName = '';
        String sendTo = ''; 
        public EmailNotification(){}
    }
}