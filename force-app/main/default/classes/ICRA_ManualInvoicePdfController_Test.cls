@isTest
public with sharing class ICRA_ManualInvoicePdfController_Test {
    @testSetup
    public Static void isDataSetup(){
        ICRA_TestDataFactory.loadCustomeSetting();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;

        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector;
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        //accountRecord.GST_Number__c = '24AAACI0218B1ZG';
        accountRecord.Group_Name__c = 'testDamco';
        accountRecord.Business_Sector__c= businessSector.Id;
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Status__c ='Active';
        Insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';         
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id); 
        Insert contactRecord;

        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', accountRecord.Id);   
        opportunityRecord.StageName = 'L1 Meeting'; 
        insert opportunityRecord;
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                Role = 'Name on Invoice')};
            Insert optyConRoles;

        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Credit Note',opportunityRecord.Id, null, null);   
        insert invoiceRecord;  
        Manual_Invoice__c manualInvoice = ICRA_TestDataFactory.createManualInvoice('OPE',accountRecord.Id,contactRecord.Id,'hy6567','jybfvyg');
        //insert manualInvoice;
        Manual_Invoice_Line_Item__c manualLineItemRecord  = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoice.Id);
        //insert manualLineItemRecord;
    }
    @isTest
    public static void manualInvoicePdfControllerTest(){
        Manual_Invoice__c manualInvoice =  [SELECT Id,Name FROM  Manual_Invoice__c LIMIT 1 ];
         PageReference pageRef = Page.ICRA_ManualInvoicePdf;
         ApexPages.currentPage().getParameters().put('id',manualInvoice.Id);
        ICRA_ManualInvoicePdfController manualInvoicePdf = new ICRA_ManualInvoicePdfController(new ApexPages.StandardController(manualInvoice));
        manualInvoicePdf.savePDF();  
    }

}