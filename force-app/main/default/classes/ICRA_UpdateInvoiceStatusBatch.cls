global class ICRA_UpdateInvoiceStatusBatch implements Database.Batchable<sObject>{
   List<Opportunity> Opp = new List<Opportunity>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String filter ='Invoice';
        String filter1 = 'Yes';
        String filter2 = 'To Be Billed';
        String filter3 = 'Proforma Invoice';
        Date today5 = System.today().addDays(-(Integer.valueOf(System.Label.PI_Batch_Start_Date)));
        String InvoiceQuery = 'SELECT Id, Name,RecordType.Name,Bill_No__c,Invoice_Status__c,Invoice_Created_Date__c,Opportunity_Name__r.Billing_Start_Date__c, Opportunity_Name__r.BD_Approve__c, Opportunity_Name__r.Owner.Name,Opportunity_Name__r.Defer_Billing_or_Exit_Case__c,Opportunity_Name__r.Owner.Email,Opportunity_Name__r.Owner.Manager.Email,Contact_Name__c, Contact_Name__r.Billing_Contact__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c  WHERE Contact_Name__r.Email != null AND RecordType.Name = :filter AND Opportunity_Name__r.CloseDate <= TODAY  AND Opportunity_Name__r.CloseDate >=:today5 AND Contact_Name__r.Billing_Contact__c = :filter1 AND Opportunity_Name__r.Defer_Billing_or_Exit_Case__c = :filter2 AND Invoice_Status__c = :filter3';
        System.debug('===== Query +====== : '+InvoiceQuery);
        return Database.getQueryLocator(InvoiceQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> InvoiceList){
        System.debug('======= execute ======='+InvoiceList);
        List<Invoice__c> tempInvoiceList = new List<Invoice__c>();
        for(Invoice__c invoice : InvoiceList){
           if(invoice.Opportunity_Name__r.BD_Approve__c == true){
                invoice.Invoice_Status__c = 'Tax Invoice';
            	tempInvoiceList.add(invoice);
           }
        }
        if(tempInvoiceList.size() > 0){
            update tempInvoiceList;
        }
        
    }  
    global void finish(Database.BatchableContext BC){
        system.debug('/  **** Inovice Batch Job is done ****  /' +BC);
    }
    
}