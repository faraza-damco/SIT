/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 05-25-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   05-24-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class EndUser_Notification_Invoices_PI implements Database.Batchable<sObject>{
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String filter ='Invoice';
        String filter1 = 'Yes';
        String filter2 = 'To Be Billed';
        String filter3 = 'QR-IRN-Generated';
        String InvoiceQuery = 'SELECT Id, Name,RecordType.Name,Bill_No__c,Invoice_Status__c,Invoice_Created_Date__c,Opportunity_Name__r.Billing_Start_Date__c,Opportunity_Name__r.Owner.Name,Opportunity_Name__r.Defer_Billing_or_Exit_Case__c,Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = :filter AND Invoice_Created_Date__c = TODAY  AND Contact_Name__r.Billing_Contact__c = :filter1 AND Opportunity_Name__r.Defer_Billing_or_Exit_Case__c = :filter2 AND Invoice_Status__c = :filter3';
        return Database.getQueryLocator(InvoiceQuery); 
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> InvoiceList){
         EmailTemplate[] emailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'End_User_Invoice_Notification' LIMIT 1];
         Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,EmailNotification> emailNotificationMap = new map<Id,EmailNotification>(); 
        
        for(Invoice__c invoiceRecord : InvoiceList){
            
            EmailNotification temp = new EmailNotification();
            temp.recordOwnerName = invoiceRecord.Opportunity_Name__r.Owner.Name; 
            temp.sendTo = invoiceRecord.Contact_Name__r.Email;
            temp.targetObjectId = invoiceRecord.Contact_Name__c;
            temp.templateName = emailTemplate[0].Id;
            temp.sendToMn = invoiceRecord.Opportunity_Name__r.Owner.Manager.Email;
            temp.sendToBd = invoiceRecord.Opportunity_Name__r.Owner.Email;
            emailNotificationMap.put(invoiceRecord.Opportunity_Name__r.OwnerId, temp);
            
            ContentDocumentLink[] pdfFile = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId =: invoiceRecord.Id AND ContentDocument.LatestPublishedVersion.Title Like'%Signed%'  order by SystemModstamp DESC LIMIT 1];
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName( invoiceRecord.Bill_No__c + ' - ' + invoiceRecord.Invoice_Created_Date__c +'.pdf');
            
            Blob Pdfget;
            try { 
                Pdfget = pdfFile.size() > 0 ? pdfFile[0].ContentDocument.LatestPublishedVersion.VersionData : Blob.valueOf('No File Found');
                
                
            } catch (VisualforceException e) {
                Pdfget = Blob.valueOf('Error While Genrating file');
            }
            
            efa.setBody(Pdfget);
            String body1 = emailTemplate[0].Body;
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'billing@icraindia.info']; 
            
            if(emailNotificationMap.values().size() > 0){
                
                for(EmailNotification email : emailNotificationMap.values()){
                    
                    Messaging.SingleEmailMessage email_record = new Messaging.SingleEmailMessage();
                    email_record.setTargetObjectId(email.targetObjectId);
                    email_record.setTemplateID(email.templateName); 
                    email_record.setOrgWideEmailAddressId(owea.get(0).Id);
                    email_record.setToAddresses(new List<String> {email.sendTo});
                    email_record.setCcAddresses(new List<String> {email.sendToMn,email.sendToBd});
                    email_record.setSaveAsActivity(false);
                    email_record.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    email_record.setPlainTextBody(body1);
                    email_record.setSubject('Invoice towards service(s) by ICRA Limited – '+ invoiceRecord.Bill_NO__c);
                    emailList.add(email_record);
                     
                }
             }
            
        }
        Messaging.sendEmail(emailList); 
     }  
    global void finish(Database.BatchableContext BC){
     }
    public class EmailNotification{ 
        String targetObjectId = ''; 
        String templateName = '';
        String recordOwnerName = '';
        String sendTo = ''; 
        String sendToMn = '';
        String sendToBd = '';
        public EmailNotification(){}
    }
}