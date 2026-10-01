/**
* @description       : 
* @author            : ABDUL MUQHEEM
* @group             : 
* @last modified on  : 04-26-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   04-20-2021   ABDUL MUQHEEM           Initial Version
* 2.0   04-23-2021   ABDUL MUQHEEM           Modified the Initiation from VF Page, Highlighted the Header Values to Custom Labels
* 3.0   04-26-2021   RITESH KUMAR            Updating the QR code and  
**/

global class IRN_Post_on_Generating{
    private Id IRNID;
    global invoicepage Invoice{get; set;}
    global ManualInvoicePage ManualInvoice{get; set;}
    global Invoice__c InvoiceDetails {get; set;}
    global Manual_Invoice__c ManualInvoiceDetails {get; set;}
    global Boolean errorMsg{get; set;}
    global static String  errorMsgDisplay{get; set;}
    global static Boolean  showSpinner{get; set;}
    global Static String ObjectType='';
    global IRN_Post_on_Generating (ApexPages.StandardController controller){
        IRNID = ''+ApexPages.currentPage().getParameters().get('id');
        
        System.Debug('IRNID==>>'+IRNID);
        init();
        
    }
    global void init(){
        IRNID= ''+ApexPages.currentPage().getParameters().get('id');
        
        if (IRNID != null) {
            try{
                showSpinner=true;
                ObjectType= IRN_Post_on_Generating.identifyObjectType(IRNID);
                System.Debug('ObjectType==>>'+ObjectType);
                if(ObjectType=='Invoice__c'){
                    Invoice = new invoicepage();
                    Invoice__c Inv = new Invoice__c();
                    Inv = [Select Id, Name, Opportunity_Name__r.Name,Opportunity_Name__r.GST_Not_Applicable__c, IRN_Number__c, Bill_No__c, Bypass_Validation__c,Invoice_Status__c from Invoice__c where id =: IRNID LIMIT 1];
                    Invoice.Invoice = Inv;
                    InvoiceDetails=Inv;
                    errorMsg = false;
                    errorMsgDisplay='';
                    System.Debug('InvoiceDetails==>>'+InvoiceDetails);
                }else if(ObjectType=='Manual_Invoice__c'){
                    ManualInvoice = new ManualInvoicePage();
                    //string IRNID = ''+ApexPages.currentPage().getParameters().get('id');
                    Manual_Invoice__c Inv = new Manual_Invoice__c();
                    Inv = [Select Id, Name, IRN_Number__c, Invoice_Status__c,Bill_No__c from Manual_Invoice__c where id =: IRNID LIMIT 1];
                    ManualInvoice.Invoice = Inv;
                    ManualInvoiceDetails=Inv;
                    errorMsg = false;
                    errorMsgDisplay='';
                }
                if(ObjectType=='Invoice__c' && InvoiceDetails.Opportunity_Name__r.GST_Not_Applicable__c==true){
                    errorMsgDisplay='IRN is not applicable if \'GST Not Applicable\' is true';
                }
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing record ID.'));
            }
        }
    }
    
    public static void loadSpinner(){
        showSpinner=true;
    }
    global  IRN_Post_on_Generating(){}
    
    global void InvokeIRN(){
        init();
        system.debug('alredy gen1');
        
        if((ObjectType=='Invoice__c' && InvoiceDetails.Invoice_Status__c=='QR-IRN-Generated')
           ||(ObjectType=='Manual_Invoice__c' && ManualInvoiceDetails.Invoice_Status__c=='QR and IRN - Generated')){
               errorMsgDisplay='Already generated';
               showSpinner=false;
               system.debug('alredy gen');
               return;
           }
        
        if(String.isBlank(errorMsgDisplay)){
            System.Debug('Errro Message====>>>'+errorMsgDisplay);
            IRNID = ''+ApexPages.currentPage().getParameters().get('id');
            system.debug('IRNID'+IRNID);
            
            if(!Test.isRunningTest()&&!System.isFuture())
            {
                getIRN(IRNID);
            }
        }
        showSpinner=false;
    }
    
    //@future(callout = true)
    public static void getIRN(String IRNID){
        list<String> InvoiceIRN = new List<String>();
        list<String> QRCode = new List<String>();
        string EndPoint = Label.PWC_End_Point_URL;// 'https://9q0rl0jztl.execute-api.ap-south-1.amazonaws.com/qa/v1/en/push';
        ObjectType= IRN_Post_on_Generating.identifyObjectType(IRNID);
        System.Debug('ObjectType==>>'+ObjectType);
        String Body='';
        if(ObjectType=='Invoice__c'){
            Body = ICRA_IntegrationUtilities.createJSONRequest(IRNID);
        }else if(ObjectType=='Manual_Invoice__c'){
            Body = ICRA_ManualInvoice_Integration_Utils.createJSONRequest(IRNID);
        }
        System.Debug('Body==>>'+Body);
        
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndPoint);
        req.setmethod('POST');
        req.setHeader('content-type', Label.IRN_Content_Type);
        req.setHeader('token', Label.IRN_Token);
        req.setHeader('customerid', Label.IRN_Customer_Type);
        req.setTimeout(120000);
        req.setBody(Body);
        HTTPResponse response;
        response = http.send(req);  
        
        String invoiceStatus = '';
        if(response.getStatusCode() == 200)
        {
            system.debug('Response ==== '+response.getBody());
            List<Object> JsonParseMap1 = (List<Object>)Json.deserializeUntyped(response.getBody()); 
            system.debug('JsonParseMap1 ===== '+JsonParseMap1);
            JSONParser parseResponse = JSON.createParser(response.getBody());
            system.debug('parseResponse ===== '+parseResponse);
            while (parseResponse.nextToken() != null) {
                if (parseResponse.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    String fieldName1 = parseResponse.getText();
                    
                    parseResponse.nextToken();
                    if(fieldName1 == 'pwc_response')
                    {
                        Map<String, Object> firstMap = (Map<String, Object>)JsonParseMap1[0];
                        Map<String, Object> dataNodeMap = (Map<String, Object>)firstMap.get('pwc_response');
                        Integer Status = Integer.valueOf(dataNodeMap.get('status'));
                        system.debug('IRN Number is : '+Status);
                        if(Status == 700){
                            invoiceStatus = 'QR-IRN-Generated';                        
                            Map<String, Object> IRP = (Map<String, Object>)firstMap.get('irp_response');
                            system.debug('IRP ==== '+firstMap.get('irp_response'));
                            system.debug('IRP map ==== '+IRP);
                            Map<String, Object> data = (Map<String, Object>)IRP.get('data');
                            system.debug('data ==== '+IRP.get('data'));
                            system.debug('data map ==== '+data);
                            Map<String, Object> nrd = (Map<String, Object>)data.get('nic_response_data');
                            system.debug('nrd ==== '+data.get('nic_response_data'));
                            system.debug('nrd map ==== '+nrd);
                            InvoiceIRN.add(string.valueOf(nrd.get('Irn')));
                            System.debug('InvoiceIRN ==='+InvoiceIRN);
                            System.debug('string value of IRN ==='+string.valueOf(nrd.get('Irn')));
                            
                            String SignedQRCode = string.valueOf(firstMap.get('qr_b64_encoded'));
                            System.debug('SignedQRCode ==='+SignedQRCode);
                            System.debug('SignedQRCode get==='+string.valueOf(firstMap.get('qr_b64_encoded')));              
                            QRCode.add(SignedQRCode); 
                            
                        }else{ 
                            invoiceStatus = 'QR and IRN - Failed';
                            String errorMsg='Server Error';
                            errorMsgDisplay = 'Server Error';
                            Map<String, Object> IRP = (Map<String, Object>)firstMap.get('irp_response');
                            Map<String, Object> data = (Map<String, Object>)IRP.get('data');
                            system.debug('data '+data);
                            if(data != null){
                                if(data.containskey('error_details'))
                                {
                                    
                                    for (Object instance : (List<Object>)data.get('error_details'))
                                    {
                                        Map<String,Object> Ermsg = (Map<String,Object>)instance;
                                        errorMsg=String.valueof(Ermsg.get('ErrorMessage'));
                                        System.debug('instance '+Ermsg);
                                    }
                                    
                                    Error_Log__c errorLog = new Error_Log__c();
                                    errorLog.Response__c = (String) response.getBody();
                                    errorlog.Error_Message__c = errorMsg;
                                    
                                    Insert errorLog;
                                    errorMsgDisplay='IRN Generation Failed due to-'+errorMsg;
                                    System.debug('Error log is '+errorLog);
                                }
                                else
                                {
                                    
                                    Error_Log__c errorLog = new Error_Log__c();
                                    errorLog.Response__c = (String) response.getBody();
                                    errorlog.Error_Message__c = string.valueOf(dataNodeMap.get('message'));
                                    Insert errorLog;
                                    errorMsgDisplay='IRN Generation Failed due to-'+string.valueOf(dataNodeMap.get('message'));
                                }
                            }else{
                                Error_Log__c errorLog = new Error_Log__c();
                                errorLog.Response__c = (String) response.getBody();
                                errorlog.Error_Message__c = string.valueOf(dataNodeMap.get('message'));
                                Insert errorLog;
                                errorMsgDisplay='IRN Generation Failed due to-'+string.valueOf(dataNodeMap.get('message'));
                            }
                            
                            
                        }  
                    }                   
                }
            }
        }
        if(InvoiceIRN.size()>0){
            UpdateInvoice(InvoiceIRN[0], IRNID, QRCode[0],invoiceStatus);
        }else{
            UpdateInvoice('', IRNID, '',invoiceStatus);
        }
    }
    public static void UpdateInvoice(String IRN_Number, String RecordId, String Base64, String status)
    {
        if(ObjectType=='Invoice__c'){
            list<Invoice__c> UpdateInvoice = new list<Invoice__c>();
            list<ContentVersion> Content = new list<ContentVersion>();
            Invoice__c Invoice = new Invoice__c();
            Invoice.Id = RecordId;
            Invoice.IRN_Number__c = IRN_Number;
            if(Base64 != '' && Base64 != null){
                Invoice.QR_Code__c = '<img src="data:image/jpeg;base64,'+Base64+'">';
            }
            
            // Yash Modified code start 
            Invoice__c invCode = [Select Bill_Due_Date__c, Credit_Note_No__c,Bypass_Validation__c FROM Invoice__c Where ID =:RecordId limit 1] ;
            if(Invoice.IRN_Number__c != NULL && Invoice.IRN_Number__c !='' ){ /*&& invCode.Credit_Note_No__c != NULL (as discussed with vaibhav dt:19-02-2025)*/ //&& invCode.Bill_Due_Date__c == System.today() removed As discussed with Arindam 12th Jan 2023.
                Invoice.Invoice_Status__c = 'QR-IRN-Generated';
                errorMsgDisplay ='Success';
                System.debug('Invoice status is '+ Invoice.Invoice_Status__c );
            }
            else if (Invoice.IRN_Number__c == NULL  || Invoice.QR_Code__c == NULL || (Invoice.IRN_Number__c == NULL && Invoice.QR_Code__c == NULL)){
                Invoice.Invoice_Status__c = 'QR and IRN - Failed' ;
                errorMsgDisplay ='QR IRN Generated failed';
                System.debug('Invoice status is '+ Invoice.Invoice_Status__c );
            }
            
            // Yash Modified code End 
            
            UpdateInvoice.add(Invoice); 
            
            if(UpdateInvoice.size()>0){
                Invoice.Bypass_Validation__c=true;
                update Invoice;  
            }
        }else if(ObjectType=='Manual_Invoice__c'){
            list<Manual_Invoice__c> UpdateInvoice = new list<Manual_Invoice__c>();
            //list<ContentVersion> Content = new list<ContentVersion>();
            Manual_Invoice__c Invoice = new Manual_Invoice__c();
            Invoice.Id = RecordId;
            Invoice.IRN_Number__c = IRN_Number;
            if(Base64 != '' && Base64 != null){
                Invoice.QR_Code__c = '<img src="data:image/jpeg;base64,'+Base64+'">';
            }
            
            //Manual_Invoice__c invCode = [Select Invoice_Status__c FROM Manual_Invoice__c Where ID =:RecordId limit 1] ;
            if(Invoice.IRN_Number__c != NULL && Invoice.IRN_Number__c !=''  /*&& invCode.Credit_Note_No__c != NULL*/){ //&& invCode.Bill_Due_Date__c == System.today() removed As discussed with Arindam 12th Jan 2023.
                Invoice.Invoice_Status__c = 'QR and IRN - Generated';
                errorMsgDisplay ='Success';
                System.debug('Invoice status is '+ Invoice.Invoice_Status__c );
            }
            else if (Invoice.IRN_Number__c == NULL  || Invoice.QR_Code__c == NULL || (Invoice.IRN_Number__c == NULL && Invoice.QR_Code__c == NULL)){
                Invoice.Invoice_Status__c = 'QR and IRN - Failed' ;
                errorMsgDisplay ='QR IRN Generated failed';
                System.debug('Invoice status is '+ Invoice.Invoice_Status__c );
            }
            
            UpdateInvoice.add(Invoice); 
            
            if(UpdateInvoice.size()>0){
                update Invoice;  
            }
        }
        
    }
    
    public class InvoicePage {
        public Invoice__c Invoice  {get;set;}
        public InvoicePage() {
            Invoice = new Invoice__c();
        }
    }
    public class ManualInvoicePage {
        public Manual_Invoice__c Invoice  {get;set;}
        public ManualInvoicePage() {
            Invoice = new Manual_Invoice__c();
        }
    }
    
    global void CanecelIRN(){
        init();
        if(ObjectType=='Invoice__c' && InvoiceDetails.IRN_Number__c==null){
            errorMsgDisplay='IRN not generated';
            showSpinner=false;
            
            return;
        }else if(ObjectType=='Manual_Invoice__c' && ManualInvoiceDetails.IRN_Number__c==null){
            errorMsgDisplay='IRN not generated';
            showSpinner=false;
            
            return;
        }
                if((ObjectType=='Invoice__c' && InvoiceDetails.Invoice_Status__c=='Canceled')
           ||(ObjectType=='Manual_Invoice__c' && ManualInvoiceDetails.Invoice_Status__c=='Canceled')){
               system.debug('errorrr');
            errorMsgDisplay='Already generated';
            showSpinner=false;         
            return;
        }
        /*    if(InvoiceDetails.IRN_Number__c==null){
errorMsgDisplay='IRN not generated';
return;
}*/
        string EndPoint = Label.IRN_Cancel; //https://9q0rl0jztl.execute-api.ap-south-1.amazonaws.com/qa/v1/en/cancel
        String Body='';
        if(ObjectType=='Invoice__c'){
            Body = ICRA_IntegrationUtilities.CancelJson(InvoiceDetails.IRN_Number__c,'Incorrect entry');
        }else if(ObjectType=='Manual_Invoice__c'){
            Body = ICRA_ManualInvoice_Integration_Utils.CancelJson(ManualInvoiceDetails.IRN_Number__c,'Incorrect entry');
        }
        //String Body = ICRA_IntegrationUtilities.CancelJson(InvoiceDetails.IRN_Number__c,'Incorrect entry');
        System.debug('======== Body ========='+Body);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndPoint);
        req.setmethod('POST');
        req.setHeader('content-type', Label.IRN_Content_Type);
        req.setHeader('token', Label.IRN_Token);
        req.setHeader('customerid', Label.IRN_Customer_Type);
        req.setTimeout(120000);
        req.setBody(Body);
        HTTPResponse response; 
        response = http.send(req); 
        String invoiceStatus = '';
        if(response.getStatusCode() == 200){ 
            List<Object> JsonParseMap1 = (List<Object>)Json.deserializeUntyped(response.getBody()); 
            
            JSONParser parseResponse = JSON.createParser(response.getBody()); 
            
            while (parseResponse.nextToken() != null) {
                if (parseResponse.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    String fieldName1 = parseResponse.getText(); 
                    parseResponse.nextToken();
                    if(fieldName1 == 'pwc_response')
                    {
                        Map<String, Object> firstMap = (Map<String, Object>)JsonParseMap1[0];
                        Map<String, Object> dataNodeMap = (Map<String, Object>)firstMap.get('pwc_response');
                        Integer Status = Integer.valueOf(dataNodeMap.get('status'));
                        system.debug('IRN Number is : '+Status);
                        if(Status == 700){
                            invoiceStatus = 'Canceled';
                            errorMsgDisplay='Success';
                            
                            
                        }else{
                            System.debug('============ Errro Code =========: '+Status);
                            invoiceStatus = 'QR and IRN - Failed'; 
                            Map<String, Object> IRP = (Map<String, Object>)firstMap.get('pwc_response');
                            Map<String, Object> cancel_response = (Map<String, Object>)firstMap.get('cancel_response');
                            String errorMsg = cancel_response != null &&  cancel_response.size() > 0 ? string.valueOf(cancel_response.get('message')) : 'Unknow Error' ;
                            String errorMsgvalidation=string.valueOf(IRP.get('validation_status'));
                            
                            if(errorMsgvalidation=='Error') {
                                
                                Error_Log__c errorLog = new Error_Log__c();
                                errorLog.Response__c = (String) response.getBody();
                                errorlog.Error_Message__c = errorMsg;
                                if(ObjectType=='Invoice__c'){
                                    errorlog.Record_ID__c = InvoiceDetails.Id;
                                    errorlog.Bill_number__c = InvoiceDetails.Bill_No__c;
                                }else if(ObjectType=='Manual_Invoice__c'){
                                    errorlog.Record_ID__c = ManualInvoiceDetails.Id;
                                    errorlog.Bill_number__c = ManualInvoiceDetails.Bill_No__c;
                                }
                                
                                Insert errorLog;
                                errorMsgDisplay='IRN Cancelation Failed due to-'+errorMsg;
                                System.debug('Error log is '+errorLog);
                            }
                            system.debug('errorMsg '+errorMsg);
                        }  
                    }                   
                }
                if(ObjectType=='Invoice__c' && invoiceStatus != null && invoiceStatus != ''){
                    InvoiceDetails.Invoice_Status__c = invoiceStatus;
                    InvoiceDetails.Cancel_IRN__c = true;
                    if(!test.isrunningtest()){
                        InvoiceDetails.Bypass_Validation__c = true;
                    }
                    Update InvoiceDetails;
                }else if(ObjectType=='Manual_Invoice__c' && invoiceStatus != null && invoiceStatus != ''){
                    ManualInvoiceDetails.Invoice_Status__c = invoiceStatus;
                    
                    Update ManualInvoiceDetails;
                    
                }
            }
        }
        showSpinner=false;
        
    }
    public Static String identifyObjectType(Id recordId) {
        SObject record = recordId.getSObjectType().newSObject(recordId);
        String objectType = String.valueOf(record.getSObjectType());
        return objectType;
    }
}