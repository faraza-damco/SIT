public with sharing class ICRA_BulkRecallController{

    // Fetch opportunities pending approval for an account
    @AuraEnabled
    public static List<PendingApprovalWrapper> getPendingApprovalOpportunities(Id accountId){
        List<PendingApprovalWrapper> optyListPendingApproval = new List<PendingApprovalWrapper>();

        if(accountId == null){
            return optyListPendingApproval;
        }

        List<ProcessInstanceWorkitem> allWorkItems = [SELECT Id, ProcessInstanceId, ActorId, Actor.Name, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name,
            ProcessInstance.Status, ProcessInstance.CreatedDate FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Opportunity'];

        Set<Id> opportunityIds = new Set<Id>();
        for(ProcessInstanceWorkitem workItem : allWorkItems){
            if(workItem.ProcessInstance.TargetObjectId != null){
                opportunityIds.add(workItem.ProcessInstance.TargetObjectId);
            }
        }

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<Opportunity> pendingOpps = [SELECT Id, Name, AccountId, RecordType.Name, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c, Defer_Billing_or_Exit_Case__c FROM Opportunity WHERE RecordType.Name = 'Surveillance' AND Id IN :opportunityIds AND AccountId = :accountId];
        if(!pendingOpps.isEmpty()){
            for (Opportunity opp : pendingOpps){
                opportunityMap.put(opp.Id, opp);
            }
        }

        if(opportunityMap.isEmpty()){
            return optyListPendingApproval;
        }

        List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>();
        
        for(ProcessInstanceWorkitem wi : allWorkItems){
            if(opportunityMap.containsKey(wi.ProcessInstance.TargetObjectId)){
                workItems.add(wi);
            }
        }

        for(ProcessInstanceWorkitem wi : workItems){
            Opportunity opp = opportunityMap.get(wi.ProcessInstance.TargetObjectId);
            PendingApprovalWrapper wrapper = new PendingApprovalWrapper();
            wrapper.opportunityId = opp.Id;
            wrapper.opportunityName = opp.Name;
            wrapper.RecordTypeName = opp.RecordType.Name;
            wrapper.Instrument_Type_4 = opp.Instrument_Type_4__c;
            wrapper.BillingStartDate = opp.Billing_Start_Date__c;
            wrapper.BillingEndDate = opp.Billing_End_Date__c;
            wrapper.BillingStatus = opp.Defer_Billing_or_Exit_Case__c;
            wrapper.oppUrl = '/' + opp.Id;
            wrapper.pendingWithId = wi.ActorId;
            wrapper.pendingWith = wi.Actor.Name;
            wrapper.workItemId = wi.Id;
            wrapper.processInstanceId = wi.ProcessInstanceId;
            optyListPendingApproval.add(wrapper);
        }
        return optyListPendingApproval; 
    }

    // Submit all pending opportunities dynamically
    @AuraEnabled
    public static List<RecallResultWrapper> recallApproval(Id accountId, String comments){
        if (String.isBlank(comments)){
            throw new AuraHandledException('Recall Comments are Mandatory !');
        }

        //Get all the approval pending opportunities for the account
        List<ProcessInstanceWorkitem> allWorkItems = [SELECT Id, ProcessInstanceId, ActorId, Actor.Name, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name,
            ProcessInstance.Status, ProcessInstance.CreatedDate FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Opportunity'];

        Set<Id> opportunityIds = new Set<Id>();
        for(ProcessInstanceWorkitem workItem : allWorkItems){
            if(workItem.ProcessInstance.TargetObjectId != null){
                opportunityIds.add(workItem.ProcessInstance.TargetObjectId);
            }
        }

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<Opportunity> pendingOpps = [SELECT Id, Name, AccountId, RecordType.Name, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c, Defer_Billing_or_Exit_Case__c FROM Opportunity WHERE RecordType.Name = 'Surveillance' AND Id IN :opportunityIds AND AccountId = :accountId];
        if(!pendingOpps.isEmpty()){
            for (Opportunity opp : pendingOpps){
                opportunityMap.put(opp.Id, opp);
            }
        }

        List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>();
        List<Id> workItemIds = new List<Id>();
        for(ProcessInstanceWorkitem wi : allWorkItems){
            if(opportunityMap.containsKey(wi.ProcessInstance.TargetObjectId)){
                workItems.add(wi);
                workItemIds.add(wi.Id);
            }
        }
        if (workItems == null || workItems.isEmpty()){
            throw new AuraHandledException('No pending approval records found.');
        }

        List<RecallResultWrapper> results = new List<RecallResultWrapper>();
        for(Id workItemId : workItemIds){
            RecallResultWrapper resultWrapper = new RecallResultWrapper();
            resultWrapper.workItemId = workItemId;

            try{
                Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                request.setWorkitemId(workItemId);
                request.setAction('Removed');
                request.setComments(comments);

                Approval.ProcessResult processResult = Approval.process(request);

                resultWrapper.success = processResult.isSuccess();

                if(!processResult.isSuccess()){
                    resultWrapper.message = 'Recall failed.';
                }else{
                    resultWrapper.message = 'Recalled successfully.';
                }
            }catch(Exception e){
                resultWrapper.success = false;
                resultWrapper.message = e.getMessage();
            }

            results.add(resultWrapper);
        }
        return results;
    }

    /*public static void emailMessage(List<String> teamLeaderList, List<String> accountOwnerList, String emailSubject, String emailbody){
        OrgWideEmailAddress [] owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
        Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();
        emailRecord.setOrgWideEmailAddressId(owea[0].Id);
        emailRecord.setToAddresses(teamLeaderList);
        emailRecord.setCcAddresses(accountOwnerList);
        emailRecord.setSaveAsActivity(false); 
        emailRecord.setSubject(emailSubject);
        emailRecord.setHtmlBody(emailbody);
        emailSet.add(emailRecord);      
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.addAll(emailSet);
        if(!(emailList.isEmpty())){
            Messaging.sendEmail(emailList);
        }
    }*/

    public class PendingApprovalWrapper{
        @AuraEnabled public Id opportunityId;
        @AuraEnabled public String opportunityName;
        @AuraEnabled public String RecordTypeName;
        @AuraEnabled public String Instrument_Type_4;
        @AuraEnabled public Date BillingStartDate;
        @AuraEnabled public Date BillingEndDate;
        @AuraEnabled public String BillingStatus;
        @AuraEnabled public String oppUrl;
        @AuraEnabled public String pendingWithId;
        @AuraEnabled public String pendingWith;
        @AuraEnabled public String workItemId;
        @AuraEnabled public String processInstanceId;
        public PendingApprovalWrapper(){}
    }

    public class RecallResultWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }
}