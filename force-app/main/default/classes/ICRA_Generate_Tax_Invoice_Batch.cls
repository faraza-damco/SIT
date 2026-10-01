/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 20-06-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-02-2025   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public with sharing class ICRA_Generate_Tax_Invoice_Batch  implements Database.Batchable<sObject>{

    private Date processDate;

    public ICRA_Generate_Tax_Invoice_Batch(){
        processDate = System.today();
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String holdUncertain = 'Hold (Uncertain)';
        String toBeBilled = 'To Be Billed';
        String closedWon= 'Closed Won';
        String approvalStatusPending= 'Pending';
        Id surveillance_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        Date taxInvoiceDate =processDate.addDays((Integer.valueOf(System.Label.Tax_Invoice_Generation)));

        String soqlquery = 'SELECT Id FROM Account WHERE Id IN ('+'SELECT AccountId FROM Opportunity WHERE AccountId != null AND StageName= :closedWon AND Defer_Billing_or_Exit_Case__c = :toBeBilled AND Billing_Start_Date__c != null AND Billing_End_Date__c != null AND recordTypeId=:surveillance_recordType AND Proforma_Invoice_Required_Surv__c=false AND BillingAddress__c!=null AND Opp_ICRA_Branch__c!=null AND Instrument_Category__c!=null AND Billing_Start_Date__c<= :taxInvoiceDate AND Billing_Start_Date__c>= :processDate '+')';
        //soqlquery +=' WHERE StageName= :closedWon AND Defer_Billing_or_Exit_Case__c = :toBeBilled AND Billing_Start_Date__c != null AND Billing_End_Date__c != null AND recordTypeId=:surveillance_recordType AND Proforma_Invoice_Required_Surv__c=false AND BillingAddress__c!=null AND Opp_ICRA_Branch__c!=null AND Instrument_Category__c!=null AND Billing_Start_Date__c<= :taxInvoiceDate AND Billing_Start_Date__c>= :processDate AND Id NOT IN (SELECT TargetObjectId FROM ProcessInstance WHERE Status =:approvalStatusPending) ORDER BY Billing_Start_Date__c ASC, CreatedDate ASC';
        System.debug('Get Query===>> '+soqlquery); 
       return Database.getQueryLocator(soqlquery);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accList){
        Set<Id> accountIds = new Set<Id>();
        for (Account a : accList) accountIds.add(a.Id);
        List<Opportunity> opportunityList = new List<Opportunity>();
        System.debug('======= execute ======='+opportunityList.size());
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id, Invoice__c> oppToInvoiceMap = new Map<Id, Invoice__c>();
        //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Invoice__c> successInvoices = new Map<Id, Invoice__c>();
        List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id, Integer> invOptyCountMap = new Map<Id, Integer>();
        Map<Id, Invoice__c> rejectedInvoiceMap = new Map<Id, Invoice__c>();
        Set<Id> oppIds = new Set<Id>(); 
        Map<String, List<Opportunity>> groupedOpptyMap = new Map<String, List<Opportunity>>();
        Map<String, Invoice__c> groupKeyToInvoiceMap = new Map<String, Invoice__c>();
        Id invoiceRecordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Date taxInvoiceDate = processDate.addDays((Integer.valueOf(System.Label.Tax_Invoice_Generation)));
        Id surveillance_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();

        List<Opportunity> opportunityListFinal = [SELECT Id,name,StageName,AccountId,CloseDate,Defer_Billing_or_Exit_Case__c,Billing_Start_Date__c,Billing_End_date__c,PR_Date__c,Amount_To_Be_Billed__c, 
        BillingAddress__c, Opp_ICRA_Branch__c,Instrument_Category__c,Hold_Up_Untill__c, Initiate_Tax_Invoice_Generated__c FROM Opportunity where accountId IN :accountIds
        AND StageName= 'Closed Won' AND Defer_Billing_or_Exit_Case__c = 'To Be Billed' AND Billing_Start_Date__c != null AND Billing_End_Date__c != null AND recordTypeId=:surveillance_recordType AND 
        Proforma_Invoice_Required_Surv__c=false AND BillingAddress__c!=null AND Opp_ICRA_Branch__c!=null AND Instrument_Category__c!=null AND Billing_Start_Date__c<= :taxInvoiceDate AND 
        Billing_Start_Date__c>= :processDate AND Id NOT IN (SELECT TargetObjectId FROM ProcessInstance WHERE Status ='Pending') ORDER BY Billing_Start_Date__c ASC, CreatedDate ASC];

        if (opportunityListFinal.isEmpty()) return;
        opportunityList = opportunityListFinal;
        
        for(Opportunity opp : opportunityList){
            if(opp.Billing_Start_Date__c != null && opp.Billing_End_date__c != null){
                oppIds.add(opp.Id);
            }
        }

        for (AggregateResult ar : [SELECT Opportunity_Name__c opty, COUNT(Id) recordCount FROM Invoice__c WHERE (Invoice_Status__c= 'Proforma Invoice' OR Invoice_Status__c='Initiate Tax Invoice' OR Invoice_Status__c='Tax Invoice' OR Invoice_Status__c='QR-IRN-Generated') AND Opportunity_Name__c IN :oppIds GROUP BY Opportunity_Name__c]){
            invOptyCountMap.put((Id)ar.get('opty'), (Integer)ar.get('recordCount'));
        }

        for(Opportunity opp : opportunityList){
            String key = opp.AccountId + '::' + opp.BillingAddress__c + '::' + opp.Opp_ICRA_Branch__c + '::' + String.valueOf(opp.Billing_Start_Date__c) + '::' + opp.Instrument_Category__c;
            if (!groupedOpptyMap.containsKey(key)) {
                groupedOpptyMap.put(key, new List<Opportunity>());
            }
            groupedOpptyMap.get(key).add(opp);
        }

        for(String groupKey : groupedOpptyMap.keySet()){
            List<Opportunity> groupOpps = groupedOpptyMap.get(groupKey);
            if (groupOpps.isEmpty()) continue;
            Opportunity firstOpp = groupOpps[0];
            Date billingDate = firstOpp.Billing_Start_Date__c;
            if(billingDate<=taxInvoiceDate &&  invOptyCountMap.get(firstOpp.Id)==null && firstOpp.Initiate_Tax_Invoice_Generated__c != true){
                Invoice__c invoice = new Invoice__c();
                invoice.Opportunity_Name__c = firstOpp.Id;
                invoice.recordTypeId = invoiceRecordType;
                invoice.Invoice_Created_Date__c = processDate;
                invoice.Invoice_Status__c = 'Initiate Tax Invoice';
                invoice.Advance_Billing_Status__c = 'New Advance billing practice';
                invoice.Auto_Generated_Tax_Invoice__c = true;
                invoice.isFirst_InvoiceLine_Item__c = true;
                invoiceList.add(invoice);
                oppToInvoiceMap.put(firstOpp.Id, invoice);
                groupKeyToInvoiceMap.put(groupKey, invoice);
            }
        }

        if(!invoiceList.isEmpty()){
            Database.SaveResult [] insertInvResult = Database.insert(invoiceList, false);
            List<Transaction_Log__c> errorLogs = new List<Transaction_Log__c>();
            groupKeyToInvoiceMap.clear();
            for (Integer i = 0; i < insertInvResult.size(); i++){
                if (insertInvResult[i].isSuccess()){
                    Invoice__c insertedInvoice = invoiceList[i];
                    Id oppId = insertedInvoice.Opportunity_Name__c;
                    successInvoices.put(oppId, insertedInvoice);
                    for (String key : groupedOpptyMap.keySet()){
                        List<Opportunity> opps = groupedOpptyMap.get(key);
                        if (!opps.isEmpty() && opps[0].Id == oppId){
                            groupKeyToInvoiceMap.put(key, insertedInvoice); 
                            break;
                        }
                    }
                }else{
                    for(Database.Error err : insertInvResult[i].getErrors()){
                        ICRA_TransactionLogHandler.addLog('ICRA_Generate_Tax_Invoice_Batch', (invoiceList[i] != null ? invoiceList[i].Opportunity_Name__c : null), null, 'Initiate Tax Invoice Creation Failed', err.getMessage());                 
                    }
                }
            }
        }

        for(String groupKey : groupedOpptyMap.keySet()){
            List<Opportunity> opps = groupedOpptyMap.get(groupKey);
            Invoice__c invoice = groupKeyToInvoiceMap.get(groupKey);
            if(invoice != null){
                for(Opportunity opp : opps){
                    if(opp.Initiate_Tax_Invoice_Generated__c != true){
                        Invoice_Line_Item__c lineItem = new Invoice_Line_Item__c();
                        lineItem.Invoice_No__c = invoice.Id;
                        lineItem.Opportunity_Name__c = opp.Id;
                        lineItemList.add(lineItem);
                        opp.Initiate_Tax_Invoice_Generated__c=true;
                        opportunitiesToUpdate.add(opp);
                    }
                }
            }
        }

        if(!lineItemList.isEmpty()){
            Database.SaveResult [] insertInvLiResult = Database.insert(lineItemList, false);
            List<Transaction_Log__c> errorLogs = new List<Transaction_Log__c>();
            for (Integer i = 0; i < insertInvLiResult.size(); i++) {
                if (!insertInvLiResult[i].isSuccess()){
                    Invoice_Line_Item__c line = lineItemList[i];
                    Id oppId = line.Opportunity_Name__c;
                    for (Database.Error err : insertInvLiResult[i].getErrors()){
                        ICRA_TransactionLogHandler.addLog('ICRA_Generate_Tax_Invoice_Batch', (lineItemList[i] != null ? lineItemList[i].Opportunity_Name__c : null), (lineItemList[i] != null ? lineItemList[i].Invoice_No__c : null), 'Initiate Tax Invoice Line Item Creation Failed', err.getMessage());
                    }
                }
            }
        }

        if(!opportunitiesToUpdate.isEmpty()){
            Database.SaveResult [] insertOppResult = Database.update(opportunitiesToUpdate, false);
            List<Transaction_Log__c> errorLogs = new List<Transaction_Log__c>();
            for (Integer i = 0; i < insertOppResult.size(); i++) {
                if (!insertOppResult[i].isSuccess()){
                    Opportunity opp = opportunitiesToUpdate[i];
                    for (Database.Error err : insertOppResult[i].getErrors()) {
                        ICRA_TransactionLogHandler.addLog('ICRA_Generate_Tax_Invoice_Batch', (opportunitiesToUpdate[i] != null ? opportunitiesToUpdate[i].Id : null), null, 'Opportunity Update Failed: Initiate Tax Invoice Generated Checkbox', err.getMessage());
                    }
                }
            }
        }
        ICRA_TransactionLogHandler.saveLogs();
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('======= finish =======:  '+BC);
    }
}