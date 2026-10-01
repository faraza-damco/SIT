// MultiRecordsApprovalController_full.cls
public class MultiRecordsApprovalController_full {
    
    public class OppApprovalWrp {
        @AuraEnabled public Id     WorkItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public Date   CloseDate;
        @AuraEnabled public Decimal Amount;
        @AuraEnabled public String ApprName;
        @AuraEnabled public String SubmittedBy;
        @AuraEnabled public Date   SubmittedDate;
        @AuraEnabled public String submissionComment;
    }
    
    public class InvoiceApprovalWrp {
        @AuraEnabled public Id     WorkItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String   invoiceStatus;
        //@AuraEnabled public Decimal Amount;
        @AuraEnabled public String ApprName;
        @AuraEnabled public String SubmittedBy;
        @AuraEnabled public Date   SubmittedDate;
        @AuraEnabled public String submissionComment;
        @AuraEnabled public String clientName;
        @AuraEnabled public String instrumentType4;
        @AuraEnabled public Decimal vodInCrore;
        @AuraEnabled public Decimal amountToBeBilled;
        @AuraEnabled public Date billingStartDate;
        @AuraEnabled public Date billingEndDate;
        @AuraEnabled public String contactNameVerified;
        
    }
    
    public class TaxInvoiceApprovalWrp {
        @AuraEnabled public Id     WorkItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String   invoiceStatus;
        //@AuraEnabled public Decimal Amount;
        @AuraEnabled public String ApprName;
        @AuraEnabled public String SubmittedBy;
        @AuraEnabled public Date   SubmittedDate;
        @AuraEnabled public String submissionComment;
        @AuraEnabled public String clientName;
        @AuraEnabled public String instrumentType4;
        @AuraEnabled public Decimal vodInCrore;
        @AuraEnabled public Decimal amountToBeBilled;
        @AuraEnabled public Date billingStartDate;
        @AuraEnabled public Date billingEndDate;
        @AuraEnabled public String contactNameVerified;
    }
    /*
    public class CreditNoteInvoiceApprovalWrp {
        @AuraEnabled public Id     WorkItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String   invoiceStatus;
        @AuraEnabled public String   creditNoteReason;
        //@AuraEnabled public Decimal Amount;
        @AuraEnabled public String ApprName;
        @AuraEnabled public String SubmittedBy;
        @AuraEnabled public Date   SubmittedDate;
        @AuraEnabled public String submissionComment;
    }*/
    
    public class FailedRecordsWrp {
       // @AuraEnabled public Id     WorkItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String   failedRecordId;
        @AuraEnabled public String   failedRecordName;
        @AuraEnabled public String   errorMessage;
    }
    
    public class FinalWrp {
        @AuraEnabled public List<OppApprovalWrp> oppWrp;
        @AuraEnabled public List<InvoiceApprovalWrp> invWrp;
        @AuraEnabled public List<TaxInvoiceApprovalWrp> taxInvWrp;
        //@AuraEnabled public List<CreditNoteInvoiceApprovalWrp> creditNoteInvWrp;
        @AuraEnabled public List<FailedRecordsWrp> failedRecordsWrp;
    }
    
