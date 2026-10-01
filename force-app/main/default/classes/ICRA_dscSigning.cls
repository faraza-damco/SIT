public class ICRA_dscSigning {
    public static string Auth(String InvId){
        HttpRequest req = new HttpRequest();
        string urlappend = '';
        ICRA_Desc_Signing__c [] dscInfo = [SELECT Id, End_Point__c, Client_Id__c, Client_Secret__c, Content_Type__c, Body__c, Name, DSCMasterValues__c, Certificate_URL__c FROM ICRA_Desc_Signing__c WHERE Name ='Authenticate' LIMIT 1];
        
        
        req.setEndpoint(dscInfo[0].End_Point__c);
        req.setMethod('POST');
        req.setHeader('clientid', dscInfo[0].Client_Id__c);
        req.setHeader('clientsecret', dscInfo[0].Client_Secret__c);
        req.setHeader('content-type', dscInfo[0].Content_Type__c);
        
        req.setTimeout(120000);
        
        string body = dscInfo[0].Body__c;
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('status: '+res.getStatus());
        system.debug('response body DSC Authentication===>>: '+res.getBody());
        Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        Map<String,Object> respMap2 = (Map<String,Object>) respMap.get('AuthenticateResult');
        if(respMap2.get('Token') != null){
            return respMap2.get('Token').tostring();
        }else{
            string error = respMap2.get('ErrorMessage').tostring();
            Error_Log__c el = new Error_Log__c();
            el.Record_ID__c =InvId;
            el.Error_Message__c = error;
            el.Response__c = res.getBody();
            el.Request_Pay_Load__c = req.getBody();
            insert el;
            return null;
        }
        
    }
    
    @AuraEnabled
    public static string SignedDoc(string InvId){
        String Token ='';
        String objectType='';
        List<Id> survOptyIds= new List<Id>();
        List<Opportunity> survOptyToUpdate= new List<Opportunity>();
        ObjectType= ICRA_dscSigning.identifyObjectType(InvId);
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        List<Manual_Invoice__c> manualInvoiceList = new List<Manual_Invoice__c>();
        if(!test.isRunningTest())
            Token = Auth(InvId);
        system.debug('Token='+Token);
        //Id invoiceTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        if(objectType=='Invoice__c'){
            invoiceList= [select id, Invoice_Status__c, RecordTypeId, RecordType.DeveloperName, Credit_Note_Type__c,Opportunity_Name__c,Opportunity_Name__r.RecordType.Name, Bypass_Validation__c from Invoice__c where id=:InvId];
            invoiceLineItemList= [select id, Invoice_No__c,Opportunity_Name__r.Defer_Billing_or_Exit_Case__c from Invoice_Line_Item__c where Invoice_No__c=:InvId];
            // for(Invoice_Line_Item__c invLineItem: invoiceLineItemList){
            //     if(invLineItem.Opportunity_Name__r.RecordType.Name=='Surveillance'){
            //         survOptyIdsMap.put(invLineItem.Opportunity_Name__c, );
            //     }
            // }
            // if(invoiceList[0].Opportunity_Name__r.RecordType.Name=='Surveillance'){
            //     survOptyIds= [select id, Defer_Billing_or_Exit_Case__c from Opportunity where id=:invoiceList[0].Opportunity_Name__c LIMIT 1];
            // }
        }else if(objectType=='Manual_Invoice__c'){
            manualInvoiceList= [select id, Invoice_Status__c, RecordTypeId, RecordType.DeveloperName from Manual_Invoice__c where id=:InvId];
        }
        ICRA_Desc_Signing__c [] dscInfo = [SELECT Id, End_Point__c, Client_Id__c, Client_Secret__c, Content_Type__c, Body__c, Name, DSCMasterValues__c, Certificate_URL__c FROM ICRA_Desc_Signing__c WHERE Name ='Authenticate' LIMIT 1];
        
        string status ='';
        if(string.isNotBlank(Token) || test.isRunningTest()){
            try{
                ContentDocumentLink[] cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: InvId AND (NOT ContentDocument.LatestPublishedVersion.Title Like'%Signed%') ORDER BY SystemModstamp DESC LIMIT 1];
                if(cdl.size()>0){
                    ContentVersion[] cv = [SELECT VersionData,Title FROM ContentVersion WHERE ContentDocumentId = :cdl[0].ContentDocumentId];
                    string paramvalue = EncodingUtil.base64Encode(cv[0].VersionData);
                    
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(dscInfo[0].Certificate_URL__c);
                    req.setMethod('POST');
                    req.setHeader('token', Token);
                    
                    //req.setTimeout(120000);
                    string body = '{"getDSCSignedBytesForPDFParams":{"originalPdfBytes":"'+ 
                        paramvalue+
                        '","DSCMasterValues":["'+dscInfo[0].DSCMasterValues__c+'"],"digitalCertificatePerSegmentForPdfList":[{"CertificateValidTo":""}],"passwordGSTIN":"","CurrFileName":"Test","irn":"","QRCode":""}}';            
                    req.setHeader('content-type', 'application/json');
                    req.setBody(body);
                    req.setTimeout(120000);
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('status: '+res.getStatus());
                    system.debug('response body DSC Signature: '+res.getBody());
                    system.debug('response: '+req);
                    system.debug('response: '+body);
                    Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String,Object> respMap2 = (Map<String,Object>) respMap.get('GetDSCSignedBytesForPDFResult');
                    String returnFile;
                    if(respMap2.get('SignedFile') != null){
                        returnFile = respMap2.get('SignedFile').tostring();
                        returnFile= returnFile.removeEnd('"');
                        returnFile= returnFile.removeStart('"');
                        
                        Blob myBlob = EncodingUtil.base64Decode(returnFile);
                        ContentVersion ContentInsert = new ContentVersion();
                        ContentInsert.Title = cv[0].Title+' | Signed';
                        ContentInsert.VersionData = myBlob;
                        ContentInsert.PathOnClient = '/'+cv[0].Title+' | Signed.pdf';
                        insert ContentInsert;
                        ContentVersion[] insertedContent = [select id, ContentDocumentId from ContentVersion WHERE Id =: ContentInsert.Id];
                        system.debug('ContentInsert.ContentDocumentId>> '+insertedContent[0].ContentDocumentId);
                        ContentDocumentLink cl = new ContentDocumentLink();
                        cl.ContentDocumentId = insertedContent[0].ContentDocumentId;
                        cl.LinkedEntityId = InvId; //Shared with record ID
                        cl.ShareType = 'V';
                        cl.Visibility = 'AllUsers';
                        insert cl;
                        if(objectType=='Invoice__c'){    
                            if(invoiceList.size()>0 && invoiceList[0].RecordType.DeveloperName=='Invoice'){
                                invoiceList[0].Invoice_Status__c='Tax Invoice';
                                invoiceList[0].Bypass_Validation__c=true;
                                update invoiceList;
                                if(!invoiceLineItemList.isEmpty()){
                                    for(Invoice_Line_Item__c invLineItem: invoiceLineItemList){
                                        system.debug('Inside Invoice Line Item of opportunity======>>>>');
                                        if(invLineItem.Opportunity_Name__r.Defer_Billing_or_Exit_Case__c!='Already Billed'){
                                            survOptyIds.add(invLineItem.Opportunity_Name__c);
                                        }
                                    }
                                    survOptyToUpdate= [Select id, Defer_Billing_or_Exit_Case__c from Opportunity where Id IN: survOptyIds];
                                    for(Opportunity opp: survOptyToUpdate){
                                        opp.Defer_Billing_or_Exit_Case__c='Already Billed';
                                    }
                                    update survOptyToUpdate;
                                }
                            }else if(invoiceList.size()>0 && invoiceList[0].RecordType.DeveloperName=='Credit_Note' && invoiceList[0].Credit_Note_Type__c=='GST Credit Note'){
                                invoiceList[0].Invoice_Status__c='GST Credit Note';
                                update invoiceList;
                            } 
                        }else if(objectType=='Manual_Invoice__c'){
                            if(manualInvoiceList.size()>0 && manualInvoiceList[0].RecordType.DeveloperName=='OPE'){
                                manualInvoiceList[0].Invoice_Status__c='OP Tax Invoice';
                                update manualInvoiceList;
                            }else if(manualInvoiceList.size()>0 && manualInvoiceList[0].RecordType.DeveloperName=='Other_Services'){
                                manualInvoiceList[0].Invoice_Status__c='OT Tax Invoice';
                                update manualInvoiceList;
                            }else if(manualInvoiceList.size()>0 && manualInvoiceList[0].RecordType.DeveloperName=='Inter_Branch_Invoice'){
                                manualInvoiceList[0].Invoice_Status__c='IB Tax Invoice';
                                update manualInvoiceList;
                            }
                        }    
                        status = 'success';
                    }else{
                        string error = respMap2.get('ErrorMessage').tostring();
                        Error_Log__c el = new Error_Log__c();
                        el.Record_ID__c =InvId;
                        el.Error_Message__c = error;
                        el.Response__c = res.getBody();
                        insert el;
                        status = error+' , Please check error log';
                    }
                }else{
                    status= 'No Document found';
                }
            }catch(exception e){
                system.debug('line: '+e.getLineNumber());
                system.debug('err: '+e.getMessage());
                throw new AuraHandledException('Error Occured: '+e.getMessage());
            }
        }else{
            status = 'Could not authenticate, Please check error log';
        }
        return status ;
    }

    public Static String identifyObjectType(Id recordId) {
        SObject record = recordId.getSObjectType().newSObject(recordId);
        String objectType = String.valueOf(record.getSObjectType());
        return objectType;
    }
}