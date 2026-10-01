public class ICRA_PI_OK_InvoiceDate {
    @invocableMethod
    public static void ICRA_PI_OK_InvoiceDate( List<Opportunity> oppList1){
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Invoice__c> updateInvoiceRecord = new List<Invoice__c>();
        Set<Id> oppIdSet = new Set<Id>();
        
        for(Opportunity oppRecord : oppList1){
            oppIdSet.add(oppRecord.Id);
            
        }
        if(oppIdSet.size() > 0){
            for(Invoice__c invoiceRecord : [SELECT Id,Name,Opportunity_Name__r.Id,Invoice_Created_Date__c,Invoice_Status__c,Opportunity_Name__r.Proforma_Invoice_ok__c 
                                            FROM Invoice__c 
                                            WHERE recordType.Name = 'Invoice' AND
                                            Opportunity_Name__r.Id IN: oppIdSet AND
                                            Opportunity_Name__r.Proforma_Invoice_ok__c = true AND
                                            Invoice_Status__c = 'Proforma Invoice'
                                            LIMIT 1]){
                                                invoiceRecord.Invoice_Created_Date__c = System.today();
                                                updateInvoiceRecord.add(invoiceRecord);
                                            }
        }
        update updateInvoiceRecord;
    }    
}