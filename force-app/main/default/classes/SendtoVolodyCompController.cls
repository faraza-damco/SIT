public class SendtoVolodyCompController {
    public static  List<String> fieldsToCheck = new List<String>();
    public Static Opportunity Opp;
    
    @AuraEnabled
    public static String getOppFields(String recordId){
        //System.Debug('SendtoVolodyCompController'+recordid);
        if(recordId == null){
            return 'Opportunity Id is null';
        }
        List<Volody_Integration__mdt> volodyMdt = [SELECT  Label, Opportunity_Fields__c FROM  Volody_Integration__mdt WHERE Label='All Fields'];
        String oppfields='';
        //String contactRolefields='';  
        if(!volodyMdt.isEmpty()){        
            oppfields = volodyMdt[0].Opportunity_Fields__c+',';
        }
        if(oppfields!=null){
            List<String> mdtOppFields = oppfields.split(',');
            fieldsToCheck.addAll(mdtOppFields);
        }

        String oppQuery='SELECT Id,'+oppfields+
            +'(SELECT Id, Contact.FirstName, Contact.LastName, Contact.Designation__c, Contact.MobilePhone, Contact.Name, Contact.Phone, Contact.Salutation,'
            +'Contact.Email, Role FROM OpportunityContactRoles where Role=\'MPRA/SOW\' OR Role=\'Name on Invoice\' OR Role=\'Email Recipient\')'
            +'FROM opportunity where Id=:recordId';
        
        System.Debug('oppQuery=========> '+oppQuery);
        System.Debug('recordId=========> '+recordId);
        Opportunity Opp=database.query(oppQuery);
        System.Debug('Opp.Statement_of_Work_No__c=========> '+Opp.Statement_of_Work_No__c);
        String oppcontactrole='';
        
        Set<String> roleSet = new Set<String>();
        if(opp.OpportunityContactRoles.size()>0){
            for(OpportunityContactRole ocr: Opp.OpportunityContactRoles){
                if (ocr.Contact == null || String.isBlank(ocr.Role)) continue;
                roleSet.add(ocr.Role);
            }
        }
        if(!roleSet.contains('MPRA/SOW')){
            fieldsToCheck.add('OpportunityContactRole with Role MPRA/SOW is not present');
        }
        if(!roleSet.contains('Name on Invoice')){
            fieldsToCheck.add('OpportunityContactRole with Role Name on Invoice is not present');
        }
        if(!roleSet.contains('Email Recipient')){
            fieldsToCheck.add('OpportunityContactRole with Role Email Recipient is not present');
        }
        
        String missingFields1= SendtoVolodyCompController.FieldValidator(fieldsToCheck,opp);
        if(missingFields1==' '|| String.isBlank(missingFields1)){
            missingFields1='All Fields Inputed';
        }
        return missingFields1;
    }
    
    // Method for field validation for checking empty values
    private static String FieldValidator(List<String> fieldsToCheck,Sobject opp){ 
        String missingFields='';
        
        for(String fieldPath : fieldsToCheck){
            Object value = getFieldValue(opp, fieldPath);
            if(value == null || (value instanceof String && String.isBlank((String)value))){
                missingFields += getFieldLabel(opp, fieldPath) + ', ';
            }
        }
        missingFields =  missingFields.removeEnd(', ');
        return missingFields;
    }
    
    private static Object getFieldValue(SObject record, String fieldPath) {
        try {
            List<String> parts = fieldPath.split('\\.');
            System.Debug('parts======>> '+parts);
            SObject currentObj = record;
            
            for(Integer i = 0; i < parts.size() - 1; i++){
                if(currentObj == null) return null;
                currentObj = currentObj.getSObject(parts[i]);
            }
            
            if(currentObj == null) return null;
            System.Debug('currentObjret====>>>   '+ currentObj.get(parts[parts.size() - 1]));
            return currentObj.get(parts[parts.size() - 1]);
        } catch(Exception e){
            return null;
        }
    }
    private static String getFieldLabel(SObject record, String fieldPath) {
        try {
            // If relationship field → return API name
            if (fieldPath.contains('.')){
                return fieldPath;
            }else if(fieldPath.endsWith('__r')){
                return fieldPath;
            }else if(fieldPath.contains('OpportunityContactRole with Role')){
                return fieldPath;
            }
            
            // If Opportunity field → return Label
            Schema.DescribeFieldResult fieldDescribe = record.getSObjectType().getDescribe().fields.getMap().get(fieldPath).getDescribe();
            return fieldDescribe.getLabel();
        } catch (Exception e) {
            System.Debug('e'+fieldPath);
            return fieldPath; 
        }
    }
    
    public static VolodyWrapper getTokenForVolody(){
        //Custom Setting to get the integration details
        Volody_Details__c vd = [select Id, Endpoint__C,Password__c, UserName__c from Volody_Details__c Limit 1];
        String BaseUrl=vd.Endpoint__C;
        
        HttpRequest req=new HttpRequest(); 
        req.setMethod('POST');
        req.setEndpoint(BaseUrl+'/api/v1/login_token');
        req.setHeader('Content-Type','application/json');
        
        String body=json.serialize(new map<String,String>{
            'email'=>vd.UserName__c,
            'password'=>vd.Password__c
        });
        
        req.setBody(body);
        Http http = new Http();
        String setCookie='';
        String token='';
        String error='';
        VolodyWrapper wrapper;

        try{
            System.Debug('try');
            HttpResponse res=http.send(req);
            Map<String,object> result= (Map<String,object>)(json.deserializeUntyped(res.getbody()));
            token=(String) result.get('access_token');
            setCookie = res.getHeader('Set-Cookie');
            
            if(res.getStatusCode()!=200){
                System.Debug('res'+res.getStatusCode());
                System.Debug('res'+res);
                error = res.getBody();
            } 
            wrapper=new VolodyWrapper(BaseUrl,setCookie,token,error);
            return wrapper;
        }
        catch(exception e){
            System.Debug('StackTrace: ' + e.getStackTraceString());
            wrapper=new VolodyWrapper('','','',e.getMessage());            
        }
        return wrapper;      
    }

    @AuraEnabled (cacheable=true)
    public static List<object> getAgreementType(){
        VolodyWrapper wrapperVar= SendtoVolodyCompController.getTokenForVolody();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(wrapperVar.baseUrl+'/api/fetch_agreement_data');
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer '+wrapperVar.accessToken);
        req.setHeader('Content-Type','application json');
        
        if(!String.isBlank(wrapperVar.cookie)){
            String cookiePair = wrapperVar.cookie.split(';')[0];
            req.setHeader('Cookie', cookiePair);
        }
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        System.Debug('res'+res);
        
        List<object> result = (List<object>)JSON.deserializeUnTyped(res.getBody());
        List<String> aggType = new List<String>();
        Map<String,List<object>> ogMap=new map<String,List<object>>();
        System.Debug('result->'+result);
        for (Object obj : result) {
            Map<String, Object> record = (Map<String, Object>) obj;
            
            for(String key:record.keyset()){
                if(!ogMap.containskey(key)){
                    ogMap.put(key,new List<object>());
                }
                ogMap.get(key).add(record.get(key));
            }
            aggType.add((String)record.get('label'));       
        }  
        List<object> acc = (ogMap.get('label'));
        System.Debug('acc'+acc);
        System.Debug('ogMap'+ogMap);
        return acc  ;     
    }
    
    @AuraEnabled
    public static String createCrmContract(String optyId, String agreement){ 

        System.Debug('optyId-> '+optyId +' agreement-> '+agreement);
        // Generating the AccessToken
        VolodyWrapper wrapperVar= SendtoVolodyCompController.getTokenForVolody(); 
        String APIstatus=(wrapperVar.error);
        
        List<Volody_Integration__mdt> volodyMdt = [SELECT  Label, Opportunity_Fields__c FROM  Volody_Integration__mdt WHERE Label='All Fields'];
        String oppFields='';

        if(!volodyMdt.isEmpty()){        
            oppFields = volodyMdt[0].Opportunity_Fields__c+',';
        }       

        String optyFields='SELECT Id,'+oppFields+
            +'(SELECT Id, Contact.Salutation, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Designation__c, Contact.MobilePhone,'
            +'Contact.Email, Contact.Phone, Role FROM OpportunityContactRoles where Role=\'MPRA/SOW\' OR Role=\'Name on Invoice\' OR Role=\'Email Recipient\')'
            +' FROM opportunity where Id=:optyId';
            
        Opportunity Opty = Database.Query(optyFields);
        //System.Debug('optyFields=========> '+optyFields);

        Map<String, Map<String, String>> roleData = new Map<String, Map<String, String>>();
        if(Opty.OpportunityContactRoles.size()>0){
            for(OpportunityContactRole ocr: Opty.OpportunityContactRoles){
                if (ocr.Contact == null || String.isBlank(ocr.Role)) continue;
                roleData.put(ocr.Role, new Map<String, String>{
                    'FirstName' => ocr.Contact.FirstName,
                    'MiddleName' => ocr.Contact.MiddleName,
                    'LastName' => ocr.Contact.LastName,
                    'Designation' => ocr.Contact.Designation__c,
                    'MobilePhone' => ocr.Contact.MobilePhone,
                    'Name' => ocr.Contact.Name,
                    'Phone' => ocr.Contact.Phone,
                    'Salutation' => ocr.Contact.Salutation,
                    'Email' => ocr.Contact.Email
                });
            }
        }
        
        if(String.isBlank(wrapperVar.error)){
            httpRequest req = new httpRequest();
            req.setEndpoint(wrapperVar.baseUrl+'/api/v1/crm_contract');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + wrapperVar.accessToken);
            req.setHeader('Content-Type', 'application/json');
            
            if (String.isNotBlank(wrapperVar.cookie)) {
                String cookiePair = wrapperVar.cookie.split(';')[0];
                req.setHeader('Cookie', cookiePair);
            }

            Map<String, Object> payload = new Map<String, Object>{
                'agreement_name' => agreement,
                'parent_company_name' => 'ICRA Limited',
                'req_user_email' => UserInfo.getUserEmail(),
                'api_type' => 'Salesforce',
                'crm_unqiue_ref_id' => Opty.Id,
                'call_back_url' => '',
                'call_back_header_token' => '',
                'MPRA_SoW_Reference_Number_iflow__c' => Opty.MPRA_SoW_Reference_Number_iflow__c!=null ? Opty.MPRA_SoW_Reference_Number_iflow__c : null,
                'CurrencyIsoCode' => Opty.CurrencyIsoCode!=null ? Opty.CurrencyIsoCode : null,
                'MPRA_Sent_Date__c' => Opty.MPRA_Sent_Date__c!=null ? Opty.MPRA_Sent_Date__c : null,
                'EndDate' => null,
                'Title' => Opty.Signing_authority__r != null ? (Opty.Signing_authority__r.Title != null ? Opty.Signing_authority__r.Title : null) : null,
                'Signing_Name' => Opty.Signing_authority__r != null ? (Opty.Signing_authority__r.Name != null ? Opty.Signing_authority__r.Name : null) : null,
                'Designation' => Opty.Signing_authority__r != null ? (Opty.Signing_authority__r.Designation__c != null ? Opty.Signing_authority__r.Designation__c : null) : null,
                'Branch_Name' => Opty.Opp_ICRA_Branch__r.Name,
                'Street' => Opty.Opp_ICRA_Branch__r.Street__c != null ? Opty.Opp_ICRA_Branch__r.Street__c : null,
                'City' => Opty.Opp_ICRA_Branch__r.City__c != null ? Opty.Opp_ICRA_Branch__r.City__c : null,
                'State__c' => Opty.Opp_ICRA_Branch__r.State__c != null ? Opty.Opp_ICRA_Branch__r.State__c : null,
                'Zip_Postal_Code__c' => Opty.Opp_ICRA_Branch__r.Zip_Postal_Code__c != null ? Opty.Opp_ICRA_Branch__r.Zip_Postal_Code__c : null,
                'GSTIN__c' => Opty.Opp_ICRA_Branch__r.GSTIN__c != null ? Opty.Opp_ICRA_Branch__r.GSTIN__c : null,
                'PAN__c' => Opty.Opp_ICRA_Branch__r.PAN__c != null ? Opty.Opp_ICRA_Branch__r.PAN__c : null,
                'Account_Name' => Opty.Account.Name,
                'Billing_Street__c' => Opty.BillingAddress__r.Billing_Street__c != null ? Opty.BillingAddress__r.Billing_Street__c : null,
                'Billing_City__c' => Opty.BillingAddress__r.Billing_City__c != null ? Opty.BillingAddress__r.Billing_City__c : null,
                'Billing_Zip_Postal_Code__c' => Opty.BillingAddress__r.Billing_Zip_Postal_Code__c != null ? Opty.BillingAddress__r.Billing_Zip_Postal_Code__c : null,
                'Billing_state__c' => Opty.BillingAddress__r.BillingState__c != null ? Opty.BillingAddress__r.BillingState__c : null,
                'BillingCountry__c' => Opty.BillingAddress__r.BillingCountry__c != null ? Opty.BillingAddress__r.BillingCountry__c : null,
                //'GSTN__c' => Opty.BillingAddress__r.GSTN__c!=null ? Opty.BillingAddress__r.GSTN__c : null,
                'MPRA_Salutation' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('Salutation') != null ? roleData.get('MPRA/SOW').get('Salutation') : null) : null,
                'MPRA_Name' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('Name') != null ? roleData.get('MPRA/SOW').get('Name') : null) : null,
                'MPRA_FirstName' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('FirstName') != null ? roleData.get('MPRA/SOW').get('FirstName') : null) : null,
                'MPRA_MiddleName' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('MiddleName') != null ? roleData.get('MPRA/SOW').get('MiddleName') : null) : null,
                'MPRA_LastName' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('LastName') != null ? roleData.get('MPRA/SOW').get('LastName') : null) : null,
                'MPRA_Designation__c' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('Designation') != null ? roleData.get('MPRA/SOW').get('Designation') : null) : null,
                'MPRA_Phone' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('Phone') != null ? roleData.get('MPRA/SOW').get('Phone') : null) : null,
                'MPRA_Mobile' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('MobilePhone') != null ? roleData.get('MPRA/SOW').get('MobilePhone') : (roleData.get('MPRA/SOW').get('Phone') != null ? roleData.get('MPRA/SOW').get('Phone') : null)) : null,
                'MPRA_Email' => roleData.containsKey('MPRA/SOW') ? (roleData.get('MPRA/SOW').get('Email') != null ? roleData.get('MPRA/SOW').get('Email') : null) : null,
                'Invoice_Salutation' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('Salutation') != null ? roleData.get('Name on Invoice').get('Salutation') : null) : null,
                'Invoice_Name' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('Name') != null ? roleData.get('Name on Invoice').get('Name') : null) : null,
                'Invoice_FirstName' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('FirstName') != null ? roleData.get('Name on Invoice').get('FirstName') : null) : null,
                'Invoice_MiddleName' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('MiddleName') != null ? roleData.get('Name on Invoice').get('MiddleName') : null) : null,
                'Invoice_LastName' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('LastName') != null ? roleData.get('Name on Invoice').get('LastName') : null) : null,
                'Invoice_Designation__c' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('Designation') != null ? roleData.get('Name on Invoice').get('Designation') : null) : null,
                'Invoice_Phone' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('Phone') != null ? roleData.get('Name on Invoice').get('Phone') : null) : null,
                'Invoice_Mobile' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('MobilePhone') != null ? roleData.get('Name on Invoice').get('MobilePhone') : (roleData.get('Name on Invoice').get('Phone') != null ? roleData.get('Name on Invoice').get('Phone') : null)) : null,
                'Invoice_Email' => roleData.containsKey('Name on Invoice') ? (roleData.get('Name on Invoice').get('Email') != null ? roleData.get('Name on Invoice').get('Email') : null) : null,
                'Email_Salutation' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('Salutation') != null ? roleData.get('Email Recipient').get('Salutation') : null) : null,
                'Email_Name' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('Name') != null ? roleData.get('Email Recipient').get('Name') : null) : null,
                'Email_FirstName' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('FirstName') != null ? roleData.get('Email Recipient').get('FirstName') : null) : null,
                'Email_MiddleName' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('MiddleName') != null ? roleData.get('Email Recipient').get('MiddleName') : null) : null,
                'Email_LastName' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('LastName') != null ? roleData.get('Email Recipient').get('LastName') : null) : null,
                'Email_Designation__c' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('Designation') != null ? roleData.get('Email Recipient').get('Designation') : null) : null,
                'Email_Phone' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('Phone') != null ? roleData.get('Email Recipient').get('Phone') : null) : null,
                'Email_Mobile' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('MobilePhone') != null ? roleData.get('Email Recipient').get('MobilePhone') : (roleData.get('Email Recipient').get('Phone') != null ? roleData.get('Email Recipient').get('Phone') : null)) : null,
                'Email_Email' => roleData.containsKey('Email Recipient') ? (roleData.get('Email Recipient').get('Email') != null ? roleData.get('Email Recipient').get('Email') : null) : null,
                'Statement_of_Work_No__c' => Opty.Statement_of_Work_No__c!=null ? Opty.Statement_of_Work_No__c : null,
                'SOW_Effective_Date__c' => Opty.SOW_Effective_Date__c!=null ? Opty.SOW_Effective_Date__c : null,
                //'Amt_of_CAP_fee__c' => Opty.Amt_of_CAP_fee__c!=null ? Opty.Amt_of_CAP_fee__c : null,
                'VoD_in_crore__c' => Opty.VoD_in_crore__c!=null ? Opty.VoD_in_crore__c : null,
                'Crore_or_Million__c' => Opty.Crore_or_Million__c!=null ? Opty.Crore_or_Million__c : null,
                'Payment_Terms__c' => Opty.Payment_Terms__c!=null ? Opty.Payment_Terms__c : null,
                'Delayed_Payment_Interest_Rate__c' => Opty.Delayed_Payment_Interest_Rate__c!=null ? Opty.Delayed_Payment_Interest_Rate__c : null,
                'ASF_Final_Amount__c' => Opty.ASF_Final_Amount__c!=null ? Opty.ASF_Final_Amount__c : null,
                'IRF_Final_Amount__c' => Opty.IRF_Final_Amount__c!=null ? Opty.IRF_Final_Amount__c : null,
                'CashflowPool' => Opty.Cash_Flow_Pool__c!=null ? Opty.Cash_Flow_Pool__c : null,
                'Scheme_Trust_Name__c' => Opty.Scheme_Trust_Name__c!=null ? Opty.Scheme_Trust_Name__c : null,
                'CounterParty' => Opty.Rated_Entity__r.Name!=null ? Opty.Rated_Entity__r.Name : null,
                'RatedEntity' => Opty.Rated_Entity__c!=null ? Opty.Rated_Entity__r.Name : null,
                'PAN_Number__c' => Opty.Rated_Entity__r.PAN_Number__c!=null ? Opty.Rated_Entity__r.PAN_Number__c : null,
                'TAN_Number__c' => Opty.Rated_Entity__r.TAN_Number__c!=null ? Opty.Rated_Entity__r.TAN_Number__c : null,
                'ShippingStreet' => Opty.Rated_Entity__r.ShippingStreet!=null ? Opty.Rated_Entity__r.ShippingStreet : null,
                'ShippingCity' => Opty.Rated_Entity__r.ShippingCity!=null ? Opty.Rated_Entity__r.ShippingCity : null,
                'ShippingPostalcode' => Opty.Rated_Entity__r.ShippingPostalcode!=null ? Opty.Rated_Entity__r.ShippingPostalcode : null,
                'ShippingState' => Opty.Rated_Entity__r.ShippingState!=null ? Opty.Rated_Entity__r.ShippingState : null,
                'ShippingCountry' => Opty.Rated_Entity__r.ShippingCountry!=null ? Opty.Rated_Entity__r.ShippingCountry : null,
                'Surveillance_Fee_Revision_Maximum_new__c' => Opty.Surveillance_Fee_Revision_Maximum_new__c!=null ? Opty.Surveillance_Fee_Revision_Maximum_new__c : null,
                'InstrumentType1' => Opty.Instrument_type_1__c!=null ? Opty.Instrument_type_1__c : null,
                'InstrumentType2' => Opty.Instrument_type_2__c!=null ? Opty.Instrument_type_2__c : null,
                'InstrumentType3' => Opty.Instrument_type_3__c!=null ? Opty.Instrument_type_3__c : null,
                'InstrumentType4' => Opty.Instrument_type_4__c!=null ? Opty.Instrument_type_4__c : null,
                'InstrumentCategory' => Opty.Instrument_Category__c!=null ? Opty.Instrument_Category__c : null,
                'account_pan_number__c' => Opty.PAN_Number__c!=null ? Opty.PAN_Number__c : null,
                'account_tan_number__c' => Opty.TAN_Number__c!=null ? Opty.TAN_Number__c : null,
                'account_gstn__c' => Opty.GST_Number__c!=null ? Opty.GST_Number__c : null,
                'min_asf_per_agreement__c' => Opty.Minimum_ASF__c!=null ? Opty.Minimum_ASF__c : null,
                'ini_rating_as_agreement_bps__c' => Opty.Initial_Rating_Fee_as_per_Agreement_BPS__c!=null ? Opty.Initial_Rating_Fee_as_per_Agreement_BPS__c : null,
                'ann_surv_as_agreement_bps__c' => Opty.ASF_as_per_Agreement_BPS__c!=null ? Opty.ASF_as_per_Agreement_BPS__c : null,
                'asf_agreement_client_client__c' => Opty.ASF_Agreement_with_Client__c!=null ? Opty.ASF_Agreement_with_Client__c : null
            };

            String body = JSON.serialize(payload);
            System.Debug('body===========>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+body);
            req.setBody(body);
            
            Http http = new Http();
            try{
                HttpResponse res = http.send(req);
                Opportunity opp = new Opportunity(Id = optyId);
                Map<String,object> result = (Map<String,object>)JSON.deserializeUnTyped(res.getBody());
                System.Debug('result'+result);
                if(res.getStatuscode()!=200){
                    APIstatus=(String)JSON.Serialize(result.get('errors'));
                }
                else{
                    opp.Contract_ID__c = (String)JSON.serialize(result.get('clm_reference_id'));
                    opp.Contract_Link__c = (String)JSON.serialize(result.get('clm_document_link'));
                    APIstatus = 'Success';
                    System.Debug('opp'+opp);
                    Update opp;
                }
            }
            catch(exception e){
                APIstatus = e.getMessage();
            }
        }
        System.Debug('APIstatus-- '+APIstatus);
        return APIstatus;
    }
    
    public static void getContractStatusAPI(){
        VolodyWrapper wrapperVar= SendtoVolodyCompController.getTokenForVolody();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(wrapperVar.baseUrl+'/api/v1/contract_status?clm_reference_id=7');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + wrapperVar.accessToken);
        
        if(String.isNotBlank(wrapperVar.cookie)){
            String cookiePair = wrapperVar.cookie.split(';')[0];
            req.setHeader('Cookie', cookiePair);
        }

        String body = '{"clm_reference_id": 7}';
        //   req.setBody(body);
        HttpResponse res = http.send(req);
        System.Debug('Response Status: ' + res.getStatusCode());
        System.Debug('Response Body: ' + res.getBody());
    }
    
    public class VolodyWrapper{
        public String baseUrl;
        public String cookie;
        public String accessToken;
        public String error;
        
        public VolodyWrapper (String baseUrl,  String cookie, String accessToken,String error){
            this.baseUrl=baseUrl;
            this.cookie=cookie;
            this.accessToken=accessToken;
            this.error=error;
        }
    }
}