/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-29-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   06-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class CreateRollingOpportunityBatch_FromProd  implements Database.Batchable<sObject> {
    string AccountnameParameter;
    string OpportunityIdParameter;
    public CreateRollingOpportunityBatch_FromProd(string Acc, string opp_Id)
    {
        this.AccountnameParameter=Acc;
        this.OpportunityIdParameter=opp_Id;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String toBeBilled = 'To Be Billed';
        String alreadyBilled = 'Already Billed';
        String clientStatus = 'Live';
        String recordType ='Surveillance';
        String accountName =AccountnameParameter;
        String opportunityId =OpportunityIdParameter;
        //String accountName2 = 'Chaitanya India Fin Credit Private Limited2';
        //and Account.name=:accountName
         Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        String soqlquery = 'SELECT Id,Alignment_Logic__c,Change_in_start_Date__c,Is_First_Child_Surv__c,Account.OwnerId,Skip_Date_Alignment__c, Opportunity_Batch_Process__c, Name,Description,StageName,Amount,CloseDate,Type,Sum_of_Volume_of_Debt__c,Mandate_Received_Date__c,Rated_by_FFP_del__c,QTR__c,Year__c,Total_Invoice_Amount__c,Balance_Amount__c,Last_Invoice_Date__c,Capped_Amount__c,Team_Member__c,Team_Manager__c,Team_Leader__c,Location_Head__c,Commercial_Head__c,Revised_Agreed_Amount_from_Credit_Note__c,OPE__c,Execution_Team__c,Execution_status__c,BLR_Sub_Instrument_1__c,BLR_Sub_Instrument_2__c,Requested_Fee__c,Minimum_ASF__c,Discount_Type__c,Write_off__c,Reason_for_write_off__c,ASF_Agreement_with_Client__c,Mark_in_case_of_SO_CE__c,Auto_Calculated_Amount__c,Reason__c,Comment__c,Annual_Initial_Rating_Amount__c,Annual_Surveillance_Opportunities_Amount__c,BLR_Sub_Instrument_3__c,Revised_Agreed_Amount__c,Analyst__c,Co_Analyst__c,Sector_Head__c,Group_Head__c,PAN_Number__c,TAN_Number__c,GST_Number__c,Instrument_type_1__c,Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Expected_Deferred_Date__c,Payment_Receipt_SGST__c,Annual_Credit_Note_Amount__c,Mandate_Type__c,Last_PR_Date__c,Parent_Opportunity__c,Likely_Initial_Rating_Fee__c,Business_Segment__c,Lead_Source__c,Write_off_date__c,Remarks_If_any__c,Instrument_Type_5__c,Contact__c,If_Others_then_specify__c,ASF_Calculated_Formula__c,IRF_Final_Amount__c,Amt_of_CAP_fee__c,IRF1__c,ASF__c,ASF_Applied_Discount__c,IRF_BPS__c,ASF_BPS__c,ASF_Final_Amount__c,IRF_Applied_Discount__c,MIS_Support__c,BLR_Sub_Instrument_4__c,BLR_Sub_Instrument_5__c,Volume_of_Debt_1_amount__c,Volume_of_Debt_2_Amount__c,Volume_of_Debt_3_amount__c,Volume_of_Debt_4_amount__c,Volume_of_Debt_5_amount__c,Loss_Reason__c,Crore_or_Million__c,Others_Reasons_Only_for_Fresh_Other__c,Lost_To__c,Line_of_Business__c,Sector__c,Sub_Sector__c,Branch__c,Debt_OR_Balance_Sheet_Size__c,BD_Team_Classification__c,Focus_Group__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,Conversion_Probability__c,Customer_Fee_Type__c,Discount_Required__c,Reason_for_Discount__c,Approving_Authority_as_per_DoA__c,Provision_to_be_made__c,Reason_for_provision__c,Provision_Date__c,Defer_Billing_or_Exit_Case__c,Surveillance_Billing_period__c,Bill_Date__c,Billing_Start_Date__c,Billing_End_date__c,Debtor_Period__c,Fee_Outstanding__c,Actual_Surveillance_Fee__c,Chance_of_Retention__c,Non_Cooperation_Withdrawal_Reason__c,Revenue_Loss_in_Rs__c,Fee_received__c,Rating_Validity_Till__c,Last_RC_Date__c,Detailed_Comment__c,Discount_Requested__c,Size_to_be_rated_this_year_in_Cr_M__c,Size_rated_last_year_in_Cr_M__c,Volume_of_Debt_Category__c,Type_Tender__c,Client_Status__c,Amount_to_be_provisioned_In_Rs__c,Amount_to_be_written_off_In_Rs__c,Provisioned_Detailed_Remarks__c,Written_Off_Detailed_Remarks__c,Amount_Outstanding_In_Rs__c,Opportunity_Closed_Date__c,PR_Date__c,Amount_To_Be_Billed__c,Finance_Team__c,Past_Invoice_Number__c,Annual_Surveillance_Opp_Amount__c,Total_Invoice_Amount_1__c,Bill_To__c,Third_Party_Bill_To__c,Narration_for_Invoice__c,Actual_Billing_Start_Date__c,Actual_Billing_End_Date__c,Related_Opportunity_Count__c,AccountId,RecordType.Name,Rolling_and_Date_Alignmnet__c,Billing_Year_FY__c,Scheme_Trust_Name__c,OwnerId,Opp_ICRA_Branch__c,Rated_Entity__c,BillingAddress__c FROM Opportunity' ;
        soqlquery +=' WHERE Billing_Start_Date__c != null AND Client_Status__c =: clientStatus AND Billing_End_date__c != null AND (Defer_Billing_or_Exit_Case__c = :toBeBilled OR Defer_Billing_or_Exit_Case__c = :alreadyBilled) AND ASF_Final_Amount__c > 1 AND Rolling_and_Date_Alignmnet__c = false AND RecordType.Name = : recordType and Account.name=:AccountName and Id=:opportunityId';
        System.debug('Get query' +soqlquery); 
       return Database.getQueryLocator(soqlquery);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        System.debug('======= opportunityList =======:  '+opportunityList.size());
        Map<Id, List<Opportunity>> opportunityAccountMap = new Map<Id, List<Opportunity>>(); 
        Date todayDate= System.today();

        Set<String> instrumentType1Set = new Set<String>();
        Set<String> instrumentType2Set = new Set<String>();
        Set<String> instrumentType3Set = new Set<String>();
        Set<String> instrumentType4Set = new Set<String>();

        for (Opportunity opp : opportunityList) {
            instrumentType1Set.add(opp.Instrument_type_1__c);
            instrumentType2Set.add(opp.Instrument_type_2__c);
            instrumentType3Set.add(opp.Instrument_type_3__c);
            instrumentType4Set.add(opp.Instrument_type_4__c);
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
        for (Billing_Date__c billing : billingDates) {
            String key = billing.Instrument_type_1__c + '|' +
                         billing.Instrument_type_2__c + '|' +
                         billing.Instrument_type_3__c + '|' +
                         billing.Instrument_type_4__c;
            if (!billingDateMap.containsKey(key)) {
                billingDateMap.put(key, billing);
            }
        }

        for (Opportunity opp : opportunityList) {
            String key = opp.Instrument_type_1__c + '|' +
                         opp.Instrument_type_2__c + '|' +
                         opp.Instrument_type_3__c + '|' +
                         opp.Instrument_type_4__c;

            Billing_Date__c matchedBilling = billingDateMap.get(key);
    
            if (matchedBilling == null) {
                System.debug('No matching Billing_Date__c record found for Opportunity: ' + opp.Id);
                continue; // Skip further processing for this record
            }else{
                System.debug('Matching Billing Record Found for '+opp.Id+' =====>>>>>     '+matchedBilling);
                opp.Alignment_Logic__c= matchedBilling.Alignment_Logic__c;
            }
        }    
        update opportunityList;
        
        for(Opportunity opportunityRecord : opportunityList){
            if(opportunityRecord.AccountId != null){
                if(opportunityAccountMap.containsKey(opportunityRecord.AccountId)){
                    List<Opportunity> tempOpp = opportunityAccountMap.get(opportunityRecord.AccountId);
                    tempOpp.add(opportunityRecord); 
                    opportunityAccountMap.put(opportunityRecord.AccountId,tempOpp); 
                }else{
                    opportunityAccountMap.put(opportunityRecord.AccountId, new List<Opportunity>{opportunityRecord});
                }
            } 
        }
        
        // Debug loop   
        Map<String,List<Opportunity>> opportunityWithDateAndVod = new Map<String, List<Opportunity>>();
        
        for(String accountId : opportunityAccountMap.keySet()){ 
            
            for(Opportunity opportunityrecord : opportunityAccountMap.get(accountId)){  
                String mapkey = opportunityrecord.Instrument_type_2__c+'-'+ accountId;
                
                if(opportunityWithDateAndVod.containsKey(mapkey)){
                    List<Opportunity> tempOpp = opportunityWithDateAndVod.get(mapkey);
                    tempOpp.add(opportunityRecord); 
                    opportunityWithDateAndVod.put(mapkey,tempOpp);
 
                }else{
                    opportunityWithDateAndVod.put(mapkey, new List<Opportunity>{opportunityRecord});
                } 
            } 
        } 
        
        for(String mapkey : opportunityWithDateAndVod.keySet()){ 
            if(mapkey.contains('Bank Loan Rating')){
                System.debug('============Bank Loan Rating===============');
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){
                    blrOpportunity(sortData);
                } 
                System.debug('============ END Bank Loan Rating===============');
            }
            
            if(mapkey.contains('Money Market') || mapkey.contains('Others')){
                System.debug('============ Money Market ===============');
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){
                    moneyMarketOpportunity(sortData);
                }
                System.debug('============END Money Market ===============');
            }
        } 
        
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('======= BC =======:  '+BC);
    }
    
    public void blrOpportunity(List<Opportunity> blrOpportunityList){ 
        List<Opportunity> insertOpportunityList = new List<Opportunity>();
        List<Opportunity> updateOpportunity = new List<Opportunity>();  
        
        if(blrOpportunityList.size() > 0){    
        
            for(Opportunity opportunityrecord : blrOpportunityList){  
                //  System.debug('Name : '+opportunityrecord.Name+' ==VOD=='+opportunityrecord.VoD_in_crore__c+'== Start and End Date ======='+opportunityrecord.Billing_Start_Date__c +'====To ===='+opportunityrecord.Billing_End_Date__c+'======Amount====='+opportunityrecord.ASF_Final_Amount__c); 
                System.debug('====== Instrument_type 2 and  3 ======='+opportunityrecord.Instrument_type_2__c + '----'+opportunityrecord.Instrument_type_3__c );
                
                if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null && opportunityrecord.Opportunity_Batch_Process__c =='BLR-Date-Align' && opportunityrecord.Alignment_Logic__c!= null){  
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_date__c,opportunityrecord.Alignment_Logic__c) );
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                    // System.debug('======== Opp ====='+opportunityrecord);
                } 
            } 
        }
        
        
        if(insertOpportunityList.size() > 0){
             
            Database.SaveResult [] insertResult = Database.insert(insertOpportunityList, false);
            
            if(updateOpportunity.size() > 0){ 
                List<Opportunity> tempData = new List<Opportunity>();
                for( Opportunity record : updateOpportunity){
                    Opportunity opp = new Opportunity();
                    opp.Id =record.Id;
                    opp.Change_in_start_Date__c  = false;
                    opp.Rolling_and_Date_Alignmnet__c  = true;
                    tempData.add(opp);
                     
                }
                
                Database.SaveResult [] updateResult = Database.update (tempData , false);
            }
            
        } 
        System.debug('======blrOpportunity End========');
    }
    
    public void moneyMarketOpportunity(List<Opportunity> moneyMarketOpportunityList){ 
        
        List<Opportunity> updateOpportunity = new List<Opportunity>();        
        List<Opportunity> insertOpportunityList = new List<Opportunity>();
        
        Integer fyEndMonth = 04;
        Integer fyEndDay = 31;
        
        
        Date billingEndDate = System.today();
        Integer listSize = moneyMarketOpportunityList.size(); 
        if(moneyMarketOpportunityList.size() >0 ){ 
        
            for(Opportunity opportunityrecord : moneyMarketOpportunityList){
                                
                if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='MM-Date-FY' && opportunityrecord.Alignment_Logic__c!= null){
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                    
                } else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='MF-YF' && opportunityrecord.Alignment_Logic__c!= null) {
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                     System.debug('It is record of MF-YF');  
                } else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='BLR-Date-Align' && opportunityrecord.Alignment_Logic__c!= null) {
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                      
                }
                  //cp blr
                   else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='BLR-CP-Align' && opportunityrecord.Alignment_Logic__c!= null) {
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                   }
                    // other blr
                    else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='BLR-Other-Align' && opportunityrecord.Alignment_Logic__c!= null) {
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                    }
                    //stb blr
                    else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='BLR-STB-Align' && opportunityrecord.Alignment_Logic__c!= null) {
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                    }
                                  
                else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='MM-Date-Not-FY' && opportunityrecord.Alignment_Logic__c!= null) {
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);
                
                    
                } else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='Other' && opportunityrecord.Alignment_Logic__c!= null) {
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c));
                    
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord); 
                      
                } else if(opportunityrecord.RecordType.Name =='Surveillance' && opportunityrecord.Parent_Opportunity__c == null &&  opportunityrecord.Opportunity_Batch_Process__c =='MMSF-Date-Not-Align' && opportunityrecord.Alignment_Logic__c!= null) {
                
                    insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opportunityrecord,opportunityrecord.Billing_End_Date__c,opportunityrecord.Alignment_Logic__c)); 
                    opportunityrecord.Rolling_and_Date_Alignmnet__c = true;
                    opportunityrecord.Change_in_start_Date__c = false;
                    updateOpportunity.add(opportunityrecord);  
                }
            } 
            
        }  
        
        if(insertOpportunityList.size() > 0 ){ 
            Database.SaveResult [] insertResult = Database.insert(insertOpportunityList , false);
            
            if(updateOpportunity.size() > 0){
                List<Opportunity> tempData = new List<Opportunity>();
                
                for( Opportunity record : updateOpportunity){
                    Opportunity opp = new Opportunity();
                    opp.Id =record.Id;
                    opp.Change_in_start_Date__c  = false;
                    opp.Rolling_and_Date_Alignmnet__c  = true;
                    tempData.add(opp);
                     
                } 
                Database.SaveResult [] updateResult = Database.update (tempData , false);
            }            
        }
    }
    
    public List<Opportunity> sortOpportunity(List<Opportunity> opportunityList){
        
        Integer size = opportunityList.size();
        System.debug('========size===sort Start ====== '+size);
        for(Integer i = 0; i < size-1 ; i++){
            for(Integer j = 0; j < size-i-1 ; j++){
                if(opportunityList[j].Billing_Start_Date__c > opportunityList[j+1].Billing_Start_Date__c){
                    Opportunity temp = opportunityList[j];
                    opportunityList[j] = opportunityList[j+1];
                    opportunityList[j+1] = temp;
                }
            } 
        } 
        System.debug('========size===sort END ====== '+size);
        
        return opportunityList;
    }
    
    public List<Opportunity> createSurveillanceRollingOpportunity(Opportunity tempData, Date billingEndDate, String typeString ){
        List<Opportunity> Opty= [select Id, Mandate_ID__c,Mandate_Serial_No__c,Bill_Year__c from opportunity where mandate_id__c!=null AND Mandate_Serial_No__c!=null order by createdDate DESC LIMIT 1];
        system.debug('Batch to create rollover opportunities=======>>>>');
        system.debug('Last Created Opportunity===>>'+Opty);
        // Opportunity Opt= [select id , Update_Parent__c from opportunity where id=:tempData.Id LIMIT 1];
        // Opt.Update_Parent__c=true;
        // update Opt;
        Date today = Date.today();
        Integer currentYear = today.year();
        String financialYear;
        if (today.month() >= 4) {
            financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
        } else {
            financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
        }
        System.debug(financialYear);
        Integer mandateID= 0;
        Integer mandateSerialNo= 0;
        mandateID=Integer.valueOf(Opty[0].Mandate_ID__c);
        mandateSerialNo=Integer.valueOf(Opty[0].Mandate_Serial_No__c);
        Decimal revised_asf; 
        Date tempend = billingEndDate;
        
        List<Opportunity> insertOpportunityList = new List<Opportunity>();
        if(tempData != null ){  
            Date billingStart = System.today();  
            Date billingEnd = System.today();   
            
            if(tempData != null){
                for(Integer i = 0; i < 5; i++ ){ 
                    
                    Opportunity newRecord = new Opportunity(); 
                    if(i==0){ 
                        newRecord = tempData.clone(false, false, false,false);  
                        newRecord.Defer_Billing_or_Exit_Case__c='To Be Billed';
                        newRecord.Billing_Start_Date__c = tempend.addDays(1); // 2021-01-06 MM FY
                        newRecord.Id =null;
                        System.Debug('Alignment Logic==>'+typeString);                               // 2021-03-31 + 1 =  2022-03-31
                        if(typeString == 'Financial Year'){
                            System.debug('Financial Year Logic');
                            if(newRecord.Billing_Start_Date__c < Date.newInstance(tempend.year(), 03,31)){ 
                                newRecord.Billing_End_Date__c  = Date.newInstance(tempend.year(), 03,31); 
                                System.debug('newRecord.Billing_End_Date__c'+newRecord.Billing_End_Date__c);
                            }else{ 
                                 newRecord.Billing_End_Date__c  = Date.newInstance(tempend.year(), 03,31).addYears(1);
                                 System.debug('ELSE ==== newRecord.Billing_End_Date__c'+newRecord.Billing_End_Date__c);
                            }
                            
                        }else{
                            System.debug('12 Months Logic');
                            newRecord.Billing_End_Date__c  = tempend.addYears(1);
                            System.debug(' NOT FY ==== newRecord.Billing_End_Date__c'+newRecord.Billing_End_Date__c);
                        }
                        //newRecord.Billing_End_Date__c = typeString == 'FY' ? Date.newInstance(tempend.year(), 03,31).addYears(1) : tempend.addYears(1);
                        newRecord.Name += '-'+ newRecord.VoD_in_crore__c + '-' + newRecord.Billing_Start_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        if(tempData.Skip_Date_Alignment__c == true){
                           newRecord.Change_in_start_Date__c = false; 
                            system.debug('Change_in_start_Date__c == '+newRecord.Change_in_start_Date__c);
                        }
                        else{
                            newRecord.Change_in_start_Date__c = true;
                        }
                        if(tempData.Requested_Fee__c!=null){
                            revised_asf= tempData.Requested_Fee__c;
                        }
                        newRecord.ASF_Final_Amount__c= revised_asf==null ? tempData.ASF_Final_Amount__c : revised_asf;
                        newRecord.Requested_Fee__c= null;
                        system.debug('Change_in_start_Date__c == '+newRecord.Change_in_start_Date__c);
                        billingStart = newRecord.Billing_End_Date__c.addDays(1);
                        newRecord.Is_First_Child_Surv__c = true;
                        newRecord.Rolling_and_Date_Alignmnet__c = true; 
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Amount_To_Be_Billed__c = feeAmountCalculation(newRecord.Billing_Start_Date__c,newRecord.Billing_End_Date__c,newRecord.ASF_Final_Amount__c);
                        system.debug('   Amount_To_Be_Billed__c  '+newRecord.Amount_To_Be_Billed__c);
                        system.debug('   Billing_Start_Date__c  '+newRecord.Billing_Start_Date__c);
                        system.debug('   Billing_End_Date__c  '+newRecord.Billing_End_Date__c);
                        system.debug('   ASF_Final_Amount__c  '+newRecord.ASF_Final_Amount__c);
                        newRecord.Parent_Opportunity__c = tempData.Id;
                        //billingEnd = typeString == 'FY' ? Date.newInstance(tempend.year(), 03,31).addYears(1) : tempend.addYears(1); //Date.newInstance(tempOpportunity.Billing_End_Date__c.year(), 03,31)
                       billingEnd = newRecord.Billing_End_Date__c;

                       if(Opty[0].Bill_Year__c== financialYear){
                        newRecord.Mandate_ID__c=String.valueOf(mandateID+1);
                        newRecord.Mandate_Serial_No__c=String.valueOf(mandateSerialNo+1);
                        }else{
                            newRecord.Mandate_ID__c=financialYear+'0000'+String.valueOf(i+1);
                            newRecord.Mandate_Serial_No__c=String.valueOf(i+1);
                        }
                        mandateID++;
                        mandateSerialNo++;
                    }else{ 
                        newRecord =   tempData.clone(false, false, false,false); 
                        newRecord.Defer_Billing_or_Exit_Case__c='To Be Billed';
                        newRecord.Billing_Start_Date__c = billingEnd.addDays(1);
                        newRecord.Billing_End_Date__c = billingEnd.addYears(1);
                        newRecord.Name += '-' + newRecord.VoD_in_crore__c + '-' + newRecord.Billing_Start_Date__c.year();
                        newRecord.CloseDate = newRecord.Billing_Start_Date__c;
                        billingStart = newRecord.Billing_Start_Date__c;  
                        billingEnd = newRecord.Billing_End_Date__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;
                        newRecord.Parent_Opportunity__c = tempData.Id;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Change_in_start_Date__c = true;
                        if(tempData.Requested_Fee__c!=null){
                            revised_asf= tempData.Requested_Fee__c;
                        }
                        newRecord.ASF_Final_Amount__c= revised_asf==null ? tempData.ASF_Final_Amount__c : revised_asf;
                        newRecord.Requested_Fee__c= null;
                        newRecord.Amount_To_Be_Billed__c = feeAmountCalculation(newRecord.Billing_Start_Date__c,newRecord.Billing_End_Date__c,newRecord.ASF_Final_Amount__c);
                        newRecord.Id =null;
                        if(Opty[0].Bill_Year__c== financialYear){
                            newRecord.Mandate_ID__c=String.valueOf(mandateID+1);
                            newRecord.Mandate_Serial_No__c=String.valueOf(mandateSerialNo+1);
                            }else{
                                newRecord.Mandate_ID__c=financialYear+'0000'+String.valueOf(i+1);
                                newRecord.Mandate_Serial_No__c=String.valueOf(i+1);
                            }
                        mandateID++;
                        mandateSerialNo++;
                    }
                    newRecord.OwnerId = tempData.OwnerId;
                    newRecord.Opp_ICRA_Branch__c = tempData.Opp_ICRA_Branch__c;
                    newRecord.Team_Member__c = tempData.Team_Member__c;
                    newRecord.Rated_Entity__c = tempData.Rated_Entity__c;
                    newRecord.BillingAddress__c = tempData.BillingAddress__c;
                    newRecord.Team_Leader__c = tempData.Team_Leader__c;
                    newRecord.Bill_To__c = tempData.Bill_To__c;
                    newRecord.Payment_Receipt_Base_Amount__c = null;
                    newRecord.Payment_Receipt_CGST__c = null;
                    newRecord.Payment_Receipt_IGST__c = null;
                    newRecord.Payment_Receipt_SGST__c = null;
                    insertOpportunityList.add(newRecord);  
                }
            }
        }
        System.debug('@@@@@@insertOpportunityList'+insertOpportunityList);
        return insertOpportunityList;
    } 
    
    public Decimal feeAmountCalculation(Date startDate, Date endDate, Decimal amount){ 
        
        integer numberOfDays = startDate.daysBetween(endDate)+1;
        Integer yearDays =0;
        Decimal perDay = 0;
        Decimal totalAmount = 0;
        system.debug('numberOfDays'+numberOfDays);
        if(Date.isLeapYear(startDate.year())){
            yearDays = 366; 
            perDay = perday = amount.divide(366,2);
        }else if(numberOfDays < 365){
            
            perDay = perday = amount.divide(365,2);
            system.debug('perDay'+perDay);
        }else{
            yearDays = 365;
            perDay = perday = amount.divide(365,2);
            system.debug('perDay'+perDay);
        }
         
        if(yearDays >= 365){
            totalAmount = amount;
            system.debug('totalAmount year>365 '+totalAmount);
        }else{
            totalAmount = (perDay * numberOfDays).round(System.RoundingMode.CEILING);
            system.debug('totalAmount '+totalAmount);
        } 
        
        return totalAmount;  
    }
}