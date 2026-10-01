global class ICRA_EndUserProformaInvoice_Notification implements Database.Batchable<sObject> {
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date dueDate = System.today();
        String filter ='Invoice';
        String filter2 ='Proforma Invoice'; 
        String InvoiceQuery = 'SELECT Id, Name,RecordType.Name,Bill_NO__c,Invoice_Created_Date__c,Proforma_Invoice_ok__c,Opportunity_Name__r.RecordType.Name,Invoice_Status__c,Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Proforma_Invoice_ok__c ,Opportunity_Name__r.Owner.Manager.Email, Opportunity_Name__r.OwnerId,Opportunity_Name__r.Owner.Name,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c WHERE Contact_Name__r.Email != null AND RecordType.Name =:filter AND Invoice_Created_Date__c =: dueDate  AND Invoice_Status__c =: filter2 AND  Opportunity_Name__r.Proforma_Invoice_ok__c = True';
        return Database.getQueryLocator(InvoiceQuery); 
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> InvoiceList){ 
        EmailTemplate[] emailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'End_User_Proforma_Invoice_Notification' LIMIT 1];
        
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
                Pdfget  =  pdfFile.size() > 0 ? pdfFile[0].ContentDocument.LatestPublishedVersion.VersionData : Blob.valueOf('No File Found');
                
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
                    email_record.setSubject('Proforma Invoice towards service(s) by ICRA Limited – '+ invoiceRecord.Bill_NO__c);
                    emailSet.add(email_record); 
                } 
            }
            
        }
        emailList.addALL(emailSet);
        Messaging.sendEmail(emailList);          
    }  
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Inovice Batch Job is done ****  /' +BC); 
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