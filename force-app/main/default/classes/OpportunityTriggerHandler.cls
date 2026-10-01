/**
* @description       : Utility class for Opportunity Triggers(OFacApproved,OpportunityTrigger)
* @author            : Damco Group
* @Created on        : 03-03-2022
<<<<<<< Updated upstream
**/

public class OpportunityTriggerHandler {
    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String ERROR = 'Name on Invoice Contact Role is mandatory before moving the opportunity to the next Stage'; //\'MPRA & SoW / Subscription Form Sent\'  or \'Checker Approval\'
    private static final String SURVEILLANCE = 'Surveillance';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String INTERNALCONTROL = 'Internal Control Approval';
    private static final String MPRA_Sent = 'MPRA & SoW / Subscription Form Sent';
    private static final String BILLEDERROR = 'Cannot update Stage on Billed Opportunities';
    private static final List<String> NONBILLED = new List<String>{'Proforma Invoice','QR and IRN - Failed','Canceled'};
    private static Set<Id> approvalRecordsProcessed = new Set<Id>();
        /**
        * @Method Name       : validateNameonInvoice
        * @description       : Marking 'Name on invoice' to be mandatory on opportunity stage 'Closed Won'
        **/
        public static void validateNameonInvoice(List<Opportunity> oppoList,Map<Id,Opportunity> oldOppoMap){ 
            try{
                List<Opportunity> opportunityList = new List<Opportunity>();
                for(Opportunity opty : oppoList){
                    if((opty.StageName == MPRA_Sent && oldOppoMap.get(opty.Id).StageName!=MPRA_Sent && opty.Business_Segment__c!='Research') || (opty.StageName == INTERNALCONTROL && oldOppoMap.get(opty.Id).StageName!=INTERNALCONTROL)){
                        opportunityList.add(opty);
                    }
                }
                if(opportunityList.size()>0){
                    Map<Id,List<OpportunityContactRole>> optyInvoiceContacts = new Map<Id,List<OpportunityContactRole>>();
                    for(OpportunityContactRole conRole : [SELECT Id,ContactId,OpportunityId
                                                          FROM OpportunityContactRole 
                                                          WHERE OpportunityId IN: opportunityList
                                                          AND Role = :INVOICEROLE]){
                                                              if(optyInvoiceContacts.containsKey(conRole.OpportunityId)){
                                                                  optyInvoiceContacts.get(conRole.OpportunityId).add(conRole);
                                                              }else{
                                                                  optyInvoiceContacts.put(conRole.OpportunityId,new List<OpportunityContactRole>{conRole});
                                                              }
                                                          }
                    for(Opportunity opty : opportunityList){
                        if(!(optyInvoiceContacts.size()>0) || !optyInvoiceContacts.containsKey(opty.Id) || (optyInvoiceContacts.containsKey(opty.Id) && (optyInvoiceContacts.get(opty.Id).size() != 1))){
                            opty.addError(ERROR);
                        }
                    }
                }
            }catch(Exception ex){
                System.debug('%%%Exception- '+ex.getMessage());
            }
        }
    
