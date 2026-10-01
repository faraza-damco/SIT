/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-03-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   04-01-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class ICRA_Revenue_Milestones {
    
    @InvocableMethod
    public static void createRevenueMilestone(List<Opportunity> opportunityList){
       Database.SaveResult [] saveResult = saveRevenueMilestone(opportunityList);
    }

    public static Database.SaveResult[] saveRevenueMilestone(List<Opportunity> opportunityList){
        System.debug('===== Opportunity List =====: '+ opportunityList);
        List<Revenue_Milestone__c> revenueMilestoneList = new List<Revenue_Milestone__c>();
        List<Revenue_Milestone__c> revenueMilestoneTempList = new List<Revenue_Milestone__c>();
        
        if(!opportunityList.isEmpty()){ 
            for(Opportunity opportunityRecord : opportunityList){
                
                System.debug('===== opportunityRecord =====: '+opportunityRecord);
                System.debug('===== opportunity Record Type =====: '+opportunityRecord.RecordTypeID);
                
                String newBusiness = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('New Business').getRecordTypeId();
                String Surveillance = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
                
                System.debug('===== Record Type Name =====: '+Surveillance);

                Revenue_Milestone__c revenueMilestone = new Revenue_Milestone__c();
                revenueMilestone.Account__c = opportunityRecord.AccountId;
                revenueMilestone.Opportunity__c = opportunityRecord.Id;
                revenueMilestone.Milestone_Due_Date__c = opportunityRecord.Billing_Start_Date__c; 
                
                if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){
                    
                    if(opportunityRecord.RecordTypeId == newBusiness){
                        revenueMilestone.Amount__c =  (opportunityRecord.IRF_Final_Amount__c * 0.6153846).round(System.RoundingMode.CEILING); 
                    }else{
                        //revenueMilestone.Amount__c = (opportunityRecord.Amount_To_Be_Billed__c * 0.6153846).round(System.RoundingMode.CEILING);
                    }
                    
                }else{

                    if(opportunityRecord.RecordTypeId == newBusiness){
                        
                        if(opportunityRecord.ASF_Final_Amount__c == 0 || opportunityRecord.ASF_Final_Amount__c == null ){
                            revenueMilestone.Amount__c = opportunityRecord.IRF_Final_Amount__c;
                        }else{
                            revenueMilestone.Amount__c =  (opportunityRecord.IRF_Final_Amount__c * 0.769231).round(System.RoundingMode.CEILING);
                        }
                        
                    }else{
                        //revenueMilestone.Amount__c =  (opportunityRecord.Amount_To_Be_Billed__c * 0.769231).round(System.RoundingMode.CEILING);

                    }  
                } 
                
                revenueMilestone.CurrencyIsoCode = opportunityRecord.CurrencyIsoCode;  
                
                if( 
                    (opportunityRecord.RecordTypeId == newBusiness && opportunityRecord.StageName == 'Closed Won' ) || 
                    (   opportunityRecord.RecordTypeId == Surveillance && opportunityRecord.StageName == 'Closed Won' && opportunityRecord.Defer_Billing_or_Exit_Case__c =='To Be Billed' && opportunityRecord.Is_Revenue_Milestone__c == false )
                ){ 
                    
                    if(opportunityRecord.RecordTypeId == newBusiness){
                        revenueMilestoneList.add(revenueMilestone);
                    } 
                    
                    revenueMilestone.Forecast_Category__c = 'To Be Billed';                        
                    revenueMilestoneList.addAll(creatRevenueMilestoneMonthWise(opportunityRecord,opportunityRecord.Customer_Fee_Type__c));  
                    System.debug('======== creatRevenueMilestoneMonthWise');
                    
                } else if(
                    opportunityRecord.RecordTypeId == Surveillance && opportunityRecord.StageName == 'Closed Won' && 
                    opportunityRecord.Defer_Billing_or_Exit_Case__c =='Deferred (Unbilled)'
                ){
                    
                    revenueMilestone.Forecast_Category__c = 'Deferred (Unbilled)';
                    //revenueMilestoneList.add(revenueMilestone); 
                    revenueMilestoneList.addAll(deferredRevenueMilestone(opportunityRecord,opportunityRecord.Customer_Fee_Type__c));
                    System.debug('======== deferredRevenueMilestone');
                    
                }else if((
                    opportunityRecord.RecordTypeId == Surveillance && opportunityRecord.StageName == 'Closed Won' && 
                    opportunityRecord.Defer_Billing_or_Exit_Case__c =='To Be Billed' && opportunityRecord.Is_Revenue_Milestone__c == true && opportunityRecord.Is_Hold__c == false
                )){
                    
                    revenueMilestone.Forecast_Category__c = 'Deferred (Unbilled) - To Be Billed';
                    //revenueMilestoneList.add(revenueMilestone); 
                    revenueMilestoneList.addAll(toBeBilledRevenueMilestone(opportunityRecord,'Deferred (Unbilled) - To Be Billed',opportunityRecord.Customer_Fee_Type__c));
                    revenueMilestoneList.addALL(shiftofunbilledtoBilled(opportunityRecord,opportunityRecord.Customer_Fee_Type__c));
                    System.debug('======== shiftofunbilledtoBilled');
                    
                }else if((
                    opportunityRecord.RecordTypeId == Surveillance && opportunityRecord.StageName == 'Closed Won' && 
                    opportunityRecord.Defer_Billing_or_Exit_Case__c =='To Be Billed' && opportunityRecord.Is_Revenue_Milestone__c == true && opportunityRecord.Is_Hold__c == true
                )){
                    revenueMilestone.Forecast_Category__c = 'Hold Uncertain - To Be Billed';
                    //revenueMilestoneList.add(revenueMilestone); 
                    revenueMilestoneList.addAll(toBeBilledRevenueMilestone(opportunityRecord,'Hold Uncertain - To Be Billed',opportunityRecord.Customer_Fee_Type__c));
                    System.debug('======== toBeBilledRevenueMilestone Hold');
                }else if((
                    opportunityRecord.RecordTypeId == Surveillance && opportunityRecord.StageName == 'Closed Won' && 
                    opportunityRecord.Defer_Billing_or_Exit_Case__c =='Hold (Uncertain)'  
                )){
                    
                    revenueMilestone.Forecast_Category__c = 'Hold (Uncertain)';
                    //revenueMilestoneList.add(revenueMilestone); 
                    revenueMilestoneList.addAll(holdRevenueMilestone(opportunityRecord,opportunityRecord.Customer_Fee_Type__c)); 
                     System.debug('======== toBeBilledRevenueMilestone Hold Uncertain');
                    
                }
            }
        }
        Database.SaveResult [] saveResult = new List<Database.SaveResult>();
        if(revenueMilestoneList.size()>0){
            System.debug('======== Record Size ====='+revenueMilestoneList.size()); 
            saveResult = Database.insert(revenueMilestoneList,false); 
        }

        return saveResult;

    }
    
    public static List<Revenue_Milestone__c> creatRevenueMilestoneMonthWise(Opportunity opportunityrecord, String cap){
        List<Revenue_Milestone__c> revenueMilestoneList = new List<Revenue_Milestone__c>();
        String newBusiness = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('New Business').getRecordTypeId(); 
        
        if(opportunityRecord.Billing_Start_Date__c != null){
            Integer monthSize = 0;
            Integer numberOfDays = 0;
            Date startDate = opportunityRecord.Billing_Start_Date__c; 
            numberOfDays = opportunityRecord.Billing_Start_Date__c.daysBetween(opportunityRecord.Billing_End_Date__c)+1;
            System.debug('========= numberOfDays'+numberOfDays);
            if(cap == 'Cap'){
                Date LastDate = Date.newInstance((startDate.year()+1), 03, 31);
                monthSize =  startDate.monthsBetween(LastDate)+1;
                System.debug('==== Months ==== '+monthSize);
            }else{
                Date LastDate = opportunityRecord.Billing_End_Date__c;
                monthSize =  startDate.monthsBetween(LastDate); 
            }
            
            Boolean isfirstDate = true;
            Date endDate = Date.today();
            for(Integer count = 0 ; count <= monthSize ; count++){
                
                startDate = opportunityRecord.Billing_Start_Date__c.addMonths(count);
                
                Integer remaningDays =0;
                if(isfirstDate){
                    remaningDays = Date.daysInMonth(startDate.year(), startDate.month()) - startDate.day();
                    endDate = startDate.addDays(remaningDays);
                }else{
                    
                    startDate = endDate.addDays(1);
                    System.debug('===============startDate ==============='+startDate);
                    
                    remaningDays = Date.daysInMonth(startDate.year(), startDate.month()) - startDate.day();
                    endDate = startDate.addDays(remaningDays);
                    
                    if(count==monthSize){
                        endDate = opportunityRecord.Billing_End_date__c; 
                    }
                    System.debug('===============endDate ==============='+endDate);
                }
                
                isfirstDate = false;
                
                Revenue_Milestone__c revenueMilestone = new Revenue_Milestone__c();
                revenueMilestone.Account__c = opportunityRecord.AccountId;
                revenueMilestone.Opportunity__c = opportunityRecord.Id;
                Date opportunityDate = opportunityRecord.Billing_Start_Date__c;
                revenueMilestone.CurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
                revenueMilestone.Forecast_Category__c = 'To Be Billed'; 
                revenueMilestone.Milestone_Due_Date__c =startDate;
                revenueMilestone.Milestone_Start_Date__c = startDate;
                revenueMilestone.Milestone_End_Date__c = endDate;  
                if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){
                    Decimal perday =0;
                    Decimal balance = 0;

                    if(opportunityRecord.RecordTypeId == newBusiness){
                        balance = opportunityRecord.IRF_Final_Amount__c - ((opportunityRecord.IRF_Final_Amount__c*0.6153846));
                    }else{
                        balance = opportunityRecord.Amount_To_Be_Billed__c;
                    }
                    
                    System.debug('=========== balance'+balance); 
                    perday = balance.divide(numberOfDays,2);
                    System.debug('=========== perday'+perday); 

                    revenueMilestone.Amount__c =  (perday * (startDate.daysBetween(endDate)+1)).round();
                    System.debug('=========== Amount__c'+(perday * (startDate.daysBetween(endDate)+1)));
                }else{
                    Decimal perday =0;
                    Decimal balance = 0;

                    if(opportunityRecord.RecordTypeId == newBusiness){
                        balance = opportunityRecord.IRF_Final_Amount__c - ((opportunityRecord.IRF_Final_Amount__c*0.769231));
                    }else{
                        balance = opportunityRecord.Amount_To_Be_Billed__c;
                    }

                    System.debug('=========== balance'+balance); 
                    perday = balance.divide(numberOfDays,4);
                    System.debug('=========== perday'+perday);
                     
                    
                    revenueMilestone.Amount__c =  (perday * (startDate.daysBetween(endDate)+1)).round();
                    System.debug('=========== Amount__c'+(perday * (startDate.daysBetween(endDate)+1)));
                    
                } 
                revenueMilestoneList.add(revenueMilestone);
            }
        }  
        return revenueMilestoneList;
    }
    
    public static List<Revenue_Milestone__c>  revenueMilestoneWithOpportunity(String opportunityId){ 
        
        Revenue_Milestone__c [] revenueMilestoneList = [
            SELECT Amount__c, CurrencyIsoCode, Milestone_Due_Date__c, Milestone_Type__c, Name, Opportunity__c 
            FROM Revenue_Milestone__c
            WHERE Opportunity__c =: opportunityId AND Milestone_Type__c  = 'Deferred (Unbilled) - To Be Billed'
            LIMIT 5000
        ];  
        
        return revenueMilestoneList;
        
    } 
    
    public static List<Revenue_Milestone__c> deferredRevenueMilestone( Opportunity opportunityRecord, String cap){
        System.debug('===== updateRevenueMilestone =====: ' );
        System.debug('===== opportunityRecord =====: '+opportunityRecord); 
        List<Revenue_Milestone__c> revenueMilestoneList = new List<Revenue_Milestone__c>();
        
        if(opportunityRecord.Billing_Start_Date__c != null){  
            
            Integer monthSize = 0;
            Date startDate = opportunityRecord.Billing_Start_Date__c; 
            Date LastDate = Date.newInstance((startDate.year()+1), 03, 31);
            
            if(cap == 'Cap'){
                monthSize =  startDate.monthsBetween(LastDate)+1;
                System.debug('==== Months ==== '+monthSize);
            }else{
                monthSize = 12;
            } 
            
            Boolean isfirstDate = true;
            Date endDate = Date.today();
            
            for(Integer count = 0 ; count < monthSize ; count++){
                
                Revenue_Milestone__c revenueMilestone = new Revenue_Milestone__c();
                revenueMilestone.Account__c = opportunityRecord.AccountId;
                revenueMilestone.Opportunity__c = opportunityRecord.Id;
                Date opportunityDate = opportunityRecord.Billing_Start_Date__c;
                revenueMilestone.CurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
                
                revenueMilestone.Milestone_Due_Date__c =opportunityDate.addMonths(count) ; 
                revenueMilestone.Forecast_Category__c = 'Deferred (Unbilled)';
                if(opportunityDate.addMonths(count) <= opportunityRecord.Expected_Deferred_Date__c ){
                    if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){ 
                        Decimal perday =0;
                        Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                        System.debug('=========== balance'+balance);
                        if(!Date.isLeapYear(startDate.year())){
                            perday = balance.divide(365,2);
                            System.debug('=========== perday'+perday);
                        }else{
                            perday = balance.divide(366,2);
                            System.debug('=========== perday'+perday);
                        }
                        
                        revenueMilestone.Amount__c =  (perday * (startDate.daysBetween(endDate)+1)).round(System.RoundingMode.CEILING);
                        System.debug('=========== Amount__c'+(perday * (startDate.daysBetween(endDate)+1)));
                    }else{ 
                        Decimal perday =0;
                        Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                        System.debug('=========== balance'+balance);
                        if(Date.isLeapYear(startDate.year())){
                            perday = balance.divide(365,2);
                            System.debug('=========== perday'+perday);
                        }else{
                            perday = balance.divide(366,2);
                            System.debug('=========== perday'+perday);
                        }
                        
                        revenueMilestone.Amount__c =  (perday * (startDate.daysBetween(endDate)+1)).round(System.RoundingMode.CEILING);
                        System.debug('=========== Amount__c'+(perday * (startDate.daysBetween(endDate)+1)));
                    }
                    
                }else{
                    revenueMilestone.Amount__c = 0;
                    
                } 
                revenueMilestoneList.add(revenueMilestone);
            }
        }  
        return revenueMilestoneList;
        
    }
    
    public static List<Revenue_Milestone__c> toBeBilledRevenueMilestone( Opportunity opportunityRecord, String category, String cap){
        System.debug('===== updateRevenueMilestone =====: ' );
        System.debug('===== opportunityRecord =====: '+opportunityRecord); 
        List<Revenue_Milestone__c> revenueMilestoneList = new List<Revenue_Milestone__c>();
        Double totalAmount = 0; 
        Boolean isBillto = true;
        if(opportunityRecord.Billing_Start_Date__c != null){
            Integer monthSize = 0;
            Date startDate = opportunityRecord.Billing_Start_Date__c; 
            Date LastDate = Date.newInstance((startDate.year()+1), 03, 31);
            
            if(cap == 'Cap'){
                monthSize =  startDate.monthsBetween(LastDate)+1;
                System.debug('==== Months ==== '+monthSize);
            }else{
                monthSize = 12;
            }
            
            Boolean isfirstDate = true;
            Date endDate = Date.today();
            
            for(Integer count = 0 ; count < monthSize ; count++){
                
                startDate = opportunityRecord.Billing_Start_Date__c.addMonths(count);
                
                Integer remaningDays =0;
                if(isfirstDate){
                    remaningDays = Date.daysInMonth(startDate.year(), startDate.month()) - startDate.day();
                    endDate = startDate.addDays(remaningDays);
                }else{
                    
                    startDate = endDate.addDays(1);
                    System.debug('===============startDate ==============='+startDate);
                    
                    remaningDays = Date.daysInMonth(startDate.year(), startDate.month()) - startDate.day();
                    endDate = startDate.addDays(remaningDays);
                    
                    if(count==12){
                        endDate = opportunityRecord.Billing_End_date__c; 
                    }
                    System.debug('===============endDate ==============='+endDate);
                }
                
                isfirstDate = false;
                
                Revenue_Milestone__c revenueMilestone = new Revenue_Milestone__c();
                revenueMilestone.Account__c = opportunityRecord.AccountId;
                revenueMilestone.Opportunity__c = opportunityRecord.Id;
                Date opportunityDate = opportunityRecord.Billing_Start_Date__c;
                revenueMilestone.CurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
                
                // revenueMilestone.Milestone_Due_Date__c =opportunityDate.addMonths(count) ; 
                revenueMilestone.Milestone_Due_Date__c =startDate;
                revenueMilestone.Milestone_Start_Date__c = startDate;
                revenueMilestone.Milestone_End_Date__c = endDate;
                revenueMilestone.Forecast_Category__c = category;
                
                if(opportunityDate.addMonths(count) <= opportunityRecord.LastModifiedDate ){
                    if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){
                        Decimal perday =0;
                        Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                        System.debug('=========== balance'+balance);
                        if(!Date.isLeapYear(startDate.year())){
                            perday = balance.divide(365,2);
                            System.debug('=========== perday'+perday);
                        }else{
                            perday = balance.divide(366,2);
                            System.debug('=========== perday'+perday);
                        }
                        
                        totalAmount +=  (perday * (startDate.daysBetween(endDate)+1));
                        
                        //totalAmount += (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.6153846))/12;
                    }else{
                        //totalAmount += (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.769231))/12;
                        Decimal perday =0;
                        Decimal balance = opportunityRecord.Amount_To_Be_Billed__c ;
                        System.debug('=========== balance'+balance);
                        if(!Date.isLeapYear(startDate.year())){
                            perday = balance.divide(365,2);
                            System.debug('=========== perday'+perday);
                        }else{
                            perday = balance.divide(366,2);
                            System.debug('=========== perday'+perday);
                            totalAmount +=  (perday * (startDate.daysBetween(endDate)+1));
                        }
                    }
                    
                    revenueMilestone.Amount__c= 0;
                    
                }else{
                    if(isBillto){ 
                        
                        if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){
                            Decimal perday =0;
                            Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                            System.debug('=========== balance'+balance);
                            if(!Date.isLeapYear(startDate.year())){
                                perday = balance.divide(365,2);
                                System.debug('=========== perday'+perday);
                            }else{
                                perday = balance.divide(366,2);
                                System.debug('=========== perday'+perday);
                            }
                            
                            revenueMilestone.Amount__c = (totalAmount + (perday * (startDate.daysBetween(endDate)+1))).round(System.RoundingMode.CEILING);
                            
                            //revenueMilestone.Amount__c = totalAmount + (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.6153846))/12;
                        }else{
                            // revenueMilestone.Amount__c = totalAmount + (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.769231))/12;
                            Decimal perday =0;
                            Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                            System.debug('=========== balance'+balance);
                            if(!Date.isLeapYear(startDate.year())){
                                perday = balance.divide(365,2);
                                System.debug('=========== perday'+perday);
                            }else{
                                perday = balance.divide(366,2);
                                System.debug('=========== perday'+perday);
                            }
                            
                            revenueMilestone.Amount__c = (totalAmount + (perday * (startDate.daysBetween(endDate)+1))).round(System.RoundingMode.CEILING);
                        } 
                        
                        isBillto = false;
                    }else{
                        
                        if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){
                            Decimal perday =0;
                            Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                            System.debug('=========== balance'+balance);
                            if(!Date.isLeapYear(startDate.year())){
                                perday = balance.divide(365,2);
                                System.debug('=========== perday'+perday);
                            }else{
                                perday = balance.divide(366,2);
                                System.debug('=========== perday'+perday);
                            }
                            
                            revenueMilestone.Amount__c = (perday * (startDate.daysBetween(endDate)+1)).round(System.RoundingMode.CEILING);
                            
                        }else{
                            // revenueMilestone.Amount__c = (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.769231))/12;
                            Decimal perday =0;
                            Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                            System.debug('=========== balance'+balance);
                            if(!Date.isLeapYear(startDate.year())){
                                perday = balance.divide(365,2);
                                System.debug('=========== perday'+perday);
                            }else{
                                perday = balance.divide(366,2);
                                System.debug('=========== perday'+perday);
                            }
                            
                            revenueMilestone.Amount__c = (perday * (startDate.daysBetween(endDate)+1)).round(System.RoundingMode.CEILING);
                        }
                    } 
                } 
                revenueMilestoneList.add(revenueMilestone); 
            }
        }  
        return revenueMilestoneList; 
    } 
    
    public static List<Revenue_Milestone__c> holdRevenueMilestone( Opportunity opportunityRecord, String cap){
        System.debug('===== updateRevenueMilestone =====: ' );
        System.debug('===== opportunityRecord =====: '+opportunityRecord); 
        List<Revenue_Milestone__c> revenueMilestoneList = new List<Revenue_Milestone__c>();
        
        if(opportunityRecord.Billing_Start_Date__c != null){
            
            Integer monthSize = 0;
            Date startDate = opportunityRecord.Billing_Start_Date__c; 
            Date LastDate = Date.newInstance((startDate.year()+1), 03, 31);
            
            if(cap == 'Cap'){
                monthSize =  startDate.monthsBetween(LastDate)+1;
                System.debug('==== Months ==== '+monthSize);
            }else{
                monthSize = 12;
            }
            
            Boolean isfirstDate = true;
            Date endDate = Date.today();
            for(Integer count = 0 ; count < monthSize ; count++){
                
                Revenue_Milestone__c revenueMilestone = new Revenue_Milestone__c();
                revenueMilestone.Account__c = opportunityRecord.AccountId;
                revenueMilestone.Opportunity__c = opportunityRecord.Id;
                Date opportunityDate = opportunityRecord.Billing_Start_Date__c;
                revenueMilestone.CurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
                
                //revenueMilestone.Milestone_Due_Date__c =opportunityDate.addMonths(count) ; 
                revenueMilestone.Forecast_Category__c = 'Hold (Uncertain)';
                revenueMilestone.Milestone_Due_Date__c =startDate;
                revenueMilestone.Milestone_Start_Date__c = startDate;
                revenueMilestone.Milestone_End_Date__c = endDate;  
                revenueMilestone.Amount__c = 0; 
                revenueMilestoneList.add(revenueMilestone);
            }
        }  
        return revenueMilestoneList;
        
    }
    
    
    public static List<Revenue_Milestone__c> shiftofunbilledtoBilled( Opportunity opportunityRecord, String cap){  
        
        System.debug('===== updateRevenueMilestone =====: ' );
        System.debug('===== opportunityRecord =====: '+opportunityRecord);
        
        List<Revenue_Milestone__c> revenueMilestoneList = new List<Revenue_Milestone__c>();
        Decimal totalAmount = 0; 
        Boolean isBillto = true;
        
        if(opportunityRecord.Billing_Start_Date__c != null){      
            
            Integer monthSize = 0;
            Date startDate = opportunityRecord.Billing_Start_Date__c; 
            Date LastDate = Date.newInstance((startDate.year()+1), 03, 31);
            
            if(cap == 'Cap'){
                monthSize =  startDate.monthsBetween(LastDate)+1;
                System.debug('==== Months ==== '+monthSize);
            }else{
                monthSize = 12;
            }
            
            Boolean isfirstDate = true;
            Date endDate = Date.today();
            
            for(Integer count = 0 ; count < monthSize ; count++){
                
                startDate = opportunityRecord.Billing_Start_Date__c.addMonths(count);
                
                Integer remaningDays =0;
                if(isfirstDate){
                    remaningDays = Date.daysInMonth(startDate.year(), startDate.month()) - startDate.day();
                    endDate = startDate.addDays(remaningDays);
                }else{
                    
                    startDate = endDate.addDays(1);
                    System.debug('===============startDate ==============='+startDate);
                    
                    remaningDays = Date.daysInMonth(startDate.year(), startDate.month()) - startDate.day();
                    endDate = startDate.addDays(remaningDays);
                    
                    if(count==12){
                        endDate = opportunityRecord.Billing_End_date__c; 
                    }
                    System.debug('===============endDate ==============='+endDate);
                }
                
                isfirstDate = false;
                
                Revenue_Milestone__c revenueMilestone = new Revenue_Milestone__c();
                revenueMilestone.Account__c = opportunityRecord.AccountId;
                revenueMilestone.Opportunity__c = opportunityRecord.Id;
                Date opportunityDate = opportunityRecord.Billing_Start_Date__c;
                revenueMilestone.CurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
                revenueMilestone.Milestone_Due_Date__c =startDate;
                revenueMilestone.Milestone_Start_Date__c = startDate;
                revenueMilestone.Milestone_End_Date__c = endDate; 
                
                //revenueMilestone.Milestone_Due_Date__c =opportunityDate.addMonths(count) ; 
                revenueMilestone.Forecast_Category__c = 'Shift of Unbilled to Billed';
                
                if(opportunityDate.addMonths(count) <= opportunityRecord.LastModifiedDate ){
                    
                    if(opportunityRecord.Instrument_type_3__c == 'Bank Loan Rating'){
                        //totalAmount += (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.6153846))/12;
                        Decimal perday =0;
                        Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                        System.debug('=========== balance'+balance);
                        if(!Date.isLeapYear(startDate.year())){
                            perday = balance.divide(365,2);
                            System.debug('=========== perday'+perday);
                        }else{
                            perday = balance.divide(366,2);
                            System.debug('=========== perday'+perday); 
                        }
                        
                        totalAmount +=  (perday * (startDate.daysBetween(endDate)+1));
                        
                    }else{
                        //totalAmount += (opportunityRecord.ASF_Final_Amount__c - (opportunityRecord.ASF_Final_Amount__c*0.769231))/12;
                        Decimal perday =0;
                        Decimal balance = opportunityRecord.Amount_To_Be_Billed__c;
                        System.debug('=========== balance'+balance);
                        if(!Date.isLeapYear(startDate.year())){
                            perday = balance.divide(365,2);
                            System.debug('=========== perday'+perday);
                        }else{
                            perday = balance.divide(366,2);
                            System.debug('=========== perday'+perday);
                        }
                        
                        totalAmount +=  (perday * (startDate.daysBetween(endDate)+1));
                    }
                    revenueMilestone.Amount__c= 0;
                    
                }else{
                    
                    if(isBillto){
                        revenueMilestone.Amount__c = 0 - (totalAmount).round(System.RoundingMode.CEILING);
                        isBillto = false;
                    }else{
                        revenueMilestone.Amount__c = 0;
                    }
                    
                }  
                revenueMilestoneList.add(revenueMilestone);
            }
        }  
        return revenueMilestoneList ;
    } 
}