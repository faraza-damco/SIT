/*
 * @description       : OFAC
 * @author            : Damco
 * @group             : 
 * @last modified on  : 23-08-2024
 * @last modified by  : Damco
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   23-08-2024   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
*/

public class ICRA_OFAC_Details {

    @InvocableMethod
    public static void ICRA_OFAC_Details(List<Id> accIds){
        ICRA_OFAC_Details.pushToOfac(accIds);
    }

    public static string Auth(String accId){
        HttpRequest req = new HttpRequest();
        OFAC_Details__c [] ofacInfo = [SELECT Id, End_Point__c, Content_Type__c, Body__c, Name  FROM OFAC_Details__c];

        req.setEndpoint(ofacInfo[0].End_Point__c);
        req.setMethod('POST');
        req.setHeader('content-type', ofacInfo[0].Content_Type__c);
        req.setTimeout(120000);
        
        string body = ofacInfo[0].Body__c;
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('status: '+res.getStatus());
        system.debug('response: '+res.getBody());
        Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        system.debug('Response====>>>'+respMap);
        if(respMap.get('access_token')!=null){
            return respMap.get('access_token').toString();
        }else{
            Error_Log__c el = new Error_Log__c();
            el.Record_ID__c =accId;
            el.Response__c = res.getBody();
            el.Request_Pay_Load__c = req.getBody();
            insert el;
            return null;
        }     
    }

    @future(callout=true)
    public static void pushToOfac(List<Id> accIds){ 
            OFAC_Details__c [] ofacInfo = [SELECT OFAC_End_Point__c  FROM OFAC_Details__c];
            for(Id accId: accIds){
            Account acc = [SELECT ID, Name, ShippingCountry, OFAC_Status__c, OFAC_Date__c, OFAC_Batch_ID__c, OFAC_xml_Responce__c, Account_Status__c, OFAC_Check__c, recordType.Name FROM Account WHERE Id =:accId LIMIT 1];
            if(acc.recordType.Name=='Issuer'){
                try{
                    String Token ='';
                    //if(!test.isRunningTest()){
                        Token = Auth(acc.Id);
                        system.debug('Token='+Token);
                        String body= '{"account_id":"'+acc.Id+'", "name": "'+acc.Name+'", "country": "'+acc.ShippingCountry+'"}';
                        HttpRequest req = new HttpRequest();
                        req.setHeader('Authorization', 'Bearer '+Token);
                        req.setEndpoint(ofacInfo[0].OFAC_End_Point__c);
                        req.setMethod('POST');
                        req.setHeader('content-type','application/json');
                        req.setBody(body);
                        req.setTimeout(120000);
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        system.debug('Request==> : '+req+'\n'+body);
                        system.debug('Response==> : '+res+ '             Status==> : '+res.getStatus());
                        system.debug('Response_Body==> : '+res.getBody());
                        if(res.getBody()!=null & res.getBody()!=''){
                            OFAC_Response ofacResponse= new OFAC_Response();
                            ofacResponse = (OFAC_Response)JSON.deserialize(res.getBody(),OFAC_Response.class); 
                            system.debug('Deserialised Response ==> '+ofacResponse);
                            if(ofacResponse.resp_code=='S'){
                                if(ofacResponse.ofac_status=='NOMATCH'){
                                    acc.OFAC_Check__c=true;
                                    acc.Ofac_Approved__c=true;
                                    acc.OFAC_Document_Received__c=true;
                                    acc.Account_Status__c='Active';
                                    acc.OFAC_Approval_Status__c='Auto Approved';
                                }else{
                                    acc.OFAC_Check__c=true;
                                    acc.Ofac_Approved__c=false;
                                    acc.OFAC_Document_Received__c=false;
                                    acc.Account_Status__c='OFAC Pending'; 
                                }
                                acc.OFAC_Status__c=ofacResponse.ofac_status;
                                acc.OFAC_Date__c=Date.ValueOf(ofacResponse.ofac_moody_last_updated_date);
                                acc.OFAC_Batch_ID__c=ofacResponse.batchId;
                                acc.OFAC_xml_Responce__c= String.ValueOf(res.getBody());
                                update acc;
                            }else{
                                acc.OFAC_xml_Responce__c= String.ValueOf(res.getBody())+'\n'+res;
                                update acc;
                            }
                        }
                    //}
                }catch(exception ex){
                    system.debug('Some error has occured. Please Contact System Administrator with details '+ex.getMessage()+'-'+'at line number '+ex.getLineNumber());
                }finally{
                    acc.OFAC_Check__c=false;
                    update acc;
                }
            }
        }
    }

    public  class OFAC_Response{
        public string req_ack_Id;
        public string resp_code;
        public string resp_message;
        public string ofac_status;
        public string batchId;
        public string ofac_moody_last_updated_date;
        public string ofac_moody_api_result_data;
    }
}