    /**
* @Method Name       : lockStageOnBilledOppty
* @description       : Do not allow changes to Stage on 'Closed Won' Billed opportunity
**/
    public static void lockStageOnBilledOppty(List<Opportunity> newOpportunities,Map<Id,Opportunity> oldOpportunities){
        try{
            List<Opportunity> opportunityList = new List<Opportunity>();
            for(Opportunity opty : newOpportunities){
                if(opty.StageName != CLOSEDSTAGE && oldOpportunities.get(opty.Id).StageName==CLOSEDSTAGE){
                    opportunityList.add(opty);
                }
            }
            if(opportunityList.size()>0){
                Set<Id> billedOpty = new Set<Id>();
                for(Invoice__c inv : [SELECT Id,Opportunity_Name__c FROM Invoice__c where Opportunity_Name__c IN :opportunityList AND Invoice_Status__c NOT IN :NONBILLED]){
                    billedOpty.add(inv.Opportunity_Name__c);
                }
                for(Opportunity opty : opportunityList){
                    if(billedOpty.contains(opty.Id)){
                        opty.addError(BILLEDERROR);
                    }
                }
            }
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }
    /**
* @Method Name       : createContactRoles
* @description       : To clone Opportunity Contact Roles into Rollong opportunities
**/
    public static void createContactRoles(List<Opportunity> opportunityList){
        try{
            //Id surveillanceRecID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SURVEILLANCE).getRecordTypeId();
            Set<Id> parentOptyIds = new Set<Id>();
            for(Opportunity opty : opportunityList){
                if(opty.Parent_Opportunity__c!=null ){
                    parentOptyIds.add(opty.Parent_Opportunity__c);                   
                }
            }
            if(parentOptyIds.size()>0){
                Map<Id,List<OpportunityContactRole>> optyContactRoleMap = new Map<Id,List<OpportunityContactRole>>();
                Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
                for(OpportunityContactRole optyContactRole : [SELECT Id,Role,ContactId,OpportunityId,IsPrimary 
                                                              FROM OpportunityContactRole 
                                                              WHERE OpportunityId IN :parentOptyIds])
                {
                    if(!optyContactRoleMap.containsKey(optyContactRole.OpportunityId)){
                        optyContactRoleMap.put(optyContactRole.OpportunityId,new List<OpportunityContactRole>());
                    }
                    optyContactRoleMap.get(optyContactRole.OpportunityId).add(optyContactRole);
                    
                }
                if(optyContactRoleMap.size()>0){
                    List<OpportunityContactRole> optyConRolesToInsert = new List<OpportunityContactRole>();
                    for(Opportunity opty : opportunityList){
                        if(optyContactRoleMap.containsKey(opty.Parent_Opportunity__c)){
                            for(OpportunityContactRole parentRole : optyContactRoleMap.get(opty.Parent_Opportunity__c)){ 
                                if((parentRole.Role!='MPRA/SOW' && parentRole.Role!='Proposal Primary Contact') && /*parentRole.Opportunity*/opty.RecordTypeId == oppRecordTypeId ){
                                    OpportunityContactRole tempRole = parentRole.clone(false,false,false,false);
                                    tempRole.OpportunityId = opty.Id;
                                    tempRole.Rollover_Check__c = true;
                                    optyConRolesToInsert.add(tempRole);
                                }
                            }
                        }
                    }
                    if(optyConRolesToInsert.size()>0){
                        Database.Insert(optyConRolesToInsert,false);
                    }
                }
            }
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }
    public static void proposalContactRequired(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        Set<Id> optyIds= oldMap.keyset();
        Set<String> roles= new Set<String>();
        Map<Id,OpportunityContactRole> mapOfIdVsOpportunityContactRole= new Map<Id,OpportunityContactRole>([select id, OpportunityId,Role from OpportunityContactRole where OpportunityId IN: optyIds]);
        if(mapOfIdVsOpportunityContactRole.size()>0){
            for(OpportunityContactRole optConRole: mapOfIdVsOpportunityContactRole.values()){
                roles.add(optConRole.Role);
            }
            for(Id key: optyIds){
                Opportunity oldOpty= oldMap.get(key);
                Opportunity newOpty= newMap.get(key);
                if(oldOpty.stageName=='Discount Approved' && newOpty.stageName=='Proposal Submission'){
                    if(!roles.contains('Proposal Primary Contact')){
                        Trigger.new[0].addError('There must be atleast one Contact Role with role as Proposal Primary Contact');
                    }
                }
            }
        }else if(roles.isEmpty()){
            for(Id key: optyIds){
                Opportunity oldOpty= oldMap.get(key);
                Opportunity newOpty= newMap.get(key);
                if(oldOpty.stageName=='Discount Approved' && newOpty.stageName=='Proposal Submission'){
                    Trigger.new[0].addError('There must be atleast one Contact Role with role as Proposal Primary Contact');
                }
            }
        }
        
    }
    public static void changeMinimumASF(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        Set<Id> optyIds= oldMap.keyset();
        Set<Id> branchIds = new Set<Id>();
        for(Opportunity opp : newMap.values()){
            Opportunity oldOpp = oldMap.get(opp.Id);
            if (opp.Opp_ICRA_Branch__c != null){
                branchIds.add(opp.Opp_ICRA_Branch__c);
            }
        }
        Map<Id, Branch__c> branchMap = new Map<Id, Branch__c>([SELECT Id, Finance_Email_ID_User__c FROM Branch__c WHERE Id IN :branchIds]);

        for(Id key: optyIds){
            Opportunity oldOpty= oldMap.get(key);
            Opportunity newOpty= newMap.get(key);
            if(oldOpty.ASF_Agreement_with_Client__c=='In BPS' && newOpty.ASF_Agreement_with_Client__c=='In Absolute'){
                newOpty.Minimum_ASF__c=null;
            }
            if(oldOpty.StageName!='Internal Control Approval' && newOpty.StageName=='Internal Control Approval' && oldOpty.Update_Opportunity_Checker__c==false){
                newOpty.Update_Opportunity_Checker__c= true;
            }
            if((oldOpty.Instrument_type_4__c=='Mutual Fund Rating' || oldOpty.Instrument_type_4__c=='Security Receipts' || oldOpty.Instrument_type_4__c=='AIF' || oldOpty.Instrument_type_4__c=='Pass Through Certificates') && (newOpty.Instrument_type_4__c!='Mutual Fund Rating' && newOpty.Instrument_type_4__c!='Security Receipts' && newOpty.Instrument_type_4__c!='AIF' && newOpty.Instrument_type_4__c!='Pass Through Certificates') || (oldOpty.Instrument_type_4__c!='Pass Through Certificates' && newOpty.Instrument_type_4__c=='Pass Through Certificates')){
                system.debug('Scheme Name==>>'+'Old:'+oldOpty.Instrument_type_4__c+'New:'+newOpty.Instrument_type_4__c);
                newOpty.Scheme_Trust_Check__c=false;
                newOpty.Scheme_Trust_Name__c= '';
            }
            if(oldOpty.Surveillance_Fee_Revision_Maximum_new__c=='Other' && newOpty.Surveillance_Fee_Revision_Maximum_new__c!='Other'){
                newOpty.Other__c=null;
            }
            if((newOpty.StageName=='Negotiation' && ((oldOpty.Proposed_Rating_Fee__c!=null && newOpty.Proposed_Rating_Fee__c==null) || (oldOpty.Proposed_Surveillance_Fee__c!=null && newOpty.Proposed_Surveillance_Fee__c==null))) || (oldOpty.Instrument_type_1__c <> newOpty.Instrument_type_1__c) || (oldOpty.Instrument_type_2__c <> newOpty.Instrument_type_2__c) || (oldOpty.Instrument_type_3__c <> newOpty.Instrument_type_3__c) || (oldOpty.Instrument_type_4__c <> newOpty.Instrument_type_4__c) /*(oldOpty.Proposed_Rating_Fee__c!=null || oldOpty.Proposed_Surveillance_Fee__c!=null) && (newOpty.Proposed_Rating_Fee__c==null || newOpty.Proposed_Surveillance_Fee__c==null)*/){
                if(oldOpty.Pricing_Auto_Approved__c){
                    newOpty.Pricing_Auto_Approved__c=false;
                }
                newOpty.Pricing_Not_Auto_Approved__c=false;
                newOpty.Proposed_Rating_Fee__c=null;
                newOpty.Proposed_Surveillance_Fee__c=null;
                newOpty.Deviation_IRF_Percent__c=null;
                newOpty.Deviation_ASF_Percent__c=null;
                newOpty.Annual_Surveillance_Fee_as_per_Framework__c=null;    
                newOpty.Target_Fee_IRF__c=null;    
                newOpty.Pricing_Approved_by_Business_Head__c=false;    
                newOpty.Pricing_Approved_by_Commercial_Head__c=false;    
                newOpty.Pricing_Approved_by_CEO__c=false;  
                newOpty.Minimum_Deviation_PA__c=null;
                newOpty.Maximum_Deviation_PA__c=null;
                newOpty.BD_Head_Approval_PA__c=false;
                newOpty.CBO_Approval_PA__c=false;
                newOpty.MD_CEO_Approval_PA__c=false;
            }
            if(oldOpty.Instrument_type_4__c=='Monitoring Activity' && newOpty.Instrument_type_4__c!='Monitoring Activity'){
                newOpty.Bypass_Validation__c=true;
                newOpty.Billing_Start_Date__c=null;
                newOpty.Billing_End_date__c=null;
            }
            
            
            if(newOpty.Defer_Billing_or_Exit_Case__c != oldOpty.Defer_Billing_or_Exit_Case__c) {
                newOpty.Prior_Billing_Status__c = oldOpty.Defer_Billing_or_Exit_Case__c;
            }
            if((newOpty.Billing_Approval_Status__c != oldOpty.Billing_Approval_Status__c) &&  newOpty.Billing_Approval_Status__c =='Rejected') {
                newOpty.Defer_Billing_or_Exit_Case__c = oldOpty.Prior_Billing_Status__c;
            }

            if(newOpty.Opp_ICRA_Branch__c!=null && oldOpty.StageName!='Closed Won' && oldOpty.StageName!='Closed Lost' && (oldOpty.Finance_Team__c==null || (String.ValueOf(oldOpty.Finance_Team__c)<>String.ValueOf(branchMap.get(oldOpty.Opp_ICRA_Branch__c).Finance_Email_ID_User__c) && oldOpty.Finance_Team__c!=null))){
                newOpty.Finance_Team__c= branchMap.get(newOpty.Opp_ICRA_Branch__c).Finance_Email_ID_User__c;
            }
        }
    }
    
    public static void checkerRejectionReason(List<Opportunity> OppList, Map<Id,Opportunity> oldMap){
        Map<Id, Opportunity> mapOfIDvsOpportunity = new Map<Id, Opportunity>{};
            for(Opportunity Opp: OppList){
                //Opportunity oldOpp = System.Trigger.oldMap.get(Opp.Id);
                Opportunity oldOpp = oldMap.get(Opp.Id);
                if(oldOpp.Approval_Status__c != 'Rejected' && Opp.Approval_Status__c == 'Rejected'){ 
                    mapOfIDvsOpportunity.put(Opp.Id, Opp);  
                }
            }
        
        if(!mapOfIDvsOpportunity.isEmpty()){
            List<Id> processInstanceIds = new List<Id>{};
                for(Opportunity Oppo : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE ID IN :mapOfIDvsOpportunity.keySet()]){
                    processInstanceIds.add(Oppo.ProcessInstances[0].Id);
                }
            
            for(ProcessInstance pi : [SELECT TargetObjectId, (SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 ) FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC]){                   
                if((pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0)){
                    mapOfIDvsOpportunity.get(pi.TargetObjectId).addError(
                        'Rejection Reason is Mandatory while Rejecting a Record');
                }
            }  
        }
    }
      // This methid creates the records in cstom Approval object 
    Public static void CreateApprovalRecords(List<Opportunity>newList, map<Id,Opportunity>oldMap){

        Set<Id> changedOppIds = new Set<Id>();
        for (Opportunity opp : newList){
            if (approvalRecordsProcessed.contains(opp.Id)){
                continue;
            }

            Opportunity oldOpp = oldMap.get(opp.Id);
            if(
                oldOpp != null && oldOpp.Approval_Status__c != opp.Approval_Status__c){
                changedOppIds.add(opp.Id);
            }
        }

        if(changedOppIds.isEmpty()){
            return;
        }

        approvalRecordsProcessed.addAll(changedOppIds);

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Name, Approval_Status__c, Opportunity_Checker__r.Name, Account.Name, MPRA_SoW_Reference_Number_iflow__c FROM Opportunity WHERE Id IN :changedOppIds]);
        List<ProcessInstance> processInstances = [SELECT Id, Status,LastActorId, TargetObjectId,CompletedDate, CreatedDate,SubmittedBy.Name, (SELECT Id, StepStatus, Comments, ActorId, Actor.Name, CreatedDate,OriginalActor.Name,ProcessInstanceId  FROM Steps ORDER BY CreatedDate DESC)
                                  FROM ProcessInstance  WHERE TargetObjectId IN :changedOppIds AND ProcessDefinition.Name='Checker Approval' ORDER BY CreatedDate DESC];
        
