@RestResource(urlMapping='/AccountUpdate/*')
global with sharing class ICRA_Account_Update_DataOne {
    @HttpPost
    global static ICRA_Account_Update_DataOne.ResponseWrapper accountUpdate(){
        String req= RestContext.request.requestBody.toString();
        ICRA_Account_Update_DataOne.ResponseWrapper returnValue= new ICRA_Account_Update_DataOne.ResponseWrapper();
        if(String.isNotBlank(req)){
            try{
                ICRA_Account_Update_Wrapper accWrapper= (ICRA_Account_Update_Wrapper) JSON.deserialize(req, ICRA_Account_Update_Wrapper.class);
                system.debug('Request Payload==>>'+accWrapper);
                // if(accWrapper.data<>null){
                //     for(ICRA_Account_Update_Wrapper.data data: accWrapper.data){

                //     }
                // }
                if(accWrapper.data[0].sf_account_id!='' /*&& accWrapper.data[0].orbis_id!=''*/){
                    List<Account> accData= [select id,name,Orbis_ID__c, /*bvd_connector__BvD_Id__c,*/Sector_L1__c,Sector_L2__c,Sector__c,Sector_L4__c,Sub_Sector__c,Classification__c from Account where id=:accWrapper.data[0].sf_account_id LIMIT 1];
                    if(accData!=null && accData.size()>0){
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].sectorL1))){
                            accData[0].Sector_L1__c= String.valueOf(accWrapper.data[0].sectorL1);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].sectorL2))){
                            accData[0].Sector_L2__c= String.valueOf(accWrapper.data[0].sectorL2);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].sectorL3))){
                            accData[0].Sector__c= String.valueOf(accWrapper.data[0].sectorL3);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].sectorL4))){
                            accData[0].Sector_L4__c= String.valueOf(accWrapper.data[0].sectorL4);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].sectorL5))){
                            accData[0].Sub_Sector__c= String.valueOf(accWrapper.data[0].sectorL5);
                        }
                        /*if(!String.isBlank(String.valueOf(accWrapper.data[0].bvd_id))){
                            accData[0].bvd_connector__BvD_Id__c= String.valueOf(accWrapper.data[0].bvd_id);
                        }*/
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].orbis_id))){
                            accData[0].Orbis_ID__c= String.valueOf(accWrapper.data[0].orbis_id);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].accountName))){
                            accData[0].Name= String.valueOf(accWrapper.data[0].accountName);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].group_name))){
                            accData[0].Group_Name__c= String.valueOf(accWrapper.data[0].group_name);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].phone))){
                            accData[0].Phone= String.valueOf(accWrapper.data[0].phone);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].website))){
                            accData[0].Website= String.valueOf(accWrapper.data[0].website);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].constitution_type))){
                            accData[0].Constitution_Type_Picklist__c= String.valueOf(accWrapper.data[0].constitution_type);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].md_text))){
                            accData[0].MD_text__c= String.valueOf(accWrapper.data[0].md_text);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].cfo_text))){
                            accData[0].CFO_text__c= String.valueOf(accWrapper.data[0].cfo_text);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].pan_number))){
                            accData[0].PAN_Number__c= String.valueOf(accWrapper.data[0].pan_number);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].tan_number))){
                            accData[0].TAN_Number__c= String.valueOf(accWrapper.data[0].tan_number);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].lei_number))){
                            accData[0].LEI_Number__c= String.valueOf(accWrapper.data[0].lei_number);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].cin_number))){
                            accData[0].CIN_Number__c= String.valueOf(accWrapper.data[0].cin_number);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].shippingCountry))){
                            accData[0].ShippingCountry= String.valueOf(accWrapper.data[0].shippingCountry);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].shippingStreet))){
                            accData[0].ShippingStreet= String.valueOf(accWrapper.data[0].shippingStreet);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].shippingCity))){
                            accData[0].ShippingCity= String.valueOf(accWrapper.data[0].shippingCity);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].shippingState))){
                            accData[0].ShippingState= String.valueOf(accWrapper.data[0].shippingState);
                        }
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].shippingPostalCode))){
                            accData[0].ShippingPostalCode= String.valueOf(accWrapper.data[0].shippingPostalCode);
                        } 
                        if(!String.isBlank(String.valueOf(accWrapper.data[0].businessClassification))){
                            accData[0].Classification__c= String.valueOf(accWrapper.data[0].businessClassification);
                        }
                        
                        update accData;
                        returnValue.StatusMessage= 'Account Updated Successfully!';
                    }else{
                        returnValue.StatusMessage= 'Record not found';

                    }
                }else{
                    returnValue.StatusMessage= 'Please provide Account Id';
                }


            }catch(Exception ex){
                system.debug(ex.getMessage()+'----line no ===>>> '+ex.getLineNumber());
                ICRA_Account_Update_DataOne.ResponseWrapper returnValueEx= new ICRA_Account_Update_DataOne.ResponseWrapper();
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