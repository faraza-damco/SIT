/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-02-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-02-2025   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public with sharing class CreateRolloverForAlreadyBilledOpty  implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String alreadyBilled = 'Already Billed';
        String closedWon= 'Closed Won';
        String instrument_type_4= 'Monitoring Activity';
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        String soqlquery = 'SELECT Id,Alignment_Logic__c,Change_in_start_Date__c,Is_First_Child_Surv__c,Account.OwnerId,Skip_Date_Alignment__c, Opportunity_Batch_Process__c, Name,Description,StageName,Amount,CloseDate,Type,Sum_of_Volume_of_Debt__c,Mandate_Received_Date__c,Rated_by_FFP_del__c,QTR__c,Year__c,Total_Invoice_Amount__c,Balance_Amount__c,Last_Invoice_Date__c,Capped_Amount__c,Team_Member__c,Team_Manager__c,Team_Leader__c,Location_Head__c,Commercial_Head__c,Revised_Agreed_Amount_from_Credit_Note__c,OPE__c,Quality_Analyst__c,Execution_status__c,BLR_Sub_Instrument_1__c,BLR_Sub_Instrument_2__c,Requested_Fee__c,Minimum_ASF__c,Discount_Type__c,Write_off__c,Reason_for_write_off__c,ASF_Agreement_with_Client__c,Mark_in_case_of_SO_CE__c,Auto_Calculated_Amount__c,Reason__c,Comment__c,Annual_Initial_Rating_Amount__c,Annual_Surveillance_Opportunities_Amount__c,BLR_Sub_Instrument_3__c,Revised_Agreed_Amount__c,Analyst__c,Co_Analyst__c,Sector_Head__c,Group_Head__c,PAN_Number__c,TAN_Number__c,GST_Number__c,Instrument_type_1__c,Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Expected_Deferred_Date__c,Payment_Receipt_SGST__c,Annual_Credit_Note_Amount__c,Mandate_Type__c,Last_PR_Date__c,Parent_Opportunity__c,Likely_Initial_Rating_Fee__c,Business_Segment__c,Lead_Source__c,Write_off_date__c,Remarks_If_any__c,Instrument_Type_5__c,Contact__c,If_Others_then_specify__c,ASF_Calculated_Formula__c,IRF_Final_Amount__c,Amt_of_CAP_fee__c,IRF1__c,ASF__c,ASF_Applied_Discount__c,IRF_BPS__c,ASF_BPS__c,ASF_Final_Amount__c,IRF_Applied_Discount__c,MIS_Support__c,BLR_Sub_Instrument_4__c,BLR_Sub_Instrument_5__c,Volume_of_Debt_1_amount__c,Volume_of_Debt_2_Amount__c,Volume_of_Debt_3_amount__c,Volume_of_Debt_4_amount__c,Volume_of_Debt_5_amount__c,Loss_Reason__c,Crore_or_Million__c,Others_Reasons_Only_for_Fresh_Other__c,Lost_To__c,Line_of_Business__c,Sector__c,Sub_Sector__c,Branch__c,Debt_OR_Balance_Sheet_Size__c,BD_Team_Classification__c,Focus_Group__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,Conversion_Probability__c,Customer_Fee_Type__c,Discount_Required__c,Reason_for_Discount__c,Approving_Authority_as_per_DoA__c,Provision_to_be_made__c,Reason_for_provision__c,Provision_Date__c,Defer_Billing_or_Exit_Case__c,Surveillance_Billing_period__c,Bill_Date__c,Billing_Start_Date__c,Billing_End_date__c,Debtor_Period__c,Fee_Outstanding__c,Actual_Surveillance_Fee__c,Chance_of_Retention__c,Non_Cooperation_Withdrawal_Reason__c,Revenue_Loss_in_Rs__c,Fee_received__c,Rating_Validity_Till__c,Last_RC_Date__c,Detailed_Comment__c,Discount_Requested__c,Size_to_be_rated_this_year_in_Cr_M__c,Size_rated_last_year_in_Cr_M__c,Volume_of_Debt_Category__c,Type_Tender__c,Client_Status__c,Amount_to_be_provisioned_In_Rs__c,Amount_to_be_written_off_In_Rs__c,Provisioned_Detailed_Remarks__c,Written_Off_Detailed_Remarks__c,Amount_Outstanding_In_Rs__c,Opportunity_Closed_Date__c,PR_Date__c,Amount_To_Be_Billed__c,Finance_Team__c,Past_Invoice_Number__c,Annual_Surveillance_Opp_Amount__c,Total_Invoice_Amount_1__c,Bill_To__c,Third_Party_Bill_To__c,Narration_for_Invoice__c,Actual_Billing_Start_Date__c,Actual_Billing_End_Date__c,Related_Opportunity_Count__c,AccountId,RecordType.Name,Rolling_and_Date_Alignmnet__c,Billing_Year_FY__c,Scheme_Trust_Name__c, Date_of_Communication__c, Billing_Duration__c, Revised_Billing_End_Date__c, CurrencyIsoCode, Approved_by_Commercial_Head__c, Legal_Compliance_Approval__c, Approved_by_MD_CEO_Group__c, Additional_Discount_Approved__c, Execution_Status_new__c, Rollover_Check__c, Mandate_ID__c, Mandate_Serial_No__c, OwnerId, Owner.Email, Parent_Opportunity__r.Name, Created_From__c, SurveillanceCreated__c, IPO_Surveillance_Created__c, Billing_Notification_Email_Sent__c, Revised_IRF__c, BillingAddress__c, Opp_ICRA_Branch__c, Rated_Entity__c FROM Opportunity' ;
        soqlquery +=' WHERE StageName= :closedWon AND Defer_Billing_or_Exit_Case__c = :alreadyBilled AND Instrument_type_4__c= :instrument_type_4 AND Billing_Start_Date__c != null AND Fund_Utilization__c = false AND Billing_Duration__c != null AND IPO_Surveillance_Created__c = false ORDER BY Billing_Start_Date__c DESC ';
        System.debug('Get Query' +soqlquery); 
       return Database.getQueryLocator(soqlquery);  
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        System.debug('======= opportunityList =======IPO:  '+opportunityList.size());
        Date revised_end_date;
        //Date IPO_Date;
        Date dateRange;
        Integer T_Days;
        Integer mandateID= 0;
        Integer mandateSerialNo= 0;
        Date todayDate= System.today();
        Map<Id,Opportunity> optyMap= new Map<Id,Opportunity>();
        List<Opportunity> insertOpportunityList = new List<Opportunity>();
        List<Opportunity> updateOpportunity = new List<Opportunity>(); 
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Opportunity> emailOpty = new List<Opportunity>(); 
        List<String> emailOptyId = new List<String>(); 
        List<Surveillance_Creation__mdt> survCreation = [Select Id, DeveloperName, Number_of_Days__c from Surveillance_Creation__mdt where DeveloperName = 'IPO' LIMIT 1];
        T_Days= (Integer)survCreation[0].Number_of_Days__c;
        //Email
        OrgWideEmailAddress [] owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
        EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue, Body FROM EmailTemplate WHERE DeveloperName ='Billing_Alert'];
        Set<Messaging.SingleEmailMessage> emailSet = new Set<Messaging.SingleEmailMessage>(); 
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        String financeTeamEmail = System.Label.Email_Address_Billing;
        List<String> financeTeamMembers = new List<String>();
        Date billingStartDate_next;
        Date revisedEndDate_next;

        if (String.isNotBlank(financeTeamEmail)) {
            for (String value : financeTeamEmail.split(',')) {
                if (String.isNotBlank(value)) { // Ignore empty values
                    financeTeamMembers.add(value.trim());
                }
            }
        }

        System.debug('Finance Team Email Address: ' + financeTeamMembers);

        // Fetch the last record
        List<Opportunity> lastOpty= [select Id, Mandate_ID__c,Mandate_Serial_No__c,Bill_Year__c from opportunity where mandate_id__c!=null AND Mandate_Serial_No__c!=null order by createdDate DESC LIMIT 1];
        system.debug('Last Created Opportunity===>>'+lastOpty);
        Date today = Date.today();
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
            revised_end_date= opportunityRecord.Revised_Billing_End_Date__c!=null ? opportunityRecord.Revised_Billing_End_Date__c : opportunityRecord.Billing_End_date__c; 
            //IPO_Date= revised_end_date.addDays(-T_Days);
            dateRange= today.addDays(T_Days);
            if(/*IPO_Date>=todayDate && IPO_Date<=revised_end_date*/ revised_end_date<=dateRange && !optyMap.containsKey(opportunityRecord.Id)){
                optyMap.put(opportunityRecord.Id,opportunityRecord);
            } 
        }

        if(!optyMap.isEmpty()){
            for(Opportunity opty : optyMap.values()){
                revised_end_date= opty.Revised_Billing_End_Date__c!=null ? opty.Revised_Billing_End_Date__c : opty.Billing_End_date__c; 
                insertOpportunityList.addAll(createSurveillanceRollingOpportunity(opty, revised_end_date, opty.Billing_Duration__c, mandateID, mandateSerialNo));
                // opty.Rolling_and_Date_Alignmnet__c = true;
                // opty.Change_in_start_Date__c = false;
                updateOpportunity.add(opty);
                emailOptyId.add(opty.Id);
                mandateID++;
                mandateSerialNo++;
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
                    opp.SurveillanceCreated__c= true;
                    opp.IPO_Surveillance_Created__c= true;
                    tempData.add(opp);
                    emailOptyId.add(opp.Id);
                } 
                Database.SaveResult [] updateResult = Database.update (tempData , false);
            }     
            if(updateOpportunity.size() > 0){ 
                //List<Opportunity> tempData = new List<Opportunity>();
                for(Integer i = 0; i < insertResult.size(); i++){
                    Database.SaveResult result = insertResult[i];
                    if(result.isSuccess()){
                        Opportunity opp = new Opportunity();
                        opp.Id =result.getId();
                        System.Debug('Opportunity with Id '+opp.Id+ ' is created successfully');
                    }else{
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error for record: ' + updateOpportunity[i] + ' - ' + error.getMessage());
                        }
                    }
                }
            }
            //} 

            if(emailOptyId!=null && emailOptyId.size()>0){
                emailOpty= [Select id, name, Owner.Email, Instrument_type_4__c, Billing_Duration__c, Defer_Billing_or_Exit_Case__c, Fund_Utilization__c, Billing_Start_Date__c, Billing_End_date__c, Owner.FirstName, Owner.LastName, Billing_Notification_Email_Sent__c, Revised_Billing_End_Date__c from Opportunity where Id IN: emailOptyId];
            }
            System.Debug('No of opportunities for which email is to be triggered: '+emailOpty.size()+'    '+emailOpty);

            if(emailOpty!= null && !emailOpty.isEmpty()){
                for(Opportunity opty: emailOpty){
                    revisedEndDate_next= opty.Revised_Billing_End_Date__c==null ? opty.Billing_End_Date__c : opty.Revised_Billing_End_Date__c;
                    billingStartDate_next= revisedEndDate_next.addDays(1);

                    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                    singleEmail.setTemplateId(emailTemplate.Id);
                    singleEmail.setWhatId(opty.Id);
                    singleEmail.setOrgWideEmailAddressId(owea[0].Id);
                    singleEmail.setSubject('Reminder: Upcoming Billing Period for Opportunity '+opty.Name);
                    if (opty.Owner != null && String.isNotBlank(opty.Owner.Email)){
                        singleEmail.setToAddresses(new List<String> {opty.Owner.Email});
                    }
                    if (!financeTeamMembers.isEmpty()){
                        singleEmail.setccAddresses(financeTeamMembers);
                    }
                    String htmlBody = emailTemplate.HtmlValue;
                    htmlBody = htmlBody.replace('{!Opportunity.Name}', opty.Name);
                    htmlBody = htmlBody.replace('{!Opportunity.Id}', opty.Id);
                    htmlBody = htmlBody.replace('{!Opportunity.Instrument_type_4__c}', opty.Instrument_type_4__c);
                    htmlBody = htmlBody.replace('{!Opportunity.Billing_Duration__c}', opty.Billing_Duration__c);
                    htmlBody = htmlBody.replace('{!Opportunity.Defer_Billing_or_Exit_Case__c}', opty.Defer_Billing_or_Exit_Case__c);
                    htmlBody = htmlBody.replace('{!Opportunity.Fund_Utilization__c}', String.valueOf(opty.Fund_Utilization__c));
                    htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', opty.Owner.FirstName+''+opty.Owner.LastName);
                    htmlBody = htmlBody.replace('{!Opportunity.Billing_Start_Date__c}', (opty.Billing_Start_Date__c != null) ? opty.Billing_Start_Date__c.format() : '');
                    htmlBody = htmlBody.replace('{!Opportunity.Billing_End_date__c}', (opty.Billing_End_date__c != null) ? opty.Billing_End_date__c.format() : '');
                    htmlBody = htmlBody.replace('{!Opportunity.Next_Invoice_Date__c}', (billingStartDate_next != null) ? billingStartDate_next.format() : '');
                    htmlBody = htmlBody.replace('{!Opportunity.Link}', System.URL.getOrgDomainUrl().toExternalForm()+'/'+opty.Id);
                    singleEmail.setHtmlBody(htmlBody);
                    singleEmail.setSaveAsActivity(false);
                    System.Debug('Till Here=========>>>>'+opty);
                    System.Debug('Single Email Configuration: =========>>>>'+singleEmail);
                    emailSet.add(singleEmail);
                    //optyMap.put(opty.Id, opty);
                }
                System.Debug('Email Set Configured: '+emailSet.size()+'   '+emailSet);
            }
            emailList.addAll(emailSet);
            if(!emailList.isEmpty()){
                System.Debug('Email List Configured: '+emailList.size()+'      '+emailList);
                Messaging.SendEmailResult [] results = Messaging.SendEmail(emailList);
                System.Debug('Email Result '+results);
                Integer index = 0;
                for (Messaging.SendEmailResult result : results) {
                    if (result.isSuccess()) {
                        Opportunity updateOpty = new Opportunity();
                        updateOpty.Id = emailOpty[index].Id; 
                        updateOpty.Billing_Notification_Email_Sent__c = true;
                        // updateOpty.Change_in_start_Date__c  = false;
                        // updateOpty.Rolling_and_Date_Alignmnet__c  = true;
                        // updateOpty.SurveillanceCreated__c= true;
                        // updateOpty.IPO_Surveillance_Created__c= true;
                        opportunitiesToUpdate.add(updateOpty);
                    }
                    index++;
                }
                System.Debug('Send Email Results '+results.size()+'    '+results);
                if (!opportunitiesToUpdate.isEmpty()) {
                    Database.SaveResult [] updateResult = Database.update (opportunitiesToUpdate , false);
                    //update opportunitiesToUpdate;
                    System.debug('Number of Opportunities created: ' + opportunitiesToUpdate.size() + ' <<<<<<<<<<<<<==========*******==========>>>>>>>>>>>>> ');
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('======= finish =======:  '+BC);
    }
       
    
    public List<Opportunity> createSurveillanceRollingOpportunity(Opportunity tempData, Date billingEndDate, String typeString, Integer mandateID, Integer mandateSerialNo ){
        system.debug('Batch to create rollover opportunities: IPO=======>>>>');
        Id SurvRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();

        String Instrument_type_4='';
        if(tempData.Instrument_type_4__c=='Bank Loan Rating Fresh'){
            Instrument_type_4='Bank Loan Rating' ;
        } else {
            Instrument_type_4=tempData.Instrument_type_4__c;
        }
        Date today = Date.today();
        Integer currentYear = today.year();
        String financialYear;
        if (today.month() >= 4) {
            financialYear = String.valueOf(currentYear).substring(2) + String.valueOf(currentYear + 1).substring(2);
        } else {
            financialYear = String.valueOf(currentYear - 1).substring(2) + String.valueOf(currentYear).substring(2);
        }
        System.debug(financialYear);

        List<Opportunity> insertOpportunityList = new List<Opportunity>();
        if(tempData != null ){  

            Decimal revised_asf; 
            Decimal revised_irf; 
            String formattedStartDate;
            String formattedEndDate;
            Date billingStartDate_newRecord;  
            Date billingEndDate_newRecord;   
            Date revisedEndDate;   

                for(Integer i = 1; i <= 1; i++ ){ 
                    Opportunity newRecord = new Opportunity(); 
                    if(i==1){ 
                        newRecord.AccountId=tempData.AccountId;
                        newRecord.Client_Status__c='Live'; 
                        newRecord.Customer_Fee_Type__c=tempData.Customer_Fee_Type__c;
                        newRecord.Business_Segment__c=tempData.Business_Segment__c; 
                        newRecord.StageName=tempData.StageName; 
                        newRecord.Contact__c=tempData.Contact__c;                                                                 
                        newRecord.Instrument_type_1__c=tempData.Instrument_type_1__c;  
                        newRecord.Instrument_type_2__c=tempData.Instrument_type_2__c;                                                                
                        newRecord.Instrument_type_3__c=tempData.Instrument_type_3__c; 
                        newRecord.Instrument_type_4__c=Instrument_type_4; 
                        newRecord.BLR_Sub_Instrument_1__c=tempData.BLR_Sub_Instrument_1__c; 
                        newRecord.BLR_Sub_Instrument_2__c=tempData.BLR_Sub_Instrument_2__c;                                                                 
                        newRecord.BLR_Sub_Instrument_3__c=tempData.BLR_Sub_Instrument_3__c; 
                        newRecord.BLR_Sub_Instrument_4__c=tempData.BLR_Sub_Instrument_4__c; 
                        newRecord.BLR_Sub_Instrument_5__c=tempData.BLR_Sub_Instrument_5__c;                                                                 
                        newRecord.Remarks_If_any__c=tempData.Remarks_If_any__c; 
                        newRecord.Volume_of_Debt_1_amount__c=tempData.Volume_of_Debt_1_amount__c;                                                                
                        newRecord.Volume_of_Debt_2_Amount__c=tempData.Volume_of_Debt_2_Amount__c; 
                        newRecord.Volume_of_Debt_3_amount__c=tempData.Volume_of_Debt_3_amount__c; 
                        newRecord.Volume_of_Debt_4_amount__c=tempData.Volume_of_Debt_4_amount__c; 
                        newRecord.Volume_of_Debt_5_amount__c=tempData.Volume_of_Debt_5_amount__c;                                                                 
                        newRecord.CurrencyIsoCode=tempData.CurrencyIsoCode; 
                        newRecord.VoD_in_crore__c=tempData.VoD_in_crore__c;
                        newRecord.ASF_Agreement_with_Client__c=tempData.ASF_Agreement_with_Client__c; 
                        newRecord.OPE__c=tempData.OPE__c;                                                                 
                        newRecord.Minimum_ASF__c=tempData.Minimum_ASF__c; 
                        newRecord.Amt_of_CAP_fee__c=tempData.Amt_of_CAP_fee__c;                                                                                                                              
                        newRecord.Actual_Surveillance_Fee__c=tempData.Actual_Surveillance_Fee__c;
                        newRecord.Rolling_and_Date_Alignmnet__c = true;                                                                
                        newRecord.Fee_Outstanding__c=tempData.Fee_Outstanding__c; 
                        newRecord.Chance_of_Retention__c=tempData.Chance_of_Retention__c;                                                                
                        newRecord.Revenue_Loss_in_Rs__c=tempData.Revenue_Loss_in_Rs__c; 
                        newRecord.Rating_Validity_Till__c=tempData.Rating_Validity_Till__c;                                                               
                        newRecord.Mandate_Received_Date__c=tempData.Mandate_Received_Date__c; 
                        newRecord.Change_in_start_Date__c = false ;                                                                
                        newRecord.Fee_received__c=tempData.Fee_received__c; 
                        newRecord.Non_Cooperation_Withdrawal_Reason__c=tempData.Non_Cooperation_Withdrawal_Reason__c;                                                                
                        newRecord.Last_RC_Date__c=tempData.Last_RC_Date__c; 
                        newRecord.Description=tempData.Description; 
                        newRecord.Write_off__c=tempData.Write_off__c;                                                                
                        newRecord.Write_off_date__c=tempData.Write_off_date__c; 
                        newRecord.Written_Off_Detailed_Remarks__c=tempData.Written_Off_Detailed_Remarks__c;                                                               
                        newRecord.Reason_for_write_off__c=tempData.Reason_for_write_off__c; 
                        newRecord.Amount_to_be_written_off_In_Rs__c=tempData.Amount_to_be_written_off_In_Rs__c;                                                               
                        newRecord.Discount_Required__c=tempData.Discount_Required__c; 
                        newRecord.Discount_Type__c=tempData.Discount_Type__c; 
                        newRecord.Size_to_be_rated_this_year_in_Cr_M__c=tempData.Size_to_be_rated_this_year_in_Cr_M__c;                                                               
                        newRecord.Detailed_Comment__c=tempData.Detailed_Comment__c; 
                        newRecord.Size_rated_last_year_in_Cr_M__c=tempData.Size_rated_last_year_in_Cr_M__c; 
                        newRecord.Reason_for_Discount__c=tempData.Reason_for_Discount__c; 
                        newRecord.Approving_Authority_as_per_DoA__c=tempData.Approving_Authority_as_per_DoA__c;                                                             
                        newRecord.Revised_Agreed_Amount__c=tempData.Revised_Agreed_Amount__c;  
                        newRecord.Provision_to_be_made__c=tempData.Provision_to_be_made__c; 
                        newRecord.Provision_Date__c=tempData.Provision_Date__c; 
                        newRecord.Provisioned_Detailed_Remarks__c=tempData.Provisioned_Detailed_Remarks__c;                                                              
                        newRecord.Reason_for_provision__c=tempData.Reason_for_provision__c; 
                        newRecord.Amount_to_be_provisioned_In_Rs__c=tempData.Amount_to_be_provisioned_In_Rs__c; 
                        newRecord.Defer_Billing_or_Exit_Case__c='To Be Billed'; 
                        newRecord.Reason__c=tempData.Reason__c; 
                        newRecord.CloseDate=today;                                                               
                        newRecord.Approved_by_Commercial_Head__c=tempData.Approved_by_Commercial_Head__c; 
                        newRecord.Legal_Compliance_Approval__c=tempData.Legal_Compliance_Approval__c; 
                        newRecord.Approved_by_MD_CEO_Group__c=tempData.Approved_by_MD_CEO_Group__c; 
                        newRecord.Additional_Discount_Approved__c=tempData.Additional_Discount_Approved__c;                                        
                        newRecord.Team_Member__c=tempData.Team_Member__c; 
                        newRecord.Team_Leader__c=tempData.Team_Leader__c; 
                        newRecord.Commercial_Head__c=tempData.Commercial_Head__c; 
                        newRecord.Team_Manager__c=tempData.Team_Manager__c; 
                        newRecord.Location_Head__c=tempData.Location_Head__c; 
                        newRecord.MIS_Support__c=tempData.MIS_Support__c; 
                        newRecord.Analyst__c=tempData.Analyst__c; 
                        newRecord.Co_Analyst__c=tempData.Co_Analyst__c;                                      
                        newRecord.Quality_Analyst__c=tempData.Quality_Analyst__c; 
                        newRecord.Sector_Head__c=tempData.Sector_Head__c; 
                        newRecord.Group_Head__c=tempData.Group_Head__c;
                        newRecord.Scheme_Trust_Name__c=tempData.Scheme_Trust_Name__c; 
                        newRecord.Execution_Status_new__c=tempData.Execution_Status_new__c;
                        newRecord.Rollover_Check__c=true; 
                        newRecord.recordTypeID= SurvRecordTypeId;
                        newRecord.Id =null;
                        newRecord.Mandate_ID__c= String.valueOf(mandateID);
                        newRecord.Mandate_Serial_No__c= String.valueOf(mandateSerialNo);
                        newRecord.Related_Opportunity_Count__c= tempData.Related_Opportunity_Count__c==null ? 1 : tempData.Related_Opportunity_Count__c+1; 
                        revisedEndDate= tempData.Revised_Billing_End_Date__c==null ? tempData.Billing_End_Date__c : tempData.Revised_Billing_End_Date__c;

                        System.Debug('Billing Duration==>'+typeString);                              
                        if(typeString == 'Yearly'){
                            System.debug('Year Logic');
                            billingStartDate_newRecord= revisedEndDate.addDays(1);
                            billingEndDate_newRecord= billingStartDate_newRecord.addYears(1).addDays(-1);
                            newRecord.Billing_Start_Date__c  = billingStartDate_newRecord;
                            newRecord.Billing_End_Date__c  = billingEndDate_newRecord;
                            System.debug('==== newRecord.Billing Dates======'+newRecord.Billing_Start_Date__c+' ---- '+newRecord.Billing_End_Date__c);
                        }else if(typeString == 'Half-Yearly'){
                            System.debug('Half-Year Logic');
                            billingStartDate_newRecord= revisedEndDate.addDays(1);
                            billingEndDate_newRecord= billingStartDate_newRecord.addMonths(6).addDays(-1);
                            newRecord.Billing_Start_Date__c  = billingStartDate_newRecord;
                            newRecord.Billing_End_Date__c  = billingEndDate_newRecord;
                            System.debug('==== newRecord.Billing Dates======'+newRecord.Billing_Start_Date__c+' ---- '+newRecord.Billing_End_Date__c);
                        }else if(typeString == 'Quarterly'){
                            System.Debug('Quarterly Logic');
                            billingStartDate_newRecord= revisedEndDate.addDays(1);
                            billingEndDate_newRecord= billingStartDate_newRecord.addMonths(3).addDays(-1);
                            newRecord.Billing_Start_Date__c  = billingStartDate_newRecord;
                            newRecord.Billing_End_Date__c  = billingEndDate_newRecord;
                            System.debug('==== newRecord.Billing Dates======'+newRecord.Billing_Start_Date__c+' ---- '+newRecord.Billing_End_Date__c);
                        }

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
                        if(tempData.Revised_IRF__c!=null){
                            revised_irf= tempData.Revised_IRF__c;
                        }
                        newRecord.ASF_Final_Amount__c= revised_asf==null ? tempData.ASF_Final_Amount__c : revised_asf;
                        newRecord.IRF_Final_Amount__c=revised_irf==null ? tempData.IRF_Final_Amount__c : revised_irf; 
                        newRecord.Requested_Fee__c= null;
                        system.debug('Change_in_start_Date__c == '+newRecord.Change_in_start_Date__c);
                        newRecord.Is_First_Child_Surv__c = true;
                        newRecord.Total_Invoice_Amount_1__c = null;
                        newRecord.PR_Date__c = null;
                        newRecord.Billing_Duration__c = typeString;

                        newRecord.Amount_To_Be_Billed__c = feeAmountCalculation(newRecord.ASF_Final_Amount__c, newRecord.IRF_Final_Amount__c, newRecord.Billing_Duration__c, newRecord.Related_Opportunity_Count__c);
                        system.debug('   Amount_To_Be_Billed__c  '+newRecord.Amount_To_Be_Billed__c);
                        system.debug('   Billing_Start_Date__c  '+newRecord.Billing_Start_Date__c);
                        system.debug('   Billing_End_Date__c  '+newRecord.Billing_End_Date__c);
                        system.debug('   ASF_Final_Amount__c  '+newRecord.ASF_Final_Amount__c);
                        system.debug('   ASF_Final_Amount__c  '+newRecord.IRF_Final_Amount__c);

                        DateTime startDateTime = DateTime.newInstance(newRecord.Billing_Start_Date__c.year(), newRecord.Billing_Start_Date__c.month(), newRecord.Billing_Start_Date__c.day(), 0, 0, 0);
                        DateTime endDateTime = DateTime.newInstance(newRecord.Billing_End_Date__c.year(), newRecord.Billing_End_Date__c.month(), newRecord.Billing_End_Date__c.day(), 0, 0, 0);
                        formattedStartDate = startDateTime.format('MMM-yy');
                        formattedEndDate = endDateTime.format('MMM-yy');

                        if(tempData.recordType.Name=='New Business'){
                            newRecord.Parent_Opportunity__c = tempData.Id;
                            newRecord.Name=tempData.Name+'-Surveillence-'+tempData.VoD_in_crore__c+'-'+formattedStartDate+'-'+formattedEndDate;
                            newRecord.Created_From__c= tempData.Id;
                        }else{
                            newRecord.Parent_Opportunity__c = tempData.Parent_Opportunity__c;
                            newRecord.Name=tempData.Parent_Opportunity__r.Name+'-Surveillence-'+tempData.VoD_in_crore__c+'-'+formattedStartDate+'-'+formattedEndDate;
                            newRecord.Created_From__c= tempData.Id;
                        }
                    }
                    newRecord.OwnerId = tempData.OwnerId;
                    newRecord.BillingAddress__c = tempData.BillingAddress__c;
                    newRecord.Opp_ICRA_Branch__c = tempData.Opp_ICRA_Branch__c;
                    newRecord.Bill_To__c = tempData.Bill_To__c;
                    newRecord.Rated_Entity__c = tempData.Rated_Entity__c;
                    newRecord.Narration_for_Invoice__c = tempData.Narration_for_Invoice__c;
                    newRecord.Payment_Receipt_Base_Amount__c = null;
                    newRecord.Payment_Receipt_CGST__c = null;
                    newRecord.Payment_Receipt_IGST__c = null;
                    newRecord.Payment_Receipt_SGST__c = null;
                    newRecord.IPO_Rollover__c = true;
                    insertOpportunityList.add(newRecord);  
                }
        }
        System.debug('@@@@@@insertOpportunityList'+insertOpportunityList);
        return insertOpportunityList;
    } 
    
    public Decimal feeAmountCalculation(Decimal ASF, Decimal IRF, String billingDuration, Decimal relatedOpty){ 
        System.Debug('<<======>> Amount to Be Billed Calculation <<======>>' );
        Decimal totalAmount = 0;
        if(billingDuration=='Yearly'){
            if(relatedOpty<1){
                totalAmount=IRF;
            }else{
                totalAmount=ASF;
            }
        }else if(billingDuration=='Half-Yearly'){
            if(relatedOpty<=1){
                totalAmount=IRF.divide(2,2);
            }else{
                totalAmount=ASF.divide(2,2);
            }
        }else if(billingDuration=='Quarterly'){
            if(relatedOpty<=3){
                totalAmount=IRF.divide(4,2);
            }else{
                totalAmount=ASF.divide(4,2);
            }
        }

        return totalAmount.setScale(0, System.RoundingMode.HALF_UP);  
    }


}