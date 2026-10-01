/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 20-06-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-02-2025   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public with sharing class ICRA_SendToClient{
    @AuraEnabled
    public static String sendPDF(Id recordId){
        List<String> ccList = new List<String>();
        String toAddress='';
        Set<Id> docIds = new Set<Id>();
        String emailBody='';
        String subject='';
        String invoiceDate;

        OrgWideEmailAddress [] owd = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
        Id invoice_recordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Id creditNote_recordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Note').getRecordTypeId();
        Id oppSurv_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        String icra_receivable = System.Label.ICRA_Receivables_Mgmt;

        Invoice__c inv = [SELECT Id, Name, Invoice_Status__c, recordTypeId, Bill_No__c, Invoice_Created_Date__c, Total_Invoice_Amount__c, Contact_Name__r.Email,Contact_Name__r.Name,
        Opportunity_Name__r.RecordTypeId, Credit_Note_No__c, Credit_Note_Created_Date__c, Invoice_No__r.Invoice_Created_Date__c,Invoice_No__r.Contact_Name__r.Email,
        Opportunity_Name__r.Owner.Email, Invoice_No__r.Bill_No__c, Invoice_No__r.Contact_Name__r.Name, Opportunity_Name__r.Account.Name, Opportunity_Name__r.Billing_Start_Date__c, 
        Opportunity_Name__r.Team_Leader__r.Email, Opportunity_Name__r.Finance_Team__r.Email, Opportunity_Name__c, Opportunity_Name__r.Client_Mail_Address_To__c,
        Opportunity_Name__r.Client_Mail_Address_CC__c, Proforma_Invoice_Email_Sent__c, Tax_Invoice_Email_Sent__c, Proforma_Invoice_Email_Sent_Date__c, Tax_Invoice_Email_Sent_Date__c,
        Sent_To_Client_Details__c, Bypass_Validation__c, Proforma_Invoice_Sent_By__c, Tax_Invoice_Sent_By__c FROM Invoice__c WHERE Id = :recordId LIMIT 1];

        if(inv.recordTypeId == invoice_recordType && String.isBlank(inv.Contact_Name__r.Email)){
            throw new AuraHandledException('Contact does not have an email address.');
        }else if(inv.recordTypeId == creditNote_recordType && String.isBlank(inv.Invoice_No__r.Contact_Name__r.Email)){
            throw new AuraHandledException('Contact does not have an email address for the related Invoice.');
        }else if(inv.recordTypeID== invoice_recordType && ((inv.Opportunity_Name__r.Billing_Start_Date__c == null && inv.Opportunity_Name__r.RecordTypeId == oppSurv_recordType))){
            throw new AuraHandledException('Billing Start Date is not set for the related Opportunity.');
        }

        List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

        for(ContentDocumentLink link : docLinks){
            docIds.add(link.ContentDocumentId);
        }
        List<ContentVersion> invPDF = new List<ContentVersion>();

        if(!docIds.isEmpty()){
            if(inv.recordTypeID== invoice_recordType && inv.Invoice_Status__c=='Proforma Invoice'){
                invPDF = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :docIds AND FileExtension  = 'pdf' ORDER BY CreatedDate DESC];
            }else if(inv.recordTypeID== invoice_recordType && inv.Invoice_Status__c=='Tax Invoice'){
                invPDF = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :docIds AND Title LIKE '%Signed%' AND FileExtension  = 'pdf' ORDER BY CreatedDate DESC];
            }else if(inv.recordTypeID== creditNote_recordType && inv.Invoice_Status__c=='GST Credit Note'){
                invPDF = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :docIds AND Title LIKE '%Signed%' AND FileExtension  = 'pdf' ORDER BY CreatedDate DESC];
            }
        }
        System.Debug('RecordType: ' + inv.recordTypeID);
        ContentVersion pdfToSend = new ContentVersion();
        if(!invPDF.isEmpty()){
             pdfToSend = invPDF[0];
        }else{
            throw new AuraHandledException('No PDF file found for this record.');
        }

        invoiceDate = inv.Invoice_Created_Date__c!=null ? inv.Invoice_Created_Date__c.format():null;
        
        if(inv.Invoice_Status__c=='Tax Invoice'){
            subject= 'ICRA - Tax Invoice for Review and Payment Intimation ';
            emailBody = 'Dear Sir/Madam,\n\n'+
                        'Please find attached the Tax Invoice for your reference. Kindly review the details carefully and initiate the payment process accordingly. If payment has already been made, please disregard this message.\n\n'+
                        'Invoice Details:\n' +
                        'Invoice Number: '+ inv.Bill_No__c + '\n' +
                        'Invoice Date: '+ inv.Invoice_Created_Date__c.format() + '\n' +
                        'Due Date: '+ invoiceDate + '\n' +
                        'Total Amount Due: '+ inv.Total_Invoice_Amount__c + '\n\n' +
                        'Should you have any questions or require clarification regarding any aspect of the invoice, please feel free to contact us or reach out to your designated Business Development (BD) personnel.\n\n' +
                        'Thank you for choosing our services. Looking forward to a continued successful business relationship.\n\n' +
                        'Regards,\n' +
                        'ICRA Limited \n\n'+
                        'Please note, this is an automated system generated email communication.';
        }else if(inv.Invoice_Status__c=='Proforma Invoice'){
            subject= 'ICRA - Proforma Invoice for Review and Payment Intimation - ';
            emailBody = 'Dear Sir/Madam,\n\n'+
                        'Please find attached the Proforma Invoice for your reference. Kindly review the details carefully and initiate the payment process accordingly.\n\n'+
                        'Invoice Details:\n' +
                        'Invoice Number: '+ inv.Bill_No__c + '\n' +
                        'Invoice Date: '+ inv.Invoice_Created_Date__c.format() + '\n' +
                        'Due Date: '+ invoiceDate + '\n' +
                        'Total Amount Due: '+ inv.Total_Invoice_Amount__c + '\n\n' +
                        'Should you have any questions or require clarification regarding any aspect of the invoice, please feel free to contact us or reach out to your designated Business Development (BD) personnel.\n\n' +
                        'Thank you for choosing our services. Looking forward to a continued successful business relationship.\n\n' +
                        'Regards,\n' +
                        'ICRA Limited \n\n'+
                        'Please note, this is an automated system generated email communication.';
        }else if(inv.recordTypeID== creditNote_recordType){
            subject= 'ICRA - Credit Note for Review and Necessary Action - ';
            emailBody = 'Dear Sir/Madam,\n\n'+
                        'Please find attached the Credit Note As requested by you for your review and necessary action.\n\n'+
                        'Invoice Details:\n' +
                        'Invoice Number: '+ inv.Invoice_No__r.Bill_No__c + '\n' +
                        'Invoice Date: '+ inv.Invoice_No__r.Invoice_Created_Date__c.format() + '\n' +
                        'Credit Note Number: '+ inv.Credit_Note_No__c + '\n' +
                        'Credit Name Date: '+ inv.Credit_Note_Created_Date__c.format() + '\n\n' +
                        'Please review the Credit Note carefully to ensure that all the details are accurate. Please do not hesitate to contact us if you have any questions or concerns regarding any aspect of the Credit Note.\n\n' +
                        'Thank you for choosing our services. We look forward to a continued successful business relationship.\n\n' +
                        'Thank you,\n' +
                        'ICRA Limited';   
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(pdfToSend.Title + '.pdf');
        attachment.setBody(pdfToSend.VersionData);
        attachment.setContentType('application/pdf');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(inv.recordTypeID== invoice_recordType && inv.Opportunity_Name__r.Client_Mail_Address_To__c!=null){
            toAddress= inv.Opportunity_Name__r.Client_Mail_Address_To__c;
        }else if(inv.recordTypeID== creditNote_recordType && inv.Invoice_No__r.Opportunity_Name__r.Client_Mail_Address_To__c!=null){
            toAddress= inv.Invoice_No__r.Opportunity_Name__r.Client_Mail_Address_To__c;
        }

        toAddress = toAddress.trim();
        List<String> toAddresses = toAddress.split(',');    

        mail.setToAddresses(toAddresses);

        if(!String.isBlank(inv.Opportunity_Name__r.Owner.Email)){
            ccList.add(inv.Opportunity_Name__r.Owner.Email);
        }

        if(!String.isBlank(inv.Opportunity_Name__r.Team_Leader__r.Email)){
            ccList.add(inv.Opportunity_Name__r.Team_Leader__r.Email);
        }

        String clientCC = inv.Opportunity_Name__r.Client_Mail_Address_CC__c;
        clientCC = clientCC != null ? clientCC.trim() : '';
        List<String> ccAddresses = clientCC.split(',');

        for(String cc : ccAddresses){
            if(!String.isBlank(cc)){
                ccList.add(cc.trim());
            }
        }     

        if(inv.recordTypeID== invoice_recordType && inv.Invoice_Status__c=='Tax Invoice'){
            if(!String.isBlank(inv.Opportunity_Name__r.Finance_Team__r.Email)){
                ccList.add(inv.Opportunity_Name__r.Finance_Team__r.Email);
            }

            if(!String.isBlank(icra_receivable)){
                ccList.add(icra_receivable);
            }
        }


        if(!ccList.isEmpty()){
            mail.setCcAddresses(ccList);
        }

        mail.setSubject( subject+ inv.Opportunity_Name__r.Account.Name);
        mail.setPlainTextBody(emailBody);
        mail.setOrgWideEmailAddressId(owd[0].Id);
        //mail.setSaveAsActivity(true);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});

        if(inv.recordTypeID== invoice_recordType && inv.Invoice_Status__c=='Proforma Invoice'){
            Opportunity opp = [Select id, Client_Name_Correct__c, Record_Lock__c from Opportunity where id = :inv.Opportunity_Name__c];
            opp.Client_Name_Correct__c = false;
            opp.Record_Lock__c = false;
            update opp;
        }
        if(inv.recordTypeID== invoice_recordType && inv.Invoice_Status__c=='Proforma Invoice'){
            inv.Proforma_Invoice_Email_Sent__c='Yes';
            inv.Proforma_Invoice_Email_Sent_Date__c = Date.valueOf(System.now());
            inv.Proforma_Invoice_Sent_By__c = UserInfo.getUserId();
        }else if(inv.recordTypeID== invoice_recordType && inv.Invoice_Status__c=='Tax Invoice'){
            inv.Tax_Invoice_Email_Sent__c='Yes';
            inv.Tax_Invoice_Email_Sent_Date__c = Date.valueOf(System.now());
            inv.Tax_Invoice_Sent_By__c = UserInfo.getUserId();
            inv.Bypass_Validation__c = true;
        }
        update inv;

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        return 'Email sent to ' + toAddress;
    }

    @AuraEnabled
    public static String reviewPDF(Id recordId){
        Id invoice_recordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Id creditNote_recordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Note').getRecordTypeId();            
        Invoice__c inv = [SELECT Id, Name, Invoice_Status__c, Bill_No__c, RecordTypeId, Invoice_Created_Date__c, Total_Invoice_Amount__c, Contact_Name__r.Email, Opportunity_Name__r.Owner.Email, Opportunity_Name__r.Account.Name, Opportunity_Name__r.Billing_Start_Date__c FROM Invoice__c WHERE Id = :recordId LIMIT 1];
        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }
        List<ContentVersion> invPDF = new List<ContentVersion>();
        if(!docIds.isEmpty()){
            if(inv.Invoice_Status__c=='Proforma Invoice'){
                invPDF = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :docIds AND FileExtension  = 'pdf' ORDER BY CreatedDate DESC LIMIT 1];
            }else if(inv.Invoice_Status__c=='Tax Invoice'){
                invPDF = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :docIds AND Title LIKE '%Signed%' AND FileExtension  = 'pdf' ORDER BY CreatedDate DESC LIMIT 1];
            }else if(inv.recordTypeId == creditNote_recordType && inv.Invoice_Status__c=='GST Credit Note'){
                invPDF = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :docIds AND Title LIKE '%Signed%' AND FileExtension  = 'pdf' ORDER BY CreatedDate DESC LIMIT 1];
            }
        }
        System.Debug('ContentVersion: '+invPDF[0]);
        ContentVersion pdfToReview = new ContentVersion();
        if(!invPDF.isEmpty()){
             pdfToReview = invPDF[0];
        }else{
            throw new AuraHandledException('No PDF file found for this record.');
        }
        //return pdfToReview.Id;
        ContentDistribution dist = new ContentDistribution();
        dist.Name = 'Invoice PDF';
        dist.ContentVersionId = pdfToReview.Id;
        dist.PreferencesAllowViewInBrowser = true;
        dist.PreferencesAllowOriginalDownload = true;
        dist.PreferencesNotifyOnVisit = false; 
        insert dist;
        dist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :dist.Id];
        String publicUrl = dist.DistributionPublicUrl;
        System.Debug('Distribution URL: '+publicUrl);
        return publicUrl;
    }

    @AuraEnabled
        public static String displayInfo(Id recordId){
            List<Invoice__c> inv = [SELECT Id, Name, recordTypeId, Invoice_Status__c, Contact_Name__c, Contact_Name__r.Name, Contact_Name__r.Email, Opportunity_Name__c, Opportunity_Name__r.Name, 
            Opportunity_Name__r.Owner.Email, Opportunity_Name__r.Account.Name, Bill_No__c, Invoice_Created_Date__c, Total_Invoice_Amount__c, Opportunity_Name__r.Billing_Start_Date__c,
            Opportunity_Name__r.Team_Leader__c, Opportunity_Name__r.Team_Leader__r.Email, Opportunity_Name__r.Finance_Team__r.Email, Opportunity_Name__r.Client_Mail_Address_To__c,
            Opportunity_Name__r.Client_Mail_Address_CC__c, Opportunity_Name__r.AccountId, Opportunity_Name__r.Account.Owner.Email FROM Invoice__c WHERE Id = :recordId LIMIT 1];
            System.Debug(   'Invoice Record: '+inv);
            if(inv.isEmpty()){
                return 'No Invoice record found.';
            }
            
            Id invoice_recordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
            String icra_receivable = System.Label.ICRA_Receivables_Mgmt;
            String toAddress='';
            List<String> ccAddress= new List<String>();
            String emailBody='';
            String subject='';
            String invoiceDate;

            invoiceDate = inv[0].Invoice_Created_Date__c!=null ? inv[0].Invoice_Created_Date__c.format():null;

            if(inv[0].Opportunity_Name__r.Client_Mail_Address_To__c!=null){
                toAddress= inv[0].Opportunity_Name__r.Client_Mail_Address_To__c;
            }
            if(inv[0].Opportunity_Name__r.Owner.Email!=null){
                ccAddress.add(inv[0].Opportunity_Name__r.Owner.Email);
            }
            if(inv[0].Opportunity_Name__r.Account.Owner.Email!=null){
                ccAddress.add(inv[0].Opportunity_Name__r.Account.Owner.Email);
            }
            if(inv[0].Opportunity_Name__r.Team_Leader__c!=null && inv[0].Opportunity_Name__r.Team_Leader__r.Email!=null){
                ccAddress.add(inv[0].Opportunity_Name__r.Team_Leader__r.Email);
            }
            if(inv[0].Opportunity_Name__r.Client_Mail_Address_CC__c!=null){
                for(String email : inv[0].Opportunity_Name__r.Client_Mail_Address_CC__c.split(',')) {
                    if(String.isNotBlank(email)) {
                        ccAddress.add(email.trim());
                    }
                }
            }
            if(inv[0].recordTypeID== invoice_recordType && inv[0].Invoice_Status__c=='Tax Invoice'){
                if(!String.isBlank(inv[0].Opportunity_Name__r.Finance_Team__r.Email)){
                    ccAddress.add(inv[0].Opportunity_Name__r.Finance_Team__r.Email);
                }

                if(!String.isBlank(icra_receivable)){
                    ccAddress.add(icra_receivable);
                }
            }

            List <String> toAddresses = new List<String>();
            for(String email : toAddress.split(',')){
                if(String.isNotBlank(email)){
                    toAddresses.add(email.trim());
                }
            }


            Map<String, String> emailNameMap = new Map<String, String>();

            for(Contact u : [SELECT Name, Email FROM Contact WHERE Email != NULL AND (Email IN :ccAddress OR Email IN :toAddresses) AND AccountId = :inv[0].Opportunity_Name__r.AccountId]){
                emailNameMap.put(u.Email, u.Name);
            }
            List<String> toAddressList = new List<String>();
            List<String> ccAddressList = new List<String>();

            for(String email : toAddresses){
                if(emailNameMap.containsKey(email)){
                    String name = emailNameMap.get(email);
                    toAddressList.add(name + ' &lt; ' + email + ' &gt; ');
                }else{
                    toAddressList.add(+' '+email+' ');
                }
            }
            for(String email : ccAddress){
                if(emailNameMap.containsKey(email)){
                    String name = emailNameMap.get(email);
                    ccAddressList.add(name + ' &lt; ' + email + ' &gt; ');   
                }else{
                    ccAddressList.add(+' '+email+' ');
                }
            }

            if(inv[0].Invoice_Status__c=='Tax Invoice'){
                subject= 'ICRA - Tax Invoice for Review and Payment Intimation ';
                emailBody = 'Dear Sir/Madam,\n\n'+
                            'Please find attached the Tax Invoice for your reference. Kindly review the details carefully and initiate the payment process accordingly. If payment has already been made, please disregard this message.\n\n'+
                            'Invoice Details:\n' +
                            'Invoice Number: '+ inv[0].Bill_No__c + '\n' +
                            'Invoice Date: '+ inv[0].Invoice_Created_Date__c.format() + '\n' +
                            'Due Date: '+ invoiceDate + '\n' +
                            'Total Amount Due: '+ inv[0].Total_Invoice_Amount__c + '\n\n' +
                            'Should you have any questions or require clarification regarding any aspect of the invoice, please feel free to contact us or reach out to your designated Business Development (BD) personnel.\n\n' +
                            'Thank you for choosing our services. Looking forward to a continued successful business relationship.\n\n' +
                            'Regards,\n' +
                            'ICRA Limited \n\n'+
                            'Please note, this is an automated system generated email communication.';
            }else if(inv[0].Invoice_Status__c=='Proforma Invoice'){
                subject= 'ICRA - Proforma Invoice for Review and Payment Intimation - ';
                emailBody = 'Dear Sir/Madam,\n\n'+
                            'Please find attached the Proforma Invoice for your reference. Kindly review the details carefully and initiate the payment process accordingly.\n\n'+
                            'Invoice Details:\n' +
                            'Invoice Number: '+ inv[0].Bill_No__c + '\n' +
                            'Invoice Date: '+ inv[0].Invoice_Created_Date__c.format() + '\n' +
                            'Due Date: '+ invoiceDate + '\n' +
                            'Total Amount Due: '+ inv[0].Total_Invoice_Amount__c + '\n\n' +
                            'Should you have any questions or require clarification regarding any aspect of the invoice, please feel free to contact us or reach out to your designated Business Development (BD) personnel.\n\n' +
                            'Thank you for choosing our services. Looking forward to a continued successful business relationship.\n\n' +
                            'Regards,\n' +
                            'ICRA Limited \n\n'+
                            'Please note, this is an automated system generated email communication.';
            }
            String infoMsg = 'Below are the details for sending the Invoice PDF to the client and details are fetched from the Opportunity as mentioned below: ' + '\n\n' +
                             'Opportunity Name: '+ inv[0].Opportunity_Name__r.Name + '\n\n' +
                             'Email Subject: ICRA - '+ inv[0].Invoice_Status__c + ' for Review and Payment Intimation ' +inv[0].Opportunity_Name__r.Account.Name + '\n\n' +
                             'Client Mail Address (To):  &lt '+ toAddressList +' &gt'+ '\n\n' +
                             (inv[0].recordTypeID== invoice_recordType && inv[0].Invoice_Status__c=='Tax Invoice' ? 'CC Address (Opportunity Owner, Account Owner, Team Leader,  Client Mail Address (cc), Finance Team & ICRA Receivables Management): ' : 'CC Address (Opportunity Owner, Account Owner, Team Leader & Client Mail Address (cc)): ') +ccAddressList + '\n\n'+

                             '**Note: Once the "Send to Client" button is clicked, the invoice PDF will be sent to the above recipients.'+ '\n\n'+
                             emailBody + '\n\n';

            return infoMsg;
        }
}