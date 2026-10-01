public with sharing class ICRA_MultiApproval_OptyController {

    // Return pending approval opportunities for a given Account (for current user)
    @AuraEnabled(cacheable=true)
    public static List<OpportunityApprovalWrapper> getOpportunitiesForAccount(Id accountId){
        if (accountId == null) {
            return new List<OpportunityApprovalWrapper>();
        }

        // 1) Get Opportunities for the account
        List<Opportunity> opps = [
            SELECT Id, Name, StageName, RecordType.Name, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c,  
            Defer_Billing_or_Exit_Case__c, Approval_Process__c, LastModifiedDate, LastModifiedBy.Name, Account.OwnerId, Account.Business_Sector__r.Business_Head__r.Email,
            Team_Leader__c, VoD_in_crore__c, Size_to_be_rated_this_year_in_Cr_M__c, Rated_VOD__c, ASF_Final_Amount__c, Requested_Fee__c, Account.Name, Account.Owner.Email,
            Ready_for_Approval__c, Team_Leader__r.Email, Total_VoD_at_Instrument_Category__c, Instrument_type_1__c, Instrument_Category__c, Revised_Billing_End_Date__c, Revised_Billing_Status__c
            FROM Opportunity WHERE RecordType.Name='Surveillance' AND AccountId = :accountId AND (Defer_Billing_or_Exit_Case__c = 'To Be Billed' OR Defer_Billing_or_Exit_Case__c= 'Hold (Uncertain)')
        ];

        if (opps.isEmpty()) {
            return new List<OpportunityApprovalWrapper>();
        }

        // Build map for easy lookup
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opps);
        Set<Id> oppIds = oppMap.keySet();

        // 2) Get ProcessInstanceWorkitems for these Opportunities that are Pending and assigned to current user
        Set<Id> approverIds = new Set<Id>();
        approverIds.add(UserInfo.getUserId());

        for(User u : [SELECT Id FROM User WHERE DelegatedApproverId = :UserInfo.getUserId()]){
            approverIds.add(u.Id);
        }
        List<ProcessInstanceWorkitem> items = [SELECT Id, ProcessInstance.TargetObjectId, CreatedDate FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND ActorId IN :approverIds AND
         ProcessInstance.TargetObjectId IN :oppIds ORDER BY CreatedDate DESC];

        List<OpportunityApprovalWrapper> results = new List<OpportunityApprovalWrapper>();
        for (ProcessInstanceWorkitem wi : items) {
            Opportunity opp = oppMap.get(wi.ProcessInstance.TargetObjectId);
            if (opp != null) {
                //String lastModBy = (opp.LastModifiedBy != null) ? opp.LastModifiedBy.Name : null;
                results.add(new OpportunityApprovalWrapper(wi, opp));
            }
        }
        return results;
    }

    // Bulk approve/reject workitems. action must be valid (e.g. 'Approve' or 'Reject')
    @AuraEnabled
    public static void processApprovals(List<Id> workItemIds, String action, String comments){
        
        if (workItemIds == null || workItemIds.isEmpty()) return;
        action = (action == null) ? '' : action.trim();

        // 1) Query workitems; map workitem -> ProcessInstanceId & OppId
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, ActorId FROM ProcessInstanceWorkitem WHERE Id IN :workItemIds];

        Map<Id, Id> wiToProcessInstance = new Map<Id, Id>();
        Map<Id, Id> wiToOpp = new Map<Id, Id>();
        Set<Id> processInstanceIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        for (ProcessInstanceWorkitem wi : workItems){
            wiToProcessInstance.put(wi.Id, wi.ProcessInstanceId);
            wiToOpp.put(wi.Id, wi.ProcessInstance.TargetObjectId);
            processInstanceIds.add(wi.ProcessInstanceId);
            oppIds.add(wi.ProcessInstance.TargetObjectId);
        }
        System.Debug('---processInstanceIds--->' + processInstanceIds);
        // 2) Determine approver level for each ProcessInstance BEFORE processing
        // approvedSteps count: 0 => first approver, 1 => second approver
        Map<Id, Integer> processInstanceToApprovedCount = new Map<Id, Integer>();
        if (!processInstanceIds.isEmpty()){
			for (AggregateResult ar : [SELECT ProcessInstanceId pi, COUNT(Id) cnt FROM ProcessInstanceStep WHERE ProcessInstanceId IN :processInstanceIds AND StepStatus = 'Approved' GROUP BY ProcessInstanceId]){
				processInstanceToApprovedCount.put((Id)ar.get('pi'), (Integer)ar.get('cnt'));
			}

			// ensure missing entries default to 0
			for (Id pid : processInstanceIds) {
				if (!processInstanceToApprovedCount.containsKey(pid)) 
					processInstanceToApprovedCount.put(pid, 0);
			}
        }
        System.Debug('processInstanceToApprovedCount--->'+processInstanceToApprovedCount);

        // 3) Execute approvals / rejections
        // We'll try each workitem individually to ensure partial failures are manageable
        for (Id wiId : workItemIds){
            try {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(wiId);
                req.setAction(action);
                if (comments != null) req.setComments(comments);
                Approval.process(req);
            }catch (Exception ex){
                //log and continue - you may want to bubble up or collect failures for UI
                System.debug('Approval process failed for workItem ' + wiId + ' : ' + ex.getMessage());
            }
        }

        // 4) After processing, branch based on action to send consolidated emails
        if (action.equalsIgnoreCase('Approve')){
            // For approved items: some processInstances will have next pending workitems (next approvers)
            // while others will have finished (final approval) — handle both sets.
            handlePostApproveEmails(new List<Id>(oppIds), new List<Id>(workItemIds), new Set<Id>(processInstanceIds));
        }else if(action.equalsIgnoreCase('Reject')){
            // Send rejection emails to account owners (consolidated)
            User currentUser = [SELECT Id, Name, Email, UserRole.DeveloperName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            sendRejectionEmailToAccountOwners(new List<Id>(oppIds), comments, currentUser);
        }
    }

    // Wrapper for an Opportunity entry shown in UI
    public class OpportunityApprovalWrapper {
        @AuraEnabled public Id workItemId;
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String accountName;
        @AuraEnabled public String RecordTypeName;
        @AuraEnabled public String Instrument_Type_4;
        @AuraEnabled public Date BillingStartDate;
        @AuraEnabled public Date BillingEndDate;
        @AuraEnabled public String BillingStatus;
        @AuraEnabled public String oppUrl;
        @AuraEnabled public String accUrl;

        public OpportunityApprovalWrapper(ProcessInstanceWorkitem wi, Opportunity o){
            this.workItemId = wi.Id;
            this.Id = o.Id;
            this.Name = o.Name;
            this.accountName = o.Account.Name;
            this.RecordTypeName = o.RecordType.Name;
            this.Instrument_Type_4 = o.Instrument_Type_4__c;
            this.BillingStartDate = o.Billing_Start_Date__c;
            this.BillingEndDate = o.Billing_End_Date__c;
            this.BillingStatus = o.Defer_Billing_or_Exit_Case__c;
            this.oppUrl = '/' + o.Id;
            this.accUrl = '/' + o.AccountId;
        }
    }
    public static void handlePostApproveEmails(List<Id> oppIds, List<Id> processedWorkItemIds, /*String cboComments, */Set<Id> processInstanceIds){
        if (oppIds == null || oppIds.isEmpty()) return;
        
        // 1) For the processed workitems, get their ProcessInstanceIds (we already had mapping earlier; but requery to be safe)
        // Query pending workitems for these opportunities (these will be the next approvers)
        List<ProcessInstanceWorkitem> nextPending = [SELECT Id, ActorId, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending'
            AND ProcessInstance.TargetObjectId IN :oppIds AND Id NOT IN :processedWorkItemIds];

        // prepare grouping: nextApproverId -> oppIds
        Map<Id, List<Id>> approverToOppIds = new Map<Id, List<Id>>();
        Set<Id> nextOppIds = new Set<Id>();
        for (ProcessInstanceWorkitem wi : nextPending){
            if (wi.ActorId == null) continue;
            if (!approverToOppIds.containsKey(wi.ActorId)) approverToOppIds.put(wi.ActorId, new List<Id>());
            approverToOppIds.get(wi.ActorId).add(wi.ProcessInstance.TargetObjectId);
            nextOppIds.add(wi.ProcessInstance.TargetObjectId);
        }

        // 2) Opps that do NOT have any next pending workitems are final-approved opps
        Set<Id> oppsWithNext = nextOppIds;
        Set<Id> finalApprovedOpps = new Set<Id>();
        for (Id oid : oppIds){
            if (!oppsWithNext.contains(oid)){
                finalApprovedOpps.add(oid);
            }
        }

        // 3) Fetch Opportunity details needed for emails
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if (!oppIds.isEmpty()){
            for (Opportunity o : [SELECT Id, Name, StageName, RecordType.Name, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c,
                Defer_Billing_or_Exit_Case__c, Approval_Process__c, LastModifiedDate, LastModifiedBy.Name, Account.OwnerId, Account.Business_Sector__r.Business_Head__r.Email,
                Team_Leader__c, VoD_in_crore__c, Size_to_be_rated_this_year_in_Cr_M__c, Rated_VOD__c, ASF_Final_Amount__c, Requested_Fee__c, Account.Name, Account.Owner.Email,
                Ready_for_Approval__c, Team_Leader__r.Email, Total_VoD_at_Instrument_Category__c, Account.Owner.Name, Account.Classification__c, Owner.Email, Account.Business_Sector__r.Name,
                BD_Head__c, BD_Head__r.Email, Commercial_Head__c, Commercial_Head__r.Email, Account.CurrencyIsoCode, Instrument_type_1__c, Instrument_Category__c, Revised_Billing_End_Date__c, Revised_Billing_Status__c
                FROM Opportunity WHERE Id IN :oppIds ORDER BY CreatedDate DESC, Id DESC
            ]){
                oppMap.put(o.Id, o);
            }
        }

        // 4) Send consolidated email to each next approver (grouped)
        if (!approverToOppIds.isEmpty()){
            sendConsolidatedEmailToApprovers(approverToOppIds, oppMap, oppsWithNext, /*comments,*/ processInstanceIds);
        }

        // 5) Send consolidated final-approval email(s) to account owner(s) for finalApprovedOpps
        if (!finalApprovedOpps.isEmpty()){
            sendFinalApprovalEmailToAccountOwners(new List<Id>(finalApprovedOpps), oppMap/*, comments*/);
        }
    }    
        //      ============================
        // 4) Send consolidated email to next approvers (one email per approver) — uses FIRST_LEVEL_APPROVAL template
        // ============================
    public static void sendConsolidatedEmailToApprovers(Map<Id, List<Id>> approverToOppIds, Map<Id, Opportunity> oppMap, Set<Id> pendingOpps, Set<Id> processInstanceIds){
        if (oppMap.isEmpty()) return;
        String emailSubject = '';
        String emailbody = '';
        Set<String> ownerPreviousApproversCCSet = new Set<String>();
        List<String> ownerPreviousApproversCCList = new List<String>();
        Set<String> nextApproverToSet= new Set<String>();
        List<String> nextApproverToList= new List<String>();
        List<Opportunity> oppList = new List<Opportunity>(oppMap.values());
        Opportunity oppAtZero = oppList.size() > 0 ? oppList[0] : null;
        String accountId= oppAtZero.AccountId;
        String accountName= oppAtZero.Account.Name;
        String accountCurrency = oppAtZero.Account.CurrencyIsoCode;
        String hierarchyEmailCEO = [SELECT User_Name__c, Email__c FROM Hierarchy__mdt WHERE DeveloperName = 'CEO'].Email__c;
        User ceoUser = [SELECT Id, Name, Email FROM User WHERE Email = :hierarchyEmailCEO LIMIT 1];
        Map<Id, User> approverUsers = new Map<Id, User>([SELECT Id,Name,Email,DelegatedApproverId FROM User WHERE Id IN :approverToOppIds.keySet()]);
        User delegatedUser;

        for(Id approverId : approverToOppIds.keySet()){
            User approverUser = approverUsers.get(approverId);
            if(approverUser != null){
                nextApproverToSet.add(approverUser.Email);
                if(approverUser.DelegatedApproverId != null){
                    delegatedUser = [SELECT Email FROM User WHERE Id = :approverUser.DelegatedApproverId];
                    nextApproverToSet.add(delegatedUser.Email);
                }
            }            
        }

        nextApproverToList.addAll(nextApproverToSet);
        System.Debug('nextApproverToList_===>'+nextApproverToList);

        Map<Id, List<Opportunity>> parentToChildrenMap = new Map<Id, List<Opportunity>>();
        //List<Opportunity> noParentList = new List<Opportunity>();
        List<Opportunity> filteredList = new List<Opportunity>();   // To hold latest child opps and no parent opps: Surveillance opps only

        List<Opportunity> optyList = [SELECT Id, StageName, Defer_Billing_or_Exit_Case__c, VoD_in_crore__c, Size_to_be_rated_this_year_in_Cr_M__c, ASF_Final_Amount__c, Requested_Fee__c, Team_Leader__c,
                                     Account.Business_Sector__c, Account.Business_Sector__r.Business_Head__r.Email, Team_Leader__r.Email, Parent_Opportunity__c, CreatedDate, Instrument_Category__c,
                                     Mandate_ID__c, Name, RecordType.Name, Instrument_type_1__c, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c, Approval_Process__c, LastModifiedDate, 
                                     Billing_Year_FY__c, LastModifiedBy.Name, Account.OwnerId, Rated_VOD__c, Account.Name, Account.Owner.Email, Account.Owner.Name, Hold_Up_Untill__c, Reason__c, CurrencyDisplayFormula__c, Revised_Billing_End_Date__c, Revised_Billing_Status__c
                                     FROM Opportunity WHERE RecordType.Name='Surveillance' AND accountId = :accountId];

        List<Opportunity> currentFYchilds= ICRA_OpportunityApprovalController.getCurrentFYOpps(optyList);
        filteredList.addAll(currentFYchilds);            

        Boolean hasNonSF = false;
        Boolean hasSF = false;
        //Account Level Calculations
        List<Opportunity> oppts = oppMap.values();
        for(Opportunity opp : oppts){
            if(opp.Instrument_type_1__c == 'Non Structured Finance' && (opp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || opp.Defer_Billing_or_Exit_Case__c == 'Hold (Uncertain)')){
                hasNonSF = true;
            }else if(opp.Instrument_type_1__c == 'Structured Finance' && (opp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || opp.Defer_Billing_or_Exit_Case__c == 'Hold (Uncertain)')){
                hasSF = true;
            }
        }
        ICRA_OpportunityApprovalController.OpportunityValueCalculator values = new ICRA_OpportunityApprovalController.OpportunityValueCalculator(filteredList);
        Decimal vodSumSF = values.vodSumSF;
        Decimal vodSumNonSF = values.vodSumNonSF;
        Decimal asfSF = values.asfSF;
        Decimal asfNonSF = values.asfNonSF;

        List<Id> processInstanceIdsList = new List<Id>();
        processInstanceIdsList.addAll(processInstanceIds);

        List<ProcessInstanceStep> approvalSteps = [SELECT ProcessInstanceId,ActorId,Actor.Name,Comments,StepStatus,CreatedDate FROM ProcessInstanceStep WHERE ProcessInstanceId =:processInstanceIdsList[0]
            ORDER BY ProcessInstanceId, CreatedDate DESC];

        String commentsHistory = '';
        for(ProcessInstanceStep step : approvalSteps){
            /*if(String.isBlank(step.Comments))
                continue;*/

            commentsHistory +=
                '<b>' +
                'Comment from ' + step.Actor.Name +
                '</b> :  ';

            commentsHistory +=
                step.Comments +
                '<br/>';
        }
        
        List<Opportunity> opportList = [Select id, Name, Team_Leader__c, Team_Leader__r.Email, Account.Business_Sector__c, Account.Business_Sector__r.Business_Head__r.Email,
                                     StageName, Defer_Billing_or_Exit_Case__c, VoD_in_crore__c, Size_to_be_rated_this_year_in_Cr_M__c, ASF_Final_Amount__c, Requested_Fee__c, 
                                     Parent_Opportunity__c, CreatedDate, Instrument_Category__c, Mandate_ID__c, RecordType.Name, Instrument_Type_4__c, Billing_Start_Date__c, 
                                     Billing_End_Date__c, Approval_Process__c, LastModifiedDate, LastModifiedBy.Name, Account.OwnerId, Account.Name, Account.Owner.Email, 
                                     Account.Owner.Name, Hold_Up_Untill__c, Reason__c, Instrument_type_1__c, Revised_Billing_End_Date__c, Revised_Billing_Status__c
                                     from opportunity where accountId= :accountId AND RecordType.Name='Surveillance' AND Id IN: pendingOpps];

            System.Debug('Single Opportunity Team Leader Email-->'+opportList[0].Team_Leader__r.Email);
            System.Debug('Single Opportunity -->'+opportList[0].Name);

            for(Id approverId : approverToOppIds.keySet()){
                User approverUser = approverUsers.get(approverId);
                if(approverUser != null){ 
                    List<Id> filteredOptyIDList = approverToOppIds.get(approverId);
                    for(Id opportunityId: filteredOptyIDList){
                        Opportunity opty = oppMap.get(opportunityId);
                        String accountOwnerEmail = opty.Account.Owner.Email != null ? opty.Account.Owner.Email : '';
                        String tlEmail = opty.Team_Leader__r.Email != null ? opty.Team_Leader__r.Email : '';
                        String bhEmail = opty.BD_Head__r.Email != null ? opty.BD_Head__r.Email : '';
                        String cboEmail = opty.Commercial_Head__r.Email != null ? opty.Commercial_Head__r.Email : '';

                        if(approverId == opty.Team_Leader__c){
                            addEmail(ownerPreviousApproversCCSet, accountOwnerEmail);
                        }else if(approverId == opty.BD_Head__c){
                            addEmail(ownerPreviousApproversCCSet, accountOwnerEmail);
                            addEmail(ownerPreviousApproversCCSet, tlEmail);
                        }else if(approverId == opty.Commercial_Head__c){
                            addEmail(ownerPreviousApproversCCSet, accountOwnerEmail);
                            addEmail(ownerPreviousApproversCCSet, tlEmail);
                            addEmail(ownerPreviousApproversCCSet, bhEmail);
                        }else if(approverId == ceoUser.Id){
                            addEmail(ownerPreviousApproversCCSet, accountOwnerEmail);
                            addEmail(ownerPreviousApproversCCSet, tlEmail);
                            addEmail(ownerPreviousApproversCCSet, bhEmail);
                            addEmail(ownerPreviousApproversCCSet, cboEmail);
                        }
                    }
                }
            }

        if(!ownerPreviousApproversCCSet.isEmpty()){
            ownerPreviousApproversCCList.addAll(ownerPreviousApproversCCSet);      
        }

        // Build HTML table
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String finalUrl = baseUrl +'/lightning/n/Pending_Approvals?c__accountId=' + accountId;
        emailSubject = accountName+': Notification of Revision for Surveillance Opportunities ';
        emailbody = 'Dear Sir/Madam,<br/>';
        emailbody += '<br/>';
        emailbody += 'Requesting your approval for changes in the following opportunities based on the discussion with the client '+accountName+'.'+ '<br/>';
        emailbody += '<br/>';
        emailbody += ICRA_OpportunityApprovalController.buildAccountTable(accountName, vodSumSF, vodSumNonSF, asfSF, asfNonSF, hasNonSF, hasSF);
        emailBody += '<br/>';
        emailBody += +commentsHistory;                  //+UserInfo.getName()+' : '  + approverComments + '<br/>'; //cboName replace with UserInfo.getName()
        emailBody += '<br/>';
        emailbody += '<br/>';
        emailbody += 'Please find below the information for approval: ';
        emailbody += '<br/><br/>';

        Map<String, List<Opportunity>> categoryMap = new Map<String, List<Opportunity>>();
        for (Opportunity opp : opportList){
            String category = opp.Instrument_Category__c;
            if (!categoryMap.containsKey(category)){
                categoryMap.put(category, new List<Opportunity>());
            }
            categoryMap.get(category).add(opp);
        }

        String html = '';
        for(String category : categoryMap.keySet()){
            List<Opportunity> optyCatList = categoryMap.get(category);
            System.Debug('---filteredList--->' + filteredList);
            emailbody += ICRA_OpportunityApprovalController.buildTable(category, optyCatList, filteredList);
        }
        emailbody += 'To approve or reject please click on the following link: <a href="'+finalUrl+'">Approval Link</a><br/>';
        emailbody += '<br/>';
        emailbody += 'Thank you,<br/>';
        emailbody += '<br/>';
        emailbody += 'ICRA Limited';

        // Step 3: Send consolidated email to each next approver

        if(approverToOppIds.isEmpty()) return;
        for (Id approverId : approverToOppIds.keySet()){
            system.debug('### Sending Consolidated Email to Approver: ' + approverId);
            system.debug('### List of cc Users: ' + ownerPreviousApproversCCList);
            sendEmail(nextApproverToList, ownerPreviousApproversCCList, approverId, emailSubject, emailbody);
        }
    }

    public static void sendFinalApprovalEmailToAccountOwners(List<Id> finalOppIds, Map<Id, Opportunity> oppMap){
        if (finalOppIds == null || finalOppIds.isEmpty()) return;
        String emailSubject = '';
        String emailbody = '';
        List<Opportunity> oppList = new List<Opportunity>(oppMap.values());
        Opportunity oppAtZero = oppList.size() > 0 ? oppList[0] : null;
        String accountName= oppAtZero.Account.Name;
        String accountOwnerName= oppAtZero.Account.Owner.Name;
        String accountOwnerEmail= (oppAtZero.Account != null && oppAtZero.Account.Owner != null) ? oppAtZero.Account.Owner.Email : '';
        Integer rowCount = oppList.size();
        Boolean isFirstRow = true;

        emailSubject = 'Notification of Approval of Revision for Surveillance Opportunities in '+accountName+'.';
        emailbody = 'Hi '+accountOwnerName+',<br/>';
        emailbody += '<br/>';
        emailbody += 'The MD & CEO has approved the following surveillance.<br/>';
        emailbody += '<br/>';
        emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; text-align:center; width:100%;">';
        emailBody += '<tr>';
        emailBody += '<th colspan="1">Account Name</th>';
        emailBody += '<th colspan="1">Billing Start Date</th>';
        emailBody += '</tr>';

        for(Opportunity opp : oppList){
            emailBody += '<tr>';

            if (isFirstRow) {
                emailBody += '<td rowspan="' + rowCount + '">' + accountName + '</td>';
                isFirstRow = false;
            }

            emailBody += '<td>' + (opp.Billing_Start_Date__c != null ? opp.Billing_Start_Date__c.format() : '-') +'</td>';
            emailBody += '</tr>';
        }

        emailBody += '<br/>';
        emailBody += '</table>';
        emailbody += '<br/>';
        emailbody += 'Thank you,<br/>';
        emailbody += '<br/>';
        emailbody += 'ICRA Limited';

       // Group by account owner email
        //Map<String, List<Opportunity>> ownerToOpps = new Map<String, List<Opportunity>>();
        Set<String> approvedEmailccSet = new Set<String>();
        List<String> approvedEmailccList = new List<String>();
        for (Id oid : finalOppIds){
            Opportunity opty = oppMap.get(oid);
            String tlEmail = opty.Team_Leader__r.Email != null ? opty.Team_Leader__r.Email : '';
            String bhEmail = opty.BD_Head__r.Email != null ? opty.BD_Head__r.Email : '';
            String cboEmail = opty.Commercial_Head__r.Email != null ? opty.Commercial_Head__r.Email : '';
            if (opty == null) continue;
            approvedEmailccSet.add(tlEmail);
            approvedEmailccSet.add(bhEmail);
            approvedEmailccSet.add(cboEmail);
        }
        if(!approvedEmailccSet.isEmpty()){
            approvedEmailccList.addAll(approvedEmailccSet);
        }
        sendEmail(new List<String>{accountOwnerEmail}, approvedEmailccList, null, emailSubject, emailbody);
    }

    public static void sendRejectionEmailToAccountOwners(List<Id> oppIds, String comments, user currentUser){
        if (oppIds == null || oppIds.isEmpty()) return;
        String emailSubject = '';
        String emailbody = '';
        //String accountOwnerEmail = ''; 
        String currentUserRole = '';
        Set<String> ccEmailSet = new Set<String>();
        List<String> ccEmailList = new List<String>();
        List<Opportunity> oppList = [SELECT Id, Name, Account.Name, Account.Owner.Email, Account.Owner.Name, Team_Leader__r.Email, Account.Business_Sector__r.Business_Head__r.Email, BD_Head__r.Email, Commercial_Head__r.Email, Team_Leader__c, BD_Head__c, Commercial_Head__c FROM Opportunity WHERE Id IN :oppIds];

        String businessHeadEmail= oppList[0].Account.Business_Sector__r.Business_Head__r.Email;
        Opportunity oppAtZero = oppList.size() > 0 ? oppList[0] : null; 
        String accountName= oppAtZero.Account.Name; 
        String hierarchyEmailCEO = [SELECT User_Name__c, Email__c FROM Hierarchy__mdt WHERE DeveloperName = 'CEO'].Email__c;
        User ceoUser = [SELECT Id, Name, Email FROM User WHERE Email = :hierarchyEmailCEO LIMIT 1];
        String accountOwnerEmail = (oppAtZero.Account != null && oppAtZero.Account.Owner != null) ? oppAtZero.Account.Owner.Email : '';
        String accountOwnerName = (oppAtZero.Account != null && oppAtZero.Account.Owner != null) ? oppAtZero.Account.Owner.Name : '';
        Integer rowCount = oppList.size();
        Boolean isFirstRow = true;

        String roleName = currentUser.UserRole.DeveloperName;
        if(!String.isBlank(roleName) && roleName == 'Commercial_Head'){
            currentUserRole = 'Chief Business Officer';
        }else if(!String.isBlank(roleName) && roleName == 'MD_and_Group_CEO'){
            currentUserRole = 'MD & CEO';
        }else if(oppList[0].Team_Leader__c != null && oppList[0].Team_Leader__c == currentUser.Id){
            currentUserRole = 'Team Leader';
        }else if(oppList[0].BD_Head__c != null && oppList[0].BD_Head__c == currentUser.Id){
            currentUserRole = 'Business Sector Head';
        }else{
            currentUserRole = 'Business User';  //No Role Assigned
        }

        emailSubject = 'Notification of Rejection of Revision for Surveillance Opportunities in '+accountName+'.';  
        emailbody = 'Hi '+accountOwnerName+',<br/>';
        emailbody += '<br/>';
        emailbody += 'The '+currentUserRole+' has rejected the following Account with a reason provided by Reason: '+comments+'.<br/>';
        emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; text-align:center; width:100%;">';
        emailBody += '<tr>';
        emailBody += '<th colspan="1">Account Name</th>';
        emailBody += '<th colspan="1">Opportunity Name</th>';
        emailBody += '</tr>';

        for(Opportunity opp : oppList){
            emailBody += '<tr>';

            if (isFirstRow) {
                emailBody += '<td rowspan="' + rowCount + '">' + accountName + '</td>';
                isFirstRow = false;
            }

            emailBody += '<td>' + (opp.Name != null ? opp.Name : '-') +'</td>';
            emailBody += '</tr>';
        }

        emailBody += '<br/>';
        emailBody += '</table>';
        emailbody += '<br/>';
        emailbody += 'Please rectify the changes as per the comment provided by the ' +currentUserRole+ ' and resend the Opportunity.'; 
        emailbody += '<br/>';
        emailbody += 'Thank you,<br/>';
        emailbody += '<br/>';
        emailbody += 'ICRA Limited';

        //Map<String, List<Opportunity>> ownerToOpps = new Map<String, List<Opportunity>>();
        for(Opportunity opty : oppList){
            String oppId = opty.Id;
            if (String.isBlank(oppId)) continue;
            String tlEmail = opty.Team_Leader__r.Email != null ? opty.Team_Leader__r.Email : '';
            String bhEmail = opty.BD_Head__r.Email != null ? opty.BD_Head__r.Email : '';
            String cboEmail = opty.Commercial_Head__r.Email != null ? opty.Commercial_Head__r.Email : '';
            if (String.isBlank(accountOwnerEmail)) continue;
            if(currentUser.Id==opty.Team_Leader__c){
                ccEmailSet.add(bhEmail);
            }else if(currentUser.Id==opty.BD_Head__c){
                ccEmailSet.add(tlEmail);
            }else if(currentUser.Id==opty.Commercial_Head__c){
                ccEmailSet.add(tlEmail);
                ccEmailSet.add(bhEmail);
            }else if(currentUser.Id==ceoUser.Id){
                ccEmailSet.add(tlEmail);
                ccEmailSet.add(bhEmail);
                ccEmailSet.add(cboEmail);
            }
        }
        if(!ccEmailSet.isEmpty()){
            ccEmailList.addAll(ccEmailSet);      
        }
        sendEmail(new List<String>{accountOwnerEmail}, ccEmailList, null, emailSubject, emailbody);
    }

    public static void sendEmail(List<String> toAddresses, List<String> ccAddresses, Id targetObjectId, String subject, String htmlBody){
        if (toAddresses == null || toAddresses.isEmpty()) {
            return; // Nothing to send
        }
        OrgWideEmailAddress [] owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(owea[0].Id);
        email.setToAddresses(toAddresses);

        if (ccAddresses != null && !ccAddresses.isEmpty()) {
            email.setCcAddresses(ccAddresses);
        }
        if (targetObjectId != null) {
            email.setTargetObjectId(targetObjectId);
        }

        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
    }

	public static Opportunity getLatestOpp(List<Opportunity> opps){
		Opportunity latest = opps[0];
		for (Opportunity rec : opps) {
			if (rec.CreatedDate > latest.CreatedDate){
				latest = rec;
			}
		}
		return latest;
	}

    public static void addEmail(Set<String> emailSet, String email){
        if(!String.isBlank(email)){
            emailSet.add(email);
        }
    }
}