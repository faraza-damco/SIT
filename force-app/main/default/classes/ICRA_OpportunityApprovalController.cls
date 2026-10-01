public with sharing class ICRA_OpportunityApprovalController {

    // Fetch opportunities pending approval for an account
    @AuraEnabled
    public static OpportunityApprovalResponse getOpportunitiesForApproval(Id accountId){
        OpportunityApprovalResponse  optyListForApproval = new OpportunityApprovalResponse();
        System.Debug('AccountId--->'+accountId);
        Id currentUserId = UserInfo.getUserId();
        String hierarchyEmailCEO = [SELECT User_Name__c, Email__c FROM Hierarchy__mdt WHERE DeveloperName = 'CEO'].Email__c;
        User ceoUser = [SELECT Id, Name, Email, IsActive FROM User WHERE Email = :hierarchyEmailCEO LIMIT 1];
        Set<String> blankUsers = new Set<String>();
        Set<String> inactiveUsers = new Set<String>();
        Integer currentMonth = Date.today().month();
        Integer currentYear  = Date.today().year();
        String sturucturedFinance = 'Structured Finance';
        String nonSturucturedFinance = 'Non Structured Finance';
        for(Opportunity opp : [SELECT Id, Name, StageName, RecordType.Name, Instrument_Type_1__c, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c,  Defer_Billing_or_Exit_Case__c, Approval_Process__c, 
        LastModifiedDate, LastModifiedBy.Name,BD_Head__c, Team_Leader__c, Commercial_Head__c, BD_Head__r.IsActive, BD_Head__r.Name, BD_Head__r.Email, Team_Leader__r.IsActive, Team_Leader__r.Name, Team_Leader__r.Email,
        Commercial_Head__r.IsActive, Commercial_Head__r.Name, Commercial_Head__r.Email, Revised_Billing_Status__c, Revised_Billing_End_Date__c FROM Opportunity WHERE RecordType.Name='Surveillance' AND AccountId = :accountId 
        AND Ready_for_Approval__c = true AND (Defer_Billing_or_Exit_Case__c = 'To Be Billed' OR Defer_Billing_or_Exit_Case__c= 'Hold (Uncertain)') 
        /*AND (Instrument_Type_1__c = : nonSturucturedFinance OR (Instrument_Type_1__c = : sturucturedFinance AND CALENDAR_YEAR(Billing_Start_Date__c) <= :currentYear AND CALENDAR_MONTH(Billing_Start_Date__c) <= :currentMonth))*/
        AND OwnerId = :currentUserId]){
            optyListForApproval.opportunities.add(new OpportunityWrapper(opp));

            //need to use this to check the inactive approver and add to the list of inactive approvers and display the same on UI

            if(opp.BD_Head__c == null && !blankUsers.contains('Business Head')){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        'Business Head (Missing)',
                        '',
                        'Business Head'
                    )
                );
                blankUsers.add('Business Head');
            }

            if(opp.Team_Leader__c == null && !blankUsers.contains('Team Leader')){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        'Team Leader (Missing)',
                        '',
                        'Team Leader'
                    )
                );
                blankUsers.add('Team Leader');
            }

            if(opp.Commercial_Head__c == null && !blankUsers.contains('Commercial Head')){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        'Commercial Head (Missing)',
                        '',
                        'Commercial Head'
                    )
                );
                blankUsers.add('Commercial Head');
            }

            if (opp.BD_Head__c != null && !opp.BD_Head__r.IsActive && !inactiveUsers.contains(opp.BD_Head__c)){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        opp.BD_Head__r.Name+' (Inactive)',
                        opp.BD_Head__r.Email,
                        'Business Head'
                    )
                );
            }

            if (opp.Team_Leader__c != null && !opp.Team_Leader__r.IsActive && !inactiveUsers.contains(opp.Team_Leader__c)){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        opp.Team_Leader__r.Name+' (Inactive)',
                        opp.Team_Leader__r.Email,
                        'Team Leader'
                    )
                );
            }

            if (opp.Commercial_Head__c != null && !opp.Commercial_Head__r.IsActive && !inactiveUsers.contains(opp.Commercial_Head__c)){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        opp.Commercial_Head__r.Name+' (Inactive)',
                        opp.Commercial_Head__r.Email,
                        'Commercial Head'
                    )
                );
            }

            if (ceoUser != null && !ceoUser.IsActive){
                optyListForApproval.inactiveApprovers.add(
                    new InactiveApproverWrapper(
                        ceoUser.Name+' (Inactive)',
                        ceoUser.Email,
                        'MD & CEO'
                    )
                );
            }
        }
        System.Debug('optyListForApproval--->'+optyListForApproval);
        return optyListForApproval;
    }

    // Submit all pending opportunities dynamically
    @AuraEnabled
    public static void submitForApproval(Id accountId, String comments){
        String emailSubject = '';
        String emailbody = '';
        Set<String> teamLeaderSet = new Set<String>();
        List<String> teamLeaderList = new List<String>();
        Set<String> accountOwnerSet= new Set<String>();
        List<String> accountOwnerList= new List<String>();
        Integer currentMonth = Date.today().month();
        Integer currentYear  = Date.today().year();

        if (String.isBlank(comments)){
            throw new AuraHandledException('Comments are required before submission.');
        }

        // Get all opportunities that need submission
        List<Opportunity> opps = [SELECT Id, Name, StageName, RecordType.Name, Instrument_type_1__c, Instrument_Type_4__c, Billing_Start_Date__c, Billing_End_Date__c,
        Defer_Billing_or_Exit_Case__c, Approval_Process__c, LastModifiedDate, LastModifiedBy.Name, Account.OwnerId, Account.Business_Sector__r.Business_Head__r.Email,
        Team_Leader__c, VoD_in_crore__c, Size_to_be_rated_this_year_in_Cr_M__c, Rated_VOD__c, ASF_Final_Amount__c, Requested_Fee__c, Account.Name, Account.Owner.Email, Revised_Billing_End_Date__c,
        Ready_for_Approval__c, Team_Leader__r.Email, Total_VoD_at_Instrument_Category__c, Account.Owner.Name,Parent_Opportunity__c,CreatedDate, Instrument_Category__c, Revised_Billing_Status__c,
        Mandate_ID__c, Hold_Up_Untill__c, Reason__c, Account.CurrencyIsoCode, Billing_Year_FY__c FROM Opportunity WHERE RecordType.Name='Surveillance' AND AccountId = :accountId];

        if (opps.isEmpty()) return;
        Opportunity oppAtZero = opps.size() > 0 ? opps[0] : null;
        String accountName= oppAtZero.Account.Name;
        String accountOwnerName= oppAtZero.Account.Owner.Name;
        String businessHeadEmail= oppAtZero.Account.Business_Sector__r.Business_Head__r.Email;
        String accountCurrency= oppAtZero.Account.CurrencyIsoCode;
        Id teamLeaderId = oppAtZero.Team_Leader__c;
        Map<Id, User> teamLeaderMap = new Map<Id, User>([SELECT Id,Name,Email,DelegatedApproverId FROM User WHERE Id = :teamLeaderId]);
        User delegatedUser;
        List<Opportunity> filteredList = new List<Opportunity>();   // To hold surveillance opps under an account where Billing Start Date = current Financial Year (it may have a opps where category may or may not be same)
        List<Opportunity> currentFYchilds= getCurrentFYOpps(opps);
        filteredList.addAll(currentFYchilds);

        System.Debug('---filteredList--->' + filteredList);
        Boolean hasNonSF = false;
        Boolean hasSF = false;
        //Account Level Calculations
        for(Opportunity opp : opps){
            if(opp.Instrument_type_1__c == 'Non Structured Finance' && opp.Ready_for_Approval__c == true && (opp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || opp.Defer_Billing_or_Exit_Case__c == 'Hold (Uncertain)')){
                hasNonSF = true;
            }else if(opp.Instrument_type_1__c == 'Structured Finance' && opp.Ready_for_Approval__c == true && (opp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || opp.Defer_Billing_or_Exit_Case__c == 'Hold (Uncertain)')) {
                hasSF = true;
            }
        }
        OpportunityValueCalculator values = new OpportunityValueCalculator(filteredList);
        Decimal vodSumSF = values.vodSumSF;
        Decimal vodSumNonSF = values.vodSumNonSF;
        Decimal asfSF = values.asfSF;
        Decimal asfNonSF = values.asfNonSF;

        // Fetch metadata mappings
        Map<String, String> approvalMap = new Map<String, String>();
        for (Opportunity_Approval_Mapping__mdt m : [SELECT Approval_Process__c, Approval_Process_API_Name__c FROM Opportunity_Approval_Mapping__mdt]){
            approvalMap.put(m.Approval_Process__c, m.Approval_Process_API_Name__c);
        }

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String finalUrl = baseUrl +'/lightning/n/Pending_Approvals?c__accountId=' + accountId;
        emailSubject = accountName+': Notification of Revision for Surveillance Opportunities ';
        emailbody = 'Dear Sir/Madam,<br/>';
        emailbody += '<br/>';
        emailbody += 'Requesting your approval for changes in the following opportunities based on the discussion with the client '+accountName+'.'+ '<br/>';
        emailbody += '<br/>';
        emailbody += buildAccountTable(accountName, vodSumSF, vodSumNonSF, asfSF, asfNonSF, hasNonSF, hasSF);
        emailBody += '<br/>';
        emailBody += '<b>Comment from '+accountOwnerName+':</b> ' + comments + '<br/>';
        emailbody += '<br/>';
        emailbody += 'Please find below the information for approval:  <br/>';
        emailBody += '<br/>';

        Map<String, List<Opportunity>> categoryMap = new Map<String, List<Opportunity>>();
        for (Opportunity opp : opps){
            if(opp.Ready_for_Approval__c == true && (opp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || opp.Defer_Billing_or_Exit_Case__c == 'Hold (Uncertain)') /*&& (opty.Instrument_type_1__c == 'Non Structured Finance' || (opty.Instrument_type_1__c == 'Structured Finance' && opty.Billing_Start_Date__c.year() <= Date.today().year() && opty.Billing_Start_Date__c.month() <= Date.today().month()))*/){
                String category = opp.Instrument_Category__c;
                if (!categoryMap.containsKey(category)){
                    categoryMap.put(category, new List<Opportunity>());
                }
                categoryMap.get(category).add(opp);
            }
        }

        String html = '';
        for(String category : categoryMap.keySet()){
            List<Opportunity> optyList = categoryMap.get(category); // Get the list of surveillance opportunities for the current category under an account
            html += buildTable(category, optyList, filteredList);

            for(Opportunity opty : optyList){
                String processName = approvalMap.get(opty.Approval_Process__c);
                if (String.isBlank(processName)) continue; // no mapping → skip
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(opty.Id);
                    req.setComments(comments);
                    req.setProcessDefinitionNameOrId(processName);

                    Approval.ProcessResult result = Approval.process(req);
                    if (result.isSuccess()){
                        teamLeaderSet.add(opty.Team_Leader__c);
                        User approverUser = teamLeaderMap.get(opty.Team_Leader__c);
                        if(approverUser != null){
                            if(approverUser.DelegatedApproverId != null){
                                delegatedUser = [SELECT Email FROM User WHERE Id = :approverUser.DelegatedApproverId];
                                teamLeaderSet.add(delegatedUser.Email);
                            }
                        }
                        accountOwnerSet.add(opty.Account.Owner.Email);                  
                    }
            }
        }

        emailbody += html;
        emailbody += 'To approve or reject please click on the following link: <a href="'+finalUrl+'">Approval Link</a><br/>';
        emailbody += '<br/>';
        emailbody += 'Thank you,<br/>';
        emailbody += '<br/>';
        emailbody += 'ICRA Limited';

        if(!teamLeaderSet.isEmpty()){
            teamLeaderList.addAll(teamLeaderSet);      
        }

        if(!accountOwnerSet.isEmpty()){
            accountOwnerList.addAll(accountOwnerSet);
            emailMessage(teamLeaderList, accountOwnerList, emailSubject, emailbody);
        }
    }

    public static void emailMessage(List<String> teamLeaderList, List<String> accountOwnerList, String emailSubject, String emailbody){
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
    }

    public static String getFinancialYear(){
        Integer currentYear = Date.today().year();
        String financialYear;

        if(Date.today().month() >= 4){
            financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
        }else{
            financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
        }
        System.Debug('---financialYear--->' + financialYear);
        return financialYear;
    }

    public static List<Opportunity> getCurrentFYOpps(List<Opportunity> opps){
        Integer currentYear = Date.today().year();
        String financialYear = getFinancialYear();
        System.Debug('---financialYear--->' + financialYear);
        List<Opportunity> currentFYOpps = new List<Opportunity>();

		for(Opportunity rec : opps){
			if (rec.Billing_Year_FY__c == financialYear){
				currentFYOpps.add(rec);
			}
		}
        System.Debug('---currentFYOpps--->' + currentFYOpps);
		return currentFYOpps;
	}

    public static String buildTable(String category, List<Opportunity> oppList, List<Opportunity> filteredList){
        if(oppList == null || oppList.isEmpty()) return '';

        List<Opportunity> categoryFilteredListUnderAcc = new List<Opportunity>();   // to hold the current FY opps with the same category under the account
        if(filteredList != null && !filteredList.isEmpty()){
            for(Opportunity opp : filteredList){
                if(opp.Instrument_Category__c == category){
                    categoryFilteredListUnderAcc.add(opp);
                }
            }
        }

        System.Debug('categoryFilteredListUnderAcc--->' + categoryFilteredListUnderAcc.size());
        //calculate the values within this method so that the logic is not required to be re-written in a separate
        Decimal totalPreVoDatInstrCategoryDecimal = 0;
        Decimal totalPreASFatInstrCategoryDecimal = 0;
        Decimal totalPostVoDatInstrCategoryDecimal = 0;
        Decimal totalPostASFatInstrCategoryDecimal = 0;
        String totalPreVoDatInstrCategory = '-';
        String totalPreASFatInstrCategory = '-';
        String totalPostVoDatInstrCategory = '-';
        String totalPostASFatInstrCategory = '-';

        if(categoryFilteredListUnderAcc != null && !categoryFilteredListUnderAcc.isEmpty()){
            for(Opportunity opp : categoryFilteredListUnderAcc){
                Boolean conditionsMetNonSF = (opp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || opp.Defer_Billing_or_Exit_Case__c == 'Issuer Not Cooperating' || opp.Defer_Billing_or_Exit_Case__c == 'Hold (Uncertain)') && opp.Instrument_Category__c == category && opp.Instrument_type_1__c == 'Non Structured Finance';                
                if(conditionsMetNonSF){
                    totalPreVoDatInstrCategoryDecimal += opp.VoD_in_crore__c != null ? opp.VoD_in_crore__c : 0;
                    totalPreASFatInstrCategoryDecimal += opp.ASF_Final_Amount__c != null ? opp.ASF_Final_Amount__c : 0;
                    totalPostVoDatInstrCategoryDecimal += opp.Size_to_be_rated_this_year_in_Cr_M__c != null ? opp.Size_to_be_rated_this_year_in_Cr_M__c : (opp.VoD_in_crore__c != null ? opp.VoD_in_crore__c : 0);
                    totalPostASFatInstrCategoryDecimal += opp.Requested_Fee__c != null ? opp.Requested_Fee__c : (opp.ASF_Final_Amount__c != null ? opp.ASF_Final_Amount__c : 0);
                }
            }
            totalPreVoDatInstrCategory = totalPreVoDatInstrCategoryDecimal != 0 ? String.valueOf(totalPreVoDatInstrCategoryDecimal.setScale(2, RoundingMode.HALF_UP)) : '-';
            totalPreASFatInstrCategory = totalPreASFatInstrCategoryDecimal != 0 ? String.valueOf(totalPreASFatInstrCategoryDecimal.setScale(2, RoundingMode.HALF_UP)) : '-';
            totalPostVoDatInstrCategory = totalPostVoDatInstrCategoryDecimal != 0 ? String.valueOf(totalPostVoDatInstrCategoryDecimal.setScale(2, RoundingMode.HALF_UP)) : '-';
            totalPostASFatInstrCategory = totalPostASFatInstrCategoryDecimal != 0 ? String.valueOf(totalPostASFatInstrCategoryDecimal.setScale(2, RoundingMode.HALF_UP)) : '-';
        }

        List<Map<String,String>> rowConfigs = new List<Map<String,String>>{

            new Map<String,String>{
                'label' => 'Instrument Category',
                'type'  => 'FIELD',
                'field' => 'Instrument_Category__c'
            },

            new Map<String,String>{
                'label' => 'Total Pre-Reduction VoD for Opportunity',
                'type'  => 'FIELD',
                'field' => 'VoD_in_crore__c',
                'decimalPlaces' => '2'
            },

            new Map<String,String>{
                'label' => 'Total VoD for Opportunity post reduction',
                'type'  => 'FIELD',  //CALCULATED
                'field' => 'Size_to_be_rated_this_year_in_Cr_M__c',   //POST_VOD
                'decimalPlaces' => '2',
                'blankValue' => '-'
            },

            new Map<String,String>{
                'label' => 'Pre-Reduction ASF for Opportunity',
                'type'  => 'FIELD',
                'field' => 'ASF_Final_Amount__c',
                'decimalPlaces' => '2'
            },
            
            new Map<String,String>{
                'label' => 'Post Reduction ASF for Opportunity',
                'type'  => 'FIELD', //CALCULATED
                'field' => 'Requested_Fee__c',   //POST_ASF
                'decimalPlaces' => '2',
                'blankValue' => '-'
            },
            
            new Map<String,String>{
                'label' => '% VoD Reduction for the Opportunity',
                'type'  => 'CALCULATED',
                'field' => 'VoD_REDUCTION_LOGIC'
            },
            
            new Map<String,String>{
                'label' => '% ASF Reduction for the Opportunity',
                'type'  => 'CALCULATED',
                'field' => 'ASF_REDUCTION_LOGIC'
            },
            
            new Map<String,String>{
                'label' => 'Proportionate Reduction',
                'type'  => 'CALCULATED',
                'field' => 'PROPORTIONATE_REDUCTION_LOGIC'
            },

            new Map<String,String>{
                'label' => 'Total Pre-Reduction VoD for Instrument Category',
                'type'  => 'TotalPreVoDatInstrCategory',
                'field' => ''
            },

            new Map<String,String>{
                'label' => 'Total VoD for Instrument Category post reduction',
                'type'  => 'TotalPostVoDatInstrCategory',
                'field' => ''
            },

            new Map<String,String>{
                'label' => 'Total Pre-Reduction ASF for the Instrument Category',
                'type'  => 'TotalPreASFatInstrCategory',
                'field' => ''
            },

            new Map<String,String>{
                'label' => 'Total ASF post reduction for the Instrument Category',
                'type'  => 'TotalPostASFatInstrCategory',
                'field' => ''
            },

            new Map<String,String>{
                'label' => 'Billing Start Date',
                'type'  => 'FIELD',
                'field' => 'Billing_Start_Date__c'
            },
            
            new Map<String,String>{
                'label' => 'Billing End Date',
                'type'  => 'FIELD',
                'field' => 'Billing_End_date__c'
            },

            new Map<String,String>{
                'label' => 'Revised Billing End Date',
                'type'  => 'FIELD',
                'field' => 'Revised_Billing_End_Date__c',
                'blankValue' => '-'
            },
            
            new Map<String,String>{
                'label' => 'Revised Billing Status (for Approval)',
                'type'  => 'FIELD',
                'field' => 'Revised_Billing_Status__c'
            },
            
            new Map<String,String>{
                'label' => 'Date of Hold Till',
                'type'  => 'FIELD',
                'field' => 'Hold_Up_Untill__c',
                'blankValue' => 'NA'
            },
            
            new Map<String,String>{
                'label' => 'Reason',
                'type'  => 'FIELD',
                'field' => 'Reason__c',
                'blankValue' => 'NA'
            }
        };
        String table='';
        Integer totalColumns = oppList.size() + 1;
        String baseUrlTable = URL.getOrgDomainUrl().toExternalForm();
        table += '<table border="1" cellspacing="0" cellpadding="4">';
        //Merged Header
        table += '<tr>';
        table += '<th colspan="' + totalColumns + '">';
        table += 'Case for Revision '+category;
        table += '</th>';
        table += '</tr>';
        //Opportunity Name Row
        table += '<tr>';
        table += '<td style="text-align: center;"><b>Mandate ID</b></td>';
        for(Opportunity opp : oppList){
            table += '<td><a href="' + baseUrlTable + '/' + opp.Id + '">' + opp.Mandate_ID__c + '</a></td>';
        }
        table += '</tr>';

        for(Map<String,String> rowConfig : rowConfigs){
            if(rowConfig.get('type') == 'FIELD'){
                table += buildRow(rowConfig.get('label'),
                    oppList,
                    rowConfig.get('field'),
                    rowConfig.get('blankValue'),
                    rowConfig.get('decimalPlaces')
                );
            }else{
                if(rowConfig.get('type') == 'CALCULATED'){
                    table += buildCalculatedRow(rowConfig.get('label'),
                        oppList,
                        rowConfig.get('field')
                    );
                }else if(rowConfig.get('type') == 'TotalPreVoDatInstrCategory'){
                    table += '<tr>';
                    table += '<td style="text-align: center;"><b>' + rowConfig.get('label') + '</b></td>';
                    for(Opportunity opp : oppList){
                        table += '<td style="text-align: left;">' + totalPreVoDatInstrCategory + '</td>';
                    }
                    table += '</tr>';  
                }else if(rowConfig.get('type') == 'TotalPostVoDatInstrCategory'){
                    table += '<tr>';
                    table += '<td style="text-align: center;"><b>' + rowConfig.get('label') + '</b></td>';
                    for(Opportunity opp : oppList){
                        table += '<td style="text-align: left;">' + totalPostVoDatInstrCategory + '</td>';
                    }
                    table += '</tr>';  
                }else if(rowConfig.get('type') == 'TotalPreASFatInstrCategory'){
                    table += '<tr>';
                    table += '<td style="text-align: center;"><b>' + rowConfig.get('label') + '</b></td>';
                    for(Opportunity opp : oppList){
                        table += '<td style="text-align: left;">' + totalPreASFatInstrCategory + '</td>';
                    }
                    table += '</tr>';  
                }else if(rowConfig.get('type') == 'TotalPostASFatInstrCategory'){
                    table += '<tr>';
                    table += '<td style="text-align: center;"><b>' + rowConfig.get('label') + '</b></td>';
                    for(Opportunity opp : oppList){
                        table += '<td style="text-align: left;">' + totalPostASFatInstrCategory + '</td>';
                    }
                    table += '</tr>';  
                }               
            }
        }

        table += '</table><br/><br/>';
        return table;
    }

    public static String buildRow(String label, List<Opportunity> oppList, String fieldApi, String blankValue, String decimalPlaces){
        String row = '';
        row += '<tr>';
        row += '<td style="text-align: center;"><b>' + label + '</b></td>';
        for(Opportunity opp : oppList){
        String displayValue = '';
        Object value = opp.get(fieldApi);
        if (value != null){
            if(value instanceof Date){
                displayValue = ((Date)value).format();
            }else if(value instanceof Decimal && decimalPlaces != null){
                Decimal decimalValue = (Decimal)value;
                Integer scale = Integer.valueOf(decimalPlaces);
                displayValue = String.valueOf(decimalValue.setScale(scale));
            }else{
                displayValue = String.valueOf(value);
            }
        }else if(blankValue != null){
            displayValue = blankValue;
        }
            row += '<td style="text-align: left;">' + displayValue + '</td>';
        }
        row += '</tr>';
        return row;
    }

    public static String buildCalculatedRow(String label, List<Opportunity> oppList, String key){
        System.Debug('---buildCalculatedRow--->' + key);
        String row = '';
        row += '<tr>';
        row += '<td style="text-align: center;"><b>' + label + '</b></td>';
        for(Opportunity opp : oppList){
        String value = '';
            switch on key{
                when 'VoD_REDUCTION_LOGIC'{
                    value = calculateVoDReduction(opp);
                }

                when 'ASF_REDUCTION_LOGIC'{
                    value = calculateASFReduction(opp);
                }

                when 'PROPORTIONATE_REDUCTION_LOGIC'{
                    value = calculateProportionateReduction(opp);
                }

                when else{
                    value = '';
                }
            }
            row += '<td style="text-align: left;">' + value + '</td>';
        }
        row += '</tr>';
        return row;
    }

    public static String calculateVoDReduction(Opportunity opp){
        Decimal preVoD = opp.VoD_in_crore__c != null ? opp.VoD_in_crore__c : 0;
        Decimal postVoD = opp.Size_to_be_rated_this_year_in_Cr_M__c != null ? opp.Size_to_be_rated_this_year_in_Cr_M__c : (opp.VoD_in_crore__c != null ? opp.VoD_in_crore__c : 0);
        Decimal revisedRatingVoD = opp.Size_to_be_rated_this_year_in_Cr_M__c != null ? opp.Size_to_be_rated_this_year_in_Cr_M__c : null;
        Decimal vodReduction;
        if(preVoD > 0 && revisedRatingVoD != null){
            vodReduction = ((preVoD - postVoD) / preVoD) * 100;
        }

        System.debug('---calculateVoDReduction--->' + vodReduction);

        if(vodReduction == null){
            return '-';
        }else{
            return String.valueOf(vodReduction.setScale(2, RoundingMode.HALF_UP)) + '%';
        }
    }

    public static String calculateASFReduction(Opportunity opp){
        Decimal preASF = opp.ASF_Final_Amount__c != null ? opp.ASF_Final_Amount__c : 0;
        Decimal postASF = opp.Requested_Fee__c != null ? opp.Requested_Fee__c : (opp.ASF_Final_Amount__c != null ? opp.ASF_Final_Amount__c : 0);
        Decimal revisedSurveillanceFee = opp.Requested_Fee__c != null ? opp.Requested_Fee__c : null;
        Decimal asfReduction;
        if(preASF > 0 && revisedSurveillanceFee != null){
            asfReduction = ((preASF - postASF) / preASF) * 100;
        }

        System.debug('---calculateASFReduction--->' + asfReduction);

        if(asfReduction == null){
            return '-';
        }else{
            return String.valueOf(asfReduction.setScale(2, RoundingMode.HALF_UP)) + '%';
        }

    }

    public static String calculateProportionateReduction(Opportunity opp){
        Decimal preVoD = opp.VoD_in_crore__c != null ? opp.VoD_in_crore__c : 0;
        Decimal postVoD = opp.Size_to_be_rated_this_year_in_Cr_M__c != null ? opp.Size_to_be_rated_this_year_in_Cr_M__c : (opp.VoD_in_crore__c != null ? opp.VoD_in_crore__c : 0);
        Decimal preASF = opp.ASF_Final_Amount__c != null ? opp.ASF_Final_Amount__c : 0;
        Decimal postASF = opp.Requested_Fee__c != null ? opp.Requested_Fee__c : (opp.ASF_Final_Amount__c != null ? opp.ASF_Final_Amount__c : 0);
        Decimal vodReduction = 0;
        Decimal asfReduction = 0;
        Decimal revisedVoD = opp.Size_to_be_rated_this_year_in_Cr_M__c != null ? opp.Size_to_be_rated_this_year_in_Cr_M__c : null;
        Decimal revisedASF = opp.Requested_Fee__c != null ? opp.Requested_Fee__c : null;
        String proportionateReductionValue = '';
        if(preVoD > 0){
            vodReduction = ((preVoD - postVoD) / preVoD) * 100;
        }
        if(preASF > 0){
            asfReduction = ((preASF - postASF) / preASF) * 100;
        }

        if(Math.abs(vodReduction - asfReduction) < 0.01 && (revisedVoD != null || revisedASF != null)){
            proportionateReductionValue = 'Yes';
        }else{
            proportionateReductionValue = 'No';
        }
        return proportionateReductionValue;
    }

    public class OpportunityWrapper{
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String RecordTypeName;
        @AuraEnabled public String Instrument_Type_4;
        @AuraEnabled public Date BillingStartDate;
        @AuraEnabled public Date BillingEndDate;
        @AuraEnabled public String BillingStatus;
        @AuraEnabled public String oppUrl;
        public OpportunityWrapper(Opportunity o){
            this.Id = o.Id;
            this.Name = o.Name;
            this.RecordTypeName = o.RecordType.Name;
            this.Instrument_Type_4 = o.Instrument_Type_4__c;
            this.BillingStartDate = o.Billing_Start_Date__c;
            this.BillingEndDate = o.Billing_End_Date__c;
            this.BillingStatus = o.Defer_Billing_or_Exit_Case__c;
            this.oppUrl = '/' + o.Id;
        }
    }

    public class InactiveApproverWrapper{
        @AuraEnabled public String ApproverName;
        @AuraEnabled public String ApproverEmail;
        @AuraEnabled public String ApproverRole;
        //@AuraEnabled public Boolean hasInactiveApprover = false;

        public InactiveApproverWrapper(
            String approverName,
            String approverEmail,
            String approverRole
        ) {
            this.ApproverName = approverName;
            this.ApproverEmail = approverEmail;
            this.ApproverRole = approverRole;
        }
    }

    public class OpportunityApprovalResponse{

        @AuraEnabled
        public List<OpportunityWrapper> opportunities;

        @AuraEnabled
        public List<InactiveApproverWrapper> inactiveApprovers;

        public OpportunityApprovalResponse(){
            opportunities = new List<OpportunityWrapper>();
            inactiveApprovers = new List<InactiveApproverWrapper>();
        }
    }

    public static String buildAccountTable(String accountName, Decimal vodSumSF, Decimal vodSumNonSF, Decimal asfSF, Decimal asfNonSF, Boolean hasNonSF, Boolean hasSF){
        String html = '';
        Map<String, List<Opportunity>> instrumentTypeMap = new Map<String, List<Opportunity>>();
        
        Map<String, String> instrumentType1Labels = new Map<String, String>{
            'Non Structured Finance' => 'NON-SF',
            'Structured Finance' => 'Securitization'
        };

        html += '<table style="border-collapse:collapse;width:100%;">';
        // Header
        html += '<tr>';
        html += '<th colspan="3" style="border:1px solid #000;text-align:center;">';
        html += 'Approval for ' + accountName;
        html += '</th>';
        html += '</tr>';

        if(hasNonSF){
            String displayType = instrumentType1Labels.get('Non Structured Finance');
            // Category/Type_1 cell spans the two rows
            html += '<tr>';
            html += '<td rowspan="2" ';
            html += 'style="border:1px solid #000;text-align:center;">';
            html += '<b>' + displayType + '</b>';
            html += '</td>';

            // Total VOD
            html += '<td style="border:1px solid #000;">';
            html += 'Total VOD';
            html += '</td>';

            html += '<td style="border:1px solid #000;">';
            html += vodSumNonSF != null ? String.valueOf(vodSumNonSF.setScale(2, RoundingMode.HALF_UP)+ ' Crore' ) : '-' ;
            html += '</td>';
            html += '</tr>';

            // Total ASF
            html += '<tr>';
            html += '<td style="border:1px solid #000;">';
            html += 'Total ASF As per Agreement';
            html += '</td>';
            html += '<td style="border:1px solid #000;">';
            html += asfNonSF != null ? String.valueOf(asfNonSF.setScale(2, RoundingMode.HALF_UP)) : '-';
            html += '</td>';
            html += '</tr>';
        }

        if(hasSF){
            String displayType = instrumentType1Labels.get('Structured Finance');
            // Category/Type_1 cell spans the two rows
            html += '<tr>';
            html += '<td rowspan="2" ';
            html += 'style="border:1px solid #000;text-align:center;">';
            html += '<b>' + displayType + '</b>';
            html += '</td>';

            // Total VOD
            html += '<td style="border:1px solid #000;">';
            html += 'Total VOD';
            html += '</td>';

            html += '<td style="border:1px solid #000;">';
            html += vodSumSF != null ? String.valueOf(vodSumSF.setScale(2, RoundingMode.HALF_UP)+ ' Crore' ) : '-';
            html += '</td>';
            html += '</tr>';

            // Total ASF
            html += '<tr>';
            html += '<td style="border:1px solid #000;">';
            html += 'Total ASF As per Agreement';
            html += '</td>';
            html += '<td style="border:1px solid #000;">';
            html += asfSF != null ? String.valueOf(asfSF.setScale(2, RoundingMode.HALF_UP)) : '-';
            html += '</td>';
            html += '</tr>';
        }

        html += '</table>';

        return html;
    }

    public class OpportunityValueCalculator{

        public Decimal vodSumSF;
        public Decimal vodSumNonSF;
        public Decimal asfSF;
        public Decimal asfNonSF;

        public OpportunityValueCalculator(List<Opportunity> oppList){

            vodSumSF = 0;
            vodSumNonSF = 0;
            asfSF = 0;
            asfNonSF = 0;

            for(Opportunity aOpp : oppList){
                if(aOpp.Defer_Billing_or_Exit_Case__c == 'To Be Billed' || aOpp.Defer_Billing_or_Exit_Case__c== 'Hold (Uncertain)'){
                    
                    if(aOpp.VoD_in_crore__c != null && aOpp.Instrument_type_1__c == 'Structured Finance'){
                        vodSumSF += aOpp.VoD_in_crore__c;
                    }

                    if(aOpp.VoD_in_crore__c != null && aOpp.Instrument_type_1__c == 'Non Structured Finance'){
                        vodSumNonSF += aOpp.VoD_in_crore__c;
                    }

                    if(aOpp.ASF_Final_Amount__c != null && aOpp.Instrument_type_1__c == 'Structured Finance'){
                        asfSF += aOpp.ASF_Final_Amount__c;
                    }
                    
                    if(aOpp.ASF_Final_Amount__c != null && aOpp.Instrument_type_1__c == 'Non Structured Finance'){
                        asfNonSF += aOpp.ASF_Final_Amount__c;
                    }
                }
            }
        }
    }
}