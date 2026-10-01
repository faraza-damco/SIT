@RestResource(urlMapping='/OpportunityUpdate/*')
global with sharing class ICRA_Opportunity_Update_DataOne {
    @HttpPost
    global static ICRA_Opportunity_Update_DataOne.ResponseWrapper opportunityUpdate(){
        String req= RestContext.request.requestBody.toString();
        ICRA_Opportunity_Update_DataOne.ResponseWrapper returnValue= new ICRA_Opportunity_Update_DataOne.ResponseWrapper();
        if(String.isNotBlank(req)){
            try{
                ICRA_Opportunity_Update_Wrapper oppWrapper= (ICRA_Opportunity_Update_Wrapper) JSON.deserialize(req, ICRA_Opportunity_Update_Wrapper.class);
                system.debug('Request Payload==>>'+oppWrapper);
                if(oppWrapper.data[0].mandate_Id!=''){
                    List<Opportunity> oppData= [select Mandate_ID__c, Execution_Status_new__c, Rated_Entity__c, PR_Date__c, Date_of_Communication__c, Date_of_Non_Acceptance_of_Rating__c, Analyst__c, Sector_Head__c, Co_Analyst__c, Group_Head__c, Quality_Analyst__c, Scheme_Trust_Name__c, Scheme_Trust_Check__c, WorkItem_Number__c from Opportunity where Mandate_ID__c=:oppWrapper.data[0].mandate_Id LIMIT 1];
                    if(oppData!=null && oppData.size()>0){
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].sow_status))){
                            oppData[0].Execution_Status_new__c= String.valueOf(oppWrapper.data[0].sow_status);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].ratedEntity))){
                            oppData[0].Rated_Entity__c= String.valueOf(oppWrapper.data[0].ratedEntity);     //Rated_Entitiy__c
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].pr_date))){
                            oppData[0].PR_Date__c= Date.valueOf(oppWrapper.data[0].pr_date);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].date_of_communication))){
                            oppData[0].Date_of_Communication__c= Date.valueOf(oppWrapper.data[0].date_of_communication);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].date_of_non_acceptance_of_rating))){
                            oppData[0].Date_of_Non_Acceptance_of_Rating__c= Date.valueOf(oppWrapper.data[0].date_of_non_acceptance_of_rating);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].analyst))){
                            oppData[0].Analyst__c= String.valueOf(oppWrapper.data[0].analyst);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].sector_head))){
                            oppData[0].Sector_Head__c= String.valueOf(oppWrapper.data[0].sector_head);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].co_analyst))){
                            oppData[0].Co_Analyst__c= String.valueOf(oppWrapper.data[0].co_analyst);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].group_head))){
                            oppData[0].Group_Head__c= String.valueOf(oppWrapper.data[0].group_head);
                        }
                    	if(!String.isBlank(String.valueOf(oppWrapper.data[0].quality_analyst))){
                            oppData[0].Quality_Analyst__c= String.valueOf(oppWrapper.data[0].quality_analyst);
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].workItemNumber))){
                            oppData[0].WorkItem_Number__c= String.valueOf(oppWrapper.data[0].workItemNumber);
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].scheme_trust))){
                            if(oppData[0].Scheme_Trust_Check__c){
                                oppData[0].Scheme_Trust_Check__c=false;
                            }
                            oppData[0].Scheme_Trust_Name__c= String.valueOf(oppWrapper.data[0].scheme_trust);
                        }
                        update oppData;
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].scheme_trust))){
                            oppData[0].Scheme_Trust_Check__c= true;
                        }
                        update oppData;
                        returnValue.StatusMessage= 'Opportunity Updated Successfully!';
                    }else{
                        returnValue.StatusMessage= 'Record not found';
                    }
                }else{
                    returnValue.StatusMessage= 'Please provide the Mandate Id in request payload';
                }

            }catch(Exception ex){
                system.debug(ex.getMessage()+'----line no ===>>> '+ex.getLineNumber());
                ICRA_Opportunity_Update_DataOne.ResponseWrapper returnValueEx= new ICRA_Opportunity_Update_DataOne.ResponseWrapper();
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