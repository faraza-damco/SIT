public class Total_VoD_Calculation_Batch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // One scope item = one Account. Batch size controls how many Accounts per execute.
        // We only include Accounts that have at least one qualifying Opportunity.
        //id accId = '001C100000Lq3ffIAB'; // Test Account Id
        return Database.getQueryLocator(
            'SELECT Id FROM Account WHERE Id IN (' +
            '  SELECT AccountId FROM Opportunity WHERE AccountId != null AND Instrument_Category__c != NULL' +
            ')'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        if (scope.isEmpty()) return;
		Id oppSurv_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        // Collect Account Ids in this chunk
        Set<Id> accountIds = new Set<Id>();
        for (Account a : scope) accountIds.add(a.Id);

        // Pull ALL opps for these accounts (so each account is complete within this execute)
        List<Opportunity> opps = [
            SELECT Id, AccountId, Instrument_Category__c, Total_VoD_at_Instrument_Category__c, Name, Defer_Billing_or_Exit_Case__c, Parent_Opportunity__c,
            VoD_in_crore__c, Size_to_be_rated_this_year_in_Cr_M__c, Billing_Start_Date__c, CreatedDate, RecordTypeId, PR_Date__c, Date_of_Communication__c, StageName FROM Opportunity
            WHERE Defer_Billing_or_Exit_Case__c!= 'Non Billable' AND AccountId IN : accountIds 
            ORDER BY CreatedDate DESC, Id DESC
        ];
        if (opps.isEmpty()) return;

        // Build parent->latestChild and a set of parents that have children for this scope's opp set
		Map<String, List<Opportunity>> mapOfAccountIdVsOpps = new Map<String, List<Opportunity>>();
		for(Opportunity opp : opps){
			if(opp.Instrument_Category__c != null){
				if(!mapOfAccountIdVsOpps.containsKey(opp.AccountId+':'+opp.Instrument_Category__c)){
					mapOfAccountIdVsOpps.put(opp.AccountId+':'+opp.Instrument_Category__c, new List<Opportunity>());
				}
				mapOfAccountIdVsOpps.get(opp.AccountId+':'+opp.Instrument_Category__c).add(opp);
			}
		}
		
        Map<String, Decimal> mapOfAccountIdPlusInsCategoryVsTotalVod = new Map<String, Decimal>();
		List<Opportunity> oppLst = new List<Opportunity>();
		for(String key : mapOfAccountIdVsOpps.keyset()){
			List<Opportunity> oppList = mapOfAccountIdVsOpps.get(key);
			Decimal vodSum=0;
			Map<String, List<Opportunity>> mapOfParentVsChildren = new Map<String, List<Opportunity>>();
			for(Opportunity opp : oppList){
				
				if(opp.Parent_Opportunity__c != null){
					if(!mapOfParentVsChildren.containsKey(opp.Parent_Opportunity__c)){
						mapOfParentVsChildren.put(opp.Parent_Opportunity__c, new List<Opportunity>());
					}
					mapOfParentVsChildren.get(opp.Parent_Opportunity__c).add(opp);
				}
				if(opp.Parent_Opportunity__c == null && !mapOfParentVsChildren.containsKey(opp.Id)){
					mapOfParentVsChildren.put(opp.Id, new List<Opportunity>{opp});
				}
			}
			for(String oppId : mapOfParentVsChildren.keyset()){

				if(mapOfParentVsChildren.containsKey(oppId)){
					List<Opportunity> oppList2 = mapOfParentVsChildren.get(oppId);
					Opportunity aOpp = getLatestOpp(oppList2);
					Boolean conditionsMet = aOpp.StageName != 'Closed Lost' && aOpp.Defer_Billing_or_Exit_Case__c != 'Exit Case' && ((aOpp.RecordTypeId == oppSurv_recordType && aOpp.Defer_Billing_or_Exit_Case__c != 'Already Billed') || (aOpp.RecordTypeId != oppSurv_recordType && ((aOpp.PR_Date__c!=null)||(aOpp.Date_of_Communication__c!=null))));
					system.debug(aOpp.Id+'---aOpp--->'+aOpp);
					if (aOpp.Size_to_be_rated_this_year_in_Cr_M__c != null && conditionsMet) {
						if(mapOfAccountIdPlusInsCategoryVsTotalVod.containsKey(aOpp.AccountId+':'+aOpp.Instrument_Category__c)){
							System.debug('vodSum1--->'+vodSum);
							vodSum = mapOfAccountIdPlusInsCategoryVsTotalVod.get(aOpp.AccountId+':'+aOpp.Instrument_Category__c) + aOpp.Size_to_be_rated_this_year_in_Cr_M__c;
						}
						else{
							System.debug('vodSum2--->'+vodSum);
							vodSum = aOpp.Size_to_be_rated_this_year_in_Cr_M__c;
						}
					} else if (aOpp.VoD_in_crore__c != null && conditionsMet) {
						if(mapOfAccountIdPlusInsCategoryVsTotalVod.containsKey(aOpp.AccountId+':'+aOpp.Instrument_Category__c) ){
							System.debug('vodSum3--->'+vodSum);
							vodSum = mapOfAccountIdPlusInsCategoryVsTotalVod.get(aOpp.AccountId+':'+aOpp.Instrument_Category__c) + aOpp.VoD_in_crore__c;
						}
						else{
							System.debug('vodSum4--->'+vodSum);
							vodSum = aOpp.VoD_in_crore__c;
						}
					}
					mapOfAccountIdPlusInsCategoryVsTotalVod.put(aOpp.AccountId+':'+aOpp.Instrument_Category__c, vodSum);
					system.debug(mapOfAccountIdPlusInsCategoryVsTotalVod+'---mapOfAccountIdPlusInsCategoryVsTotalVod--->');
				}
			}
		}

		for(Opportunity opp : opps){
			if(opp.StageName != 'Closed Lost'){
				if(mapOfAccountIdPlusInsCategoryVsTotalVod.containsKey(opp.AccountId+':'+opp.Instrument_Category__c)){
					opp.Total_VoD_at_Instrument_Category__c = mapOfAccountIdPlusInsCategoryVsTotalVod.get(opp.AccountId+':'+opp.Instrument_Category__c);
					oppLst.add(opp);
				}
			}

		}
		
		update oppLst;
		
	}

    public void finish(Database.BatchableContext bc) {
        // Optional logging/notifications
		system.debug('Batch Finished');
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