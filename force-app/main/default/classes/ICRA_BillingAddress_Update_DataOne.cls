@RestResource(urlMapping='/BillingAddressUpdate/*')
global with sharing class ICRA_BillingAddress_Update_DataOne {
    @HttpPost
    global static ICRA_BillingAddress_Update_DataOne.ResponseWrapper billingAddressUpdate(){
        String req= RestContext.request.requestBody.toString();
        ICRA_BillingAddress_Update_DataOne.ResponseWrapper returnValue= new ICRA_BillingAddress_Update_DataOne.ResponseWrapper();
        if(String.isNotBlank(req)){
            try{
                ICRA_BillingAddress_Update_Wrapper billingAddrWrapper= (ICRA_BillingAddress_Update_Wrapper) JSON.deserialize(req, ICRA_BillingAddress_Update_Wrapper.class);
                system.debug('Request Payload==>>'+billingAddrWrapper);
                if(billingAddrWrapper.data[0].billingAddress_ID!=''){
                    List<Billing_Address__c> billingAddrData= [select Id, Billing_Street__c, Billing_City__c, BillingCountry__c, BillingState__c, Billing_Zip_Postal_Code__c, GSTN__c, Billing_BvD_ID__c from Billing_Address__c where Id=:billingAddrWrapper.data[0].billingAddress_ID LIMIT 1];
                    if(billingAddrData!=null && billingAddrData.size()>0){
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].billingStreet))){
                            billingAddrData[0].Billing_Street__c= String.valueOf(billingAddrWrapper.data[0].billingStreet);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].billingCity))){
                            billingAddrData[0].Billing_City__c= String.valueOf(billingAddrWrapper.data[0].billingCity);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].billingCountry))){
                            billingAddrData[0].BillingCountry__c= String.valueOf(billingAddrWrapper.data[0].billingCountry);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].billingState))){
                            billingAddrData[0].BillingState__c= String.valueOf(billingAddrWrapper.data[0].billingState);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].billingPostalCode))){
                            billingAddrData[0].Billing_Zip_Postal_Code__c= String.valueOf(billingAddrWrapper.data[0].billingPostalCode);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].gstn))){
                            billingAddrData[0].GSTN__c= String.valueOf(billingAddrWrapper.data[0].gstn);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].bvdId))){
                            billingAddrData[0].Billing_BvD_ID__c= String.valueOf(billingAddrWrapper.data[0].bvdId);
                        }
                        if(!String.isBlank(String.valueOf(billingAddrWrapper.data[0].billingcurrency))){
                            billingAddrData[0].CurrencyIsoCode= String.valueOf(billingAddrWrapper.data[0].billingcurrency);
                        }
                        update billingAddrData;
                        returnValue.StatusMessage= 'Billing Address Updated Successfully!';
                    }else{
                        returnValue.StatusMessage= 'Record not found';
                    }
                }else{
                    returnValue.StatusMessage= 'Please provide the Billing Address Id in request payload';
                }

            }catch(Exception ex){
                system.debug(ex.getMessage()+'----line no ===>>> '+ex.getLineNumber());
                ICRA_BillingAddress_Update_DataOne.ResponseWrapper returnValueEx= new ICRA_BillingAddress_Update_DataOne.ResponseWrapper();
                returnValueEx.StatusMessage= 'Some error occured while processing the request'+': '+ex.getMessage();
                return returnValueEx;
            }
        }
        return returnValue;
    }
    global class ResponseWrapper{
        //global Integer StatusCode;
        global String StatusMessage;
    }
}