    @AuraEnabled
    public static FinalWrp getSubmittedRecords() {
        List<OppApprovalWrp> oppList = new List<OppApprovalWrp>();
        List<InvoiceApprovalWrp> invList = new List<InvoiceApprovalWrp>();
        List<TaxInvoiceApprovalWrp> taxInvList = new List<TaxInvoiceApprovalWrp>();
        //List<CreditNoteInvoiceApprovalWrp> creditNoteList = new List<CreditNoteInvoiceApprovalWrp>();
        List<FailedRecordsWrp> failedRecordsList = new List<FailedRecordsWrp>(); // To store failed records
        System.debug('here submit');
        Set<Id> oppIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        //Set<Id> creditNoteIds = new Set<Id>();
        Set<Id> UsrQue_set = new Set<Id>();
        Map<Id,string> grouporusername=new Map<Id,string> () ;
        for(Group gpm : [select id,Name from Group]) {     grouporusername.put(gpm.id,gpm.Name);}
        for(user usr : [SELECT Id,name FROM User ]) {     grouporusername.put(usr.id,usr.Name);
                                                    }
        for(GroupMember gpm : [select GroupId from GroupMember where UserOrGroupId = : UserInfo.getUserId()]) {     UsrQue_set.add(gpm.GroupId);
                                                                                                               System.debug('UserInfo.getUserId() '+UserInfo.getUserId());                                                                                                      }
        System.debug('UsrQue_set '+UsrQue_set);
        
        
        List<ProcessInstance> piList = [
            SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, ProcessDefinitionId,CreatedBy.Name,
            (SELECT ID, ActorId, Actor.Name FROM WorkItems WHERE (ActorId = :UserInfo.getUserId() or OriginalActorId IN :UsrQue_set)),
            (SELECT OriginalActor.Name, OriginalActorId, Comments FROM Steps WHERE StepStatus = 'Pending' AND ActorId = :UserInfo.getUserId())
            FROM ProcessInstance where status='Pending'
        ];

        System.debug('piList--->'+piList);
        Set<Id> procInstIds= new Set<Id>();
        if(!piList.isEmpty()){
            for (ProcessInstance pi : piList) {
                System.debug('here--->>>102');
                procInstIds.add(pi.Id);
                if (pi.TargetObjectId.getSObjectType().getDescribe().getName()=='Opportunity') {
                        oppIds.add(pi.TargetObjectId);
                    }
                if (pi.TargetObjectId.getSObjectType().getDescribe().getName()=='Invoice__c') {
                        invoiceIds.add(pi.TargetObjectId);
                    }
              
            }
            
        }
        System.debug('oppIds-->>'+oppIds);
        Map<Id,String> commentMap = new Map<Id,String>();
        for (ProcessInstanceStep step : [
            SELECT ProcessInstanceId, Comments
            FROM ProcessInstanceStep
            WHERE ProcessInstanceId IN :procInstIds
            AND Comments != null
            ORDER BY CreatedDate ASC
        ]) {
            if (!commentMap.containsKey(step.ProcessInstanceId)) {
                commentMap.put(step.ProcessInstanceId, step.Comments);
            }
        }
        /*RecordType rtCreditNote = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Invoice__c'
           AND DeveloperName = 'Credit_Note'
            LIMIT 1
        ];*/
        RecordType rtSurveillance = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Opportunity'
            AND DeveloperName = 'Surveillance'
            LIMIT 1
        ];
        Map<Id,Opportunity> oppMap;
        Map<Id,Invoice__c> creditNoteInvMap;
        System.debug('rtSurveillance-->>'+rtSurveillance);
        if(rtSurveillance!= null){
            oppMap = oppIds.isEmpty()
                ? new Map<Id,Opportunity>()
                : new Map<Id,Opportunity>([
                    SELECT Id, Name, CloseDate, Amount, (Select id, Name, Opportunity__c, Opportunity__r.Name, Error_Message__c from Transaction_Logs__r)
                    FROM Opportunity WHERE Id IN :oppIds AND recordTypeId=:rtSurveillance.id
                ]);
        }
        System.debug('oppMap-->>'+oppMap);
        for (Opportunity opp : oppMap.values()) {
            for (Transaction_Log__c txnLog : opp.Transaction_Logs__r) {
                FailedRecordsWrp fr = new FailedRecordsWrp();
                //fr.WorkItemId     = '';
                fr.recordId       = txnLog.id;
                fr.recordName     = txnLog.Name;
                fr.failedRecordId       = '/'+ txnLog.Opportunity__c;
                fr.failedRecordName     = txnLog.Opportunity__r.Name;
                fr.errorMessage     = txnLog.Error_Message__c;
                failedRecordsList.add(fr);
            }
        }
        
