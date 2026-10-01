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
public class ICRA_SaveInvoicePDF {
    public static void saveInvoice(String parentId){
        //Check the parrentId is null or not 
        if(parentId != null && parentId != '' && parentId != 'null' ){

            //creat page refference of Invocie PDF to get the PDF.
            PageReference pdf = new PageReference('/apex/ICRA_Invoice_pdf?id='+parentId);
            String fileName='';

            // Get Invocie record. (Get assigne the file name )
            Invoice__c invoiceRecord = [
                SELECT Id , Name, RecordType.Name,Credit_Note_No__c, Bill_No__c 
                FROM Invoice__c 
                WHERE Id =: parentId
                LIMIT 1
            ]; 

            //If invoice record type is Credite note then file name is equal to Credit note number else Bill number.
            if(invoiceRecord.RecordType.Name == 'Credit Note'){
                fileName = invoiceRecord.Credit_Note_No__c;
            }else{
                fileName =  invoiceRecord.Bill_No__c;
            } 


            // Creat content Version record to store and insert the PDF.
            ContentVersion contentVersionRecord = new ContentVersion();
            contentVersionRecord.ContentLocation = 'S';
            contentVersionRecord.PathOnClient =  fileName+'.pdf';
            contentVersionRecord.Title = fileName;

            //Blod Hold the PDF file content (Binary)
            Blob body;
            try { 
                body = pdf.getContent();

            } catch (VisualforceException e) {
                body = Blob.valueOf('Error While Genrating file');
            }

            contentVersionRecord.VersionData =  body;

            // Insert the file
            insert contentVersionRecord;

            // Get the Information of currently inserted file (This is used to link the file with Invoice Object)
            Id contentVersionID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionRecord.Id].ContentDocumentId;

            //Creat refference to link the document (PDF file) to invoice object.
            ContentDocumentLink contentDocument = new ContentDocumentLink();
            // Document ID 
            contentDocument.ContentDocumentId = contentVersionID;
            //Record Id (Invoice Record id )
            contentDocument.LinkedEntityId = parentId;
            contentDocument.ShareType = 'V';  
            contentDocument.Visibility = 'AllUsers';
            
            //Link the file with related object 
            insert contentDocument;
        }
    }
}