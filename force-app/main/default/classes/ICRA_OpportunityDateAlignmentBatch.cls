/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 09-08-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification

* 1.0   06-24-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class ICRA_OpportunityDateAlignmentBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String toBeBilled = 'To Be Billed';
        String clientStatus = 'Live'; 
        String soqlquery = 'SELECT ASF_Final_Amount__c, AccountId, Amount_To_Be_Billed__c, Batch_is_Running__c, BD_Approve__c, Billing_End_date__c, Billing_Start_Date__c, Billing_Year_FY__c, CloseDate, Client_Status__c, Defer_Billing_or_Exit_Case__c, IRF_Final_Amount__c, Id, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, Is_Date_Alignment_Done__c, Name, PR_Date__c, Parent_Opportunity__c, RecordTypeId, RecordType.Name,Rolling_and_Date_Alignmnet__c, StageName, Total_Invoice_Amount_1__c, VoD_in_crore__c, Change_in_start_Date__c,Opportunity_Batch_Process__c FROM Opportunity' ;
        soqlquery +=' WHERE Billing_Start_Date__c != null  AND Billing_End_date__c != null AND ( ASF_Final_Amount__c > 0 OR IRF_Final_Amount__c > 0 ) AND Is_Date_Alignment_Done__c = false ORDER BY Name DESC ';
        System.debug('Get query' +soqlquery); 
        return Database.getQueryLocator(soqlquery); 
        
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){ 
        Map<Id, List<Opportunity>> opportunityAccountMap = new Map<Id, List<Opportunity>>(); 
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        Set<id> accountIdSet = new Set<Id>(); 
        
        for(Opportunity tempRecord : opportunityList){
            accountIdSet.add(tempRecord.AccountId);
        }
        
        Set<String> newBusinessName = new Set<String>();
        
        for(Opportunity opportunityRecord : [SELECT Id, Name , Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                               Is_Date_Alignment_Done__c, Skip_Date_Alignment__c
                                               FROM Opportunity 
                                               WHERE AccountID IN : accountIdSet]){
            
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
        
        System.debug('======= Map Key set ====='+opportunityWithDateAndVod.keySet());
        
        for(String mapkey : opportunityWithDateAndVod.keySet()){  
        
            if(mapkey.contains('Bank Loan Rating')){ 
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){ 
                    System.debug('=================Bank Loan Rating====='+sortData.size());
                    updateOpportunityList.addAll( dataAlignment(sortData ,'BRL'));
                }
                
            } else if(mapkey.contains('Money Market')){
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){ 
                    System.debug('=================Money Market====='+sortData.size());
                    updateOpportunityList.addAll( dataAlignment(sortData, 'MM'));
                }   
                
            } else if(mapkey.contains('Others')){
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){ 
                    System.debug('=================Others====='+sortData.size());
                    updateOpportunityList.addAll( dataAlignment(sortData,'OT'));
                }  
                 
            }
            
        }
        
        if(updateOpportunityList.size()>0){ 
            Database.SaveResult [] updateResult = Database.update (updateOpportunityList, false);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('======= BC =======:  '+BC);
    }
    
    public List<Opportunity> sortOpportunity(List<Opportunity> opportunityList){
        
        Integer size = opportunityList.size();
        System.debug('========size===sort Start ====== '+size);
        for(Integer i = 0; i < size-1 ; i++){
            for(Integer j = 0; j < size-i-1 ; j++){
                if(opportunityList[j].Billing_End_Date__c > opportunityList[j+1].Billing_End_Date__c){
                    Opportunity temp = opportunityList[j];
                    opportunityList[j] = opportunityList[j+1];
                    opportunityList[j+1] = temp;
                }
            } 
        } 
        System.debug('========size===sort END ====== '+size);
        
        return opportunityList;
    }
    
    public List<Opportunity> dataAlignment(List<Opportunity> opportunityList, String alignmentMode){ 
        System.debug('================ dataAlignment =============== : '+opportunityList.size()); 
        List<Opportunity> updateOpportunity = new List<Opportunity>();
        if(opportunityList.size() > 0){
            Date compareDate = opportunityList.size() > 0 ? opportunityList[0].Billing_End_Date__c:System.today();
            System.debug('======== Date compare ======='+compareDate);
            String dateAndName = '----';
            Date prevDate = Date.today();
            for(Opportunity tempOpportunity : opportunityList){
            
                if(tempOpportunity.RecordType.Name =='Surveillance' && tempOpportunity.Opportunity_Batch_Process__c == 'BLR-Date-Align' && tempOpportunity.Skip_Date_Alignment__c == false ){
                    
                    Date tempdate = Date.newInstance(tempOpportunity.Billing_End_Date__c.year(), compareDate.month(),compareDate.day()); 
                    Integer noOfDays = tempOpportunity.Billing_Start_Date__c.daysBetween(tempOpportunity.Billing_End_Date__c)+1;
                    System.debug('============Bank Loan Rating==========='+tempdate);
                    if(tempOpportunity.Change_in_start_Date__c == false){
                        //01/09/2021 - 28-02-2022
                        if( tempOpportunity.Billing_End_Date__c < tempdate){ // 28-02-2022 < 31- 03-2022 tempdate = end 
                            
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                              if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                                tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                             }else{
                                   tempOpportunity.Billing_End_Date__c = tempdate; 
                             } 

                        }else{
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                              if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                                tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                             }else{
                                   tempOpportunity.Billing_End_Date__c = tempdate; 
                             }
                        } 


                    }else{ 
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            tempOpportunity.Billing_End_Date__c = tempdate.addYears(-1);
                            tempOpportunity.Billing_Start_Date__c = tempOpportunity.Billing_End_Date__c.addYears(-1).addDays(1); 
                        }else{
                            tempOpportunity.Billing_End_Date__c = tempdate;
                            tempOpportunity.Billing_Start_Date__c = tempdate.addYears(-1).addDays(1);
                        } 
                    }
                    
                    tempOpportunity.Amount_To_Be_Billed__c = feeAmountCalculation(tempOpportunity.Billing_Start_Date__c,tempOpportunity.Billing_End_Date__c,tempOpportunity.ASF_Final_Amount__c);
                    tempOpportunity.CloseDate = tempOpportunity.Billing_Start_Date__c;
                    tempOpportunity.Is_Date_Alignment_Done__c = true;
                    updateOpportunity.add(tempOpportunity);  
                    
                } else if(tempOpportunity.RecordType.Name =='Surveillance' && tempOpportunity.Opportunity_Batch_Process__c == 'MM-Date-FY' && tempOpportunity.Skip_Date_Alignment__c == false  ){
                
                    System.debug('============Money Market===========');
                    Date tempdate = Date.newInstance(tempOpportunity.Billing_End_Date__c.year(), 03,31); 
                    Integer noOfDays = tempOpportunity.Billing_Start_Date__c.daysBetween(tempOpportunity.Billing_End_Date__c)+1;
                    
                    if(tempOpportunity.Change_in_start_Date__c == false){
                        
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                              if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                                tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                             }else{
                                   tempOpportunity.Billing_End_Date__c = tempdate; 
                             }                            
                        }else{
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                              if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                                tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                             }else{
                                   tempOpportunity.Billing_End_Date__c = tempdate; 
                             }
                        }
                        
                    }else{
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            tempOpportunity.Billing_End_Date__c = tempdate.addYears(-1);
                            tempOpportunity.Billing_Start_Date__c = tempOpportunity.Billing_End_Date__c.addYears(-1).addDays(1); 
                        }else{
                            tempOpportunity.Billing_End_Date__c = tempdate;
                            tempOpportunity.Billing_Start_Date__c = tempdate.addYears(-1).addDays(1);
                        }
                        
                    }
                    tempOpportunity.CloseDate = tempOpportunity.Billing_Start_Date__c;
                    tempOpportunity.Amount_To_Be_Billed__c = feeAmountCalculation(tempOpportunity.Billing_Start_Date__c,tempOpportunity.Billing_End_Date__c,tempOpportunity.ASF_Final_Amount__c);
                    tempOpportunity.Is_Date_Alignment_Done__c = true;
                    updateOpportunity.add(tempOpportunity); 
                    
                } else if(tempOpportunity.RecordType.Name =='Surveillance' &&  tempOpportunity.Opportunity_Batch_Process__c == 'MM-Date-Not-FY' && tempOpportunity.Skip_Date_Alignment__c == false  ){
                
                    System.debug('============Money Market===========');
                     Date tempdate = Date.newInstance(tempOpportunity.Billing_End_Date__c.year(), compareDate.month(),compareDate.day()); 
                    Integer noOfDays = tempOpportunity.Billing_Start_Date__c.daysBetween(tempOpportunity.Billing_End_Date__c)+1;
                    
                    if(tempOpportunity.Change_in_start_Date__c == false){
                        
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                              if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                                tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                             }else{
                                   tempOpportunity.Billing_End_Date__c = tempdate; 
                             }                           
                        }else{
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                            if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                              tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                           }else{
                                 tempOpportunity.Billing_End_Date__c = tempdate; 
                           }
                        }
                        
                    }else{
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            tempOpportunity.Billing_End_Date__c = tempdate.addYears(-1);
                            tempOpportunity.Billing_Start_Date__c = tempOpportunity.Billing_End_Date__c.addYears(-1).addDays(1); 
                        }else{
                            tempOpportunity.Billing_End_Date__c = tempdate;
                            tempOpportunity.Billing_Start_Date__c = tempdate.addYears(-1).addDays(1);
                        }
                        
                    }
                    tempOpportunity.CloseDate = tempOpportunity.Billing_Start_Date__c;
                    tempOpportunity.Amount_To_Be_Billed__c = feeAmountCalculation(tempOpportunity.Billing_Start_Date__c,tempOpportunity.Billing_End_Date__c,tempOpportunity.ASF_Final_Amount__c);
                    tempOpportunity.Is_Date_Alignment_Done__c = true;
                    updateOpportunity.add(tempOpportunity); 
                    
                } else if(tempOpportunity.RecordType.Name =='Surveillance' && tempOpportunity.Opportunity_Batch_Process__c == 'MF-YF' && tempOpportunity.Skip_Date_Alignment__c == false ){
                    System.debug('============Mutual Fund===========');
                    Date tempdate = Date.newInstance(tempOpportunity.Billing_End_Date__c.year(), 03,31); 
                    Integer noOfDays = tempOpportunity.Billing_Start_Date__c.daysBetween(tempOpportunity.Billing_End_Date__c)+1;
                    
                    if(tempOpportunity.Change_in_start_Date__c == false){
                        
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                            if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                              tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                           }else{
                                 tempOpportunity.Billing_End_Date__c = tempdate; 
                           }                            
                        }else{
                            Integer days = tempOpportunity.Billing_Start_Date__c.daysBetween(tempdate); 
                              if(days < 0 ){ // 01/09/2023 - 31- 03-2022 (-1)
                                tempOpportunity.Billing_End_Date__c = tempdate.addYears(1);  //31- 03-2021
                             }else{
                                   tempOpportunity.Billing_End_Date__c = tempdate; 
                             }
                        }
                        
                    }else{
                        if( tempOpportunity.Billing_End_Date__c < tempdate){
                            tempOpportunity.Billing_End_Date__c = tempdate.addYears(-1);
                            tempOpportunity.Billing_Start_Date__c = tempOpportunity.Billing_End_Date__c.addYears(-1).addDays(1); 
                        }else{
                            tempOpportunity.Billing_End_Date__c = tempdate;
                            tempOpportunity.Billing_Start_Date__c = tempdate.addYears(-1).addDays(1);
                        }
                    }
                    
                    tempOpportunity.CloseDate = tempOpportunity.Billing_Start_Date__c;
                    tempOpportunity.Amount_To_Be_Billed__c = feeAmountCalculation(tempOpportunity.Billing_Start_Date__c,tempOpportunity.Billing_End_Date__c,tempOpportunity.ASF_Final_Amount__c);
                    tempOpportunity.Is_Date_Alignment_Done__c = true;
                    updateOpportunity.add(tempOpportunity);
                }
            }
            
        } 
        return updateOpportunity;
        
    }
    
    public Decimal feeAmountCalculation(Date startDate, Date endDate, Decimal amount){  
        
        integer numberOfDays = startDate.daysBetween(endDate)+1;
        Integer yearDays =0;
        Decimal perDay = 0;
        Decimal totalAmount = 0;
        
        if(Date.isLeapYear(startDate.year())){
            yearDays = 366; 
            perday = amount.divide(366,2);
        }else{
            yearDays = 365;
            perday = amount.divide(365,2);
        }
         
        
        if(numberOfDays >= 365){
            totalAmount = amount;
        }else{
            totalAmount = (perDay * numberOfDays).round(System.RoundingMode.CEILING);
        }
        
        return totalAmount;  
    } 
}