        Map<Id, ProcessInstance> latestPIByOpp = new Map<Id, ProcessInstance>();
        for (ProcessInstance pi : processInstances){
            if (!latestPIByOpp.containsKey(pi.TargetObjectId)){
                latestPIByOpp.put(pi.TargetObjectId, pi);
            }
        }
        Map<String, Approval__c> approvalByProcessInstance = new Map<String, Approval__c>();
        for (Approval__c app : [SELECT Id,Name,Opportunity__c,Approval_Comments__c,ProcessInstanceId__c,Approval_Status__c,Approver__c,Original_Approver__c,CreatedDate,Submitted_Date__c,Completed_Date__c FROM Approval__c
            WHERE Opportunity__c IN :changedOppIds
        ]){
            if (app.ProcessInstanceId__c != null){
                approvalByProcessInstance.put(app.ProcessInstanceId__c, app);
            }
        }
        List<Approval__c> approvalList = new List<Approval__c>();

        for (ProcessInstance pi : latestPIByOpp.values()){
            Opportunity opp = oppMap.get(pi.TargetObjectId);
            if(opp == null){
                continue;
            }

            if (pi.Steps != null && !pi.Steps.isEmpty()){
                ProcessInstanceStep ps = pi.Steps[0];
                Approval__c appr;
                if(approvalByProcessInstance.containsKey(ps.ProcessInstanceId)){
                    appr = approvalByProcessInstance.get(ps.ProcessInstanceId);
                }else{
                    appr = new Approval__c();
                }
                appr.Opportunity__c = opp.Id;
                appr.Approval_Comments__c = ps.Comments;
                appr.Approval_Status__c = ps.StepStatus;
                appr.Approver__c = ps.Actor != null ? ps.Actor.Name : null;
                appr.Original_Approver__c = ps.OriginalActor != null ? ps.OriginalActor.Name : null;
                appr.ProcessInstanceId__c = ps.ProcessInstanceId;
                appr.Completed_Date__c = pi.CompletedDate;
                appr.MPRA_SoW_Reference_Number__c = opp.MPRA_SoW_Reference_Number_iflow__c;
                appr.Account_Name__c = opp.Account != null ? opp.Account.Name : null;
                approvalList.add(appr);
            }
            else{
                Approval__c appr = new Approval__c();
                appr.Opportunity__c = opp.Id;
                appr.Approval_Status__c = pi.Status == 'Started' ? 'Pending' : pi.Status;
                appr.Original_Approver__c = opp.Opportunity_Checker__r != null ? opp.Opportunity_Checker__r.Name : null;
                appr.Submitted_By__c = pi.SubmittedBy != null ? pi.SubmittedBy.Name : null;
                appr.Submitted_Date__c = pi.CreatedDate;
                appr.ProcessInstanceId__c = pi.Id;
                appr.MPRA_SoW_Reference_Number__c = opp.MPRA_SoW_Reference_Number_iflow__c;
                appr.Account_Name__c = opp.Account != null ? opp.Account.Name : null;
                approvalList.add(appr);
            }
        }

        system.debug('approvalList'+approvalList); 
        if (!approvalList.isEmpty()) {
            upsert approvalList;
        }     
    }
}