public class ecgOpportunityValidationController {
    @AuraEnabled(cacheable=true) 
    public static opportunity oppData(string recordId){
        return[Select Id, StageName, BD_Team_Classification__c, Instrument_type_4__c, Instrument_type_2__c, VoD_in_crore__c,Account.classification__c FROM Opportunity WHERE Id =: recordId];  
    }
    
}