/*
=====================================================================================================
>  Requirement          :  "Creating TEST class for Record type Credit Note, Application-ICRA"

>  Developer Team       :   DAMCO_ICRA.
>  Developer Name       :   ABDUL MUQHEEM

>  Created Date         :   February 05, 2021
>  Completed Date       :   February 

>  Modified Date        :   -------
>  Modified By          :   -------
>  Modified Description :   -------
======================================================================================================
*/

@isTest( )
public class ICRA_Controller_CreditNote_Test {
    
     @testSetup
    public Static void isDataSetup (){
        
        ICRA_TestDataFactory.loadCustomeSetting();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
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
        businessSector.ICRA_Branch__c = branchRecord.Id;
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
        accountRecord.OFAC_Check__c =true;
        accountRecord.Constitution_Type_Picklist__c ='Other';
        accountRecord.Branch__c= branchRecord.Id;
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
        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';      
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

        Invoice__c invRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null, 'Initiate Tax Invoice');
        insert invRecord;
        invRecord.Invoice_Status__c = 'Tax Invoice';
        update invRecord;        

        Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Credit Note',opportunityRecord.Id, invRecord.Id, null);   
        insert invoiceRecord; 
    }
    
    @isTest
    public static void creditNotePdfTest(){
        Invoice__c invoice = [SELECT Id, Name FROM Invoice__c LIMIT 1];        
        PageReference pageRef = Page.ICRA_Creditnote_PDF;
        ApexPages.currentPage().getParameters().put('id',invoice.Id);  
        ICRA_Controller_CreditNote creditNotePdf = new ICRA_Controller_CreditNote(new ApexPages.StandardController(invoice));
        creditNotePdf.savePDF();  

    }
}