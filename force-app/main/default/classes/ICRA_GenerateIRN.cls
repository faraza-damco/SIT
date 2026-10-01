global class ICRA_GenerateIRN {
    
      
    global Boolean errorMsg{get; set;}
    global static String  errorMsgDisplay{get; set;}
    
    @InvocableMethod
    global static void InvokeIRN(List<Invoice__c> invoiceList){ 
        for(Invoice__c invoice : invoiceList){
            getIRN(invoice.Id, invoice.Bill_No__c); 
        } 
    }  
    
    public static void getIRN(String invoiceID, String billNumber) {
        list<String> InvoiceIRN = new List<String>();
        list<String> QRCode = new List<String>();
        string EndPoint = Label.PWC_End_Point_URL; 
        List<Invoice__c> updateInvoiceList = new List<Invoice__c>();
        
        String Body = ICRA_IntegrationUtilities.createJSONRequest(invoiceID);
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
            System.debug('========= response http ======'+response.getStatusCode());
            system.debug('========= Response Body ============ ' +response.getbody());
            List<Object> JsonParseMap1 = (List<Object>)Json.deserializeUntyped(response.getBody()); 
            
            JSONParser parseResponse = JSON.createParser(response.getBody());
            System.debug('======  parseResponse ===== : '+parseResponse); 
            
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
                            Map<String, Object> data = new Map<String, Object>();
                            if(IRP.get('data') != null){
                                data = (Map<String, Object>)IRP.get('data');
                            }  
                            Map<String, Object> nrd = (Map<String, Object>)data.get('nic_response_data');
                            String irnStr  = string.valueOf(nrd.get('Irn')); 
                            String signedQRCode = string.valueOf(firstMap.get('qr_b64_encoded')); 
                            
                            updateInvoiceList.add(updateInvoice(irnStr, invoiceID, signedQRCode, invoiceStatus));
                            
                        }else{ 
                            invoiceStatus = 'QR and IRN - Failed'; 
                            Map<String, Object> IRP = (Map<String, Object>)firstMap.get('irp_response');
                            Map<String, Object> data = new Map<String, Object>();
                            if(IRP.get('data') != null){
                                data = (Map<String, Object>)IRP.get('data');
                            } 
                            system.debug('data '+data);
                            if(data.containskey('error_details'))
                            {
                                String errorMsg='';
                                for (Object instance : (List<Object>)data.get('error_details'))
                                {
                                    Map<String,Object> Ermsg = (Map<String,Object>)instance; 
                                    errorMsg=String.valueof(Ermsg.get('ErrorMessage'));
                                    System.debug('instance '+Ermsg);
                                }
                                
                                Error_Log__c errorLog = new Error_Log__c();
                                errorLog.Response__c = (String) response.getBody();
                                errorMsgDisplay= 'Error - '+Status+', IRN Generation Failed due to-'+errorMsg;
                                errorlog.Error_Message__c = errorMsgDisplay;
                                errorlog.Record_ID__c = invoiceID;
                                errorLog.Bill_number__c = billNumber;
                                errorlog.Request_Pay_Load__c = Body; 
                                Insert errorLog;
                               
                                System.debug('Error log is '+errorLog);
                            }
                            else
                            {
                                
                                Error_Log__c errorLog = new Error_Log__c();
                                errorLog.Response__c = (String) response.getBody();
                                errorMsgDisplay= 'Error - '+Status+', IRN Generation Failed due to -'+string.valueOf(dataNodeMap.get('message'));
                                errorlog.Error_Message__c = errorMsgDisplay;
                                errorlog.Record_ID__c = invoiceID;
                                errorLog.Bill_number__c = billNumber;
                                errorlog.Request_Pay_Load__c = Body; 
                                Insert errorLog; 
                                System.debug('Error log is '+errorLog);
                            }
                            
                            updateInvoiceList.add(updateInvoice('', invoiceID, '', invoiceStatus)); 
                        }  
                    }                   
                }
            }
            
            if(updateInvoiceList.size() > 0 ){ 
                Database.SaveResult [] result = Database.update(updateInvoiceList,false); 
            }
        }else{
            System.debug('========= response http ======'+response.getStatusCode());
            Integer statusCode = response.getStatusCode();
            Error_Log__c errorlog = new Error_Log__c();
            errorlog.Response__c = (String) response.getBody();
            errorMsgDisplay = 'Error - '+ statusCode +', Server Error : 504 Gateway Timeout Error ';
            errorlog.Error_Message__c = errorMsgDisplay;
            errorlog.Record_ID__c = invoiceID;
            errorLog.Bill_number__c = billNumber;
            errorlog.Request_Pay_Load__c = Body; 
            Insert errorLog; 
            System.debug('Error log is '+errorLog);
        } 
        
    }
    public static Invoice__c  updateInvoice(String IRN_Number, String RecordId, String base64str, String status) {
        System.debug('====== status ====='+status); 
        Invoice__c invoiceRecord = new Invoice__c();
        invoiceRecord.Id = RecordId;
        invoiceRecord.IRN_Number__c = IRN_Number;
        
        if(status != null && status != ''){
            invoiceRecord.Invoice_Status__c = status;
        } 
        
        if(base64str != '' && base64str != null){
            invoiceRecord.QR_Code__c = '<img src="data:image/jpeg;base64,'+base64str+'">';
        }
        
        
        System.debug('====== invoiceRecord ====='+invoiceRecord);
        
        return invoiceRecord;
    }
    
    public class InvoicePage {
        public Invoice__c Invoice  {get;set;}
        public InvoicePage() {
            Invoice = new Invoice__c();
        }
    } 
}