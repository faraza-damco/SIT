@RestResource(urlMapping='/CreateSurveillanceOpportunityDataOne/*')
global with sharing class ICRA_Create_Opportunity_DataOne {
    @HttpPost
    global static ICRA_Create_Opportunity_DataOne.ResponseWrapper createSurvOpportunity(){
        Integer mandateID= 0;
        Integer mandateSerialNo= 0;  
        String req= RestContext.request.requestBody.toString();
        ICRA_Create_Opportunity_DataOne.ResponseWrapper returnValue= new ICRA_Create_Opportunity_DataOne.ResponseWrapper();
        if(String.isNotBlank(req)){
            Savepoint savePoint = Database.setSavepoint();
            try{
                ICRA_Create_Opportunity_Wrapper oppWrapper= (ICRA_Create_Opportunity_Wrapper) JSON.deserialize(req, ICRA_Create_Opportunity_Wrapper.class);
                system.debug('Request Payload==>>'+oppWrapper);
                
                if(oppWrapper.data[0].mandate_id!=''){
                    List<Opportunity> oppData= [select Id, Name, pr_date__c, date_of_communication__c, surveillance_id__c, rated_vod__c, Scheme_Trust_Name__c, instrument_category__c, recordTypeID
                     from Opportunity where mandate_id__c=:oppWrapper.data[0].mandate_id LIMIT 1];
                    if(oppData!=null && oppData.size()>0){
                        Id SurvRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].pr_date))){
                            oppData[0].pr_date__c= Date.valueOf(oppWrapper.data[0].pr_date);                        
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].date_of_communication))){
                            oppData[0].date_of_communication__c= Date.valueOf(oppWrapper.data[0].date_of_communication);                        
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].surveillance_id))){
                            oppData[0].surveillance_id__c= oppWrapper.data[0].surveillance_id;                        
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].rated_vod))){
                            oppData[0].rated_vod__c= Decimal.ValueOf(oppWrapper.data[0].rated_vod);                        
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].client_status)) && oppData[0].recordTypeID== SurvRecordTypeId){
                            oppData[0].Client_Status__c= oppWrapper.data[0].client_status;                        
                        }
                        if(!String.isBlank(String.valueOf(oppWrapper.data[0].trust_name))){
                            oppData[0].Scheme_Trust_Name__c= oppWrapper.data[0].trust_name;                        
                        }
                        update oppData[0];
                        returnValue.StatusMessage= 'Record updated successfully';
                        returnValue.StatusCode= '200';
                    }else{
                        returnValue.StatusMessage= 'No record found against the provided Mandate Id';
                        returnValue.StatusCode= '400';
                    }
                }else if(oppWrapper.data[0].mandate_id=='' && oppWrapper.data[0].account_id!='' && oppWrapper.data[0].instrument_category!='' && oppWrapper.data[0].surveillance_id!=''){
                        List<Opportunity> insertOpportunityList= new List<Opportunity>();
                        List<Opportunity> updateOpportunity= new List<Opportunity>();
                        Id surveillance_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
                        Id newBusiness_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
                        String surveillanceID= oppWrapper.data[0].surveillance_id==null? null: String.valueOf(oppWrapper.data[0].surveillance_id);
                        String ratedVOD= oppWrapper.data[0].rated_vod==null? null: String.valueOf(oppWrapper.data[0].rated_vod);
                        String schemeTrust= oppWrapper.data[0].trust_name==null? null: String.valueOf(oppWrapper.data[0].trust_name);
                        //String clientStatus= oppWrapper.data[0].client_status==null? null: String.valueOf(oppWrapper.data[0].client_status);
                        List<Opportunity> lastOpty= [select Id, mandate_id__c,Mandate_Serial_No__c,Bill_Year__c from opportunity where mandate_id__c!=null AND Mandate_Serial_No__c!=null order by createdDate DESC LIMIT 1]; 
                        //system.debug('Last Created Opportunity===>>'+lastOpty);
                        Date today = Date.today();
                        Integer currentYear = today.year();
                        String financialYear;
                        if (today.month() >= 4) {
                            financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
                        } else {
                            financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
                        }
                        //System.debug(financialYear);
                        mandateID=Integer.valueOf(lastOpty[0].mandate_id__c);
                        mandateSerialNo=Integer.valueOf(lastOpty[0].Mandate_Serial_No__c);
                        Integer k=0;
                        if(lastOpty[0].Bill_Year__c== financialYear){
                            mandateID=mandateID+1;
                            mandateSerialNo=mandateSerialNo+1;
                        }else{
                            mandateID=Integer.valueOf(financialYear+'0000'+(k+1));
                            mandateSerialNo=(k+1);
                            }

                        List<Opportunity> oppData= [select AccountId,RecordType.Name, Sector__c, Client_Status__c, Customer_Fee_Type__c, Branch__c, Line_of_Business__c, Sub_Sector__c, Focus_Group__c, 
                                            Name, Parent_Opportunity__c, Business_Segment__c, StageName, Contact__c,Opportunity_Closed_Date__c,
                                            OwnerId, RecordTypeId, Instrument_type_1__c, Instrument_type_3__c, BLR_Sub_Instrument_1__c,
                                            BLR_Sub_Instrument_2__c, BLR_Sub_Instrument_3__c, BLR_Sub_Instrument_4__c,
                                            BLR_Sub_Instrument_5__c, Instrument_type_2__c, Instrument_type_4__c, Remarks_If_any__c, Volume_of_Debt_1_amount__c,
                                            Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c,
                                            CurrencyIsoCode, Volume_of_Debt_Category__c, VoD_in_crore__c, Crore_or_Million__c,
                                            Debt_OR_Balance_Sheet_Size__c, CurrencyDisplayFormula__c, IRF_Final_Amount__c, Initial_Rating_Fee_as_per_Agreement_BPS__c,
                                            ASF_Final_Amount__c, ASF_as_per_Agreement_BPS__c, ASF_Agreement_with_Client__c, OPE__c, IRF_Applied_Discount__c,
                                            ASF_Applied_Discount__c, Minimum_ASF__c, Amt_of_CAP_fee__c, Total_Invoice_Amount__c, Balance_Amount__c, 
                                            Total_Payment_Received__c, Billing_Start_Date__c, Actual_Surveillance_Fee__c, Fee_Outstanding__c, 
                                            Chance_of_Retention__c, Revenue_Loss_in_Rs__c, Rating_Validity_Till__c, Mandate_Received_Date__c, Billing_End_date__c,
                                            Fee_received__c, Non_Cooperation_Withdrawal_Reason__c, Last_RC_Date__c, Description, Write_off__c, Write_off_date__c, 
                                            Written_Off_Detailed_Remarks__c, Reason_for_write_off__c, Amount_to_be_written_off_In_Rs__c, Discount_Required__c, 
                                            Discount_Type__c, Size_to_be_rated_this_year_in_Cr_M__c, Discount_Requested__c, Detailed_Comment__c, 
                                            Size_rated_last_year_in_Cr_M__c, Requested_Fee__c, Reason_for_Discount__c, Approving_Authority_as_per_DoA__c, 
                                            Revised_Agreed_Amount__c, Revised_Agreed_Amount_from_Credit_Note__c, Provision_to_be_made__c, Provision_Date__c,
                                            Provisioned_Detailed_Remarks__c, Reason_for_provision__c, Amount_to_be_provisioned_In_Rs__c, Defer_Billing_or_Exit_Case__c,
                                            Reason__c, CloseDate, Expected_Deferred_Date__c, Comment__c, Approved_by_Commercial_Head__c, isLeapYear__c, 
                                            Legal_Compliance_Approval__c, Approved_by_MD_CEO_Group__c, Additional_Discount_Approved__c, PAN_Number__c, GST_Number__c, 
                                            TAN_Number__c, Team_Member__c, Team_Leader__c, Commercial_Head__c, Team_Manager__c, Location_Head__c, MIS_Support__c, 
                                            Analyst__c, Co_Analyst__c, Quality_Analyst__c, Sector_Head__c, Group_Head__c, Execution_Status_new__c, pr_date__c, BillingAddress__c,
                                            Scheme_Trust_Name__c,date_of_communication__c, Opp_ICRA_Branch__c, Rated_Entity__c, Bill_To__c, instrument_category__c, Created_From__c, rated_vod__c,Parent_Opportunity__r.VoD_Currency__c, VoD_Currency__c,
                                            Related_Opportunity_Count__c, Narration_for_Invoice__c, Revised_Billing_End_Date__c, Parent_Opportunity__r.Name, surveillance_id__c, Mandate_Type__c, Parent_Opportunity__r.Mandate_Type__c, SurveillanceCreated__c,
                                            BD_Head__c, Parent_Opportunity__r.BD_Head__c from Opportunity where StageName='Closed Won' and Surveillance_Created_via_DataOne__c=false and Surveillance_Created_via_T_Logic__c=false and Defer_Billing_or_Exit_Case__c!='Exit Case'
                                            and Billing_End_Date__c!=null and Rated_Entity__c=:oppWrapper.data[0].account_id and instrument_category__c=:oppWrapper.data[0].instrument_category ORDER BY CreatedDate DESC, Billing_Start_Date__c DESC];
                    system.debug('---Size--->'+oppData.size()+' Opportunity Data===>'+oppData);
                    if(oppData!=null && oppData.size()>0){
                        Date todayDate= System.today();
                        Set<String> instrumentType1Set = new Set<String>();
                        Set<String> instrumentType2Set = new Set<String>();
                        Set<String> instrumentType3Set = new Set<String>();
                        Set<String> instrumentType4Set = new Set<String>();

                        for (Integer i=0; i< oppData.size(); i++) {
                            Opportunity opp= oppData[i];
                            instrumentType1Set.add(opp.Instrument_type_1__c);
                            instrumentType2Set.add(opp.Instrument_type_2__c);
                            instrumentType3Set.add(opp.Instrument_type_3__c);
                            instrumentType4Set.add(opp.Instrument_type_4__c);
                        }
          
                        List<Billing_Date__c> billingDates = [
                            SELECT Id, Alignment_Logic__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_Type_3__c, Instrument_Type_4__c, Start_Date__c, End_date__c FROM Billing_Date__c 
                            WHERE Instrument_type_1__c IN :instrumentType1Set
                            AND Instrument_type_2__c IN :instrumentType2Set
                            AND Instrument_Type_3__c IN :instrumentType3Set
                            AND Instrument_Type_4__c IN :instrumentType4Set
                            AND Start_Date__c <= :todayDate
                            AND End_date__c >= :todayDate
                            ORDER BY Start_Date__c DESC
                        ];
                        //System.Debug('Billing Date==>  '+billingDates.size()+billingDates);

                        Map<String, Billing_Date__c> billingDateMap = new Map<String, Billing_Date__c>();
                        if(!billingDates.isEmpty()){
                            for (Billing_Date__c billing : billingDates) {
                                String key = billing.Instrument_type_1__c+ '|' +billing.Instrument_type_2__c + '|' +billing.Instrument_type_3__c + '|' +billing.Instrument_type_4__c;
                                if (!billingDateMap.containsKey(key)) {
                                    billingDateMap.put(key, billing);
                                }
                            }
                        }

                        Set<Id> parentIds = new Set<Id>();
                        for(Integer i=0; i< oppData.size(); i++){
                            Opportunity oppty= oppData[i];
                            if(oppty.Parent_Opportunity__c == null){
                                parentIds.add(oppty.Id);
                            }else{
                                parentIds.add(oppty.Parent_Opportunity__c);
                            }
                        }

                        Map<Id, Integer> childCountMap = new Map<Id, Integer>();

                        // Group by Parent_Opportunity__c to count children for each parent
                        for (AggregateResult ar : [
                            SELECT Parent_Opportunity__c parentId, COUNT(Id) recordCount
                            FROM Opportunity
                            WHERE Parent_Opportunity__c IN :parentIds
                            GROUP BY Parent_Opportunity__c
                        ]) {
                            childCountMap.put((Id)ar.get('parentId'), (Integer)ar.get('recordCount'));
                        }

                        Map<Id, List<Opportunity>> parentToChildrenMap = new Map<Id, List<Opportunity>>();  // Map to hold parent-child relationships: to create rollover against latest opportunity only
                        Set<Id> allParentOppIds = new Set<Id>();

                        for (Opportunity opp : oppData){
                            if (opp.Parent_Opportunity__c != null){
                                allParentOppIds.add(opp.Parent_Opportunity__c);
                                if (!parentToChildrenMap.containsKey(opp.Parent_Opportunity__c)){
                                    parentToChildrenMap.put(opp.Parent_Opportunity__c, new List<Opportunity>());
                                }
                                parentToChildrenMap.get(opp.Parent_Opportunity__c).add(opp);
                            }
                        }       

                        Set<Opportunity> createRollOverForSet = new Set<Opportunity>();
                        for (Opportunity opp : oppData){
                            if(opp.Instrument_type_1__c=='Structured Finance' && String.isBlank(schemeTrust)){
                                returnValue.StatusMessage = 'Scheme Trust name is required for Structured Finance instrument type.';
                                returnValue.StatusCode= '400';
                                return returnValue;
                            }
                            else if(opp.Parent_Opportunity__c == null){
                                if (parentToChildrenMap.containsKey(opp.Id)){
                                    List<Opportunity> childList = parentToChildrenMap.get(opp.Id);
                                    Opportunity latestChild = childList[0]; // Because already ordered by CreatedDate,Billing Start Date DESC
                                    if(latestChild.Surveillance_ID__c <> surveillanceID && (latestChild.Instrument_type_1__c=='Non Structured Finance' || (latestChild.Instrument_type_1__c=='Structured Finance' && schemeTrust.equalsIgnoreCase(String.valueOf(latestChild.Scheme_Trust_Name__c))))){
                                        createRollOverForSet.add(latestChild);
                                    }
                                }else if(opp.Mandate_Type__c != 'Fresh From Fresh' && opp.recordTypeId == newBusiness_recordType && opp.Surveillance_ID__c <> surveillanceID && (opp.Instrument_type_1__c=='Non Structured Finance' || (opp.Instrument_type_1__c=='Structured Finance' && schemeTrust.equalsIgnoreCase(String.valueOf(opp.Scheme_Trust_Name__c))))){
                                    //System.Debug('NOT FFF====>'+opp.Mandate_Type__c+''+opp.Id+' '+opp.Surveillance_ID__c);
                                    createRollOverForSet.add(opp);
                                }else if(opp.Mandate_Type__c == 'Fresh From Fresh' && opp.recordTypeId == newBusiness_recordType && (opp.Instrument_type_1__c=='Non Structured Finance' || (opp.Instrument_type_1__c=='Structured Finance' && schemeTrust.equalsIgnoreCase(String.valueOf(opp.Scheme_Trust_Name__c))))){
                                    //System.Debug('FFF====>'+opp.Mandate_Type__c+''+opp.Id+' '+opp.Surveillance_ID__c);
                                    createRollOverForSet.add(opp);
                                }else if(opp.recordTypeId == surveillance_recordType && opp.Surveillance_ID__c <> surveillanceID && (opp.Instrument_type_1__c=='Non Structured Finance' || (opp.Instrument_type_1__c=='Structured Finance' && schemeTrust.equalsIgnoreCase(String.valueOf(opp.Scheme_Trust_Name__c))))){
                                    createRollOverForSet.add(opp);
                                }
                            }else if(opp.Parent_Opportunity__c != null){
                                if (parentToChildrenMap.containsKey(opp.Parent_Opportunity__c)){
                                    List<Opportunity> childList = parentToChildrenMap.get(opp.Parent_Opportunity__c);
                                    Opportunity latestChild = childList[0]; 
                                    if(latestChild.Surveillance_ID__c <> surveillanceID && (latestChild.Instrument_type_1__c=='Non Structured Finance' || (latestChild.Instrument_type_1__c=='Structured Finance' && schemeTrust.equalsIgnoreCase(String.valueOf(latestChild.Scheme_Trust_Name__c))))){
                                        createRollOverForSet.add(latestChild);
                                    }
                                }
                            }
                        }        
                        

                        List<Opportunity> createRollOverForList= new List<Opportunity>();
                        createRollOverForList.addAll(createRollOverForSet);
                        if(createRollOverForList.isEmpty()){
                            returnValue.StatusMessage = 'No eligible Opportunities found for creating rollover.';
                            returnValue.StatusCode= '400';
                        }
                        System.Debug('======Opportunities to create roll over for=======: ' + createRollOverForList.size());

                        for(Integer i=0; i< createRollOverForList.size(); i++){
                            Opportunity opty= createRollOverForList[i];
                            String key = opty.Instrument_type_1__c+ '|' +opty.Instrument_type_2__c + '|' +opty.Instrument_type_3__c + '|' +opty.Instrument_type_4__c;
                            Billing_Date__c matchedBilling = billingDateMap.get(key);
                            if (matchedBilling == null) {
                                //System.debug('No matching Billing_Date__c record found for Opportunity: ' + opty.Id);
                                continue; // Skip further processing for this record
                            }else{
                                //System.debug('Matching Billing Record Found for '+opty.Id+' =====>>>>>     '+matchedBilling);
                                opty.Alignment_Logic__c= matchedBilling.Alignment_Logic__c;
                            }
                            Id lookupId = (opty.Parent_Opportunity__c == null) ? opty.Id : opty.Parent_Opportunity__c;
                            Integer recordCount = childCountMap.containsKey(lookupId) ? childCountMap.get(lookupId) : 0;
                            insertOpportunityList.addAll(ICRA_Create_Opportunity_DataOne.createSurveillanceOpportunityDataOne(opty, mandateID, mandateSerialNo, surveillanceID, opty.Alignment_Logic__c, recordCount, ratedVOD, schemeTrust));
                            updateOpportunity.add(opty);
                            mandateID++;
                            mandateSerialNo++;
                        }

                        if(!insertOpportunityList.isEmpty()){
                            List<Database.SaveResult> insertResults = Database.insert(insertOpportunityList, true);
                            List<String> errorMessages = new List<String>();
                            List<String> successMessages = new List<String>();
                            Boolean allSuccess = true;
                            for (Integer i = 0; i < insertResults.size(); i++) {
                                Database.SaveResult result = insertResults[i];
                                if (!result.isSuccess()) {
                                    allSuccess = false;
                                    for (Database.Error error : result.getErrors()) {
                                        errorMessages.add('Insert Error for record at index ' + i + ': ' + error.getMessage());
                                    }
                                }else{
                                    successMessages.add('Successfully inserted Opportunity with Id: ' + result.getId());
                                }
                            }

                            if(allSuccess && !updateOpportunity.isEmpty()){
                                List<Opportunity> tempData = new List<Opportunity>();
                                for (Opportunity record : updateOpportunity){
                                    tempData.add(new Opportunity(
                                        Id = record.Id,
                                        Change_in_start_Date__c=false,
                                        Rolling_and_Date_Alignmnet__c=true,
                                        SurveillanceCreated__c=true,
                                        Surveillance_Created_via_DataOne__c=true
                                        //Surveillance_ID__c = surveillanceID
                                    ));
                                }

                                List<Database.SaveResult> updateResults = Database.update(tempData, true);

                                for(Integer j = 0; j < updateResults.size(); j++){
                                    if(!updateResults[j].isSuccess()) {
                                        for (Database.Error error : updateResults[j].getErrors()){
                                            errorMessages.add('Update Error for Opportunity ' + updateResults[j].getId() + ': ' + error.getMessage());
                                        }
                                    }else{
                                        successMessages.add('Successfully updated Opportunity with Id: ' + updateResults[j].getId());
                                    }
                                }
                            }

                            if (errorMessages.isEmpty()) {
                                returnValue.StatusMessage = 'All operations completed successfully.';
                                returnValue.StatusCode= '200';
                            } else {
                                returnValue.StatusMessage = String.join(errorMessages, '\n');
                                returnValue.StatusCode= '400';
                            }
                        }
                    }else{
                        returnValue.StatusMessage= 'Record not found';
                        returnValue.StatusCode= '400';
                    }
                }else{
                    returnValue.StatusMessage = 'Please provide appropriate details. Check if Account Id, Instrument Category and Surveillance Id are provided or not.';
                    returnValue.StatusCode= '400';
                }
            }catch(Exception ex){
                Database.rollback(savePoint);
                system.debug(ex.getMessage()+'----line no ===>>> '+ex.getLineNumber());
                ICRA_Create_Opportunity_DataOne.ResponseWrapper returnValueEx= new ICRA_Create_Opportunity_DataOne.ResponseWrapper();
                returnValueEx.StatusMessage= 'Some error occured while processing the request'+': '+ex.getMessage();
                returnValueEx.StatusCode= '500';
                return returnValueEx;
            }
        }
        return returnValue;
    }

    public static List<Opportunity> createSurveillanceOpportunityDataOne(Opportunity oppData, Integer mandateID, Integer mandateSerialNo, String surveillanceID, String alignmentLogic, Integer recordCount, String ratedVOD, String schemeTrust){
        List<Opportunity> toInsertOpportunityList= new List<Opportunity>();
        ICRA_Create_Opportunity_DataOne.ResponseWrapper returnValuex= new ICRA_Create_Opportunity_DataOne.ResponseWrapper();
        Id SurvRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        String formattedStartDate;
        String formattedEndDate;
        Date billing_start_date;
        Date billing_end_date;
        Date billing_end_date2;
        Date revisedEndDate;
        Decimal revisedVoD;
        Decimal revisedASF;
        Boolean is_Leap_Year;
        //Integer recordCount;
        String instrument_1= oppData.Instrument_type_1__c;
        String instrument_2= oppData.Instrument_type_2__c;
        String instrument_3= oppData.Instrument_type_3__c;
        String instrument_4= oppData.Instrument_type_4__c;

        if(oppData.Billing_End_Date__c!=null){
            revisedEndDate= oppData.Revised_Billing_End_Date__c==null ? oppData.Billing_End_Date__c : oppData.Revised_Billing_End_Date__c;
            revisedVoD= oppData.Size_to_be_rated_this_year_in_Cr_M__c==null ? oppData.VoD_in_crore__c : oppData.Size_to_be_rated_this_year_in_Cr_M__c;
            revisedASF= oppData.Requested_Fee__c==null ? oppData.ASF_Final_Amount__c : oppData.Requested_Fee__c;
            billing_start_date= revisedEndDate.addDays(1);
            billing_end_date2= billing_start_date.addYears(1);
            is_Leap_Year= isLeapYearBilling(billing_start_date, billing_end_date2);
            System.Debug('isLeapYear==>'+is_Leap_Year);
            if(is_Leap_Year){
                billing_end_date= billing_start_date.addDays(365);
            }else{
                billing_end_date= billing_start_date.addDays(364);
            }

            if(alignmentLogic!=null){
                if(alignmentlogic=='Financial Year' && (recordCount==null || recordCount<1)){
                    if(billing_start_date.month()>=4){
                        billing_end_date= Date.parse('31/03/'+string.valueOf(billing_end_date.year()));
                    }else if(billing_start_date.month()<4){
                        billing_end_date= Date.parse('31/03/'+string.valueOf(billing_start_date.year()));
                    }
                }
            }else{
                System.Debug('========>Alignment Logic is not present for the instruments combination');
            }

            Opportunity survOpty = new opportunity();
            if(surveillanceID!='' && surveillanceID!=null){
            survOpty.surveillance_id__c= surveillanceID;
            }
            survOpty.AccountId=oppData.AccountId;
            survOpty.instrument_category__c=oppData.instrument_category__c;
            if(oppData.Defer_Billing_or_Exit_Case__c=='Non Billable'){
                survOpty.Billing_Start_Date__c= oppData.Billing_Start_Date__c;
            }else if(oppData.Defer_Billing_or_Exit_Case__c!='Non Billable'){
                survOpty.Billing_Start_Date__c= billing_start_date;
            }

            if(oppData.Defer_Billing_or_Exit_Case__c=='Non Billable'){
                survOpty.Billing_End_Date__c= oppData.Billing_End_Date__c;
            }else if(oppData.Defer_Billing_or_Exit_Case__c!='Non Billable'){
                survOpty.Billing_End_Date__c= billing_end_date;
            }

            if(oppData.recordTypeId==SurvRecordTypeId){
                survOpty.Client_Status__c= oppData.Client_Status__c;
            }else{
                survOpty.Client_Status__c= 'Live';
            }
            survOpty.Customer_Fee_Type__c=oppData.Customer_Fee_Type__c;
            survOpty.Business_Segment__c=oppData.Business_Segment__c; 
            survOpty.StageName='Closed Won'; 
            survOpty.Contact__c=oppData.Contact__c;                                                                 
            survOpty.Instrument_type_1__c=oppData.Instrument_type_1__c;  
            survOpty.Instrument_type_2__c=oppData.Instrument_type_2__c;                                                                
            survOpty.Instrument_type_3__c=oppData.Instrument_type_3__c; 
            if(oppData.Instrument_type_4__c=='Bank Loan Rating Fresh'){
                survOpty.Instrument_type_4__c='Bank Loan Rating';
            }else{
                survOpty.Instrument_type_4__c=oppData.Instrument_type_4__c;
            }
            survOpty.BLR_Sub_Instrument_1__c=oppData.BLR_Sub_Instrument_1__c; 
            survOpty.BLR_Sub_Instrument_2__c=oppData.BLR_Sub_Instrument_2__c;                                                                 
            survOpty.BLR_Sub_Instrument_3__c=oppData.BLR_Sub_Instrument_3__c; 
            survOpty.BLR_Sub_Instrument_4__c=oppData.BLR_Sub_Instrument_4__c; 
            survOpty.BLR_Sub_Instrument_5__c=oppData.BLR_Sub_Instrument_5__c;                                                                 
            survOpty.Remarks_If_any__c=oppData.Remarks_If_any__c; 
            survOpty.Volume_of_Debt_1_amount__c=oppData.Volume_of_Debt_1_amount__c;                                                                
            survOpty.Volume_of_Debt_2_Amount__c=oppData.Volume_of_Debt_2_Amount__c; 
            survOpty.Volume_of_Debt_3_amount__c=oppData.Volume_of_Debt_3_amount__c; 
            survOpty.Volume_of_Debt_4_amount__c=oppData.Volume_of_Debt_4_amount__c; 
            survOpty.Volume_of_Debt_5_amount__c=oppData.Volume_of_Debt_5_amount__c;                                                                 
            survOpty.CurrencyIsoCode=oppData.CurrencyIsoCode; 
            survOpty.VoD_in_crore__c=revisedVoD;
            survOpty.ASF_Agreement_with_Client__c=oppData.ASF_Agreement_with_Client__c; 
            survOpty.OPE__c=oppData.OPE__c;                                                                 
            survOpty.Minimum_ASF__c=oppData.Minimum_ASF__c; 
            survOpty.Amt_of_CAP_fee__c=oppData.Amt_of_CAP_fee__c;                                                                                                                              
            survOpty.Actual_Surveillance_Fee__c=oppData.Actual_Surveillance_Fee__c;
            survOpty.Rolling_and_Date_Alignmnet__c = true;                                                                
            survOpty.Fee_Outstanding__c=oppData.Fee_Outstanding__c; 
            survOpty.Chance_of_Retention__c=oppData.Chance_of_Retention__c;                                                                
            survOpty.Revenue_Loss_in_Rs__c=oppData.Revenue_Loss_in_Rs__c; 
            survOpty.Rating_Validity_Till__c=oppData.Rating_Validity_Till__c;                                                               
            survOpty.Mandate_Received_Date__c=oppData.Mandate_Received_Date__c; 
            survOpty.Change_in_start_Date__c = false ;                                                                
            survOpty.Fee_received__c=oppData.Fee_received__c; 
            survOpty.Non_Cooperation_Withdrawal_Reason__c=oppData.Non_Cooperation_Withdrawal_Reason__c;                                                                
            survOpty.Last_RC_Date__c=oppData.Last_RC_Date__c; 
            survOpty.Description=oppData.Description; 
            survOpty.Write_off__c=oppData.Write_off__c;                                                                
            survOpty.Write_off_date__c=oppData.Write_off_date__c; 
            survOpty.Written_Off_Detailed_Remarks__c=oppData.Written_Off_Detailed_Remarks__c;                                                               
            survOpty.Reason_for_write_off__c=oppData.Reason_for_write_off__c; 
            survOpty.Amount_to_be_written_off_In_Rs__c=oppData.Amount_to_be_written_off_In_Rs__c;                                                               
            survOpty.Discount_Required__c=oppData.Discount_Required__c; 
            survOpty.Discount_Type__c=oppData.Discount_Type__c;                                                                
            survOpty.Detailed_Comment__c=oppData.Detailed_Comment__c; 
            survOpty.Size_rated_last_year_in_Cr_M__c=oppData.Size_rated_last_year_in_Cr_M__c; 
            survOpty.Reason_for_Discount__c=oppData.Reason_for_Discount__c; 
            survOpty.Approving_Authority_as_per_DoA__c=oppData.Approving_Authority_as_per_DoA__c;                                                             
            survOpty.Revised_Agreed_Amount__c=oppData.Revised_Agreed_Amount__c;  
            survOpty.Provision_to_be_made__c=oppData.Provision_to_be_made__c; 
            survOpty.Provision_Date__c=oppData.Provision_Date__c; 
            survOpty.Provisioned_Detailed_Remarks__c=oppData.Provisioned_Detailed_Remarks__c;                                                              
            survOpty.Reason_for_provision__c=oppData.Reason_for_provision__c; 
            survOpty.Amount_to_be_provisioned_In_Rs__c=oppData.Amount_to_be_provisioned_In_Rs__c; 
            survOpty.Defer_Billing_or_Exit_Case__c='Non Billable'; 
            survOpty.Reason__c=oppData.Reason__c; 
            survOpty.CloseDate=Date.today();                                                              
            survOpty.Approved_by_Commercial_Head__c=oppData.Approved_by_Commercial_Head__c; 
            survOpty.Legal_Compliance_Approval__c=oppData.Legal_Compliance_Approval__c; 
            survOpty.Approved_by_MD_CEO_Group__c=oppData.Approved_by_MD_CEO_Group__c; 
            survOpty.Additional_Discount_Approved__c=oppData.Additional_Discount_Approved__c;                                        
            survOpty.Team_Member__c=oppData.Team_Member__c; 
            survOpty.Team_Leader__c=oppData.Team_Leader__c; 
            survOpty.Commercial_Head__c=oppData.Commercial_Head__c; 
            survOpty.Team_Manager__c=oppData.Team_Manager__c; 
            survOpty.Location_Head__c=oppData.Location_Head__c; 
            survOpty.MIS_Support__c=oppData.MIS_Support__c; 
            survOpty.Analyst__c=oppData.Analyst__c; 
            survOpty.Co_Analyst__c=oppData.Co_Analyst__c;                                      
            survOpty.Quality_Analyst__c=oppData.Quality_Analyst__c; 
            survOpty.Sector_Head__c=oppData.Sector_Head__c; 
            survOpty.Group_Head__c=oppData.Group_Head__c;
            //survOpty.Scheme_Trust_Name__c=oppData.Scheme_Trust_Name__c; 
            if(schemeTrust!=null && schemeTrust!='' && oppData.Instrument_type_1__c=='Structured Finance'){
                survOpty.Scheme_Trust_Name__c= String.Valueof(schemeTrust);
            }
            survOpty.Rollover_Check__c=true; 
            survOpty.recordTypeID= SurvRecordTypeId;
            survOpty.Related_Opportunity_Count__c= oppData.Related_Opportunity_Count__c==null ? 1 : oppData.Related_Opportunity_Count__c+1; 
            survOpty.ASF_Final_Amount__c= revisedASF;
            survOpty.IRF_Final_Amount__c= oppData.IRF_Final_Amount__c; 
            survOpty.Requested_Fee__c= null;
            survOpty.pr_date__c = null;
            if(ratedVOD!=null && ratedVOD!=''){
            survOpty.rated_vod__c= Decimal.ValueOf(ratedVOD);
            }
            //survOpty.rated_vod__c = oppData.rated_vod__c;
            if(oppData.recordType.Name=='New Business' || (oppData.recordType.Name=='Surveillance' && oppData.Parent_Opportunity__c==null)){
			    survOpty.VoD_Currency__c= oppData.VoD_Currency__c;
            }else{
                survOpty.VoD_Currency__c= oppData.Parent_Opportunity__r.VoD_Currency__c;
            }
            DateTime startDateTime = DateTime.newInstance(survOpty.Billing_Start_Date__c.year(), survOpty.Billing_Start_Date__c.month(), survOpty.Billing_Start_Date__c.day(), 0, 0, 0);
            DateTime endDateTime = DateTime.newInstance(survOpty.Billing_End_Date__c.year(), survOpty.Billing_End_Date__c.month(), survOpty.Billing_End_Date__c.day(), 0, 0, 0);
            formattedStartDate = startDateTime.format('MMM-yy');
            formattedEndDate = endDateTime.format('MMM-yy');

            if(oppData.recordType.Name=='New Business'){
                survOpty.Parent_Opportunity__c = oppData.Id;
                survOpty.Name=oppData.Name+'-Surveillence-'+revisedVoD+'-'+formattedStartDate+'-'+formattedEndDate;
                survOpty.Created_From__c= oppData.Id;
            }else{
                if(oppData.Parent_Opportunity__c!=null){
                    survOpty.Parent_Opportunity__c = oppData.Parent_Opportunity__c;
                    survOpty.Name=oppData.Parent_Opportunity__r.Name+'-Surveillence-'+revisedVoD+'-'+formattedStartDate+'-'+formattedEndDate;
                }else{
                    survOpty.Parent_Opportunity__c = oppData.Id;
                    survOpty.Name=oppData.Name+'-Surveillence-'+revisedVoD+'-'+formattedStartDate+'-'+formattedEndDate;
                }
                survOpty.Created_From__c= oppData.Id;
            }
            if(oppData.BD_Head__c != null){
                survOpty.BD_Head__c=oppData.BD_Head__c;
            }else if(oppData.Parent_Opportunity__c != null && oppData.Parent_Opportunity__r.BD_Head__c != null){
                survOpty.BD_Head__c=oppData.Parent_Opportunity__r.BD_Head__c;
            }
            survOpty.OwnerId = oppData.OwnerId;
            survOpty.BillingAddress__c = oppData.BillingAddress__c;
            survOpty.Opp_ICRA_Branch__c = oppData.Opp_ICRA_Branch__c;
            survOpty.Bill_To__c = oppData.Bill_To__c;
            survOpty.Rated_Entity__c = oppData.Rated_Entity__c;
            survOpty.mandate_id__c= String.valueOf(mandateID);
            survOpty.Mandate_Serial_No__c= String.valueOf(mandateSerialNo);
            survOpty.DataOne_Rollover__c= true;
            toInsertOpportunityList.add(survOpty);
        }else{
            System.Debug('Billing End Date is not present for the opportunity');
        }
        System.Debug('toInsertOpportunityList==>'+toInsertOpportunityList);
        return toInsertOpportunityList;
    }

    global class ResponseWrapper{
        global String StatusMessage;
        global String StatusCode;
    }

    public static Boolean isLeapYearBilling(Date billingStartDate, Date billingEndDate) {       
        Integer startYear = billingStartDate.year();
        Integer endYear = billingEndDate.year();

        Boolean condition1 = is_LeapYear(startYear) && 
                             billingStartDate <= Date.newInstance(startYear, 2, 29);
                             
        Boolean condition2 = is_LeapYear(endYear) && 
                             billingEndDate >= Date.newInstance(endYear, 2, 29);
                             
        Boolean condition3 = startYear < endYear && 
                             is_LeapYear(endYear);

        return condition1 || condition2 || condition3;
    }

    public static Boolean is_LeapYear(Integer year) {
        return (Math.mod(year, 4) == 0) && (Math.mod(year, 100) != 0 || Math.mod(year, 400) == 0);
    }
}