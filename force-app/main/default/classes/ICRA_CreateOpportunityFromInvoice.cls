public class ICRA_CreateOpportunityFromInvoice {
    
    @InvocableMethod
    public static void creatOpportunity(List<Invoice_Line_Item__c> lineList){
        
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<Id> opportunityparentSet = new Set<Id>();
        Map<Id, List<Opportunity>> opportunityMap = new Map<Id, List<Opportunity>>(); 
        List<Opportunity> opportuityList = new List<Opportunity>();
        List<Opportunity> insertopportuityList = new List<Opportunity>();
        
        for(Invoice_Line_Item__c lineRecord : lineList){
            if(lineRecord.Opportunity_Name__c != null){ 
                opportunityIdSet.add(lineRecord.Opportunity_Name__c ); 
            } 
        }
        
        for(Opportunity oppRecord : [SELECT Id , Parent_Opportunity__c , Name FROM Opportunity WHERE Id IN: opportunityIdSet]){
            if(oppRecord.Parent_Opportunity__c != null){
                opportunityparentSet.add(oppRecord.Parent_Opportunity__c);
            } else{
                opportunityparentSet.add(oppRecord.Id);
            }  
        }  
        
        for(Opportunity oppRecord : [ 
            SELECT Id, Change_in_start_Date__c, Name,Description,StageName,Amount,CloseDate,Type,Sum_of_Volume_of_Debt__c,Mandate_Received_Date__c,Rated_by_FFP_del__c,
            Total_Payment_Received__c,QTR__c,Year__c,Total_Invoice_Amount__c,Balance_Amount__c,Last_Invoice_Date__c,Capped_Amount__c,Team_Member__c,Team_Manager__c,
            Team_Leader__c,Location_Head__c,Commercial_Head__c,Revised_Agreed_Amount_from_Credit_Note__c,OPE__c,Quality_Analyst__c,Execution_status__c,BLR_Sub_Instrument_1__c,
            BLR_Sub_Instrument_2__c,Minimum_ASF__c,Discount_Type__c,Write_off__c,Reason_for_write_off__c,ASF_Agreement_with_Client__c,Mark_in_case_of_SO_CE__c,
            Auto_Calculated_Amount__c,Reason__c,Comment__c,Annual_Initial_Rating_Amount__c,Annual_Surveillance_Opportunities_Amount__c,BLR_Sub_Instrument_3__c,
            Revised_Agreed_Amount__c,Analyst__c,Co_Analyst__c,Sector_Head__c,Group_Head__c,PAN_Number__c,TAN_Number__c,GST_Number__c,Instrument_type_1__c,
            Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Expected_Deferred_Date__c,
            Payment_Receipt_Base_Amount__c,Payment_Receipt_SGST__c,Payment_Receipt_CGST__c,Payment_Receipt_IGST__c,
            Annual_Credit_Note_Amount__c,Mandate_Type__c,Last_PR_Date__c,Parent_Opportunity__c,Likely_Initial_Rating_Fee__c,
            Business_Segment__c,Lead_Source__c,Write_off_date__c,Remarks_If_any__c,Instrument_Type_5__c,Contact__c,If_Others_then_specify__c,
            ASF_Calculated_Formula__c,IRF_Final_Amount__c,Amt_of_CAP_fee__c,IRF1__c,ASF__c,ASF_Applied_Discount__c,IRF_BPS__c,ASF_BPS__c,ASF_Final_Amount__c,   
            IRF_Applied_Discount__c,MIS_Support__c,BLR_Sub_Instrument_4__c,BLR_Sub_Instrument_5__c,Volume_of_Debt_1_amount__c,Volume_of_Debt_2_Amount__c,Volume_of_Debt_3_amount__c,
            Volume_of_Debt_4_amount__c,Volume_of_Debt_5_amount__c,Loss_Reason__c,Crore_or_Million__c,Others_Reasons_Only_for_Fresh_Other__c,Lost_To__c,Line_of_Business__c,
            Sector__c,Sub_Sector__c,Branch__c,Debt_OR_Balance_Sheet_Size__c,BD_Team_Classification__c,Focus_Group__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,
            ASF_as_per_Agreement_BPS__c,Conversion_Probability__c,Customer_Fee_Type__c,Discount_Required__c,Reason_for_Discount__c,Approving_Authority_as_per_DoA__c,
            Provision_to_be_made__c,Reason_for_provision__c,Provision_Date__c,Defer_Billing_or_Exit_Case__c,Surveillance_Billing_period__c,Bill_Date__c,
            Billing_Start_Date__c,Billing_End_date__c,Debtor_Period__c,Fee_Outstanding__c,Actual_Surveillance_Fee__c,Chance_of_Retention__c,Non_Cooperation_Withdrawal_Reason__c,
            Revenue_Loss_in_Rs__c,Fee_received__c,Rating_Validity_Till__c,Last_RC_Date__c,Requested_Fee__c,Detailed_Comment__c,Discount_Requested__c,Size_to_be_rated_this_year_in_Cr_M__c,
            Size_rated_last_year_in_Cr_M__c,Volume_of_Debt_Category__c,Type_Tender__c,Client_Status__c,Amount_to_be_provisioned_In_Rs__c,Amount_to_be_written_off_In_Rs__c,Provisioned_Detailed_Remarks__c,
            Written_Off_Detailed_Remarks__c,Amount_Outstanding_In_Rs__c,Opportunity_Closed_Date__c,PR_Date__c,Amount_To_Be_Billed__c,
            Annual_Surveillance_Opp_Amount__c,Total_Invoice_Amount_1__c,Bill_To__c,Third_Party_Bill_To__c,Narration_for_Invoice__c,Actual_Billing_Start_Date__c,
            Actual_Billing_End_Date__c,Related_Opportunity_Count__c,AccountId,RecordType.Name,Rolling_and_Date_Alignmnet__c,Billing_Year_FY__c, Parent_Opportunity__r.Name
            FROM Opportunity 
            WHERE (ID = : opportunityIdSet OR Parent_Opportunity__c = : opportunityparentSet )  AND 
            RecordType.Name = 'Surveillance'
            ORDER BY Name ASC
        ]){  
            
            System.debug('================ oppRecord ====='+oppRecord);
            if(oppRecord.Parent_Opportunity__c != null){
                if(opportunityMap.containsKey(oppRecord.Parent_Opportunity__c)){
                    opportunityMap.get(oppRecord.Parent_Opportunity__c).add(oppRecord);
                }else{
                    opportunityMap.put(oppRecord.Parent_Opportunity__c, new List<Opportunity>{oppRecord});
                }
            }else{
                if(opportunityMap.containsKey(oppRecord.Id)){
                    opportunityMap.get(oppRecord.Id).add(oppRecord);
                }else{
                    opportunityMap.put(oppRecord.Id, new List<Opportunity>{oppRecord});
                }
            }
            if(opportunityIdSet.contains(oppRecord.Id)){
                opportuityList.add(oppRecord);
            }
        }
        
        if(opportuityList.size() > 0){
            for(Opportunity opportunityRecord : opportuityList){
                if(opportunityRecord.Parent_Opportunity__c != null){
                    if(opportunityMap.containsKey(opportunityRecord.Parent_Opportunity__c)){
                        
                        Opportunity tempOpportunity = sortOpportunity(opportunityMap.get(opportunityRecord.Parent_Opportunity__c))[0];
                        Opportunity tempOpportunityClone = new Opportunity();
                        tempOpportunityClone =  tempOpportunity.clone(false, false, false,false);
                        tempOpportunityClone.Id = null;
                        tempOpportunityClone.Billing_Start_Date__c = tempOpportunity.Billing_END_Date__c.addDays(1);
                        tempOpportunityClone.Billing_End_Date__c =tempOpportunity.Billing_END_Date__c.addYears(1);
                        tempOpportunityClone.CloseDate = tempOpportunity.Billing_END_Date__c.addDays(1);
                        tempOpportunityClone.Name =  tempOpportunity.Parent_Opportunity__r.Name+'-'+tempOpportunity.Billing_End_Date__c.year(); 
                        insertopportuityList.add(tempOpportunityClone);
                    } 
                }else{
                    if(opportunityMap.containsKey(opportunityRecord.Id)){
                        Opportunity tempOpportunity = sortOpportunity(opportunityMap.get(opportunityRecord.Id))[0];
                        Opportunity tempOpportunityClone = new Opportunity();
                        tempOpportunityClone =  tempOpportunity.clone(false, false, false,false);
                        tempOpportunityClone.Id = null;
                        tempOpportunityClone.Parent_Opportunity__c = opportunityRecord.Id;
                        tempOpportunityClone.Billing_Start_Date__c = tempOpportunity.Billing_END_Date__c.addDays(1);
                        tempOpportunityClone.Billing_End_Date__c =tempOpportunity.Billing_END_Date__c.addYears(1);
                        tempOpportunityClone.CloseDate = tempOpportunity.Billing_END_Date__c.addDays(1);
                        tempOpportunityClone.Name =  tempOpportunity.Parent_Opportunity__r.Name+'-'+tempOpportunity.Billing_End_Date__c.year(); 
                        insertopportuityList.add(tempOpportunityClone);
                    }
                }
            } 
        }  
        
        if(insertopportuityList.size() > 0){ 
            Database.SaveResult [] result = Database.insert(insertopportuityList, false);
        }
        
    }  
    
    public static List<Opportunity> sortOpportunity(List<Opportunity> opportunityList){ 
        Integer size = opportunityList.size(); 
        for(Integer i = 0; i < size-1 ; i++){
            for(Integer j = 0; j < size-i-1 ; j++){
                if(opportunityList[j].Billing_End_Date__c < opportunityList[j+1].Billing_End_Date__c){
                    Opportunity temp = opportunityList[j];
                    opportunityList[j] = opportunityList[j+1];
                    opportunityList[j+1] = temp;
                }
            } 
        } 
        return opportunityList;
    }
}