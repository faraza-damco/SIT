global class UpdateInvoicePDF_Title_Batch implements Database.Batchable<sobject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext bc){
        string proforma = 'Tax Invoice';
        String soqlquery = 'SELECT Id,Name,Invoice_Status__c FROM Invoice__c';
        soqlquery +=' WHERE Invoice_Status__c =: proforma';
        System.debug('Get query' +soqlquery); 
        return Database.getQueryLocator(soqlquery);
    }
    global void execute(Database.BatchableContext bc, List<Invoice__c> invoiceList){
        List<ContentDocument> cdlistupdate = new List<ContentDocument>();

        Map<Id,Invoice__c> piInvoicemap = new Map<Id,Invoice__c>();
        Map<Id,Invoice__c> taxInvoicemap = new Map<Id,Invoice__c>();
        Map<Id,ContentDocument> contentPDF = new Map<Id,ContentDocument>();
        for(Invoice__c inv : invoiceList){
            if(inv.Invoice_Status__c == 'Tax Invoice'){
                piInvoicemap.put(inv.id,inv);
            }
        }
        
        for(ContentDocumentLink pdffile : [ SELECT Id,LinkedEntityId,ContentDocument.title,ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                                           ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId IN: piInvoicemap.keySet() AND 
                                           ContentDocument.LatestPublishedVersion.ContentSize > 1023 AND
                                           (NOT(ContentDocument.LatestPublishedVersion.Title Like'%INV%'))
                                           ORDER BY SystemModstamp DESC LIMIT 1
                                          ]){
                                              
                                              contentPDF.put(pdffile.ContentDocumentId,pdffile.ContentDocument);
                                          }
        
        for(ContentDocument cdd : [SELECT Id,Title FROM ContentDocument WHERE Id =: contentPDF.keySet()]){
            cdd.Title = cdd.Title + ' TAX';
            cdlistupdate.add(cdd);
            system.debug('Tilte '+cdd.Title);
        }
        update cdlistupdate;
    }
    global void finish(Database.BatchableContext bc){}
    
}