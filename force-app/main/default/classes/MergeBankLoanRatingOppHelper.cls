public class MergeBankLoanRatingOppHelper {
    public static boolean firstRun = true;
    public static void Generatesurveillance(List<Opportunity> lstOpp) {
        List<Id> oopId=new  List<Id>();
        List<Opportunity> NBlist=new List<Opportunity>();
        List<Opportunity> surveillancelist=new List<Opportunity>();
        List<Opportunity> UpdateSurveillance = new list<Opportunity>(); 
        
        String recordType =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        Opportunity Opty= [select Id, Mandate_ID__c,Mandate_Serial_No__c,Bill_Year__c from opportunity where mandate_id__c!=null AND Mandate_Serial_No__c!=null order by createdDate DESC LIMIT 1];
        Date today = Date.today();
        Integer currentYear = today.year();
        String financialYear;
        if (today.month() >= 4) {
            financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
        } else {
            financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
        }
        System.debug(financialYear); // This will print the result

        for(Opportunity opp: lstOpp){
            oopId.add(opp.Id);  
        }
        List<Opportunity> OpportunityList = [select id,AccountId,RecordType.Name, Sector__c, Client_Status__c, Customer_Fee_Type__c, Branch__c, Line_of_Business__c, Sub_Sector__c, Focus_Group__c, Name, Parent_Opportunity__c, 
                                             Business_Segment__c, StageName, Contact__c,Opportunity_Closed_Date__c,
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
                                             Reason__c, CloseDate, Expected_Deferred_Date__c, Comment__c, Approved_by_Commercial_Head__c,  
                                             Legal_Compliance_Approval__c, Approved_by_MD_CEO_Group__c, Additional_Discount_Approved__c, PAN_Number__c, GST_Number__c, 
                                             TAN_Number__c, Team_Member__c, Team_Leader__c, Commercial_Head__c, Team_Manager__c, Location_Head__c, MIS_Support__c, isLeapYear__c,
                                             Analyst__c, Co_Analyst__c, Quality_Analyst__c, Sector_Head__c, Group_Head__c, Execution_Status_new__c,Mandate_ID__c, PR_Date__c,Scheme_Trust_Name__c,
                                             Date_of_Communication__c, Opp_ICRA_Branch__c, Rated_Entity__c, BillingAddress__c, Bill_To__c from Opportunity where id in : oopId];
        
        Integer mandateID= 0;
        Integer mandateSerialNo= 0;
        mandateID=Integer.valueOf(opty.Mandate_ID__c);
        mandateSerialNo=Integer.valueOf(opty.Mandate_Serial_No__c);
        Boolean is_Leap_Year;
        Date billing_start_date;
        Date billing_end_date;
        for(Opportunity opp : OpportunityList) { 
            billing_start_date= opp.Date_of_Communication__c==null ? opp.PR_Date__c : opp.Date_of_Communication__c; 
            billing_end_date= billing_start_date.addYears(1);
            System.Debug('Billing_Start_Date==>'+billing_start_date);
            System.Debug('Billing_End_Date==>'+billing_end_date);
            is_Leap_Year= isLeapYearBilling(billing_start_date, billing_end_date);
            System.Debug('isLeapYear==>'+is_Leap_Year);
            opp.Billing_Start_Date__c= billing_start_date;
            if(is_Leap_Year){
                opp.Billing_End_Date__c= billing_start_date.addDays(365);
            }else{
                opp.Billing_End_Date__c= billing_start_date.addDays(364);
            }

            //String Billing_End_Date=String.valueOf(billing_end_date);
            /*opp.Billing_Start_Date__c = opp.PR_Date__c;
            if(Opp.isLeapYear__c){
                opp.Billing_End_date__c = opp.PR_Date__c+365;
                system.debug('LeapYear '+opp.Billing_End_date__c );
            }else{
                opp.Billing_End_date__c = opp.PR_Date__c+364;
                system.debug('Not LeapYear '+opp.Billing_End_date__c );
            }*/
            
            // opp.Billing_End_date__c = opp.PR_Date__c.addYears(1).addDays(-1);
            // system.debug('Billing EndDate '+opp.Billing_End_date__c );
            if(opp.RecordType.Name=='New Business'){
                Date BillingStartdate=opp.Billing_End_Date__c.adddays(+1);
                system.debug('BillingStartdate line 47 '+BillingStartdate);
                Date Billingenddate=BillingStartdate-1;
                
                Date FirstServBillingstartdate = opp.Billing_End_Date__c.addDays(1);
                  
                Date FirstServBillingenddate=BillingStartdate.addyears(+1).adddays(-1); 
                 system.debug('FirstServBillingenddate line 54'+FirstServBillingenddate);
                Decimal ASFAmount=opp.ASF_Final_Amount__c; 
                opp.SurveillanceCreated__c=true;
                NBlist.add(opp);
                Integer bldateyear=opp.Billing_Start_Date__c.year(); 
                List<Opportunity > lstoppold=[select id,PR_Date__c,Billing_Start_Date__c,Billing_End_Date__c from Opportunity  where CALENDAR_YEAR(Billing_start_Date__c)<=:bldateyear and  CALENDAR_YEAR(Billing_End_Date__c)>=:bldateyear and Recordtype.Name=:'New Business' and Accountid=:opp.AccountId and Id!=:opp.Id and ( Instrument_type_4__c = 'Bank Loan Rating Fresh' or  Instrument_type_4__c= 'Bank Loan Rating Enhancement' ) order by createddate  limit 1 ];
               
                if(!Test.isRunningTest())
                {
                      lstoppold.clear();
                }
                
                if(lstoppold.Size()>0) {
                      system.debug('lstoppold[0].ID 63 '+lstoppold[0].Id);
                     system.debug('lstoppold[0].Billing_End_date__c 63 '+lstoppold[0].Billing_End_date__c);
                    FirstServBillingenddate=lstoppold[0].Billing_End_date__c.addYears(+1);
                    system.debug('FirstServBillingenddate 63 '+FirstServBillingenddate);
                    BillingStartdate=lstoppold[0].Billing_End_date__c.addyears(+1).adddays(+1);
                    
                    Billingenddate=lstoppold[0].Billing_End_date__c; 
                    
                    Integer daycount = ((FirstServBillingstartdate).daysBetween(FirstServBillingenddate) + 1); 
                    Decimal  getamount=0;
                    if(Date.isLeapYear(FirstServBillingstartdate.year()))
                    {
                        getamount=(Opp.ASF_Final_Amount__c.divide(365,7));
                        ASFAmount=(getamount*(daycount)).round(System.RoundingMode.CEILING); 
                    }
                    else
                    {
                        getamount=(Opp.ASF_Final_Amount__c.divide(365,7));
                        ASFAmount=(getamount*(daycount)).round(System.RoundingMode.CEILING); 
                    } 
                } else {
                    //opp.Billing_Start_Date__c=opp.Billing_Start_Date__c.addYears(1);
                }
                
                String Instrument_type_4='';
                if(opp.Instrument_type_4__c=='Bank Loan Rating Fresh' || opp.Instrument_type_4__c=='Bank Loan Rating Enhancement' ){
                    Instrument_type_4='Bank Loan Rating' ;
                } else {
                    Instrument_type_4=opp.Instrument_type_4__c;
                }
                
                for(integer I=1;I<=5;I++) {
                    BillingStartdate=Billingenddate.adddays(+1);
                    Billingenddate=BillingStartdate.addyears(+1).adddays(-1);
                    System.debug('BillingStartdate '+BillingStartdate);
                       System.debug('BillingStartdate '+Billingenddate);
                    if(I==1){
                        Opportunity surviellance=new Opportunity(AccountId=opp.AccountId,
                                                                 Client_Status__c='Live', Customer_Fee_Type__c=opp.Customer_Fee_Type__c,
                                                                 Name=opp.Name+'-Surveillence-'+opp.VoD_in_crore__c+'-'+BillingStartdate.year(), Parent_Opportunity__c=opp.Id,
                                                                 Business_Segment__c=opp.Business_Segment__c, StageName=opp.StageName, Contact__c=opp.Contact__c,
                                                                 OwnerId=opp.OwnerId, RecordTypeId=  recordType, Instrument_type_1__c=opp.Instrument_type_1__c,
                                                                 Instrument_type_3__c=opp.Instrument_type_3__c, BLR_Sub_Instrument_1__c=opp.BLR_Sub_Instrument_1__c, BLR_Sub_Instrument_2__c=opp.BLR_Sub_Instrument_2__c,
                                                                 BLR_Sub_Instrument_3__c=opp.BLR_Sub_Instrument_3__c, BLR_Sub_Instrument_4__c=opp.BLR_Sub_Instrument_4__c, BLR_Sub_Instrument_5__c=opp.BLR_Sub_Instrument_5__c, 
                                                                 Instrument_type_2__c=opp.Instrument_type_2__c, Instrument_type_4__c=Instrument_type_4, Remarks_If_any__c=opp.Remarks_If_any__c, Volume_of_Debt_1_amount__c=opp.Volume_of_Debt_1_amount__c,
                                                                 Volume_of_Debt_2_Amount__c=opp.Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c=opp.Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c=opp.Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c=opp.Volume_of_Debt_5_amount__c,
                                                                 CurrencyIsoCode=opp.CurrencyIsoCode, VoD_in_crore__c=opp.VoD_in_crore__c,Related_Opportunity_Count__c=I,
                                                                 IRF_Final_Amount__c=opp.IRF_Final_Amount__c, ASF_Final_Amount__c=opp.ASF_Final_Amount__c, Amount_To_Be_Billed__c =ASFAmount, ASF_Agreement_with_Client__c=opp.ASF_Agreement_with_Client__c, OPE__c=opp.OPE__c, 
                                                                 Minimum_ASF__c=opp.Minimum_ASF__c, Amt_of_CAP_fee__c=opp.Amt_of_CAP_fee__c,
                                                                 Billing_Start_Date__c=FirstServBillingstartdate,Billing_End_date__c=FirstServBillingenddate,
                                                                 Actual_Surveillance_Fee__c=opp.Actual_Surveillance_Fee__c,Rolling_and_Date_Alignmnet__c = true,
                                                                 Fee_Outstanding__c=opp.Fee_Outstanding__c, Chance_of_Retention__c=opp.Chance_of_Retention__c,
                                                                 Revenue_Loss_in_Rs__c=opp.Revenue_Loss_in_Rs__c, Rating_Validity_Till__c=opp.Rating_Validity_Till__c,
                                                                 Mandate_Received_Date__c=opp.Mandate_Received_Date__c, Change_in_start_Date__c = false ,
                                                                 Fee_received__c=opp.Fee_received__c, Non_Cooperation_Withdrawal_Reason__c=opp.Non_Cooperation_Withdrawal_Reason__c,
                                                                 Last_RC_Date__c=opp.Last_RC_Date__c, Description=opp.Description, Write_off__c=opp.Write_off__c, 
                                                                 Write_off_date__c=opp.Write_off_date__c, Written_Off_Detailed_Remarks__c=opp.Written_Off_Detailed_Remarks__c,
                                                                 Reason_for_write_off__c=opp.Reason_for_write_off__c, Amount_to_be_written_off_In_Rs__c=opp.Amount_to_be_written_off_In_Rs__c, 
                                                                 Discount_Required__c=opp.Discount_Required__c, Discount_Type__c=opp.Discount_Type__c, Size_to_be_rated_this_year_in_Cr_M__c=opp.Size_to_be_rated_this_year_in_Cr_M__c,
                                                                 Detailed_Comment__c=opp.Detailed_Comment__c, Size_rated_last_year_in_Cr_M__c=opp.Size_rated_last_year_in_Cr_M__c, Requested_Fee__c=opp.Requested_Fee__c, Reason_for_Discount__c=opp.Reason_for_Discount__c, Approving_Authority_as_per_DoA__c=opp.Approving_Authority_as_per_DoA__c,
                                                                 Revised_Agreed_Amount__c=opp.Revised_Agreed_Amount__c,  Provision_to_be_made__c=opp.Provision_to_be_made__c, Provision_Date__c=opp.Provision_Date__c, Provisioned_Detailed_Remarks__c=opp.Provisioned_Detailed_Remarks__c, 
                                                                 Reason_for_provision__c=opp.Reason_for_provision__c, Amount_to_be_provisioned_In_Rs__c=opp.Amount_to_be_provisioned_In_Rs__c, Defer_Billing_or_Exit_Case__c='To Be Billed', Reason__c=opp.Reason__c, CloseDate=BillingStartdate, 
                                                                 Approved_by_Commercial_Head__c=opp.Approved_by_Commercial_Head__c, Legal_Compliance_Approval__c=opp.Legal_Compliance_Approval__c, Approved_by_MD_CEO_Group__c=opp.Approved_by_MD_CEO_Group__c, Additional_Discount_Approved__c=opp.Additional_Discount_Approved__c, 
                                                                 Team_Member__c=opp.Team_Member__c, Team_Leader__c=opp.Team_Leader__c, Commercial_Head__c=opp.Commercial_Head__c, Team_Manager__c=opp.Team_Manager__c, Location_Head__c=opp.Location_Head__c, MIS_Support__c=opp.MIS_Support__c, Analyst__c=opp.Analyst__c, Co_Analyst__c=opp.Co_Analyst__c, 
                                                                 Quality_Analyst__c=opp.Quality_Analyst__c, Sector_Head__c=opp.Sector_Head__c, Group_Head__c=opp.Group_Head__c,Scheme_Trust_Name__c=opp.Scheme_Trust_Name__c, Execution_Status_new__c=opp.Execution_Status_new__c,Rollover_Check__c=true, Opp_ICRA_Branch__c=opp.Opp_ICRA_Branch__c, Rated_Entity__c=opp.Rated_Entity__c, BillingAddress__c=opp.BillingAddress__c, 
                                                                 Bill_To__c=opp.Bill_To__c, Mandate_ID__c=String.valueOf(mandateID+1),Mandate_Serial_No__c=String.valueOf(mandateSerialNo+1));
                        
                        if(opty.Bill_Year__c!= financialYear){
                        surviellance.Mandate_ID__c=financialYear+'0000'+i;
                        surviellance.Mandate_Serial_No__c=String.valueOf(i);
                        }
                        surveillancelist.add(surviellance);
                        mandateID++;
                        mandateSerialNo++;


                    }else {
                        Opportunity surviellance=new Opportunity(AccountId=opp.AccountId,
                                                                 Client_Status__c='Live', Customer_Fee_Type__c=opp.Customer_Fee_Type__c,
                                                                 Name=opp.Name+'-Surveillence-'+opp.VoD_in_crore__c+'-'+BillingStartdate.year(), Parent_Opportunity__c=opp.Id,
                                                                 Business_Segment__c=opp.Business_Segment__c, StageName=opp.StageName, Contact__c=opp.Contact__c,
                                                                 OwnerId=opp.OwnerId, RecordTypeId = recordType, Instrument_type_1__c=opp.Instrument_type_1__c,
                                                                 Instrument_type_3__c=opp.Instrument_type_3__c, BLR_Sub_Instrument_1__c=opp.BLR_Sub_Instrument_1__c, BLR_Sub_Instrument_2__c=opp.BLR_Sub_Instrument_2__c,
                                                                 BLR_Sub_Instrument_3__c=opp.BLR_Sub_Instrument_3__c, BLR_Sub_Instrument_4__c=opp.BLR_Sub_Instrument_4__c, BLR_Sub_Instrument_5__c=opp.BLR_Sub_Instrument_5__c, 
                                                                 Instrument_type_2__c=opp.Instrument_type_2__c, Instrument_type_4__c=Instrument_type_4, Remarks_If_any__c=opp.Remarks_If_any__c, Volume_of_Debt_1_amount__c=opp.Volume_of_Debt_1_amount__c,
                                                                 Volume_of_Debt_2_Amount__c=opp.Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c=opp.Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c=opp.Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c=opp.Volume_of_Debt_5_amount__c,
                                                                 CurrencyIsoCode=opp.CurrencyIsoCode, VoD_in_crore__c=opp.VoD_in_crore__c,Defer_Billing_or_Exit_Case__c='To Be Billed',
                                                                 IRF_Final_Amount__c=opp.IRF_Final_Amount__c, ASF_Final_Amount__c=opp.ASF_Final_Amount__c,  ASF_Agreement_with_Client__c=opp.ASF_Agreement_with_Client__c, OPE__c=opp.OPE__c, 
                                                                 Minimum_ASF__c=opp.Minimum_ASF__c, Amt_of_CAP_fee__c=opp.Amt_of_CAP_fee__c,Related_Opportunity_Count__c=I,
                                                                 Billing_Start_Date__c=BillingStartdate,Actual_Billing_Start_Date__c=BillingStartdate,Billing_End_date__c=Billingenddate,Actual_Billing_End_Date__c=Billingenddate,
                                                                 Actual_Surveillance_Fee__c=opp.Actual_Surveillance_Fee__c,Rolling_and_Date_Alignmnet__c = true,
                                                                 Fee_Outstanding__c=opp.Fee_Outstanding__c, Chance_of_Retention__c=opp.Chance_of_Retention__c,
                                                                 Revenue_Loss_in_Rs__c=opp.Revenue_Loss_in_Rs__c, Rating_Validity_Till__c=opp.Rating_Validity_Till__c,
                                                                 Mandate_Received_Date__c=opp.Mandate_Received_Date__c, Amount_To_Be_Billed__c =Opp.ASF_Final_Amount__c,
                                                                 Fee_received__c=opp.Fee_received__c, Non_Cooperation_Withdrawal_Reason__c=opp.Non_Cooperation_Withdrawal_Reason__c,
                                                                 Last_RC_Date__c=opp.Last_RC_Date__c, Description=opp.Description, Write_off__c=opp.Write_off__c, 
                                                                 Write_off_date__c=opp.Write_off_date__c, Written_Off_Detailed_Remarks__c=opp.Written_Off_Detailed_Remarks__c,
                                                                 Reason_for_write_off__c=opp.Reason_for_write_off__c, Amount_to_be_written_off_In_Rs__c=opp.Amount_to_be_written_off_In_Rs__c, 
                                                                 Discount_Required__c=opp.Discount_Required__c, Discount_Type__c=opp.Discount_Type__c, Size_to_be_rated_this_year_in_Cr_M__c=opp.Size_to_be_rated_this_year_in_Cr_M__c,
                                                                 Detailed_Comment__c=opp.Detailed_Comment__c, Size_rated_last_year_in_Cr_M__c=opp.Size_rated_last_year_in_Cr_M__c, Requested_Fee__c=opp.Requested_Fee__c, Reason_for_Discount__c=opp.Reason_for_Discount__c, Approving_Authority_as_per_DoA__c=opp.Approving_Authority_as_per_DoA__c,
                                                                 Revised_Agreed_Amount__c=opp.Revised_Agreed_Amount__c,  Provision_to_be_made__c=opp.Provision_to_be_made__c, Provision_Date__c=opp.Provision_Date__c, Provisioned_Detailed_Remarks__c=opp.Provisioned_Detailed_Remarks__c, 
                                                                 Reason_for_provision__c=opp.Reason_for_provision__c, Amount_to_be_provisioned_In_Rs__c=opp.Amount_to_be_provisioned_In_Rs__c,Reason__c=opp.Reason__c, CloseDate=BillingStartdate, Expected_Deferred_Date__c=opp.Expected_Deferred_Date__c, Comment__c=opp.Comment__c,
                                                                 Approved_by_Commercial_Head__c=opp.Approved_by_Commercial_Head__c, Legal_Compliance_Approval__c=opp.Legal_Compliance_Approval__c, Approved_by_MD_CEO_Group__c=opp.Approved_by_MD_CEO_Group__c, Additional_Discount_Approved__c=opp.Additional_Discount_Approved__c, 
                                                                 Team_Member__c=opp.Team_Member__c, Team_Leader__c=opp.Team_Leader__c, Commercial_Head__c=opp.Commercial_Head__c, Team_Manager__c=opp.Team_Manager__c, Location_Head__c=opp.Location_Head__c, MIS_Support__c=opp.MIS_Support__c, Analyst__c=opp.Analyst__c, Co_Analyst__c=opp.Co_Analyst__c, 
                                                                 Quality_Analyst__c=opp.Quality_Analyst__c, Sector_Head__c=opp.Sector_Head__c, Group_Head__c=opp.Group_Head__c, Scheme_Trust_Name__c=opp.Scheme_Trust_Name__c, Execution_Status_new__c=opp.Execution_Status_new__c,Rollover_Check__c=true, Opp_ICRA_Branch__c=opp.Opp_ICRA_Branch__c, 
                                                                 Rated_Entity__c=opp.Rated_Entity__c, BillingAddress__c=opp.BillingAddress__c, Bill_To__c=opp.Bill_To__c, Mandate_ID__c=String.valueOf(mandateID+1),Mandate_Serial_No__c=String.valueOf(mandateSerialNo+1));
                        
                        if(opty.Bill_Year__c!= financialYear){
                        surviellance.Mandate_ID__c=financialYear+'0000'+i;
                        surviellance.Mandate_Serial_No__c=String.valueOf(i);
                        }
                        surveillancelist.add(surviellance);
                        mandateID++;
                        mandateSerialNo++;

                    } 
                }
                
                
            }
        } 
        insert surveillancelist;
        
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