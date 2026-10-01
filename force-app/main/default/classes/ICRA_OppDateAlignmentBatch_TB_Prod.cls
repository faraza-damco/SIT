public class ICRA_OppDateAlignmentBatch_TB_Prod  implements Database.Batchable<sObject> {
    string AccountnameParameter;
    public ICRA_OppDateAlignmentBatch_TB_Prod(string Acc)
    {
        this.AccountnameParameter=Acc;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String toBeBilled = 'To Be Billed';
        String clientStatus = 'Live'; 
        String recordType = 'Surveillance';
     //   String AccountName = 'Dixon Technologies (India) Limited (erstwhile Dixon Technologies (India) Private Limited)';
       // String AccountName = 'TG - Client ICRA Gurgaon';
        //String AccountName = 'Final Testing';
        //and Account.name=:AccountName
       String accountName =AccountnameParameter;
        String soqlquery = 'SELECT ASF_Final_Amount__c,Start_Change__c,Edited_By_Batch_UI__c,Account.name,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c, AccountId, Amount_To_Be_Billed__c, Batch_is_Running__c, BD_Approve__c, Billing_End_date__c, Billing_Start_Date__c, Billing_Year_FY__c, CloseDate, Client_Status__c, Defer_Billing_or_Exit_Case__c, IRF_Final_Amount__c, Id, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c, Instrument_type_4__c, Is_Date_Alignment_Done__c, Name, PR_Date__c, Parent_Opportunity__c, RecordTypeId, RecordType.Name,Rolling_and_Date_Alignmnet__c, StageName, Total_Invoice_Amount_1__c, VoD_in_crore__c, Change_in_start_Date__c,Opportunity_Batch_Process__c FROM Opportunity' ;
        soqlquery +=' WHERE Billing_Start_Date__c != null AND  Rolling_and_Date_Alignmnet__c = true AND Billing_End_date__c != null AND ( ASF_Final_Amount__c >0  OR IRF_Final_Amount__c > 0 ) AND Is_Date_Alignment_Done__c = false AND RecordType.Name = :recordType AND Defer_Billing_or_Exit_Case__c =:toBeBilled AND Account.name=:accountName ORDER BY Name DESC '; //AND Skip_Date_Alignment__c = true
        System.debug('Get query' +soqlquery); 
        return Database.getQueryLocator(soqlquery); 
        
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){ 
        Map<Id, List<Opportunity>> opportunityAccountMap = new Map<Id, List<Opportunity>>(); 
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        Set<id> accountIdSet = new Set<Id>(); 
        
        for(Opportunity tempRecord : opportunityList){
          //  System.debug('==== full list of opp ====='+tempRecord.Id +'--'+tempRecord.Name +'--'+tempRecord.Rolling_and_Date_Alignmnet__c);
            accountIdSet.add(tempRecord.AccountId);
        }
        
        
        for(Opportunity opportunityRecord : [SELECT Id, Name ,Parent_Opportunity__r.recordtype.Name,Parent_Opportunity__c, Instrument_type_1__c, Instrument_type_2__c, Instrument_type_3__c,Instrument_type_4__c,Billing_End_Date__c,AccountID ,Billing_Start_Date__c, RecordType.Name, Opportunity_Batch_Process__c,Change_in_start_Date__c, Amount_To_Be_Billed__c ,ASF_Final_Amount__c,
                                             Is_Date_Alignment_Done__c,Edited_By_Batch_UI__c,Skip_Date_Alignment__c,Start_Change__c,Parent_Opportunity__r.Billing_End_date__c,Parent_RecordType__c
                                             FROM Opportunity 
                                             WHERE AccountID IN : accountIdSet AND 
                                             Defer_Billing_or_Exit_Case__c = 'To Be Billed' AND 
                                             RecordType.Name = 'Surveillance' AND
                                             Billing_Start_Date__c != null AND
                                             Billing_End_date__c != null AND
                                             Rolling_and_Date_Alignmnet__c = true AND Billing_End_date__c != null AND ( ASF_Final_Amount__c > 1  OR IRF_Final_Amount__c > 1 ) //AND Skip_Date_Alignment__c = true
                                            ]){
                                                
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
                 String mapkey='';
                //system.debug('opportunityrecord.Instrument_type_4__c '+opportunityrecord.Instrument_type_4__c);
               // system.debug('opportunityrecord.Instrument_type_2__c '+opportunityrecord.Instrument_type_2__c);
                //system.debug('opportunityrecord.Instrument_type_3__c '+opportunityrecord.Instrument_type_3__c);
                if(opportunityrecord.Instrument_type_2__c == 'Rating - Bank Loan Rating')
                {
                      mapkey = 'Bank Loan Rating'+'-'+ accountId;
                }else if(opportunityrecord.Instrument_type_2__c =='Others' && opportunityrecord.Instrument_type_3__c =='Others')
                {
                      mapkey = 'Other-Other-BLR'+'-'+ accountId;
                }
                else if( (opportunityrecord.Instrument_type_2__c =='Rating - Money Market (Non-SF)' && opportunityrecord.Instrument_type_3__c =='Commercial Paper/Certificate of Deposit/Short-term Debt' && (opportunityrecord.Instrument_type_4__c =='Commercial Paper' || opportunityrecord.Instrument_type_4__c =='Short Term Borrowing Programme')))
                {
                      mapkey = 'Money-Market-CP-BLR'+'-'+ accountId;
                }  
               /* else if( (opportunityrecord.Instrument_type_2__c =='Rating - Money Market (Non-SF)' && opportunityrecord.Instrument_type_3__c =='Commercial Paper/Certificate of Deposit/Short-term Debt' &&  opportunityrecord.Instrument_type_4__c =='Short Term Borrowing Programme'))
                {
                      mapkey = 'Money-Market-CP-BLR'+'-'+ accountId;
                }   */ 
                else
                {
                        mapkey = opportunityrecord.Instrument_type_2__c+'-'+ accountId;
                    System.debug('mapkey'+mapkey);
                }
             
                
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
                
            }else if(mapkey.contains('Money-Market-CP-BLR')){
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){ 
                    System.debug('=================Money Market CP====='+sortData.size());
                    updateOpportunityList.addAll( dataAlignment(sortData, 'BRL'));
                }   
                
            } 
            /*else if(mapkey.contains('Money-Market-STB-BLR')){
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){ 
                    System.debug('=================Money Market STB====='+sortData.size());
                    updateOpportunityList.addAll( dataAlignment(sortData, 'BRL'));
                }   
                
            } */
			else if(mapkey.contains('Other-Other-BLR')){
                Opportunity [] sortData = sortOpportunity(opportunityWithDateAndVod.get(mapkey));
                if(sortData.size() >0){ 
                    System.debug('=================Money Market Other====='+sortData.size());
                    updateOpportunityList.addAll( dataAlignment(sortData, 'BRL'));
                }   
                
            } 
			else if(mapkey.contains('Money Market')){
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
            
            System.debug('updateOpportunityList '+updateOpportunityList);
           
           /* for(Opportunity tempOpportunity : updateOpportunityList){
                system.debug('updateOpportunityList Data one by One'+tempOpportunity);
                
            }*/
            
            Database.SaveResult [] updateResults = Database.update (updateOpportunityList, false);
            /* List<Error_Log__c> ELoglist=new List<Error_Log__c>();
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    updateResults.get(i).getId();
                    
                }else if (!updateResults.get(i).isSuccess()){
                    Error_Log__c  Elog=new Error_Log__c();
                    // DML operation failed
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    updateOpportunityList.get(i);//failed record from the list
                    system.debug('Failed ID'+updateOpportunityList.get(i).Id);
                    Elog.Record_ID__c=updateOpportunityList.get(i).Id;
                    Elog.Error_Message__c=failedDML;
                    ELoglist.add(Elog);
                    
                }
                
            }
            if(ELoglist.Size()>0)
            {
                Database.insert(ELoglist, false);
            } */
        }
    }
    
    public void finish(Database.BatchableContext BC ){
        System.debug('======= BC =======:  '+BC);
        Database.executeBatch(new ICRA_UpdateEditedBy_Batch(),20);
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
         System.debug('========opportunityList===sort END ====== '+opportunityList);
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
            Map<id,Opportunity> updoppmapParent=new  Map<id,Opportunity>();
            Map<id,List<Opportunity>> updoppmapChield=new  Map<id,List<Opportunity>>();
            Map<id,string> NB_FirstSurv=new  Map<id,string>();
            
            for(Opportunity tempOpportunity : opportunityList){
                system.debug('==== Name of the Opp ======'+tempOpportunity.Name +'-'+ +tempOpportunity.Change_in_start_Date__c);
               //system.debug('==== Enter in IF loop of change in start date'+tempOpportunity.Change_in_start_Date__c);
                if(tempOpportunity.Change_in_start_Date__c == false)
                {
                    if(tempOpportunity.Parent_Opportunity__r.recordtype.Name=='New Business')
                    {
                        NB_FirstSurv.put(tempOpportunity.Parent_Opportunity__c,tempOpportunity.ID);//NB-First Surv
                    }
                    updoppmapParent.put(tempOpportunity.Id,tempOpportunity);//First Surv Id -rec
                    System.debug('===== Parent Map of Surv'+updoppmapParent);
                }
                else
                {
                    if(NB_FirstSurv.containskey(tempOpportunity.Parent_Opportunity__c))
                    {
                        if(updoppmapChield.containskey(NB_FirstSurv.get(tempOpportunity.Parent_Opportunity__c))){
                            updoppmapChield.get(NB_FirstSurv.get(tempOpportunity.Parent_Opportunity__c)).add(tempOpportunity);

                                
                            
                        }
                        else
                        {
                            updoppmapChield.put(NB_FirstSurv.get(tempOpportunity.Parent_Opportunity__c), New List<Opportunity>{tempOpportunity});//First-Second Surv
                        }
                        
                    }
                    else
                    {
                       
                        if(updoppmapChield.containskey(tempOpportunity.Parent_Opportunity__c)){
                            List<Opportunity> childOpps = updoppmapChield.get(tempOpportunity.Parent_Opportunity__c);
                            childOpps.add(tempOpportunity);
                            updoppmapChield.put(tempOpportunity.Parent_Opportunity__c,childOpps);
                            System.debug('===== updoppmapChield in for loop second time  ====='+childOpps.size()+ '-' +updoppmapChield);
                        }
                        else
                        {
                            updoppmapChield.put(tempOpportunity.Parent_Opportunity__c, New List<Opportunity>{tempOpportunity});
                            System.debug('===== updoppmapChield in for loop First time  ====='+updoppmapChield.size()+ '-' +updoppmapChield);
                        }
                         
                    }
                    
                }
                
            }
            system.debug('=================== updoppmapParent =========================='+updoppmapParent);
             system.debug('=================== updoppmapChield =========================='+updoppmapChield.size());
             system.debug('=================== compareDate =========================='+compareDate);
            
            updateOpportunity.addAll(ICRA_DatealighnmentHelper.UpdateDate(updoppmapParent,updoppmapChield,compareDate));
            
    /*        for(Opportunity tempOpportunity : opportunityList){
                
                if(tempOpportunity.RecordType.Name =='Surveillance' && tempOpportunity.Opportunity_Batch_Process__c == 'BLR-Date-Align' && tempOpportunity.Skip_Date_Alignment__c == false ){
                    
                    
                    
                }
               
                else if(tempOpportunity.RecordType.Name =='Surveillance' &&  tempOpportunity.Opportunity_Batch_Process__c == 'MM-Date-Not-FY' && tempOpportunity.Skip_Date_Alignment__c == false  ){
                    
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
                    system.debug('tempOpportunity Name'+tempOpportunity.Name);
                    updateOpportunity.add(tempOpportunity);  
                    
               } 
            }
            */
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