/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-05-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public with sharing class ICRA_InvoicePdfController_Test {

    @testSetup
    public static void isDataSetup (){
        ICRA_TestDataFactory.loadCustomeSetting();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;
        
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        businessSector.ICRA_Branch__c=branchrecord.Id;
        insert businessSector;

        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
       // accountRecord.PAN_Number__c = 'AABCU9603R';
       	//accountRecord.GST_Number__c = '24AAACI0218B1ZG';
        accountRecord.Group_Name__c = 'testDamco';
        accountRecord.Branch__c=branchrecord.Id;
        accountRecord.Business_Sector__c= businessSector.Id;
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Status__c ='Active'; 
       accountRecord.Constitution_Type_Picklist__c = 'Other';
        accountRecord.OFAC_Check__c =true; 
        Insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AABCU9603R1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true; 
                billingAddr.Tax_GST_Classification__c='SEZ';
        insert billingAddr;

        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id); 
        Insert contactRecord;
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);  
        opportunityRecord.StageName = 'Closed Won'; 
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c = ''; 
        insert opportunityRecord;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                Role = 'Name on Invoice')};
            Insert optyConRoles;
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,null); 
        insert invoiceRecord; 
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id); 
        Invoice_Line_Item__c invoiceLineRecord_B = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
    }
    
    @isTest
    public static void InvoicePdfControllerTest(){
        Invoice__c invoice = [SELECT Id, Name FROM Invoice__c LIMIT 1];         
        PageReference pageRef = Page.ICRA_Invoice_pdf;
        ApexPages.currentPage().getParameters().put('id',invoice.Id);  
        ICRA_InvoicePdfController invoicePdf = new ICRA_InvoicePdfController(new ApexPages.StandardController(invoice));
        invoicePdf.savePDF();   

    }
    
    
}