/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-19-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   02-19-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public inherited sharing class ICRA_PaymentReceiptPdfController_Test {
    @testSetup
    public Static void isDataSetup (){
        ICRA_TestDataFactory.loadCustomeSetting();
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
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
        businessSector.ICRA_Branch__c=branchRecord.id;
        insert businessSector;
        
        Account acc =  ICRA_TestDataFactory.CreateAccount('ConRoleTest', 'Issuer', null); 
       // acc.PAN_Number__c = 'AAFCR5512V';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.ofac_check__c =true;
        Acc.Account_Status__c ='Active';
        Acc.OFAC_Approval_Status__c ='Approved';
        Acc.Branch__c =branchRecord.Id;
        Acc.OFAC_Document_Received__c=true;
        Acc.Ofac_Approved__c=true;
        Acc.Constitution_Type_Picklist__c='other';
        Acc.Bypass__c=true;
        Insert acc;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        //billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        billingAddr.Tax_GST_Classification__c='SEZ';
        insert billingAddr;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', acc.Id); 
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'Surveillance', acc.Id); 
        insert opportunityRecord;
        
        system.debug('opportunityRecord'+opportunityRecord);
        OpportunityContactRole optyConRoles = new OpportunityContactRole(
            ContactId = contactRecord.Id,
            OpportunityId = opportunityRecord.Id,
            IsPrimary = true,
            Role = 'Name on Invoice');
        
        insert optyConRoles;
        
        
        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,'Proforma Invoice');
        system.debug('invoiceRecord'+invoiceRecord);
        insert invoiceRecord;
        Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id); 
        Invoice_Line_Item__c invoiceLineRecord_B = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        
        Payment_Receipt__c paymentReceipt =   ICRA_TestDataFactory.createPaymentReceipt(opportunityRecord.Id, invoiceRecord.Id);
        insert paymentReceipt;
    }
    
    @isTest
    public static void paymentReceiptPdfTest(){
        Payment_Receipt__c paymentReceipt = [SELECT Id, Name FROM Payment_Receipt__c LIMIT 1];        
        PageReference pageRef = Page.ICRA_PaymentReceipt_pdf;
        ApexPages.currentPage().getParameters().put('id',paymentReceipt.Id);  
        ICRA_PaymentReceiptPdfController creditNotePdf = new ICRA_PaymentReceiptPdfController(new ApexPages.StandardController(paymentReceipt));
        creditNotePdf.savePDF();
    }
}