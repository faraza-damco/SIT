@isTest
public class contentDocumentLinkTrigger_TestClass {
    @isTest 
    public static void contentDocumentLinkTest(){
        Branch__c br= new Branch__c();
        br.Name= 'Test';
        br.Branch_Code__c= 'branchCode';
        br.City__c= 'Delhi';
        br.Zip_Postal_Code__c= '258963';
        br.OFAC_Approver__c= UserInfo.getUserId();
        insert br;

        Account ac= new Account();
        ac.Name='Test';
        ac.Branch__c=br.Id;
        ac.Ownership_Type_Picklist__c='Government';
        ac.Classification__c='SECG';
        ac.Volume_of_Debt_Category__c='50-100';
        ac.Sector__c='Banks';
        ac.Account_Classification__c='SEZ';
        ac.PSU_Type__c='Central';
        ac.Line_of_Business__c='Finance and Banking';
        ac.Sub_Sector__c='Private Sector Banks';
        ac.OFAC_Document_Received__c=false;
        ac.ShippingCountry='India';
        ac.ShippingState='UP';
        ac.PAN_Number__c='XXXXX4976H';
        insert ac;
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'ofactest';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];


        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=ac.id;
        contentlink.ShareType= 'V';
        contentlink.LinkedEntityId = ac.Id; 
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    }
}