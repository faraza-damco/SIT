public class ICRA_dscSigning_MPRA_SoW {
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
    
    public static Map<String,Object> SignedDoc(string InvId, String base64){ 
        String Token ='';
        // String objectType='';
        // ObjectType= ICRA_dscSigning.identifyObjectType(InvId);
        // List<Invoice__c> invoiceList = new List<Invoice__c>();
        // List<Manual_Invoice__c> manualInvoiceList = new List<Manual_Invoice__c>();
        if(!test.isRunningTest())
            Token = Auth(InvId);
        system.debug('Token='+Token);
        //Id invoiceTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        // if(objectType=='Invoice__c'){
        //     invoiceList= [select id, Invoice_Status__c, RecordTypeId, RecordType.DeveloperName, Credit_Note_Type__c from Invoice__c where id=:InvId];
        // }else if(objectType=='Manual_Invoice__c'){
        //     manualInvoiceList= [select id, Invoice_Status__c, RecordTypeId, RecordType.DeveloperName from Manual_Invoice__c where id=:InvId];
        // }
        ICRA_Desc_Signing__c [] dscInfo = [SELECT Id, End_Point__c, Client_Id__c, Client_Secret__c, Content_Type__c, Body__c, Name, DSCMasterValues__c, Certificate_URL__c FROM ICRA_Desc_Signing__c WHERE Name ='Authenticate' LIMIT 1];
        
        string status ='';
        if(string.isNotBlank(Token) || test.isRunningTest()){
            try{
                //ContentDocumentLink[] cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: InvId AND (NOT ContentDocument.LatestPublishedVersion.Title Like'%Signed%') ORDER BY SystemModstamp DESC LIMIT 1];
                if(!string.isBlank(base64)){
                    //ContentVersion[] cv = [SELECT VersionData,Title FROM ContentVersion WHERE ContentDocumentId = :cdl[0].ContentDocumentId];
                    //string paramvalue = EncodingUtil.base64Encode(cv[0].VersionData);
                    
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(dscInfo[0].Certificate_URL__c);
                    req.setMethod('POST');
                    req.setHeader('token', Token);
                    
                    //req.setTimeout(120000);
                    string body = '{"getDSCSignedBytesForPDFParams":{"originalPdfBytes":"'+base64+'","DSCMasterValues":["'+System.Label.Signing_Authority_MPRA_SoW/*dscInfo[0].DSCMasterValues__c*/+'"],"digitalCertificatePerSegmentForPdfList":[{"CertificateValidTo":""}],"passwordGSTIN":"","CurrFileName":"Test","irn":"","QRCode":""}}';            
                    req.setHeader('content-type', 'application/json');
                    req.setBody(body);
                    req.setTimeout(120000);
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('status: '+res.getStatus());
                    system.debug('response: '+req);
                    system.debug('Body: '+body);
                    Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String,Object> respMap2 = (Map<String,Object>) respMap.get('GetDSCSignedBytesForPDFResult');
                    String returnFile;
                    return respMap2;
                    /*if(respMap2.get('SignedFile') != null){
                        system.debug('Response======>>>>'+respMap2.get('SignedFile').tostring());
                        returnFile = respMap2.get('SignedFile').tostring();
                        returnFile= returnFile.removeEnd('"');
                        returnFile= returnFile.removeStart('"');
                        
                        Blob myBlob = EncodingUtil.base64Decode(returnFile);
                        ContentVersion ContentInsert = new ContentVersion();
                        ContentInsert.Title = 'Doc'+' | Signed';
                        ContentInsert.VersionData = myBlob;
                        ContentInsert.PathOnClient = '/'+' | Signed.pdf';
                        insert ContentInsert;
                        ContentVersion[] insertedContent = [select id, ContentDocumentId from ContentVersion WHERE Id =: ContentInsert.Id];
                        system.debug('ContentInsert.ContentDocumentId>> '+insertedContent[0].ContentDocumentId);
                        ContentDocumentLink cl = new ContentDocumentLink();
                        cl.ContentDocumentId = insertedContent[0].ContentDocumentId;
                        cl.LinkedEntityId = InvId; //Shared with record ID
                        cl.ShareType = 'V';
                        cl.Visibility = 'AllUsers';
                        insert cl;
                        // if(objectType=='Invoice__c'){    
                        //     if(invoiceList.size()>0 && invoiceList[0].RecordType.DeveloperName=='Invoice'){
                        //         invoiceList[0].Invoice_Status__c='Tax Invoice';
                        //         update invoiceList;
                        //     }else if(invoiceList.size()>0 && invoiceList[0].RecordType.DeveloperName=='Credit_Note' && invoiceList[0].Credit_Note_Type__c=='GST Credit Note'){
                        //         invoiceList[0].Invoice_Status__c='GST Credit Note';
                        //         update invoiceList;
                        //     } 
                        // }else if(objectType=='Manual_Invoice__c'){
                        //     if(manualInvoiceList.size()>0 && manualInvoiceList[0].RecordType.DeveloperName=='OPE'){
                        //         manualInvoiceList[0].Invoice_Status__c='OP Tax Invoice';
                        //         update manualInvoiceList;
                        //     }else if(manualInvoiceList.size()>0 && manualInvoiceList[0].RecordType.DeveloperName=='Other_Services'){
                        //         manualInvoiceList[0].Invoice_Status__c='OT Tax Invoice';
                        //         update manualInvoiceList;
                        //     }
                         //}    
                        status = 'success';
                    }else{
                        string error = respMap2.get('ErrorMessage').tostring();
                        Error_Log__c el = new Error_Log__c();
                        el.Record_ID__c =InvId;
                        el.Error_Message__c = error;
                        el.Response__c = res.getBody();
                        insert el;
                        status = error+' , Please check error log';
                    }*/
                }else{
                    //status= 'No Document found';
                    return null;
                }
            }catch(exception e){
                system.debug('line: '+e.getLineNumber());
                system.debug('err: '+e.getMessage());
                return null;
                //throw new AuraHandledException('Error Occured: '+e.getMessage());
            }
        }else{
            //status = 'Could not authenticate, Please check error log';
            return null;
        }
        //return status ;
    }

    // public Static String identifyObjectType(Id recordId) {
    //     SObject record = recordId.getSObjectType().newSObject(recordId);
    //     String objectType = String.valueOf(record.getSObjectType());
    //     return objectType;
    // }
}