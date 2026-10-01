/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-29-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   05-24-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class ICRA_ProformaInvoiceGenrationBatch Implements Database.Batchable<sObject>{ 
    
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        String toBeBilled = 'To Be Billed'; 
        String recordType = 'Surveillance'; 
        String stageName = 'Closed Won';
        String opportunitySOQL ='';
        Date next90Days = Date.today().addDays(90);
        Date todayDate = Date.today().addDays(- (Integer.valueOf(System.Label.PI_Batch_Start_Date)));
        opportunitySOQL = 'SELECT Id, AccountId, BD_Approve__c, Name, StageName, PR_Date__c, ASF_Final_Amount__c, Billing_End_date__c, Billing_Start_Date__c, Defer_Billing_or_Exit_Case__c, Instrument_type_3__c, Instrument_type_2__c, Instrument_type_1__c, IRF_Final_Amount__c, RecordType.Name FROM Opportunity';
        opportunitySOQL += ' WHERE StageName = :stageName AND Defer_Billing_or_Exit_Case__c =:toBeBilled AND CloseDate >=: todayDate AND  CloseDate <=: next90Days AND RecordType.Name =: recordType AND  (Total_Invoice_Amount_1__c <= 1 OR Total_Invoice_Amount_1__c = null ) AND  Amount_To_Be_Billed__c >= 1' ;
        
        return Database.getQueryLocator(opportunitySOQL); 
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        System.debug('======= execute ======='+opportunityList);  
        List<Opportunity> tempList = new List<Opportunity>();
        for(Opportunity opportunityRecord : opportunityList){
            if((opportunityRecord.Instrument_type_1__c == 'Structured Finance')|| opportunityREcord.Instrument_type_1__c == 'Non Structured Finance'){
                tempList.add(opportunityREcord);
            }
        }
        if(tempList.size() > 0){
            ICRA_CreateMultipleInvoice.filterAndCreateInvoice(opportunityList, 'Surveillance-90');
        }
        
    } 
    
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Opportunity Batch Job is done ****  /' +BC); 
    }
}