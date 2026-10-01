/**
 * ICRA_CreateSurveillanceViaTLogic
 *
 * Handles creation of Surveillance opportunities via T-Logic.
 */
public with sharing class ICRA_CreateSurveillanceViaTLogic {
    /**
     * Parameter wrapper to reduce long parameter lists and improve readability.
     */
    public class CreateSurvParams {
        public Integer mandateID;
        public Integer mandateSerialNo;
        public String alignmentLogic;
        public Integer recordCount;
        public Date processDate;
        public CreateSurvParams(){}
    }

    public List<Opportunity> createSurveillanceViaTLogic(Opportunity opty, Integer mandateID, Integer mandateSerialNo, String alignmentLogic, Integer recordCount, Date processDate){
        CreateSurvParams p = new CreateSurvParams();
        p.mandateID = mandateID;
        p.mandateSerialNo = mandateSerialNo;
        p.alignmentLogic = alignmentLogic;
        p.recordCount = recordCount;
        p.processDate = processDate;
        return createSurveillanceViaTLogic(opty, p);
    }

    /**
     * Primary method using a parameter wrapper.
     */
    public List<Opportunity> createSurveillanceViaTLogic(Opportunity opty, CreateSurvParams params){
        system.debug('Batch to create rollover opportunities:=======>>>>');

    Date revisedBillingEndDate= opty.Revised_Billing_End_Date__c==null ? opty.Billing_End_Date__c : opty.Revised_Billing_End_Date__c;
    List<Opportunity> futureOptyCheck = new List<Opportunity>();
    Id parentOppId = opty.Parent_Opportunity__c;
    Id oppId = opty.Id;
    Id businessSectorId = opty.Account.Business_Sector__c;
    Id oppOwnerId = opty.OwnerId;

    if(opty.Parent_Opportunity__c != null){
        futureOptyCheck = [SELECT Id,Billing_Start_Date__c, Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppId and Billing_Start_Date__c>: revisedBillingEndDate LIMIT 1]; //to check whether the T-Hit opportunity's parent has any child record with Billing Start Date greater than the Billing End Date of T-Hit opportunity, if yes then it will not create surveillance opportunity to avoid duplicates. If no child record is present then it will create surveillance opportunity. 
        
    }else{
        futureOptyCheck = [SELECT Id,Billing_Start_Date__c,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :oppId and Billing_Start_Date__c>: revisedBillingEndDate LIMIT 1]; //to check whether the T-Hit opportunity has any child record, if yes then it will not create surveillance opportunity to avoid duplicates. If no child record is present then it will create surveillance opportunity. 
}
        List<Opportunity> toinsertOpportunityList = new List<Opportunity>();
        if(opty.Surveillance_Created_via_T_Logic__c==false && opty.Child_updated_via_T_Logic__c==false && opty != null && futureOptyCheck.isEmpty()){
            Id survRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
            String instrumentType4='';
            if(opty.Instrument_type_4__c=='Bank Loan Rating Fresh'){
                instrumentType4='Bank Loan Rating';
            } else {
                instrumentType4=opty.Instrument_type_4__c;
            }
            Date today = params.processDate;
            Integer currentYear = today.year();
            String financialYear;
            if (today.month() >= 4) {
                financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
            } else {
                financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
            }

            List<Team_Leader_Mapping__c> teamLeaderList = [SELECT Id, Team_Leader__c, Status__c FROM Team_Leader_Mapping__c WHERE Business_Sector__c = :businessSectorId AND Individual_Contributor__c = :oppOwnerId AND Status__c = 'Active' LIMIT 1];
            Id teamLeader = teamLeaderList.isEmpty() ? opty.Owner.ManagerId : teamLeaderList[0].Team_Leader__c;

            System.debug(financialYear);
                Decimal revisedIrf;
                String formattedStartDate;
                String formattedEndDate;
                Date billingStartDate;
                Date billingEndDate;
                Date billingEndDate2;
                Date revisedEndDate;
                Decimal revisedASF;
                Decimal revisedVoD;
                Boolean isLeapYear;

                revisedEndDate= opty.Revised_Billing_End_Date__c==null ? opty.Billing_End_Date__c : opty.Revised_Billing_End_Date__c;
                revisedVoD= opty.Size_to_be_rated_this_year_in_Cr_M__c==null ? opty.VoD_in_crore__c : opty.Size_to_be_rated_this_year_in_Cr_M__c;
                revisedASF= opty.Requested_Fee__c==null ? opty.ASF_Final_Amount__c : opty.Requested_Fee__c;
                billingStartDate= revisedEndDate.addDays(1);
                billingEndDate2= billingStartDate.addYears(1);
                isLeapYear= isLeapYearBilling(billingStartDate, billingEndDate2);
                //System.Debug('isLeapYear==>'+isLeapYear);
                if(isLeapYear){
                    billingEndDate= billingStartDate.addDays(365);
                }else{
                    billingEndDate= billingStartDate.addDays(364);
                }

                if(params.alignmentLogic!=null && params.alignmentLogic=='Financial Year' && (params.recordCount==null || params.recordCount<1)){
                    if(billingStartDate.month()>=4){
                        billingEndDate= Date.parse('31/03/'+string.valueOf(billingEndDate.year()));
                    }else if(billingStartDate.month()<4){
                        billingEndDate= Date.parse('31/03/'+string.valueOf(billingStartDate.year()));
                    }
                }
                Opportunity survOpty = new Opportunity();
                    survOpty.AccountId=opty.AccountId;
                    survOpty.Instrument_Category__c=opty.Instrument_Category__c;
                    survOpty.Billing_Start_Date__c= billingStartDate;
                    survOpty.Billing_End_Date__c= billingEndDate;
                    survOpty.Client_Status__c='Live'; 
                    survOpty.Customer_Fee_Type__c=opty.Customer_Fee_Type__c;
                    survOpty.Business_Segment__c=opty.Business_Segment__c;
                    survOpty.StageName='Closed Won'; 
                    survOpty.Contact__c=opty.Contact__c;
                    survOpty.Instrument_type_1__c=opty.Instrument_type_1__c;
                    survOpty.Instrument_type_2__c=opty.Instrument_type_2__c;
                    survOpty.Instrument_type_3__c=opty.Instrument_type_3__c;
                    if(opty.Instrument_type_4__c=='Bank Loan Rating Fresh'){
                        survOpty.Instrument_type_4__c='Bank Loan Rating';
                    }else{
                        survOpty.Instrument_type_4__c=opty.Instrument_type_4__c;
                    }
                    survOpty.BLR_Sub_Instrument_1__c=opty.BLR_Sub_Instrument_1__c;
                    survOpty.BLR_Sub_Instrument_2__c=opty.BLR_Sub_Instrument_2__c;
                    survOpty.BLR_Sub_Instrument_3__c=opty.BLR_Sub_Instrument_3__c;
                    survOpty.BLR_Sub_Instrument_4__c=opty.BLR_Sub_Instrument_4__c;
                    survOpty.BLR_Sub_Instrument_5__c=opty.BLR_Sub_Instrument_5__c;
                    survOpty.Remarks_If_any__c=opty.Remarks_If_any__c;
                    survOpty.Volume_of_Debt_1_amount__c=opty.Volume_of_Debt_1_amount__c;
                    survOpty.Volume_of_Debt_2_Amount__c=opty.Volume_of_Debt_2_Amount__c;
                    survOpty.Volume_of_Debt_3_amount__c=opty.Volume_of_Debt_3_amount__c;
                    survOpty.Volume_of_Debt_4_amount__c=opty.Volume_of_Debt_4_amount__c;
                    survOpty.Volume_of_Debt_5_amount__c=opty.Volume_of_Debt_5_amount__c;
                    survOpty.CurrencyIsoCode=opty.CurrencyIsoCode;
                    survOpty.VoD_in_crore__c=revisedVoD;
                    survOpty.ASF_Agreement_with_Client__c=opty.ASF_Agreement_with_Client__c;
                    survOpty.OPE__c=opty.OPE__c;
                    survOpty.Minimum_ASF__c=opty.Minimum_ASF__c;
                    survOpty.Amt_of_CAP_fee__c=opty.Amt_of_CAP_fee__c;
                    survOpty.Actual_Surveillance_Fee__c=opty.Actual_Surveillance_Fee__c;
                    survOpty.Rolling_and_Date_Alignmnet__c = true;
                    survOpty.Fee_Outstanding__c=opty.Fee_Outstanding__c;
                    survOpty.Chance_of_Retention__c=opty.Chance_of_Retention__c;
                    survOpty.Revenue_Loss_in_Rs__c=opty.Revenue_Loss_in_Rs__c;
                    survOpty.Rating_Validity_Till__c=opty.Rating_Validity_Till__c;
                    survOpty.Mandate_Received_Date__c=opty.Mandate_Received_Date__c;
                    survOpty.Change_in_start_Date__c = false ;
                    survOpty.Fee_received__c=opty.Fee_received__c;
                    survOpty.Non_Cooperation_Withdrawal_Reason__c=opty.Non_Cooperation_Withdrawal_Reason__c;
                    survOpty.Last_RC_Date__c=opty.Last_RC_Date__c;
                    survOpty.Description=opty.Description;
                    survOpty.Write_off__c=opty.Write_off__c;
                    survOpty.Write_off_date__c=opty.Write_off_date__c;
                    survOpty.Written_Off_Detailed_Remarks__c=opty.Written_Off_Detailed_Remarks__c;
                    survOpty.Reason_for_write_off__c=opty.Reason_for_write_off__c;
                    survOpty.Amount_to_be_written_off_In_Rs__c=opty.Amount_to_be_written_off_In_Rs__c;
                    survOpty.Discount_Required__c=opty.Discount_Required__c;
                    survOpty.Discount_Type__c=opty.Discount_Type__c;
                    survOpty.Detailed_Comment__c=opty.Detailed_Comment__c;
                    survOpty.Size_rated_last_year_in_Cr_M__c=opty.Size_rated_last_year_in_Cr_M__c;
                    survOpty.Reason_for_Discount__c=opty.Reason_for_Discount__c;
                    survOpty.Approving_Authority_as_per_DoA__c=opty.Approving_Authority_as_per_DoA__c;
                    survOpty.Revised_Agreed_Amount__c=opty.Revised_Agreed_Amount__c;
                    survOpty.Provision_to_be_made__c=opty.Provision_to_be_made__c;
                    survOpty.Provision_Date__c=opty.Provision_Date__c;
                    survOpty.Provisioned_Detailed_Remarks__c=opty.Provisioned_Detailed_Remarks__c;
                    survOpty.Reason_for_provision__c=opty.Reason_for_provision__c;
                    survOpty.Amount_to_be_provisioned_In_Rs__c=opty.Amount_to_be_provisioned_In_Rs__c;
                    survOpty.Defer_Billing_or_Exit_Case__c='To Be Billed';
                    survOpty.Reason__c=opty.Reason__c;
                    survOpty.CloseDate=System.Today();
                    survOpty.Approved_by_Commercial_Head__c=opty.Approved_by_Commercial_Head__c;
                    survOpty.Legal_Compliance_Approval__c=opty.Legal_Compliance_Approval__c;
                    survOpty.Approved_by_MD_CEO_Group__c=opty.Approved_by_MD_CEO_Group__c;
                    survOpty.Additional_Discount_Approved__c=opty.Additional_Discount_Approved__c;
                    survOpty.Team_Manager__c=opty.Team_Manager__c;
                    survOpty.Location_Head__c=opty.Location_Head__c;
                    survOpty.MIS_Support__c=opty.MIS_Support__c;
                    survOpty.Analyst__c=opty.Analyst__c;
                    survOpty.Co_Analyst__c=opty.Co_Analyst__c;
                    survOpty.Quality_Analyst__c=opty.Quality_Analyst__c;
                    survOpty.Sector_Head__c=opty.Sector_Head__c;
                    survOpty.Group_Head__c=opty.Group_Head__c;
                    survOpty.Scheme_Trust_Name__c=opty.Scheme_Trust_Name__c;
                    survOpty.Rollover_Check__c=true;
                    survOpty.recordTypeID= survRecordTypeId;
                    survOpty.Related_Opportunity_Count__c= opty.Related_Opportunity_Count__c==null ? 1 : opty.Related_Opportunity_Count__c+1;
                    survOpty.ASF_Final_Amount__c= revisedASF;
                    survOpty.IRF_Final_Amount__c= opty.IRF_Final_Amount__c;
                    survOpty.Requested_Fee__c= null;
                    survOpty.PR_Date__c = null;

                    DateTime startDateTime = DateTime.newInstance(survOpty.Billing_Start_Date__c.year(), survOpty.Billing_Start_Date__c.month(), survOpty.Billing_Start_Date__c.day(), 0, 0, 0);
                    DateTime endDateTime = DateTime.newInstance(survOpty.Billing_End_Date__c.year(), survOpty.Billing_End_Date__c.month(), survOpty.Billing_End_Date__c.day(), 0, 0, 0);
                    formattedStartDate = startDateTime.format('MMM-yy');
                    formattedEndDate = endDateTime.format('MMM-yy');

                    if(opty.recordType.Name=='New Business'){
                        survOpty.Parent_Opportunity__c = opty.Id;
                        survOpty.Name=opty.Name+'-Surveillence-'+revisedVoD+'-'+formattedStartDate+'-'+formattedEndDate;
                        survOpty.Created_From__c= opty.Id;
                        survOpty.VoD_Currency__c= opty.VoD_Currency__c;
                    }else if(opty.recordType.Name=='Surveillance' && opty.Parent_Opportunity__c != null){
                        survOpty.Parent_Opportunity__c = opty.Parent_Opportunity__c;
                        survOpty.Name=opty.Parent_Opportunity__r.Name+'-Surveillence-'+revisedVoD+'-'+formattedStartDate+'-'+formattedEndDate;
                        survOpty.Created_From__c= opty.Id;
                        survOpty.VoD_Currency__c= opty.Parent_Opportunity__r.VoD_Currency__c;
                    }else{
                        survOpty.Parent_Opportunity__c = opty.Id;
                        survOpty.Name=opty.Name+'-Surveillence-'+revisedVoD+'-'+formattedStartDate+'-'+formattedEndDate;
                        survOpty.Created_From__c= opty.Id;
                        survOpty.VoD_Currency__c= opty.VoD_Currency__c;
                    }
                    survOpty.OwnerId = opty.OwnerId;
                    survOpty.Team_Member__c = opty.OwnerId;
                    survOpty.Team_Leader__c = teamLeader;
                    survOpty.Finance_Team__c = opty.Opp_ICRA_Branch__r.Finance_Email_ID_User__c;
                    survOpty.BD_Head__c = opty.Account.Business_Sector__r.Business_Head__c;
                    survOpty.Commercial_Head__c=opty.Commercial_Head__c;
                    survOpty.BillingAddress__c = opty.BillingAddress__c;
                    survOpty.Opp_ICRA_Branch__c = opty.Opp_ICRA_Branch__c;
                    survOpty.Bill_To__c = opty.Bill_To__c;
                    survOpty.Rated_Entity__c = opty.Rated_Entity__c;
                    survOpty.mandate_id__c= String.valueOf(params.mandateID);
                    survOpty.Mandate_Serial_No__c= String.valueOf(params.mandateSerialNo);
                    survOpty.T_Logic_Rollover__c= true;
                    toinsertOpportunityList.add(survOpty);
        }else{
            System.Debug('Surveillance already created or a child is already present==> '+opty.Id+ ':: Surveillance Created via T-Logic==> '+ opty.Surveillance_Created_via_T_Logic__c);
        }
        System.debug('@@@@@@insert_T_OpportunityList'+toinsertOpportunityList);
        return toinsertOpportunityList;
    }

    public static Boolean isLeapYearBilling(Date billingStartDate, Date billingEndDate) {
        // Helper method to check if a year is a leap year
        Integer startYear = billingStartDate.year();
        Integer endYear = billingEndDate.year();

        // Check the three conditions
        Boolean condition1 = is_LeapYear(startYear) &&
                             billingStartDate <= Date.newInstance(startYear, 2, 29);
                             
        Boolean condition2 = is_LeapYear(endYear) &&
                             billingEndDate >= Date.newInstance(endYear, 2, 29);
                             
        Boolean condition3 = startYear < endYear &&
                             is_LeapYear(endYear);

        // Combine conditions with OR logic
        return condition1 || condition2 || condition3;
    }

    public static Boolean is_LeapYear(Integer year) {
        return (Math.mod(year, 4) == 0) && (Math.mod(year, 100) != 0 || Math.mod(year, 400) == 0);
    }
}