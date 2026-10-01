/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-24-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-24-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class ICRA_GenerateIRNandQRBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String filter ='Invoice';
        String filter1 = 'Yes';
        String filter2 = 'To Be Billed';
        String filter3 = 'Tax Invoice';
        String InvoiceQuery = 'SELECT Id, Name,RecordType.Name,Bill_No__c,Invoice_Status__c,Invoice_Created_Date__c,Opportunity_Name__r.Billing_Start_Date__c,Opportunity_Name__r.Owner.Name,Opportunity_Name__r.Defer_Billing_or_Exit_Case__c,Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = :filter AND Invoice_Created_Date__c = TODAY AND Contact_Name__r.Billing_Contact__c = :filter1 AND Opportunity_Name__r.Defer_Billing_or_Exit_Case__c = :filter2 AND Invoice_Status__c = :filter3';
        System.debug('===== Query +====== : '+InvoiceQuery);
        return Database.getQueryLocator(InvoiceQuery); 
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> InvoiceList){
        System.debug('======= execute ======='+InvoiceList);
        List<Invoice__c> tempInvoiceList = new List<Invoice__c>();
        for(Invoice__c invoice : InvoiceList){ 
            if(invoice.Invoice_Status__c == 'Tax Invoice'){ 
                ICRA_GenerateIRN.getIRN(invoice.Id, invoice.Bill_No__c);  
            } 
        } 
    }  
    
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Inovice Batch Job is done ****  /' +BC); 
        
    } 
}