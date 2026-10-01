public class Fee_calculation_Handler {
    public static Boolean isFirstTime = true;
    public static String opp_Location{get;set;}
    public static String opp_Instrument{get;set;}
    public static String opp_sub_sector{get;set;}
    public static Decimal opp_vod{get;set;}
    
    public static void Pricing_calculation_Master(List<Opportunity> newOpportunity){
        Id opp_id;
        String Price_Instrument='';
        String Price_Location='';
        String Price_sector='';
        String Price_VOD='';
        Decimal Min_Fee=0.0;
        Decimal target_yield=0.0;
        string BD_Team_Classification='';
        List<Sector_Location_Master__c>SLM= New List<Sector_Location_Master__c>();
        List<Pricing_Structure__c>Price_str= New List<Pricing_Structure__c>();
        
        List<Opportunity>oppsupdate= New List<Opportunity>();
        for(Opportunity opp: newOpportunity){
            
            opp_Location=opp.Branch__c;
            opp_sub_sector=opp.Sub_Sector__c;
            opp_Instrument=opp.Instrument_type_2__c;
            opp_vod=opp.VoD_in_crore__c;
            BD_Team_Classification=opp.BD_Team_Classification__c;
            opp_id=opp.Id; 
        }
        system.debug('Location->'+opp_Location);
        system.debug('opp_sub_sector->'+opp_sub_sector);
        system.debug('Instrument->'+opp_Instrument);
        if( string.isNotBlank(opp_Location) && string.isNotBlank(opp_Instrument)){
            SLM=[Select id,Instrument__c,Location__c,Sector__c,Valid_Value__c From Sector_Location_Master__c where Instrument__c=:opp_Instrument];     
            system.debug('sector_location_Master->'+SLM);
        }
        if(!SLM.isEmpty()){
            for(Sector_Location_Master__c SlMaster:SLM){
                if(SlMaster.Instrument__c==opp_Instrument){
                    Price_Instrument=SlMaster.Instrument__c;
                }
                if(SlMaster.Location__c==opp_Location){
                    Price_Location=SlMaster.Location__c;
                }
                
                if(SlMaster.Valid_Value__c==opp_sub_sector){
                    Price_sector=SlMaster.Sector__c;
                }
            }  
        }
        if(string.isBlank(Price_Location)){
            Price_Location='Other';
        }
        if(string.isBlank(Price_sector)){
            Price_sector='Other';
        }
        if(string.isBlank(Price_Instrument)){
            Price_Instrument='Others';
        }
        system.debug('Price_Instrument->'+Price_Instrument);
        system.debug('Price_Location->'+Price_Location);
        system.debug('Price_sector->'+Price_sector);
        if(string.isNotBlank(Price_Instrument)&& string.isNotBlank(Price_Location)&& string.isNotBlank(Price_sector)){
            Price_str=[Select id,Name,Instrument__c,Location__c,Min_Fee_Rs_Lacs__c,Sector__c,Target_Yield__c,VOD_Max__c,VOD_Min__c,BD_TEAM_CLASSIFICATION__C from Pricing_Structure__c
                       where Instrument__c=:Price_Instrument and Location__c=:Price_Location and Sector__c=:Price_sector and VOD_Min__c<=:opp_vod and VOD_Max__c>=:opp_vod and BD_TEAM_CLASSIFICATION__C=:BD_Team_Classification ORDER BY VOD_Max__c ASC];
        }
        System.debug('Price_str'+Price_str);
                System.debug('Price_str'+Price_str.size());

        string ECGVODGroup='';
        if(!Price_str.isEmpty()){
            for(Pricing_Structure__c ps:Price_str){
                
                Min_Fee=ps.Min_Fee_Rs_Lacs__c;
                target_yield=ps.Target_Yield__c;
                if(ps.BD_TEAM_CLASSIFICATION__C=='ECG' && ps.Instrument__c=='Rating - Bank Loan Rating'){
                    system.debug('System.Label.ECG_1st_Group_Min'+System.Label.ECG_1st_Group_Min);
                    if(ps.VOD_Min__c==decimal.valueof(System.Label.ECG_1st_Group_Min)){
                        system.debug('Label');
                        ECGVODGroup='0-50 group';
                    }
                    else if(ps.VOD_Min__c==decimal.valueof(System.Label.ECG_2nd_Group_Min)){
                        ECGVODGroup='50-100 group';
                    }
                }  
            }
        }
        else{
            ECGVODGroup='';
            target_yield=0.10;
            Min_Fee=10000000.00;
        }
                system.debug('ECGVODGroup->'+ECGVODGroup);

        system.debug('Min_Fee->'+Min_Fee);
        system.debug('target_yield->'+target_yield);
        for(Opportunity opps:newOpportunity){
            
            opps.Min_Fee__c=Min_Fee;
            opps.Threshold_Yield__c=target_yield;
            opps.ECG_VOD_group__c=ECGVODGroup;
        }
    }
    
    public static void Existing_Fee_Master_For_SCG_ICG(List<Opportunity> newOpportunity , Set<id> OpptoAcc_id){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        
        List<Opportunity>curr_year_opp= New List<Opportunity>();
        List<Opportunity>prv_year_opp= New List<Opportunity>();
        List<Opportunity> ExistingOpportunity= New List<Opportunity>();
        List<Opportunity> All_Opp_Under_Acc= New List<Opportunity>();
        List<Opportunity> All_Opp_Under_Acc_Surv= New List<Opportunity>();
        String Branch='';
        string Sector='';
        string MandateType='';
        string Instrument='';
        string Instrument1='';
        Decimal Existing_Vod=0.0;
        Decimal Existing_Initial_Rating_Fee=0.0;
        Decimal Pre_Existing_Fee=0.0;
        Decimal Existing_Fee=0.0;
        Decimal New_vod=0.0;
        Decimal total_Account_ASF=0.0;
        Decimal total_Account_IRF=0.0;  
         

        for(Opportunity opps:newOpportunity){
            Branch=opps.Branch__c;
            Sector=opps.Sub_Sector__c;
            MandateType=opps.Mandate_Type__c;
            Instrument=opps.Instrument_type_2__c;
            Instrument1=opps.Instrument_type_1__c;
            New_vod=opps.VoD_in_crore__c;
        }
        
        if(string.isNotBlank(Branch) && MandateType!='Fresh From Existing'){
            
            Existing_Fee=0.0;
            Pre_Existing_Fee=0.0;
            
        }
        if(MandateType=='Fresh From Existing'){

            All_Opp_Under_Acc= [select id,AccountId,RecordType.Name, 
                                  ASF_Final_Amount__c,IRF_Final_Amount__c
                                  from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won' and Fiscal_Year__c=:'Current' and Instrument_type_1__c=:Instrument1 AND RecordType.Name='New Business' AND Business_Segment__c='Rating'];

        if(!All_Opp_Under_Acc.isEmpty() && All_Opp_Under_Acc!= null){
            for(Opportunity opp:All_Opp_Under_Acc){
                if(opp.RecordType.Name=='New Business' && opp.IRF_Final_Amount__c>0){
                    total_Account_IRF+= opp.IRF_Final_Amount__c;
                }
            } 
        }
       
        Date dT = System.Today();
        Date myDate=System.Today(); 
        //Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        if(dT.month()<4){
             myDate= Date.newInstance(dT.Year()-1,04,01);
         }else{
             myDate= Date.newInstance(dT.Year(),04,01);
         }                   
        

        All_Opp_Under_Acc_Surv= [select id,AccountId,RecordType.Name, ASF_Final_Amount__c,IRF_Final_Amount__c, Parent_Opportunity__c, Mandate_Id__c, Billing_Start_Date__c, createddate, Requested_Fee__c from Opportunity where AccountId in : OpptoAcc_id and StageName=:'Closed Won' and Instrument_type_1__c=:Instrument1 AND (Defer_Billing_or_Exit_Case__c='To Be Billed' OR Defer_Billing_or_Exit_Case__c='Already Billed' OR Defer_Billing_or_Exit_Case__c='Hold (Uncertain)') AND RecordType.Name='Surveillance' AND Business_Segment__c='Rating' ORDER BY Billing_Start_Date__c DESC];

        Map<String, List<Opportunity>> mapOfParentVsChildren = new Map<String, List<Opportunity>>();
			for(Opportunity opp : All_Opp_Under_Acc_Surv){
				if(opp.Parent_Opportunity__c != null){
					if(!mapOfParentVsChildren.containsKey(opp.Parent_Opportunity__c)){
						mapOfParentVsChildren.put(opp.Parent_Opportunity__c, new List<Opportunity>());
					}
					mapOfParentVsChildren.get(opp.Parent_Opportunity__c).add(opp);
				}else if(opp.Parent_Opportunity__c == null){
                    if(!mapOfParentVsChildren.containsKey(opp.Id)){
					    mapOfParentVsChildren.put(opp.Id, new List<Opportunity>());
                    }
                    mapOfParentVsChildren.get(opp.Id).add(opp);
				}
			}     
                System.Debug('mapOfParentVsChildren size====>>'+mapOfParentVsChildren.keyset());
            if(!mapOfParentVsChildren.isEmpty() && mapOfParentVsChildren!= null){
                for(String oppId: mapOfParentVsChildren.keyset()){
                    if(mapOfParentVsChildren.containsKey(oppId)){
                        List<Opportunity> oppList2 = mapOfParentVsChildren.get(oppId);
                        Opportunity latestOpp = getLatestOpp(oppList2);
                        System.Debug('latest opp====>>'+latestOpp.Id+'========'+latestOpp.Mandate_Id__c);
                        total_Account_ASF+= latestOpp.Requested_Fee__c!=null ? latestOpp.Requested_Fee__c : latestOpp.ASF_Final_Amount__c >0 ? latestOpp.ASF_Final_Amount__c : 0; 
                    }
                } 
            }
    }



        if(string.isNotBlank(Branch) && MandateType=='Fresh From Existing'){
            ExistingOpportunity= [select id,AccountId,RecordType.Name, Sector__c, Client_Status__c, Customer_Fee_Type__c, Branch__c, Line_of_Business__c, Sub_Sector__c, Focus_Group__c, Name, Parent_Opportunity__c, 
                                  Business_Segment__c, StageName, Contact__c,Opportunity_Closed_Date__c,
                                  OwnerId, RecordTypeId, Instrument_type_1__c, Instrument_type_3__c, BLR_Sub_Instrument_1__c,
                                  BLR_Sub_Instrument_2__c, BLR_Sub_Instrument_3__c, BLR_Sub_Instrument_4__c,
                                  BLR_Sub_Instrument_5__c, Instrument_type_2__c, Instrument_type_4__c, Remarks_If_any__c, Volume_of_Debt_1_amount__c,
                                  Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,Fiscal_Year__c,
                                  CurrencyIsoCode, Volume_of_Debt_Category__c, VoD_in_crore__c,Closed_Won_Date__c from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won'and RecordTypeId=:oppRecordTypeId AND Business_Segment__c='Rating' and Branch__c=:Branch /*and Sub_Sector__c=:sector*/ and Fiscal_Year__c=:'Previous' and Instrument_type_2__c=:Instrument order by Closed_Won_Date__c DESC Limit 1];
            
        }
        system.debug('ExistingOpportunity->'+ExistingOpportunity);
        if(!ExistingOpportunity.isEmpty() && ExistingOpportunity.Size()>0){
            
            for(Opportunity opp:ExistingOpportunity){
                if(opp.Closed_Won_Date__c!=null){
                    
                    prv_year_opp.add(opp);
                    prv_year_opp.sort();
                    
                }
                
            }     
        }
        if(ExistingOpportunity.isEmpty() && ExistingOpportunity==null){
            Existing_Fee=0.0;
            Pre_Existing_Fee=0.0;
            
        }
        system.debug('prv_year_opp->'+prv_year_opp);
      
        if( prv_year_opp!=null && !prv_year_opp.isEmpty()){
            
            for( opportunity exist_opp:prv_year_opp ){
                
                Existing_Vod=exist_opp.VoD_in_crore__c *10000000;
                Existing_Initial_Rating_Fee=(exist_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);
                
            }
        }
        system.debug('Existing_Vod->'+Existing_Vod);
        system.debug('Existing_Initial_Rating_Fee->'+Existing_Initial_Rating_Fee);  
        if(Existing_Vod!=null && Existing_Initial_Rating_Fee!=null && Existing_Vod!=0.0 && Existing_Initial_Rating_Fee!=0.0){
            
            Pre_Existing_Fee=Existing_Initial_Rating_Fee;
            
            
        }
        system.debug('Pre_Existing_Fee->'+Pre_Existing_Fee);
        if(Pre_Existing_Fee!=null && New_vod!=null && Pre_Existing_Fee!=0.0 && New_vod!=0.0){
            
            Existing_Fee=((Pre_Existing_Fee)*(New_vod*10000000))/100;
        }else{
            Existing_Fee=0.0;
            Pre_Existing_Fee=0.0;
        }
        system.debug('Existing_Fee->'+Existing_Fee); 
        
        for( opportunity exsopp:newOpportunity){
            exsopp.Existing_Fee__c=Existing_Fee;   
            exsopp.Pre_Existing_Fee__c=Pre_Existing_Fee*10000000;
            exsopp.Total_Account_ASF__c=total_Account_ASF;
            exsopp.Total_Account_IRF__c=total_Account_IRF;
        }      
        
    }
    
    public static void Existing_Fee_Master_For_SF(List<Opportunity> newOpportunity , Set<id> OpptoAcc_id){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        Integer Current_Fiscal_year;
        Integer CurrentYear = datetime.now().year();
        Integer Currentmonth= datetime.now().Month();
        Date Start_date=date.newInstance(CurrentYear, 04, 01);
        Date End_Date= Date.newInstance(CurrentYear+1, 03, 31);
        Id SLMRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('SF Master').getRecordTypeId();
        List<Sector_Location_Master__c>SLM= New List<Sector_Location_Master__c>();
        List<Sector_Location_Master__c>SLMSF= New List<Sector_Location_Master__c>();
        List<Opportunity>curr_year_opp= New List<Opportunity>();
        List<Opportunity>curr_year_opp_DA= New List<Opportunity>();
        List<Opportunity>curr_year_selopp= New List<Opportunity>();
        List<Opportunity>prv_year_selopp= New List<Opportunity>();
        List<Opportunity>prv_year_opp= New List<Opportunity>();
        List<Opportunity>prv_year_opp_DA= New List<Opportunity>();
        List<Opportunity> ExistingOpportunity= New List<Opportunity>();
        String Branch='';
        string Sector='';
        string MandateType='';
        string Instrument='';
        string Instrument_4='';
        Decimal Existing_Vod=0.0;
        Decimal Existing_Initial_Rating_Fee=0.0;
        Decimal Existing_ASF_Fee=0.0;
        Decimal Existing_ASF_Fee1=0.0;
        Decimal Existing_ASF_Fee2=0.0;
        Decimal Pre_Existing_Fee=0.0;
        Decimal Existing_Fee=0.0;
        Decimal New_vod=0.0;
        Decimal min_yield=0.0;
        Decimal targert_hike=0.0;
        Decimal target_asf_hike=0.0;
        Decimal min_asf_amt=0.0;
        Decimal min_irf_amt=0.0;
        Decimal asf_fee=0.0;
        String LossEstimation_DA='Loss Estimation/Direct Assignment';
        for(Opportunity opps:newOpportunity){
            Branch=opps.Branch__c;
            Sector=opps.Sub_Sector__c;
            MandateType=opps.Mandate_Type__c;
            Instrument=opps.Instrument_type_1__c;
            Instrument_4=opps.Instrument_type_4__c;
            New_vod=opps.VoD_in_crore__c;
            min_yield=opps.Threshold_Yield__c;
        }
        
        if(string.isNotBlank(Branch) && MandateType!='Fresh From Existing'){
            
            Existing_Fee=0.0;
            Pre_Existing_Fee=0.0;
            SLM=[Select id,Instrument__c,Location__c,Sector__c,Valid_Value__c,Recordtypeid,Min_Yield__c,Max_Yield__c,Min_ASF_Amount__c,Min_IRF_Amount__c,Target_ASF_Increase__c,Target_of_increase__c,Min_ASF_Yield__c From Sector_Location_Master__c where Recordtypeid=:SLMRecordTypeId ORDER By Min_Yield__c DESC Limit 1];     
            
            SLM.sort();
            system.debug('sector_location_Master->'+SLM);
            system.debug('sector_location_Master->'+SLM.size());
            
            if(!SLM.isEmpty()){
                for(Sector_Location_Master__c o : SLM){
                    system.debug('sector_location_Master->'+o.Min_Yield__c);

                    Existing_Fee=((o.Min_Yield__c)*New_vod*10000000)/100.00;
                    target_asf_hike=decimal.valueOf(o.Target_ASF_Increase__c);
                    min_irf_amt=o.Min_IRF_Amount__c;
                    min_asf_amt=o.Min_ASF_Amount__c;
                    asf_fee=((o.Min_ASF_Yield__c)*New_vod*10000000)/100.00;
                    asf_fee= math.max(asf_fee,min_asf_amt);
                }
            }
            
            for( opportunity exsopp:newOpportunity){
                
                exsopp.Existing_Fee__c=Existing_Fee;   
                exsopp.Pre_Existing_Fee__c=0.0;
                exsopp.Target_Hike__c=0.0;
                exsopp.Target_ASF_Hike__c=0.0;
                exsopp.Min_IRF_Amount_SF__c=min_irf_amt;
                exsopp.Min_ASF_Amount_SF__c=min_asf_amt;
                exsopp.ASF_Fee_SF__c=asf_fee;
                
            }   
        }
        if(string.isNotBlank(Branch) && MandateType=='Fresh From Existing'){
            ExistingOpportunity= [select id,AccountId,RecordType.Name, Sector__c, Client_Status__c, Customer_Fee_Type__c, Branch__c, Line_of_Business__c, Sub_Sector__c, Focus_Group__c, Name, Parent_Opportunity__c, 
                                  Business_Segment__c, StageName, Contact__c,Opportunity_Closed_Date__c,
                                  OwnerId, RecordTypeId, Instrument_type_1__c, Instrument_type_3__c,Instrument_type_2__c, Instrument_type_4__c, Remarks_If_any__c, Volume_of_Debt_1_amount__c,
                                  Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,Fiscal_Year__c,
                                  CurrencyIsoCode, Volume_of_Debt_Category__c, VoD_in_crore__c,Closed_Won_Date__c from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won'and RecordTypeId=:oppRecordTypeId and Branch__c=:Branch /*and Sub_Sector__c=:sector*/ and Instrument_type_1__c=:Instrument order by Closed_Won_Date__c DESC];
            
        }
        system.debug('ExistingOpportunity->'+ExistingOpportunity);
        if(!ExistingOpportunity.isEmpty() && ExistingOpportunity.Size()>0){
            
            for(Opportunity opp:ExistingOpportunity){
                
                if(opp.Closed_Won_Date__c!=null && (opp.Fiscal_Year__c=='Previous') && opp.Instrument_type_4__c!=LossEstimation_DA){  
                    prv_year_opp.add(opp);
                    prv_year_opp.sort();           
                }else if(opp.Closed_Won_Date__c!=null && (opp.Fiscal_Year__c=='Previous') && opp.Instrument_type_4__c==LossEstimation_DA){  
                    prv_year_opp_DA.add(opp);
                    prv_year_opp_DA.sort();           
                }


                if(opp.Closed_Won_Date__c!=null && (opp.Fiscal_Year__c!='Previous') && opp.Instrument_type_4__c!=LossEstimation_DA){                   
                    curr_year_opp.add(opp);
                    curr_year_opp.sort();
                }else if(opp.Closed_Won_Date__c!=null && (opp.Fiscal_Year__c!='Previous') && opp.Instrument_type_4__c==LossEstimation_DA){                   
                    curr_year_opp_DA.add(opp);
                    curr_year_opp_DA.sort();
                } 
            }
            system.debug('prv_year_opp->'+prv_year_opp);
            system.debug('curr_year_opp->'+curr_year_opp);
            /**Current Year New Business Records */
            if((((curr_year_opp!=null && prv_year_opp.isEmpty()) ||(prv_year_opp!=null && curr_year_opp!=null)) && Instrument_4!=LossEstimation_DA)){
                if(curr_year_opp.size()==1 && curr_year_opp[0].Instrument_type_4__c!=LossEstimation_DA){
                    for( opportunity exist_opp:curr_year_opp ){
                        Existing_Vod=exist_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(exist_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);   
                        Existing_ASF_Fee=(exist_opp.ASF_as_per_Agreement_BPS__c/100);   
                    }
                    system.debug('Existing_Vod->'+Existing_Vod);
                    system.debug('Existing_Initial_Rating_Fee->'+Existing_Initial_Rating_Fee); 
                    
                }else if(curr_year_opp.size()>1){
                    curr_year_selopp=[select Id,Initial_Rating_Fee_as_per_Agreement_BPS__c,VoD_in_crore__c,Closed_Won_Date__c,ASF_as_per_Agreement_BPS__c, Instrument_type_4__c from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won' and RecordTypeId=:oppRecordTypeId and Branch__c=:Branch /*and Sub_Sector__c=:sector*/ and Instrument_type_1__c=:Instrument and Instrument_type_4__c!='Loss Estimation/Direct Assignment' and Fiscal_Year__c!='Previous' Order by Initial_Rating_Fee_as_per_Agreement_BPS__c ASC Limit 1]; 
                    
                     system.debug('curr_year_selopp->'+curr_year_selopp);
                    for(opportunity curr_opp:curr_year_selopp){
                        Existing_Vod=curr_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(curr_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);  
                        Existing_ASF_Fee=(curr_opp.ASF_as_per_Agreement_BPS__c/100);  
                    }                
                }
            }else if((((curr_year_opp_DA!=null && prv_year_opp_DA.isEmpty()) ||(prv_year_opp_DA!=null && curr_year_opp_DA!=null)) && Instrument_4== LossEstimation_DA)){
                if(curr_year_opp_DA.size()==1 && curr_year_opp_DA[0].Instrument_type_4__c== LossEstimation_DA){
                    for( opportunity exist_opp:curr_year_opp_DA ){
                        Existing_Vod=exist_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(exist_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);   
                        Existing_ASF_Fee=(exist_opp.ASF_as_per_Agreement_BPS__c/100);   
                    }
                    system.debug('Existing_Vod_DA->'+Existing_Vod);
                    system.debug('Existing_Initial_Rating_Fee_DA->'+Existing_Initial_Rating_Fee); 
                                        system.debug('Existing_ASF_Fee_DA->'+Existing_ASF_Fee); 

                    
                }else if(curr_year_opp_DA.size()>1){
                    curr_year_selopp=[select Id,Initial_Rating_Fee_as_per_Agreement_BPS__c,VoD_in_crore__c,Closed_Won_Date__c,ASF_as_per_Agreement_BPS__c, Instrument_type_4__c from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won' and RecordTypeId=:oppRecordTypeId and Branch__c=:Branch and Instrument_type_1__c=:Instrument and Fiscal_Year__c!='Previous' and Instrument_type_4__c=: LossEstimation_DA Order by Initial_Rating_Fee_as_per_Agreement_BPS__c ASC Limit 1]; 
                    
                     system.debug('curr_year_selopp_DA->'+curr_year_selopp);
                    for(opportunity curr_opp:curr_year_selopp){
                        Existing_Vod=curr_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(curr_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);  
                        Existing_ASF_Fee=(curr_opp.ASF_as_per_Agreement_BPS__c/100);  
                    }                
                }
            }
            /**Previous Year New Business Records */
            if(prv_year_opp!=null && curr_year_opp.isEmpty() && Instrument_4!=LossEstimation_DA){
                if(prv_year_opp.size()==1 && prv_year_opp[0].Instrument_type_4__c!=LossEstimation_DA){
                    for( opportunity prv_exist_opp:prv_year_opp ){
                        Existing_Vod=prv_exist_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(prv_exist_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100); 
                        Existing_ASF_Fee=(prv_exist_opp.ASF_as_per_Agreement_BPS__c/100);   
                        
                    }
                    system.debug('Existing_Vod->'+Existing_Vod);
                    system.debug('Existing_Initial_Rating_Fee->'+Existing_Initial_Rating_Fee);
                }
                else if(prv_year_opp.size()>1){
                    prv_year_selopp=[select Id,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,VoD_in_crore__c,Closed_Won_Date__c,StageName,Instrument_type_1__c, Instrument_type_4__c from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won' and RecordTypeId=:oppRecordTypeId and Branch__c=:Branch and Instrument_type_1__c=:Instrument and Instrument_type_4__c!='Loss Estimation/Direct Assignment' Order by Closed_Won_Date__c DESC Limit 1]; 
                    system.debug('prv_year_selopp->'+prv_year_selopp);
                    
                    for(opportunity prv_opp:prv_year_selopp){
                        Existing_Vod=prv_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(prv_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);
                        Existing_ASF_Fee=(prv_opp.ASF_as_per_Agreement_BPS__c/100);    
                    }                
                }
            }else if(prv_year_opp_DA!=null && curr_year_opp_DA.isEmpty() && Instrument_4==LossEstimation_DA){
                if(prv_year_opp_DA.size()==1 && prv_year_opp_DA[0].Instrument_type_4__c== LossEstimation_DA){
                    for( opportunity prv_exist_opp:prv_year_opp_DA ){
                        Existing_Vod=prv_exist_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(prv_exist_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100); 
                        Existing_ASF_Fee=(prv_exist_opp.ASF_as_per_Agreement_BPS__c/100);   
                        
                    }
                    system.debug('Existing_Vod_DA->'+Existing_Vod);
                    system.debug('Existing_Initial_Rating_Fee_DA->'+Existing_Initial_Rating_Fee);
                }
                else if(prv_year_opp_DA.size()>1){
                    prv_year_selopp=[select Id,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,VoD_in_crore__c,Closed_Won_Date__c,StageName,Instrument_type_1__c, Instrument_type_4__c from Opportunity where AccountId in : OpptoAcc_id and Closed_Won_Date__c!=Null and StageName=:'Closed Won' and RecordTypeId=:oppRecordTypeId and Branch__c=:Branch and Instrument_type_1__c=:Instrument and Instrument_type_4__c=: LossEstimation_DA Order by Closed_Won_Date__c DESC Limit 1]; 
                    system.debug('prv_year_selopp_DA->'+prv_year_selopp);
                    
                    for(opportunity prv_opp:prv_year_selopp){
                        Existing_Vod=prv_opp.VoD_in_crore__c *10000000;
                        Existing_Initial_Rating_Fee=(prv_opp.Initial_Rating_Fee_as_per_Agreement_BPS__c/100);
                        Existing_ASF_Fee=(prv_opp.ASF_as_per_Agreement_BPS__c/100);    
                    }                
                }
            }

            if(Existing_Vod!=null && Existing_Initial_Rating_Fee!=null && Existing_Vod!=0.0 && Existing_Initial_Rating_Fee!=0.0){
                
                Pre_Existing_Fee=Existing_Initial_Rating_Fee;
            }
            system.debug('Pre_Existing_Fee->'+Pre_Existing_Fee);
            if(Pre_Existing_Fee!=null && New_vod!=null && Pre_Existing_Fee!=0.0 && New_vod!=0.0){
                
                Existing_Fee=((Pre_Existing_Fee)*(New_vod*10000000))/100;
            }else{
                Existing_Fee=0.0;
                Pre_Existing_Fee=0.0;
            }
            system.debug('Existing_Fee->'+Existing_Fee); 
            system.debug('min_yield->'+min_yield); 
            
            if(Existing_Initial_Rating_Fee!=0.0){
                
                SLMSF=[Select id,Instrument__c,Location__c,Sector__c,Valid_Value__c,Recordtypeid,Min_Yield__c,Max_Yield__c,Min_ASF_Amount__c,Min_IRF_Amount__c,Target_ASF_Increase__c,Target_of_increase__c,Min_ASF_Yield__c From Sector_Location_Master__c where Recordtypeid=:SLMRecordTypeId and Min_Yield__c<=:Existing_Initial_Rating_Fee and Max_Yield__c>:Existing_Initial_Rating_Fee limit 1 ];
            }
            system.debug('SLMSF->'+SLMSF); 
            if(SLMSF!=null && !SLMSF.isempty()){

                for(Sector_Location_Master__c Slmf : SLMSF){
                    targert_hike=decimal.valueOf(Slmf.Target_of_increase__c);
                    target_asf_hike=decimal.valueOf(Slmf.Target_ASF_Increase__c);
                    System.debug('Existing_ASF_Fee===>>'+Existing_ASF_Fee);
                    System.debug('target_asf_hike===>>'+target_asf_hike);
                    min_irf_amt=Slmf.Min_IRF_Amount__c;
                    min_asf_amt=Slmf.Min_ASF_Amount__c;
                    Existing_ASF_Fee=(Existing_ASF_Fee!=0)? math.max(((Existing_ASF_Fee+(target_asf_hike/100)*Existing_ASF_Fee)*New_vod*10000000)/100.00, min_asf_amt):math.max(((Slmf.Min_ASF_Yield__c)*New_vod*10000000)/100.00,min_asf_amt);
                    System.debug('Existing_ASF_Fee===>>'+Existing_ASF_Fee);
                }
            }
            for( opportunity exsopp:newOpportunity){
                
                exsopp.Existing_Fee__c=Existing_Fee;   
                exsopp.Pre_Existing_Fee__c=Pre_Existing_Fee*10000000;
                exsopp.Target_Hike__c=targert_hike;
                exsopp.Target_ASF_Hike__c=target_asf_hike;
                exsopp.Min_IRF_Amount_SF__c=min_irf_amt;
                exsopp.Min_ASF_Amount_SF__c=min_asf_amt;
                exsopp.ASF_Fee_SF__c=Existing_ASF_Fee;

            } 
            
        }
        if(Existing_Initial_Rating_Fee==0.0){
            Existing_Fee=0.0;
            Pre_Existing_Fee=0.0;
            SLM=[Select id,Instrument__c,Location__c,Sector__c,Valid_Value__c,Recordtypeid,Min_Yield__c,Max_Yield__c,Min_ASF_Amount__c,Min_IRF_Amount__c,Target_ASF_Increase__c,Target_of_increase__c,Min_ASF_Yield__c From Sector_Location_Master__c where Recordtypeid=:SLMRecordTypeId ORDER By Min_Yield__c DESC Limit 1];     
            
            SLM.sort();
            system.debug('sector_location_Master->'+SLM);
            system.debug('sector_location_Master->'+SLM.size());
            
            if(!SLM.isEmpty()){
                for(Sector_Location_Master__c o : SLM){
                    system.debug('sector_location_Master->'+o.Min_Yield__c);

                    Existing_Fee=((o.Min_Yield__c)*New_vod*10000000)/100.00;
                    target_asf_hike=decimal.valueOf(o.Target_ASF_Increase__c);
                    min_irf_amt=o.Min_IRF_Amount__c;
                    min_asf_amt=o.Min_ASF_Amount__c;
                    asf_fee=((o.Min_ASF_Yield__c)*New_vod*10000000)/100.00;
                    asf_fee= math.max(asf_fee,min_asf_amt);

                }
                system.debug('asf_fee==>'+asf_fee);
                system.debug('min_irf_amt==>'+min_irf_amt);
                system.debug('min_asf_amt==>'+min_asf_amt);
            }

            for( opportunity exsopp:newOpportunity){
                
                exsopp.Existing_Fee__c=Existing_Fee;   
                exsopp.Pre_Existing_Fee__c=0.0;
                exsopp.Target_Hike__c=0.0;
                exsopp.Target_ASF_Hike__c=0.0;
                exsopp.Min_IRF_Amount_SF__c=min_irf_amt;
                exsopp.Min_ASF_Amount_SF__c=min_asf_amt;
                exsopp.ASF_Fee_SF__c=asf_fee;
            }  
        }
    }  

	public static Opportunity getLatestOpp(List<Opportunity> opps){
		if (opps == null || opps.isEmpty()){
			return null;
		}
		Opportunity latest = opps[0];
		for (Opportunity rec : opps) {
			if (rec.Billing_Start_Date__c > latest.Billing_Start_Date__c) {
				latest = rec;
			}else if(rec.Billing_Start_Date__c == latest.Billing_Start_Date__c){
				if(rec.CreatedDate > latest.CreatedDate){
					latest = rec;
				}
			}
		}
		return latest;
	}
}