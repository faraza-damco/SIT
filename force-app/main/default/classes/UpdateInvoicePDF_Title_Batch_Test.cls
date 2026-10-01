@isTest(SeeAllData=false) 
public class UpdateInvoicePDF_Title_Batch_Test {
    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String TESTNAME1 = 'ConRoleTest';
    private static final String CONEMAIL = 'testcontactrole@abc.com';
    private static final String ISSUER = 'Issuer';
    private static final String TESTNAME2 = 'TestNameRole';
    private static final String NEWBUSINESS = 'New Business';
//Test setup
    @testSetup 
    static void testSetup(){
        Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, ISSUER, null); 
        acc.PAN_Number__c = 'AAACI0218B';
       	acc.GST_Number__c = '24AAACI0218B1ZG';
        Insert acc;
        Contact con = TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME1,true);
        con.Email = CONEMAIL;
        Update con;
        Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, NEWBUSINESS, acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        insert opty; 
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = opty.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
            Insert optyConRoles;
        	Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opty.Id, null,null);
        	invoiceRecord.Invoice_Status__c = 'Tax Invoice';
        	invoiceRecord.Contact_Name__c = con.Id;
            insert invoiceRecord;
        
        	ContentVersion content=new ContentVersion(); 
        	content.Title='Tax Test'; 
        	content.PathOnClient='/' + content.Title + '.jpg'; 
        	Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'+String.valueOf(invoiceRecord)+String.valueOf(opty)+String.valueOf(acc)+String.valueOf(con)); 
        	content.VersionData=bodyBlob; 
        	insert content; 
        	ContentDocumentLink pdffile = new ContentDocumentLink(LinkedEntityId = invoiceRecord.Id,
                                                                 ContentDocumentId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid);
        	Insert pdffile;
            
            ContentVersion content2=new ContentVersion(); 
        	content2.Title='INV'; 
        	content2.PathOnClient='/' + content2.Title + '.jpg'; 
        	Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body'+String.valueOf(invoiceRecord)+String.valueOf(opty)+String.valueOf(acc)+String.valueOf(con)); 
        	content2.VersionData=bodyBlob2; 
        	insert content2; 
        	ContentDocumentLink pdffile2 = new ContentDocumentLink(LinkedEntityId = invoiceRecord.Id,
                                                                 ContentDocumentId = [select contentdocumentid from contentversion where id =: content2.id].contentdocumentid);
        	Insert pdffile2;
        
    }
//Test method
    static testMethod void validateContactRoleUpdate() {
        try{
        Test.startTest();
            Invoice__c inv = [Select Id from Invoice__c];
            inv.Invoice_Status__c = 'Tax Invoice';
            update inv;
            List<ContentDocumentLink> pdffile = [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                            ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId = :inv.Id];
			Database.executeBatch(new UpdateInvoicePDF_Title_Batch(),100);
        Test.stopTest();
        //System.assertEquals(optyList.size(),6);
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    } 
    /* static testMethod void validateContactRoleUpdate2() {
        try{
        Test.startTest();
            Invoice__c inv = [Select Id from Invoice__c];
            
            List<ContentDocumentLink> pdffile = [ SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Id,
                            ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, SystemModstamp, ContentDocument.LatestPublishedVersion.ContentSize
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId = :inv.Id];
			
            
          Database.executeBatch(new UpdateInvoicePDF_Title_Batch(),100);
        Test.stopTest();
        //System.assertEquals(optyList.size(),6);
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }*/
}