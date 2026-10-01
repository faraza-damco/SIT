trigger FEE_calculation on Opportunity (Before update, Before Insert) {
    Triggers_status__c tg_status= Triggers_status__c.getInstance();
    system.debug('Trigger Status Instance===>>'+tg_status);
    system.debug('Trigger Status===>>'+tg_status.Fee_Calculation__c);
    if((Trigger.isupdate|| Trigger.IsInsert) && Trigger.isBefore && tg_status!=null && tg_status.Fee_Calculation__c){
	
           for(Opportunity opp: Trigger.new){
               Set<id>OpptoAcc_id= New Set<id>();
               List<Opportunity> optyList= new List<Opportunity>();
               //   if(opp.Business_Segment__c == 'Rating' ){
            if( opp.StageName=='Negotiation'&& (opp.Ownership_Type__c!='Government' && opp.Customer_Fee_Type__c=='Non - Cap')&& (opp.BD_Team_Classification__c=='SECG'|| opp.BD_Team_Classification__c=='ICG'||opp.BD_Team_Classification__c=='ECG') && (opp.Mandate_Type__c=='Fresh From Existing') && (opp.Instrument_type_2__c=='Rating - Bank Loan Rating'||opp.Instrument_type_2__c=='Rating - Money Market (Non-SF)'/*||opp.Instrument_type_2__c=='Others'*/) && opp.Instrument_type_1__c=='Non Structured Finance' ){
               
               OpptoAcc_id.add(opp.AccountId);
               optyList.add(opp);
                  if(!optyList.isEmpty()){
                  Fee_calculation_Handler.Pricing_calculation_Master(optyList);
                  Fee_calculation_Handler.Existing_Fee_Master_For_SCG_ICG(optyList,OpptoAcc_id);
                  } 
            }
            else if( opp.StageName=='Negotiation'&& (opp.Ownership_Type__c!='Government' && opp.Customer_Fee_Type__c=='Non - Cap')&& (opp.BD_Team_Classification__c=='SECG'|| opp.BD_Team_Classification__c=='ICG'||opp.BD_Team_Classification__c=='ECG') && (opp.Mandate_Type__c!='Fresh From Existing') && (opp.Instrument_type_2__c=='Rating - Bank Loan Rating'||opp.Instrument_type_2__c=='Rating - Money Market (Non-SF)'/*||opp.Instrument_type_2__c=='Others'*/) && opp.Instrument_type_1__c=='Non Structured Finance' ){

               OpptoAcc_id.add(opp.AccountId);
               optyList.add(opp);
                  if(!optyList.isEmpty()){
                     Fee_calculation_Handler.Pricing_calculation_Master(optyList);
                     Fee_calculation_Handler.Existing_Fee_Master_For_SCG_ICG(optyList,OpptoAcc_id);
                  }
               
            }
            else if( opp.StageName=='Negotiation'&& (opp.Ownership_Type__c!='Government' && opp.Customer_Fee_Type__c=='Non - Cap') /*&& opp.BD_Team_Classification__c=='ICG' */&& (opp.Mandate_Type__c!='Fresh From Existing') && opp.Instrument_type_1__c=='Structured Finance' ){

               OpptoAcc_id.add(opp.AccountId);
               optyList.add(opp);
                  if(!optyList.isEmpty()){
                     Fee_calculation_Handler.Existing_Fee_Master_For_SF(optyList,OpptoAcc_id);
                  }
            }
            else if( opp.StageName=='Negotiation'&& (opp.Ownership_Type__c!='Government' && opp.Customer_Fee_Type__c=='Non - Cap') /*&& opp.BD_Team_Classification__c=='ICG' */&& (opp.Mandate_Type__c=='Fresh From Existing') && opp.Instrument_type_1__c=='Structured Finance' ){

               OpptoAcc_id.add(opp.AccountId);
               optyList.add(opp);
                  if(!optyList.isEmpty()){
                     Fee_calculation_Handler.Existing_Fee_Master_For_SF(optyList,OpptoAcc_id);
                  }
            }
            // }
       }        
   
    }   

}