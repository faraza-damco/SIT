/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-26-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-24-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class ICRA_InvoiceGenrationBatch Implements Database.Batchable<sObject>{ 
    
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String stageName = 'Closed Won';
        String toBeBilled = 'To Be Billed'; 
        Date todayDate = Date.today().addDays(-6);
        String recordType = 'New Business';
        String opportunitySOQL = 'SELECT Id, Proforma_Invoice_Required__c, AccountId, BD_Approve__c, Name, StageName, PR_Date__c,Invoice_Generation_Date__c, ASF_Final_Amount__c, Billing_End_date__c, Billing_Start_Date__c, Defer_Billing_or_Exit_Case__c, Instrument_type_3__c, Instrument_type_2__c, Instrument_type_1__c, Instrument_Type_5__c, IRF_Final_Amount__c, RecordType.Name FROM Opportunity WHERE StageName = :stageName AND Defer_Billing_or_Exit_Case__c =:toBeBilled AND Invoice_Generation_Date__c >=: todayDate AND Invoice_Generation_Date__c <= TODAY AND (Total_Invoice_Amount_1__c < 1 OR Total_Invoice_Amount_1__c = null ) AND RecordType.Name =:recordType';
       return Database.getQueryLocator(opportunitySOQL); 
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        System.debug('======= execute ======='+opportunityList); 
        List<Opportunity> tempOpportunityList = new List<Opportunity>();
        ICRA_CreateMultipleInvoice.filterAndCreateInvoice(opportunityList, 'Daily');
        
    } 
    
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Opportunity Batch Job is done ****  /' +BC);
        
        
    }
}