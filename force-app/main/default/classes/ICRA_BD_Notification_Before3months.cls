/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-25-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-25-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class ICRA_BD_Notification_Before3months implements Database.Batchable<sObject>{
     List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date dueDate = System.today().addDays(90);
         String OpportunityQuery = 'SELECT Id, Name, OwnerId,Owner.Manager.Email ,Billing_Start_Date__c,RecordType.Name,Owner.email,Bill_Date__c, Owner.Name FROM Opportunity  WHERE CloseDate >= TODAY AND CloseDate <= NEXT_N_DAYS:90 AND Total_Invoice_Amount_1__c >= 1';// AND RecordType.Name =: Surveillance
        return Database.getQueryLocator(OpportunityQuery); 
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> OpportunityList){
       EmailTemplate[] emailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'ICRA_BD_Notification_Before_3months' LIMIT 1];
        
        Set<Messaging.SingleEmailMessage> emailList = new Set<Messaging.SingleEmailMessage>(); 
        Map<Id,EmailNotification> emailNotificationMap = new map<Id,EmailNotification>(); 
        for(Opportunity opportunityRecord : OpportunityList){ 
            EmailNotification temp = new EmailNotification();
            temp.recordOwnerName = opportunityRecord.Owner.Name; 
            temp.sendTo = opportunityRecord.Owner.Email;
            temp.sendToMn = opportunityRecord.Owner.Manager.Email;
            temp.targetObjectId = opportunityRecord.OwnerId;
            temp.templateName = emailTemplate[0].Id;
            emailNotificationMap.put(opportunityRecord.OwnerId, temp); 
        }
        String body1 = emailTemplate[0].Body;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'billing@icraindia.info'];
        
        if(emailNotificationMap.values().size() > 0){
            for(EmailNotification email : emailNotificationMap.values()){
                Messaging.SingleEmailMessage email_record = new Messaging.SingleEmailMessage();
                email_record.setTargetObjectId(email.targetObjectId);
                email_record.setTemplateID(email.templateName); 
                email_record.setOrgWideEmailAddressId(owea.get(0).Id);
                email_record.setHtmlBody(emailTemplate[0].Body);
                email_record.setToAddresses(new List<String> {email.sendTo});
               // email_record.setCcAddresses(new List<String> {email.sendToMn});
                email_record.setSaveAsActivity(false);
                emailList.add(email_record);
            }
        }
        
                List<Messaging.SingleEmailMessage> tempList = new List<Messaging.SingleEmailMessage>(); 
                tempList.addALL(emailList);
        Messaging.sendEmail(tempList); 
        
    }  
    global void finish(Database.BatchableContext BC){
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