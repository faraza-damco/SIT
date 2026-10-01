global class ICRA_BD_Notification_Before30Days implements Database.Batchable<sObject>{

      List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        
        String OpportunityQuery = 'SELECT Id, Name, OwnerId,Owner.Manager.Email ,Billing_Start_Date__c,RecordType.Name,Owner.email,Bill_Date__c, Owner.Name FROM Opportunity  WHERE CloseDate >= TODAY AND CloseDate < NEXT_N_DAYS:30 AND Total_Invoice_Amount_1__c >= 0';// AND RecordType.Name =: Surveillance
        System.debug('===== Query +====== : '+OpportunityQuery);
        return Database.getQueryLocator(OpportunityQuery); 
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> OpportunityList){
         System.debug('======= execute ======='+OpportunityList.size());
    
        EmailTemplate[] emailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'BD_Notification_Batch_Execution_30Days' LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        Map<Id,EmailNotification> emailNotificationMap = new map<Id,EmailNotification>(); 
        for(Opportunity opportunityRecord : OpportunityList){ 
            EmailNotification temp = new EmailNotification();
            temp.recordOwnerName = opportunityRecord.Owner.Name; 
            temp.sendTo = opportunityRecord.Owner.Email;
            temp.sendToMn = opportunityRecord.Owner.Manager.Email;
            temp.targetObjectId = opportunityRecord.OwnerId;
            if(emailTemplate.size() > 0){
            temp.templateName = emailTemplate[0].Id;
            }
            emailNotificationMap.put(opportunityRecord.OwnerId, temp); 
        }
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'billing@icraindia.info']; 

        if(emailNotificationMap.values().size() > 0){
            for(EmailNotification email : emailNotificationMap.values()){
                Messaging.SingleEmailMessage email_record = new Messaging.SingleEmailMessage();
                email_record.setTargetObjectId(email.targetObjectId);
                email_record.setTemplateID(email.templateName); 
                email_record.setOrgWideEmailAddressId(owea.get(0).Id);
                email_record.setHtmlBody(emailTemplate[0].Body);
                email_record.setToAddresses(new List<String> {email.sendTo});
                email_record.setCcAddresses(new List<String> {email.sendToMn});
                email_record.setSaveAsActivity(false);
                emailList.add(email_record);
            }
        }
        
        System.debug('=========  emailNotificationSet === '+emailNotificationMap.values() );
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
        String sendToMn = '';
        public EmailNotification(){}
    }
}