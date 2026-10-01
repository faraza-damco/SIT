/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 11-06-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-02-2025   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public with sharing class ICRA_CreateRollover_T_Logic_Manual  implements Database.Batchable<sObject>{

    string OpportunityIdParameter;
    private Date processDate;

    public ICRA_CreateRollover_T_Logic_Manual(string opp_Id){
        this.OpportunityIdParameter=opp_Id;
        processDate = System.today();
    }
    Id surveillance_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
    Id newBusiness_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String alreadyBilled = 'Already Billed';
        String closedWon= 'Closed Won';
        String Inst_Cat_DA= 'DA';
        String Inst_Cat_RP= 'RP - Independent Credit Evaluation (ICE)';
        String Inst_Cat_IPO= 'Monitoring Activity';
        String opportunityId =OpportunityIdParameter;

        String soqlquery = 'SELECT Id,Alignment_Logic__c,Change_in_start_Date__c,Is_First_Child_Surv__c,Account.OwnerId,Skip_Date_Alignment__c, Opportunity_Batch_Process__c, Name,Description,StageName,Amount,CloseDate,Type,Sum_of_Volume_of_Debt__c,Mandate_Received_Date__c,Rated_by_FFP_del__c,QTR__c,Year__c,Total_Invoice_Amount__c,Balance_Amount__c,Last_Invoice_Date__c,Capped_Amount__c,Team_Member__c,Team_Manager__c,Team_Leader__c,Location_Head__c,Commercial_Head__c,Revised_Agreed_Amount_from_Credit_Note__c,OPE__c,Quality_Analyst__c,Execution_status__c,BLR_Sub_Instrument_1__c,BLR_Sub_Instrument_2__c,Requested_Fee__c,Minimum_ASF__c,Discount_Type__c,Write_off__c,Reason_for_write_off__c,ASF_Agreement_with_Client__c,Mark_in_case_of_SO_CE__c,Auto_Calculated_Amount__c,Reason__c,Comment__c,Annual_Initial_Rating_Amount__c,Annual_Surveillance_Opportunities_Amount__c,BLR_Sub_Instrument_3__c,Revised_Agreed_Amount__c,Analyst__c,Co_Analyst__c,Sector_Head__c,Group_Head__c,PAN_Number__c,TAN_Number__c,GST_Number__c,Instrument_type_1__c,Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Expected_Deferred_Date__c,Payment_Receipt_SGST__c,Annual_Credit_Note_Amount__c,Mandate_Type__c,Last_PR_Date__c,Parent_Opportunity__c,Likely_Initial_Rating_Fee__c,Business_Segment__c,Lead_Source__c,Write_off_date__c,Remarks_If_any__c,Instrument_Type_5__c,Contact__c,If_Others_then_specify__c,ASF_Calculated_Formula__c,IRF_Final_Amount__c,Amt_of_CAP_fee__c,IRF1__c,ASF__c,ASF_Applied_Discount__c,IRF_BPS__c,ASF_BPS__c,ASF_Final_Amount__c,IRF_Applied_Discount__c,MIS_Support__c,BLR_Sub_Instrument_4__c,BLR_Sub_Instrument_5__c,Volume_of_Debt_1_amount__c,Volume_of_Debt_2_Amount__c,Volume_of_Debt_3_amount__c,Volume_of_Debt_4_amount__c,Volume_of_Debt_5_amount__c,Loss_Reason__c,Crore_or_Million__c,Others_Reasons_Only_for_Fresh_Other__c,Lost_To__c,Line_of_Business__c,Sector__c,Sub_Sector__c,Branch__c,Debt_OR_Balance_Sheet_Size__c,BD_Team_Classification__c,Focus_Group__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,Conversion_Probability__c,Customer_Fee_Type__c,Discount_Required__c,Reason_for_Discount__c,Approving_Authority_as_per_DoA__c,Provision_to_be_made__c,Reason_for_provision__c,Provision_Date__c,Defer_Billing_or_Exit_Case__c,Surveillance_Billing_period__c,Bill_Date__c,Billing_Start_Date__c,Billing_End_date__c,Debtor_Period__c,Fee_Outstanding__c,Actual_Surveillance_Fee__c,Chance_of_Retention__c,Non_Cooperation_Withdrawal_Reason__c,Revenue_Loss_in_Rs__c,Fee_received__c,Rating_Validity_Till__c,Last_RC_Date__c,Detailed_Comment__c,Discount_Requested__c,Size_to_be_rated_this_year_in_Cr_M__c,Size_rated_last_year_in_Cr_M__c,Volume_of_Debt_Category__c,Type_Tender__c,Client_Status__c,Amount_to_be_provisioned_In_Rs__c,Amount_to_be_written_off_In_Rs__c,Provisioned_Detailed_Remarks__c,Written_Off_Detailed_Remarks__c,Amount_Outstanding_In_Rs__c,Opportunity_Closed_Date__c,PR_Date__c,Amount_To_Be_Billed__c,Finance_Team__c,Past_Invoice_Number__c,Annual_Surveillance_Opp_Amount__c,Total_Invoice_Amount_1__c,Bill_To__c,Third_Party_Bill_To__c,Narration_for_Invoice__c,Actual_Billing_Start_Date__c,Actual_Billing_End_Date__c,Related_Opportunity_Count__c,AccountId,RecordType.Name,Rolling_and_Date_Alignmnet__c,Billing_Year_FY__c,Scheme_Trust_Name__c, Date_of_Communication__c, Billing_Duration__c, Revised_Billing_End_Date__c, CurrencyIsoCode, Approved_by_Commercial_Head__c, Legal_Compliance_Approval__c, Approved_by_MD_CEO_Group__c, Additional_Discount_Approved__c, Execution_Status_new__c, Rollover_Check__c, Mandate_ID__c, Mandate_Serial_No__c, OwnerId, Owner.Email, Parent_Opportunity__r.Name, Created_From__c, SurveillanceCreated__c, IPO_Surveillance_Created__c, Billing_Notification_Email_Sent__c, Revised_IRF__c, BillingAddress__c, Opp_ICRA_Branch__c, Rated_Entity__c, Instrument_Category__c, Surveillance_Created_via_T_Logic__c, Surveillance_Updated_via_T_Logic__c, Child_updated_via_T_Logic__c, BD_Head__c, Parent_Opportunity__r.BD_Head__c,Parent_Opportunity__r.VoD_Currency__c, VoD_Currency__c FROM Opportunity' ;
        soqlquery +=' WHERE StageName= :closedWon AND Defer_Billing_or_Exit_Case__c = :alreadyBilled AND Billing_Start_Date__c != null AND Billing_End_Date__c != null AND ASF_Final_Amount__c>0 AND ((recordTypeId=:newBusiness_recordType AND (PR_Date__c!=null OR Date_of_Communication__c!=null)) OR recordTypeId=:surveillance_recordType) AND Id=: opportunityId AND Instrument_Category__c!=\'' + String.escapeSingleQuotes(Inst_Cat_DA) + '\' AND Instrument_Category__c!=\'' + String.escapeSingleQuotes(Inst_Cat_RP) + '\' AND Instrument_Category__c!=\'' + String.escapeSingleQuotes(Inst_Cat_IPO) + '\' ';
        System.debug('Get Query===>> '+soqlquery); 
       return Database.getQueryLocator(soqlquery);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        System.debug('======= opportunityList =======T-Logic:  '+opportunityList.size());
        Date revised_end_date;
        Date dateRange;
        Integer mandateID= 0;
        Integer mandateSerialNo= 0;
        Date todayDate= processDate;
        Map<Id,Opportunity> optyMap= new Map<Id,Opportunity>();
        List<Opportunity> insert_T_OpportunityList = new List<Opportunity>();
        List<Opportunity> updateOpportunity = new List<Opportunity>(); 
        Map<Id, Opportunity> inputOptyMapToUpdate = new Map<Id, Opportunity>();
        Map<Id, Opportunity> inputOptyMap = new Map<Id, Opportunity>();
        Map<Id, Id> inputOptyIdsMap = new Map<Id, Id>();
        Map<Id, Date> oppStartDateMap = new Map<Id, Date>();
        Map<Id, Date> oppEndDateMap = new Map<Id, Date>();
        Set<Id> parentIds = new Set<Id>();

        List<Opportunity> lastOpty= [select Id, Mandate_ID__c,Mandate_Serial_No__c,Bill_Year__c from opportunity where mandate_id__c!=null AND Mandate_Serial_No__c!=null order by createdDate DESC LIMIT 1];
        //system.debug('Last Created Opportunity===>>'+lastOpty);
        Date today = processDate;
        Integer currentYear = today.year();
        String financialYear;
        if (today.month() >= 4) {
            financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
        } else {
            financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
        }
        System.debug(financialYear);
        mandateID=Integer.valueOf(lastOpty[0].Mandate_ID__c);
        mandateSerialNo=Integer.valueOf(lastOpty[0].Mandate_Serial_No__c);
        Integer k=0;
        if(lastOpty[0].Bill_Year__c== financialYear){
            mandateID=mandateID+1;
            mandateSerialNo=mandateSerialNo+1;
        }else{
            mandateID=Integer.valueOf(financialYear+'0000'+(k+1));
            mandateSerialNo=(k+1);
            }

        for(Opportunity opportunityRecord : opportunityList){
                optyMap.put(opportunityRecord.Id,opportunityRecord);
        }
        System.Debug('To_Be_Processed_Opty_From_T-Logic=====>>'+optyMap);

        Set<String> instrumentType1Set = new Set<String>();
        Set<String> instrumentType2Set = new Set<String>();
        Set<String> instrumentType3Set = new Set<String>();
        Set<String> instrumentType4Set = new Set<String>();

        for(Opportunity opp : optyMap.values()){
            instrumentType1Set.add(opp.Instrument_type_1__c);
            instrumentType2Set.add(opp.Instrument_type_2__c);
            instrumentType3Set.add(opp.Instrument_type_3__c);
            instrumentType4Set.add(opp.Instrument_type_4__c);
            if (opp.Billing_Start_Date__c != null) {
                oppStartDateMap.put(opp.Id, opp.Billing_Start_Date__c);
            }
            if (opp.Billing_End_Date__c != null) {
                oppEndDateMap.put(opp.Id, opp.Billing_End_Date__c);
            }
        }

        List<Billing_Date__c> billingDates = [
            SELECT Id, Alignment_Logic__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, Start_Date__c, End_date__c FROM Billing_Date__c 
            WHERE Instrument_type_1__c IN :instrumentType1Set
              AND Instrument_type_2__c IN :instrumentType2Set
              AND Instrument_type_3__c IN :instrumentType3Set
              AND Instrument_type_4__c IN :instrumentType4Set
              AND Start_Date__c <= :todayDate
              AND End_date__c >= :todayDate
            ORDER BY Start_Date__c DESC
        ];

        Map<String, Billing_Date__c> billingDateMap = new Map<String, Billing_Date__c>();
        for(Billing_Date__c billing : billingDates){
            String key = billing.Instrument_type_1__c + '|' +
                         billing.Instrument_type_2__c + '|' +
                         billing.Instrument_type_3__c + '|' +
                         billing.Instrument_type_4__c;
            if(!billingDateMap.containsKey(key)) {
                billingDateMap.put(key, billing);
            }
        }

        if(!optyMap.isEmpty()){
            Map<String, List<Opportunity>> inputKeyToOptyMap = new Map<String, List<Opportunity>>();
            Set<Id> accountIds = new Set<Id>();
            Set<String> instrumentCategorySet = new Set<String>();
            
            for(Opportunity opty : optyMap.values()){
                if(opty.Parent_Opportunity__c == null){
                    parentIds.add(opty.Id);
                }else{
                    parentIds.add(opty.Parent_Opportunity__c);
                }
            }

            for(Opportunity opty : optyMap.values()){
                if(opty.AccountId != null && String.isNotBlank(opty.Instrument_Category__c)){
                    String key = opty.AccountId + '|' + opty.Instrument_Category__c;
                    if(!inputKeyToOptyMap.containsKey(key)){
                        inputKeyToOptyMap.put(key, new List<Opportunity>());
                    }
                    inputKeyToOptyMap.get(key).add(opty);

                    accountIds.add(opty.AccountId);
                    instrumentCategorySet.add(opty.Instrument_Category__c);
                }
            }

            Map<Id, Integer> childCountMap = new Map<Id, Integer>();

            // Group by Parent_Opportunity__c to count children for each parent
            for(AggregateResult ar : [SELECT Parent_Opportunity__c parentId, COUNT(Id) recordCount FROM Opportunity
                WHERE Parent_Opportunity__c IN :parentIds GROUP BY Parent_Opportunity__c]){
                childCountMap.put((Id)ar.get('parentId'), (Integer)ar.get('recordCount'));
            }
            System.debug('To_Be_Processed_Opty=====>>'+inputKeyToOptyMap.keySet()+'  '+'Values==>>'+inputKeyToOptyMap.values());

            for(String key: inputKeyToOptyMap.keySet()){
                for (Opportunity opp : inputKeyToOptyMap.get(key)){
                    Opportunity inputOpty = opp; //T-Hit opportunity
                    String comb = inputOpty.Instrument_type_1__c + '|' +
                    inputOpty.Instrument_type_2__c + '|' +
                    inputOpty.Instrument_type_3__c + '|' +
                    inputOpty.Instrument_type_4__c;

                    Billing_Date__c matchedBilling = billingDateMap.get(comb);

                    if(matchedBilling == null){
                        continue; // Skip further processing for this record
                    }else{
                        inputOpty.Alignment_Logic__c= matchedBilling.Alignment_Logic__c;
                    }

                    Id lookupId = (inputOpty.Parent_Opportunity__c == null) ? inputOpty.Id : inputOpty.Parent_Opportunity__c;
                    Integer recordCount = childCountMap.containsKey(lookupId) ? childCountMap.get(lookupId) : 0;
                    ICRA_CreateSurveillanceViaTLogic createSurveillance = new ICRA_CreateSurveillanceViaTLogic();
                    insert_T_OpportunityList.addAll(createSurveillance.createSurveillanceViaTLogic(inputOpty, mandateID, mandateSerialNo, inputOpty.Alignment_Logic__c, recordCount,processDate));
                    mandateID++;
                    mandateSerialNo++;
                }
            }

            System.Debug('insert_T_OpportunityList size: ' + insert_T_OpportunityList.size());
            Set<Id> inputOptyIdsSet = new Set<Id>();    
            if(!insert_T_OpportunityList.isEmpty()){
                for (Opportunity opp : insert_T_OpportunityList) {
                    //System.Debug('*********New Opty Created From********* '+opp.Created_From__c);
                    if (opp.Created_From__c != null) {
                        inputOptyIdsSet.add(opp.Created_From__c);
                    }
                }
                if(!inputOptyIdsSet.isEmpty()){
                    for (Opportunity opp : [SELECT Id, Name, StageName, CloseDate, Alignment_Logic__c, Created_From__c FROM Opportunity WHERE Id IN :inputOptyIdsSet]) {
                            inputOptyMapToUpdate.put(opp.Id, opp);
                    }
                }
            }

            if(insert_T_OpportunityList.size() > 0){
                Database.SaveResult [] insertResults = Database.insert(insert_T_OpportunityList, false);  
                List<Transaction_Log__c> errorLogs = new List<Transaction_Log__c>();
                    for(Integer i = 0; i < insertResults.size(); i++){
                        if (insertResults[i].isSuccess()) {
                            Opportunity newOpty = insert_T_OpportunityList[i];
                            Opportunity inputOpty = inputOptyMapToUpdate.get(newOpty.Created_From__c);
                            System.Debug('New Opty: '+newOpty.Id+' '+newOpty.Name);
                            System.Debug('inputOpty: '+inputOpty.Id+' '+inputOpty.Name+' '+inputOpty.Alignment_Logic__c);
                            if (inputOpty != null) {
                                inputOpty.Change_in_start_Date__c  = false;
                                inputOpty.Rolling_and_Date_Alignmnet__c  = true;
                                inputOpty.SurveillanceCreated__c= true;
                                inputOpty.Surveillance_Created_via_T_Logic__c= true;
                                updateOpportunity.add(inputOpty);
                            }
                        }else{
                            //System.debug('Failed to insert Opportunity: ' + insertResults[i].getErrors()[0].getMessage());
                            for (Database.Error err : insertResults[i].getErrors()) {
                                    ICRA_TransactionLogHandler.addLog('ICRA_CreateRollover_T_Logic_Manual', (insert_T_OpportunityList[i] != null ? insert_T_OpportunityList[i].Created_From__c : null), null, 'Insert against the tagged opportunity failed', err.getMessage());
                                }
                            
                        }
                    }
            }

            if(!updateOpportunity.isEmpty()){
                Database.SaveResult [] updateOpty= Database.update(updateOpportunity, false);
                List<Transaction_Log__c> errorLogs = new List<Transaction_Log__c>();
                for (Integer i = 0; i < updateOpty.size(); i++) {
                    if (!updateOpty[i].isSuccess()){
                        for (Database.Error err : updateOpty[i].getErrors()){
                            //System.debug('Opportunity Update Error for Opp ' + opp.Id + ': ' + err.getMessage());
                            ICRA_TransactionLogHandler.addLog('ICRA_CreateRollover_T_Logic_Manual', (updateOpportunity[i] != null ? updateOpportunity[i].Id : null), null, 'Update of T-Logic Hit Opportunity Failed: Surveillance Created via T-Logic', err.getMessage());
                        }
                    }
                }
            }
        }
        ICRA_TransactionLogHandler.saveLogs();
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('======= finish =======:  '+BC);
    }
}