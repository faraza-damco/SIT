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
global class ICRA_SaveInvoicePDFBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String proformaFilter = 'Proforma Invoice';
        String taxInvoice = 'Tax Invoice';
        String recordType = 'Invoice';
        String filter2 = 'To Be Billed';
        String InvoiceQuery = 'SELECT Id, Name,RecordType.Name,Invoice_Status__c,Invoice_Created_Date__c,Total_Invoice_Amount__c,Opportunity_Name__r.Defer_Billing_or_Exit_Case__c FROM Invoice__c WHERE Invoice_Created_Date__c = TODAY AND (Invoice_Status__c =: proformaFilter OR Invoice_Status__c =: taxInvoice) AND Opportunity_Name__r.Defer_Billing_or_Exit_Case__c =:filter2';
        return Database.getQueryLocator(InvoiceQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> InvoiceList){
        
        for(Invoice__c invoiceRecord : InvoiceList){
            
            ICRA_SaveInvoicePDF.saveInvoice(invoiceRecord.Id);
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
   
}