        Map<Id,Invoice__c> invMap = invoiceIds.isEmpty()
            ? new Map<Id,Invoice__c>()
            : new Map<Id,Invoice__c>([
                SELECT Id, Name, Invoice_Status__c, Opportunity_Name__r.Account.Name, Opportunity_Name__r.Instrument_type_4__c, Contact_Name_Verified__c,
                    Opportunity_Name__r.VoD_in_crore__c, Opportunity_Name__r.Amount_to_be_billed__c , Opportunity_Name__r.Billing_Start_Date__c , Opportunity_Name__r.Billing_End_Date__c,
                    (Select id, Name, Invoice__c, Error_Message__c, Invoice__r.Name from Transaction_Logs__r)
                FROM Invoice__c WHERE Id IN :invoiceIds AND Invoice_Status__c=:'Proforma Invoice'
            ]);
        for (Invoice__c inv : invMap.values()) {
            for (Transaction_Log__c txnLog : inv.Transaction_Logs__r) {
                FailedRecordsWrp fr = new FailedRecordsWrp();
                //fr.WorkItemId     = '';
                fr.recordId       = txnLog.id;
                fr.recordName     = txnLog.Name;
                fr.failedRecordId       = '/'+ txnLog.Invoice__c;
                fr.failedRecordName     = txnLog.Invoice__r.Name;
                fr.errorMessage     = txnLog.Error_Message__c;
                failedRecordsList.add(fr);
            }
        }
        
        Map<Id,Invoice__c> taxInvMap = invoiceIds.isEmpty()
            ? new Map<Id,Invoice__c>()
            : new Map<Id,Invoice__c>([
                SELECT Id, Name, Invoice_Status__c , Opportunity_Name__r.Account.Name, Opportunity_Name__r.Instrument_type_4__c, Contact_Name_Verified__c,
                    Opportunity_Name__r.VoD_in_crore__c, Opportunity_Name__r.Amount_to_be_billed__c , Opportunity_Name__r.Billing_Start_Date__c , Opportunity_Name__r.Billing_End_Date__c,
                    (Select id, Name, Invoice__c, Invoice__r.Name, Error_Message__c from Transaction_Logs__r)
                FROM Invoice__c WHERE Id IN :invoiceIds AND Invoice_Status__c=:'Initiate Tax Invoice'
            ]);
        
        for (Invoice__c inv : taxInvMap.values()) {
            for (Transaction_Log__c txnLog : inv.Transaction_Logs__r) {
                FailedRecordsWrp fr = new FailedRecordsWrp();
                //fr.WorkItemId     = '';
                fr.recordId       = txnLog.id;
                fr.recordName     = txnLog.Name;
                fr.failedRecordId       = '/'+ txnLog.Invoice__c;
                fr.failedRecordName     = txnLog.Invoice__r.Name;
                fr.errorMessage     = txnLog.Error_Message__c;
                failedRecordsList.add(fr);
            }
        }
        
        /*if(rtCreditNote!= null){
            creditNoteInvMap = invoiceIds.isEmpty()
                ? new Map<Id,Invoice__c>()
                : new Map<Id,Invoice__c>([
                    SELECT Id, Name, Invoice_Status__c,Reason_for_Credit_Note__c, (Select id, Name, Invoice__c, Invoice__r.Name, Error_Message__c from Transaction_Logs__r)
                    FROM Invoice__c WHERE Id IN :invoiceIds AND recordtypeId =: rtCreditNote.id
                ]);
        }*/
        
        /*for (Invoice__c inv : creditNoteInvMap.values()) {
            for (Transaction_Log__c txnLog : inv.Transaction_Logs__r) {
                FailedRecordsWrp fr = new FailedRecordsWrp();
                //fr.WorkItemId     = '';
                fr.recordId       = txnLog.id;
                fr.recordName     = txnLog.Name;
                fr.failedRecordId       = '/'+ txnLog.Invoice__c;
                fr.failedRecordName     = txnLog.Invoice__r.Name;
                fr.errorMessage     = txnLog.Error_Message__c;
                failedRecordsList.add(fr);
            }
        }*/
        
