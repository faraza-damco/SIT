global with sharing class ApprovalProcessBatchimplements implements Database.Batchable<String> {
    private List<String> lstWorkItemIds;
    private String processType;
    private String rejectionReason;
    private String recordId;
    
    global ApprovalProcessBatchimplements(
        List<String> lstWorkItemIdsfrmbatch,
        String procType,
        String rejectionReason,
        String recordId
    ) {
        this.lstWorkItemIds  = lstWorkItemIdsfrmbatch;
        this.processType     = procType;
        this.rejectionReason = rejectionReason;
        this.recordId        = recordId;
    }
    
    global Iterable<String> start(Database.BatchableContext BC) {
        return lstWorkItemIds;
    }
    
    global void execute(Database.BatchableContext BC, List<String> workItemIds) {
        System.debug('workItemIds --> ' + workItemIds);
        String recordIds = this.recordId.replace('/', '');
        System.debug('this.recordId  --> ' + this.recordId );
        
        String comments = (processType == 'Reject') ? rejectionReason : 'Approved';
        
        List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
        Map<String, String> workItemToError = new Map<String, String>();
        Map<Id, Id> workItemToRecordId = new Map<Id, Id>();

        for(ProcessInstanceWorkitem wi : [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id IN :workItemIds]){
            workItemToRecordId.put(wi.Id, wi.ProcessInstance.TargetObjectId);
        }
        
        for (String id : workItemIds) {
            try {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(id);
                req.setAction(processType);
                req.setComments(comments);
                reqs.add(req);
            } catch (Exception ex) {
                workItemToError.put(id, ex.getMessage());
            }
        }
        System.debug('workItemToError --> ' + workItemToError);
        if (!reqs.isEmpty()) {
            try {
                Approval.ProcessResult[] results = Approval.process(reqs, false);
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        System.debug('here');
                        workItemToError.put(reqs[i].getWorkitemId(), results[i].getErrors()[0].getMessage());
                    }
                }
            } catch (Exception ex) {
                // fallback if batch fails entirely
                for (Approval.ProcessWorkitemRequest req : reqs) {
                    workItemToError.put(req.getWorkitemId(), ex.getMessage());
                }
            }
        }
        List<Id> oppIds = new List<Id>();
        List<Id> invIds = new List<Id>();
        System.Debug('recordIds--->'+recordIds);
        List<String> recordIdList = new List<String>();

        for(String val : recordIds.split(',')) {
            recordIdList.add(val.trim());
        }

        if (recordIdList != null && !recordIdList.isEmpty()) {
            for (Id recId : recordIdList) {
                String idStr = (String)recId;
                if (idStr.startsWith('006')) {
                    oppIds.add(recId);
                } else if (idStr.startsWith('a0E')) {
                    invIds.add(recId);
                }
            }
        }

        List<Transaction_Log__c> existingTransactionLogs = new List<Transaction_Log__c>();
        if (!oppIds.isEmpty() || !invIds.isEmpty()){
            existingTransactionLogs = [SELECT Id, Opportunity__c, Invoice__c FROM Transaction_Log__c WHERE (Opportunity__c IN :oppIds OR Invoice__c IN :invIds) and Operation__c = '' and Batch_Process__c = ''];
        } 

        Map<Id, Transaction_Log__c> recordIdToLog = new Map<Id, Transaction_Log__c>();

        for (Transaction_Log__c transLogRec : existingTransactionLogs) {
            if (transLogRec.Opportunity__c != null) {
                recordIdToLog.put(transLogRec.Opportunity__c, transLogRec);
            }
            if (transLogRec.Invoice__c != null) {
                recordIdToLog.put(transLogRec.Invoice__c, transLogRec);
            }
        }
        // Create Transaction Log records for failures
        List<Transaction_Log__c> logsToUpsert = new List<Transaction_Log__c>();
        //Map<Id, String> recordIdToError = new Map<Id, String>();

        for (String failedId : workItemToError.keySet()) {
            Id recordId = workItemToRecordId.get(failedId);
            String errorMsg = workItemToError.get(failedId);
            Transaction_Log__c log = new Transaction_Log__c();

            if (recordId != null) {
                // recordIdToError.put(recordId, errorMsg);
                String idStr = (String)recordId;
                if (idStr.startsWith('006')) {
                    log.Opportunity__c = recordId;
                } else if (idStr.startsWith('a0E')) {
                    log.Invoice__c = recordId;
                }
            }
            Transaction_Log__c existingLog = recordIdToLog.get(recordId);
            if (existingLog != null) {
                log.Id = existingLog.Id; // update
            }

            log.Error_Message__c = errorMsg;          
            logsToUpsert.add(log);
        }

        System.debug('logsToUpsert-->'+logsToUpsert);
        if (!logsToUpsert.isEmpty()) {
            try {
                upsert logsToUpsert;
                System.debug('after logsToUpsert-->'+logsToUpsert);
            } catch (Exception e) {
                System.debug('Failed to insert transaction logs: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // no-op
    }
}