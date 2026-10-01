/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-13-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ICRA_EamilViewController {
    public List<InvoiceData> invoiceDataList {get;set;} 
    Map<Id,List<String>> optyEmailRecipsMap {get;set;}
    public String invoiceStatus {set;get;}
    public EmailTemplate[] piEmailTemplate;
    public EmailTemplate [] taxEmailTemplate;
    public OrgWideEmailAddress [] owea; 

    public ICRA_EamilViewController(){
        invoiceDataList = new List<InvoiceData>(); 
        optyEmailRecipsMap = new Map<Id,List<String>>();
        
        piEmailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'End_User_Proforma_Invoice_Notification' LIMIT 1];
        taxEmailTemplate = [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'End_User_Invoice_Notification' LIMIT 1];
        owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'billing@icraindia.info'];

        invoiceStatus = 'today';
        fetchInvoiceList(); 
    }
    
    public void fetchInvoiceList(){
        invoiceDataList.clear();
        optyEmailRecipsMap.clear();
        String filter =  invoiceStatus; 
        System.debug('====== filter ===='+filter);
        Map<Id, Invoice__c> invoiceRecordMap = new Map<Id, Invoice__c>();
        List<InvoiceData> tempInvoiceDataList = new List<InvoiceData>(); 
        // Invoice Record and PDF Files 
        Map<Id, ContentDocumentLink> pdfInvoiceMap = new Map<Id, ContentDocumentLink>();

        // Email notification.
        Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>(); 
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> ccAddress = new List<String>(); 


        if(filter == 'PI'){
            System.debug('======== Data Filter ======'+filter);
            invoiceRecordMap = new Map<Id, Invoice__c> ([
                SELECT Id, Name,RecordType.Name,Dsc_Sign__c,Bill_No__c,Invoice_Date__c,Error_Message__c,Invoice_Status__c,Invoice_Created_Date__c,Opportunity_Name__c,Opportunity_Name__r.Billing_Start_Date__c, Tax_Send__c, PI_Send__c, Tax_DSC_Sign__c, Opportunity_Name__r.Owner.Name, Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email 
                FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = 'Invoice' AND Invoice_Status__c = 'Proforma Invoice' AND PI_Send__c = false
            ]);

        } else if(filter == 'Tax'){
            System.debug('======== Data Filter ======'+filter);
            invoiceRecordMap = new Map<Id, Invoice__c> ([
                SELECT Id, Name,RecordType.Name,Dsc_Sign__c,Bill_No__c,Invoice_Status__c,Error_Message__c,Invoice_Date__c,Invoice_Created_Date__c,Opportunity_Name__c,Opportunity_Name__r.Billing_Start_Date__c, Tax_Send__c, PI_Send__c, Tax_DSC_Sign__c,  Opportunity_Name__r.Owner.Name, Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email 
                FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = 'Invoice' AND Invoice_Status__c != 'Proforma Invoice' AND Invoice_Status__c != 'Canceled'
            ]);
        }else if(filter == 'PI Sent'){
            System.debug('======== Data Filter ======'+filter);
            invoiceRecordMap = new Map<Id, Invoice__c> ([
                SELECT Id, Name,RecordType.Name,Dsc_Sign__c,Bill_No__c,Invoice_Status__c,Error_Message__c,Invoice_Date__c,Invoice_Created_Date__c,Opportunity_Name__c,Opportunity_Name__r.Billing_Start_Date__c, Tax_Send__c, PI_Send__c, Tax_DSC_Sign__c,  Opportunity_Name__r.Owner.Name, Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email 
                FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = 'Invoice' AND Invoice_Status__c = 'Proforma Invoice' AND PI_Send__c = true
            ]);
        }else if(filter == 'Tax Sent'){
            System.debug('======== Data Filter ======'+filter);
            invoiceRecordMap = new Map<Id, Invoice__c> ([
                SELECT Id, Name,RecordType.Name,Dsc_Sign__c,Bill_No__c,Invoice_Status__c,Error_Message__c,Invoice_Date__c,Invoice_Created_Date__c,Opportunity_Name__c,Opportunity_Name__r.Billing_Start_Date__c, Tax_Send__c, PI_Send__c,Tax_DSC_Sign__c,  Opportunity_Name__r.Owner.Name, Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email 
                FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = 'Invoice' AND Invoice_Status__c != 'Proforma Invoice' AND Invoice_Status__c != 'Canceled' AND Tax_Send__c = true
            ]);
        }else if(filter == 'error'){
            System.debug('======== Data Filter ======'+filter);
            invoiceRecordMap = new Map<Id, Invoice__c> ([
                SELECT Id, Name,RecordType.Name,Dsc_Sign__c,Bill_No__c,Error_Message__c,Invoice_Status__c,Invoice_Date__c,Invoice_Created_Date__c,Opportunity_Name__c,Opportunity_Name__r.Billing_Start_Date__c, Tax_Send__c, PI_Send__c, Tax_DSC_Sign__c,  Opportunity_Name__r.Owner.Name, Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email 
                FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = 'Invoice' AND Invoice_Status__c = 'QR and IRN - Failed'
            ]);
        }else if(filter == 'today'){
            System.debug('======== Data Filter ======'+filter);
            invoiceRecordMap = new Map<Id, Invoice__c> ([
                SELECT Id, Name,RecordType.Name,Dsc_Sign__c,Error_Message__c,Bill_No__c,Invoice_Status__c,Invoice_Date__c,Invoice_Created_Date__c,Opportunity_Name__c,Opportunity_Name__r.Billing_Start_Date__c, Tax_Send__c, PI_Send__c,Tax_DSC_Sign__c,  Opportunity_Name__r.Owner.Name, Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email 
                FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = 'Invoice' AND   Invoice_Status__c != 'Canceled' AND Invoice_Date__c = TODAY
            ]);
        }

        System.debug('======= invoiceList ====== '+invoiceRecordMap); 

        if(invoiceRecordMap != null){
            System.debug('======= invoice Id List ====== '+invoiceRecordMap.keySet());
            System.debug('======= invoice  List ====== '+invoiceRecordMap.values());

            if(invoiceRecordMap.keySet().size() > 0){
                if(filter == 'PI'){ 
                   System.debug('====== invoiceRecordMap ====='+filter ); //-Signed
                    for(ContentDocumentLink pdffile : [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                            ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId IN: invoiceRecordMap.keySet() AND 
                            ContentDocument.LatestPublishedVersion.ContentSize > 1023 AND
                            ContentDocument.LatestPublishedVersion.Title Like'%INV%'
                            ORDER BY 
                            SystemModstamp ASC
                    ]){
                                                    
                        pdfInvoiceMap.put(pdffile.LinkedEntityId, pdffile);
                                                    
                    }

                } else if(filter == 'Tax'){
                    System.debug('====== invoiceRecordMap ====='+filter );
                    for(ContentDocumentLink pdffile : [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                            ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId IN: invoiceRecordMap.keySet() AND 
                            ContentDocument.LatestPublishedVersion.ContentSize > 1023 AND
                            (NOT(ContentDocument.LatestPublishedVersion.Title Like'%INV%'))
                            ORDER BY 
                            SystemModstamp ASC
                    ]){                                
                        pdfInvoiceMap.put(pdffile.LinkedEntityId, pdffile);
                                                        
                    }
                }else{
                    for(ContentDocumentLink pdffile : [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                            ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId IN: invoiceRecordMap.keySet() AND 
                            ContentDocument.LatestPublishedVersion.ContentSize > 1023 
                            ORDER BY 
                            SystemModstamp ASC
                    ]){                                
                        pdfInvoiceMap.put(pdffile.LinkedEntityId, pdffile);
                                                        
                    }
                }

                System.debug('========= pdfInvoiceMap ====='+pdfInvoiceMap);

                if(pdfInvoiceMap != null){
                    
                    Set<Id> opportunityIds = new Set<Id>();
                    for(Invoice__c inv : invoiceRecordMap.Values()){
                        opportunityIds.add(inv.Opportunity_Name__c);
                    }
                    for(OpportunityContactRole ocr : [SELECT Id,Contact.Email,OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN :opportunityIds AND Contact.Email!=null AND Role = 'Email Recipient']){
                        if(optyEmailRecipsMap.containsKey(ocr.OpportunityId)){
                            optyEmailRecipsMap.get(ocr.OpportunityId).add(ocr.Contact.Email);
                        }else{
                            optyEmailRecipsMap.put(ocr.OpportunityId,new List<String>{ocr.Contact.Email});
                        }
                    }
                    
                    if(filter == 'PI'){
                        for(ContentDocumentLink pdfFile : pdfInvoiceMap.values()){
                            ccAddress.clear();
                            InvoiceData invoiceDataRecord = new InvoiceData();
                            Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();
                            if(invoiceRecordMap.containsKey(pdfFile.LinkedEntityId)){ 
                                invoiceDataRecord.selectRecord = false;
                                invoiceDataRecord.selectRecord = false;
                                invoiceDataRecord.invoiceRecord = invoiceRecordMap.get(pdfFile.LinkedEntityId); 
                                invoiceDataRecord.emailRecord = bindEmail(pdfFile, invoiceRecordMap.get(pdfFile.LinkedEntityId), 'Proforma ');
                                System.debug('======= PI  invoiceDataRecord'+invoiceDataRecord);
                                invoiceDataList.add(invoiceDataRecord);
                            }  
                        }

                    }else if(filter == 'Tax'){
                        for(ContentDocumentLink pdfFile : pdfInvoiceMap.values()){
                            ccAddress.clear();
                            InvoiceData invoiceDataRecord = new InvoiceData();
                            Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();
                            if(invoiceRecordMap.containsKey(pdfFile.LinkedEntityId)){ 
                                invoiceDataRecord.selectRecord = false;
                                invoiceDataRecord.invoiceRecord = invoiceRecordMap.get(pdfFile.LinkedEntityId); 
                                invoiceDataRecord.emailRecord = bindEmail(pdfFile, invoiceRecordMap.get(pdfFile.LinkedEntityId), ''); 
                                System.debug('======= Tax invoiceDataRecord'+invoiceDataRecord);
                                invoiceDataList.add(invoiceDataRecord);
                            }  
                        }
                    }else{
                        for(ContentDocumentLink pdfFile : pdfInvoiceMap.values()){
                            ccAddress.clear();
                            InvoiceData invoiceDataRecord = new InvoiceData();
                            Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();
                            if(invoiceRecordMap.containsKey(pdfFile.LinkedEntityId)){ 
                                invoiceDataRecord.selectRecord = false;
                                invoiceDataRecord.invoiceRecord = invoiceRecordMap.get(pdfFile.LinkedEntityId); 
                                invoiceDataRecord.emailRecord = bindEmail(pdfFile, invoiceRecordMap.get(pdfFile.LinkedEntityId), ''); 
                                System.debug('======= Tax invoiceDataRecord'+invoiceDataRecord);
                                invoiceDataList.add(invoiceDataRecord);
                            }  
                        }
                    } 
                    System.debug('======= tempInvoiceDataList === '+invoiceDataList);
                    System.debug('======= tempInvoiceDataList.size === '+invoiceDataList.size());
                }
            } 
        }
        

    }

    public void sendSelectedEmail(){
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Invoice__c > invoiceMap = new Map<Id,Invoice__c>();
        List<Invoice__c> updateInvoiceList = new List<Invoice__c>();
        Map<Id, ContentDocumentLink> pdfInvoiceMap = new Map<Id, ContentDocumentLink>();
        System.debug('======== invoiceDataList ======'+ invoiceDataList.size());
        if(invoiceDataList.size() > 0){ //PI_Send__c
            for(InvoiceData invoiceEmail : invoiceDataList){
                if(invoiceEmail.selectRecord == true && invoiceEmail.invoiceRecord != null){ 
                    invoiceMap.put(invoiceEmail.invoiceRecord.Id, invoiceEmail.invoiceRecord); 
                }
            }

            if(invoiceStatus == 'PI'){
                for(ContentDocumentLink pdffile : [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                    ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN: invoiceMap.keySet() AND 
                    ContentDocument.LatestPublishedVersion.ContentSize > 1023 AND
                    ContentDocument.LatestPublishedVersion.Title Like'%INV%'
                    ORDER BY SystemModstamp ASC
                ]){
                                                
                    pdfInvoiceMap.put(pdffile.LinkedEntityId, pdffile);
                                                
                }
                
            }else if(invoiceStatus == 'Tax'){
                for(ContentDocumentLink pdffile : [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                    ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN: invoiceMap.keySet() AND 
                    ContentDocument.LatestPublishedVersion.ContentSize > 1023 AND
                    (NOT(ContentDocument.LatestPublishedVersion.Title Like'%INV%'))
                    ORDER BY SystemModstamp ASC
                ]){
                                                
                    pdfInvoiceMap.put(pdffile.LinkedEntityId, pdffile);
                                                
                }
                
            }else{
                for(ContentDocumentLink pdffile : [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                    ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN: invoiceMap.keySet() AND 
                    ContentDocument.LatestPublishedVersion.ContentSize > 1023 
                    ORDER BY SystemModstamp ASC
                ]){                            
                    pdfInvoiceMap.put(pdffile.LinkedEntityId, pdffile);
                                                
                } 
            }
            

            System.debug('======== pdfInvoiceMap ======'+ pdfInvoiceMap);
            if(pdfInvoiceMap != null){
                for(ContentDocumentLink pdfFile : pdfInvoiceMap.values()){

                    if(invoiceMap.get(pdfFile.LinkedEntityId).Invoice_Status__c == 'Proforma Invoice'){
                        emailList.add(bindEmail(pdfFile, invoiceMap.get(pdfFile.LinkedEntityId), 'Proforma ')); 
                        invoiceStatus = 'PI';
                        Invoice__c invoice = new Invoice__c();
                        invoice.Id = pdfFile.LinkedEntityId;
                        invoice.PI_Send__c = true;
                        updateInvoiceList.add(invoice);
                    }else{
                        emailList.add(bindEmail(pdfFile, invoiceMap.get(pdfFile.LinkedEntityId), '')); 
                        invoiceStatus = 'Tax';
                        Invoice__c invoice = new Invoice__c();
                        invoice.Id = pdfFile.LinkedEntityId;
                        invoice.Tax_Send__c = true;
                        updateInvoiceList.add(invoice);
                    } 
                }
            } 

            System.debug('======== emailList ======'+ emailList.size());
            if(emailList.size() > 0){
                try{ 
                    if(updateInvoiceList.size() > 0 ){
                        Messaging.sendEmail(emailList);
                        Update updateInvoiceList;
                        
                    }
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, emailList.size() +' Email Sent to the customer'));
					fetchInvoiceList();
                }catch(Exception e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Try after sometime.'));
                } 
            }
            
        } 
    }

    public Messaging.SingleEmailMessage bindEmail(ContentDocumentLink pdfFile, Invoice__c invoiceRecord, String invoiceType ){
        List<String> ccAddress = new List<String>();
        Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();
        if(invoiceRecord != null && pdfFile != null ){ 
            ccAddress.clear();
            emailRecord.setTargetObjectId(invoiceRecord.Contact_Name__c);
            emailRecord.setTemplateID(taxEmailTemplate[0].Id); 
            emailRecord.setOrgWideEmailAddressId(owea[0].Id);
            if(invoiceRecord.Opportunity_Name__r.Owner.Manager.Email != null){
                ccAddress.add(invoiceRecord.Opportunity_Name__r.Owner.Manager.Email);
            }
            
            if(invoiceRecord.Opportunity_Name__r.Owner.Email != null){
                ccAddress.add(invoiceRecord.Opportunity_Name__r.Owner.Email); 
            }
            if(optyEmailRecipsMap.size()>0 && optyEmailRecipsMap.containsKey(invoiceRecord.Opportunity_Name__c)){
                ccAddress.addAll(optyEmailRecipsMap.get(invoiceRecord.Opportunity_Name__c));
            }

            ccAddress.add(Label.set_CC_email);
            
            emailRecord.setToAddresses(new List<String> {invoiceRecord.Contact_Name__r.Email});
            if(ccAddress.size()> 0 ){
                emailRecord.setCcAddresses(ccAddress);
            }
            
            emailRecord.setSaveAsActivity(false); 
            emailRecord.setSaveAsActivity(true);
            emailRecord.setEntityAttachments( new List<String> {pdfFile.ContentDocument.LatestPublishedVersion.Id}); 
            emailRecord.setPlainTextBody(taxEmailTemplate[0].Body);
            emailRecord.setSubject(invoiceType+'Invoice towards service(s) by ICRA Limited – '+ invoiceRecord.Bill_NO__c); 
        }

        return emailRecord;
        
    }



    class InvoiceData{
        public Boolean selectRecord {get;set;}
        public Invoice__c invoiceRecord {get;set;}
        public Transient Messaging.SingleEmailMessage emailRecord {get; private set;} 

        InvoiceData(){ 
            invoiceRecord = new Invoice__c();
            selectRecord = false;
            emailRecord = new Messaging.SingleEmailMessage();
        }
    }
     
}