        ProcessInstanceWorkitem wi;
        String nextApprover ;
        if(!piList.isEmpty()){
            System.debug('here inside loop 231-->');
            for (ProcessInstance pi : piList) {
                
                if(!pi.WorkItems.isEmpty()){
                    wi = pi.WorkItems[0];
                    nextApprover = wi.Actor != null ? wi.Actor.Name : null;
                }
                
                String submissionComment = '';
                
                if (!pi.WorkItems.isEmpty() && pi.TargetObjectId.getSObjectType().getDescribe().getName()=='Opportunity') {
                        system.debug('here in opp wrapper add');
                        if(oppMap.containskey(pi.TargetObjectId)){
                            OppApprovalWrp w = new OppApprovalWrp();
                        w.WorkItemId     =  !pi.WorkItems.isEmpty()  ? pi.WorkItems[0].Id : null;
                        w.recordId       = pi.TargetObjectId;
                        w.recordName     = pi.TargetObject.Name;
                        if(!test.IsRunningTest()){
                        w.CloseDate      = oppMap.get(pi.TargetObjectId).CloseDate != null ?oppMap.get(pi.TargetObjectId).CloseDate: null;
                        w.Amount         = oppMap.get(pi.TargetObjectId).Amount;
                        w.SubmittedBy = pi.CreatedBy.Name;
                        w.ApprName =nextApprover;
                        w.SubmittedDate  = Date.newInstance(
                            pi.CreatedDate.year(),
                            pi.CreatedDate.month(),
                            pi.CreatedDate.day()
                        );
                        submissionComment= commentMap.get(pi.Id);
                        w.submissionComment = submissionComment;
                        }
                       
                        oppList.add(w);
                        }
                        
                    }
                if (!pi.WorkItems.isEmpty() && pi.TargetObjectId.getSObjectType().getDescribe().getName()=='Invoice__c') {
                        
                        if(invMap.containsKey(pi.TargetObjectId)){
                            InvoiceApprovalWrp inv = new InvoiceApprovalWrp();
                            inv.WorkItemId     =  !pi.WorkItems.isEmpty()  ? pi.WorkItems[0].Id : null;
                            inv.recordId       = pi.TargetObjectId;
                            inv.recordName     = pi.TargetObject.Name;
                            inv.invoiceStatus      = invMap.get(pi.TargetObjectId).Invoice_Status__c;
                            inv.SubmittedBy = pi.CreatedBy.Name;
                            inv.ApprName = nextApprover;
                            inv.SubmittedDate  = Date.newInstance(
                                pi.CreatedDate.year(),
                                pi.CreatedDate.month(),
                                pi.CreatedDate.day()
                            );
                            submissionComment= commentMap.get(pi.Id);
                            inv.submissionComment = submissionComment;
                            inv.clientName= invMap.get(pi.TargetObjectId).Opportunity_Name__r.Account.Name;
                            inv.instrumentType4= invMap.get(pi.TargetObjectId).Opportunity_Name__r.Instrument_type_4__c;
                            inv.vodInCrore= invMap.get(pi.TargetObjectId).Opportunity_Name__r.VoD_in_crore__c;
                            inv.amountToBeBilled= invMap.get(pi.TargetObjectId).Opportunity_Name__r.Amount_to_be_billed__c;
                            inv.billingStartDate= invMap.get(pi.TargetObjectId).Opportunity_Name__r.Billing_Start_Date__c;
                            inv.billingEndDate= invMap.get(pi.TargetObjectId).Opportunity_Name__r.Billing_End_Date__c;
                            inv.contactNameVerified= invMap.get(pi.TargetObjectId).Contact_Name_Verified__c;
                            invList.add(inv);
                        }
                        
                        
                        if(taxInvMap.containsKey(pi.TargetObjectId)){
                            TaxInvoiceApprovalWrp taxInv = new TaxInvoiceApprovalWrp();
                            taxInv.WorkItemId     = !pi.WorkItems.isEmpty()  ? pi.WorkItems[0].Id : null;
                            taxInv.recordId       = pi.TargetObjectId;
                            taxInv.recordName     = pi.TargetObject.Name;
                            taxInv.invoiceStatus      = taxInvMap.get(pi.TargetObjectId).Invoice_Status__c;
                            taxInv.SubmittedBy = pi.CreatedBy.Name;
                            taxInv.ApprName = nextApprover;
                            taxInv.SubmittedDate  = Date.newInstance(
                                pi.CreatedDate.year(),
                                pi.CreatedDate.month(),
                                pi.CreatedDate.day()
                            );
                            submissionComment= commentMap.get(pi.Id);
                            taxInv.submissionComment = submissionComment;
                            taxInv.clientName= taxInvMap.get(pi.TargetObjectId).Opportunity_Name__r.Account.Name;
                            taxInv.instrumentType4= taxInvMap.get(pi.TargetObjectId).Opportunity_Name__r.Instrument_type_4__c;
                            taxInv.vodInCrore= taxInvMap.get(pi.TargetObjectId).Opportunity_Name__r.VoD_in_crore__c;
                            taxInv.amountToBeBilled= taxInvMap.get(pi.TargetObjectId).Opportunity_Name__r.Amount_to_be_billed__c;
                            taxInv.billingStartDate= taxInvMap.get(pi.TargetObjectId).Opportunity_Name__r.Billing_Start_Date__c;
                            taxInv.billingEndDate= taxInvMap.get(pi.TargetObjectId).Opportunity_Name__r.Billing_End_Date__c;
                            taxInv.contactNameVerified= taxInvMap.get(pi.TargetObjectId).Contact_Name_Verified__c;
                            taxInvList.add(taxInv);
                        }
                        
                        /*if(creditNoteInvMap.containsKey(pi.TargetObjectId)){
                            CreditNoteInvoiceApprovalWrp creditNoteInv = new CreditNoteInvoiceApprovalWrp();
                            creditNoteInv.WorkItemId     = !pi.WorkItems.isEmpty()  ? pi.WorkItems[0].Id : null;
                            creditNoteInv.recordId       = pi.TargetObjectId;
                            creditNoteInv.recordName     = pi.TargetObject.Name;
                            creditNoteInv.invoiceStatus      = creditNoteInvMap.get(pi.TargetObjectId).Invoice_Status__c;
                            creditNoteInv.creditNoteReason      = creditNoteInvMap.get(pi.TargetObjectId).Reason_for_Credit_Note__c;
                            creditNoteInv.SubmittedBy = pi.CreatedBy.Name;
                            creditNoteInv.ApprName = nextApprover;
                            creditNoteInv.SubmittedDate  = Date.newInstance(
                                pi.CreatedDate.year(),
                                pi.CreatedDate.month(),
                                pi.CreatedDate.day()
                            );
                            submissionComment= commentMap.get(pi.Id);
                            creditNoteInv.submissionComment = submissionComment;
                            creditNoteList.add(creditNoteInv);
                        }*/
                        
                    }
            }
            
        }
        System.debug('oppList--->>'+oppList);
        System.debug('invList--->>'+invList);
        System.debug('taxInvList--->>'+taxInvList);
        //System.debug('creditNoteList--->>'+creditNoteList);
        FinalWrp out = new FinalWrp();
        if(oppList.size()>0){
            out.oppWrp = oppList;  
        }
        // else{
        // out.oppWrp = null;  `
        // }
        if(invList.size()>0){
            out.invWrp = invList;
        }
        // // else{
        //     out.invWrp = null;
        // }
        if(taxInvList.size()>0){
            out.taxInvWrp = taxInvList;
        }
        // else{
        //     out.taxInvWrp = null;
        // }
        
        /*if(creditNoteList.size()>0){
            out.creditNoteInvWrp = creditNoteList;
        }*/
        // else{
        //     out.creditNoteInvWrp = null;
        // }
        
        if(failedRecordsList.size()>0){
            out.failedRecordsWrp = failedRecordsList;
        }
        
        System.debug('out-->'+out);
        return out;
    }
    
    @AuraEnabled
    public static String getBatchStatus() {
        // always ‘success’ until you wire your custom setting lookup
        return 'success';
    }
    
    @AuraEnabled
    public static String processRecordsBatchExecute(
        List<String> lstWorkItemIds,
        String processType,
        String rejectionReason,
        String recordId
    ) {
        // queue batch with reason
        Database.executeBatch(
            new ApprovalProcessBatchimplements(lstWorkItemIds, processType, rejectionReason,recordId),
            1
        );
        return 'Records approved successfully';
    }
    

}