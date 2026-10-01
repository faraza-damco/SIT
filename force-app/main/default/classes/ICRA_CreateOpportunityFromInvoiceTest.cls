@isTest
public with sharing class ICRA_CreateOpportunityFromInvoiceTest {
    @isTest
    public static void CreateOpportunityFromInvoice() {
                
        List<Invoice_Line_Item__c> linelist = new List<Invoice_Line_Item__c>();
        
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
        insert businessSector;

        Account acc = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branchRecord.Id);
        acc.PAN_Number__c = 'AAFCR5512V';
       	//acc.GST_Number__c = '24AAACI0218B1ZG';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.ofac_check__c =true;
        Acc.Account_Status__c ='Active';
        Acc.Branch__c =branchRecord.Id;
        Acc.OFAC_Document_Received__c=true;
        Acc.Constitution_Type_Picklist__c='other';
        insert acc;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;
        
        List<Contact> conList = new List<Contact>{TestFactory.getContact(acc.Id,'ConRoleTest','ConRoleTest',true),
            TestFactory.getContact(acc.Id,'ConRoleTest','TestNameRole',true),
            TestFactory.getContact(acc.Id,'TestNameRole','ConRoleTest',true),
            TestFactory.getContact(acc.Id,'TestNameRole','TestNameRole',true),
            TestFactory.getContact(acc.Id,'TestRole','TestRole',true),
            TestFactory.getContact(acc.Id,'NameRole','NameRole',true)};

            conList[0].Email = 'testcontactrole@abc.com';
            conList[0].Designation__c = 'DESIGNATION';
            conList[0].Account = acc;
            conList[1].Email = 'testcontactrole@abc.com';
            conList[1].Designation__c = 'DESIGNATION';
            conList[1].Account = acc;
            conList[2].Email = 'test@abcxyz.com';
            conList[2].Designation__c = 'DESIGNATION2';
            conList[2].Account = acc;
            conList[3].Email = 'testcontactrole@abc.com';
            conList[3].Designation__c = 'DESIGNATION';
            conList[3].Account = acc;
            //conList[3].Inactive__c = true;
            conList[4].Designation__c = 'DESIGNATION';
            conList[4].Email = 'test@testing.com';
            conList[4].Account = acc;
            conList[5].Email = 'test@testing.com';
            conList[5].Designation__c = 'DESIGNATION';
            conList[5].Account = acc;
            update conList;
        
        Opportunity opportunityRecord1 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity1', 'Surveillance', acc.Id);
        opportunityRecord1.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord1.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord1.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord1.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord1.CloseDate = System.today();
        
        //opportunityRecord.Total_Invoice_Amount_1__c = 10;
        insert opportunityRecord1;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity2', 'Surveillance', acc.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating'; 
        opportunityRecord.CloseDate = System.today();
        
        opportunityRecord.Parent_Opportunity__c = opportunityRecord1.Id ;
        insert opportunityRecord; 
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = conList[0].Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = 'Email Recipient'),
            new OpportunityContactRole(
                ContactId = conList[4].Id,
                OpportunityId = opportunityRecord.Id,
                Role = 'Proposal Primary Contact'),
            new OpportunityContactRole(
                ContactId = conList[1].Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = 'Name on Invoice')};
        try{
            Insert optyConRoles;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        
        Test.startTest();
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null ,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c invoicelineitemRecord = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id,opportunityRecord.Id);
        Invoice_Line_Item__c invoicelineitemRecord2 = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id,opportunityRecord1.Id);
        ICRA_CreateOpportunityFromInvoice.creatOpportunity(new List<Invoice_Line_Item__c>{invoicelineitemRecord2});
        ICRA_CreateOpportunityFromInvoice.creatOpportunity(new List<Invoice_Line_Item__c>{invoicelineitemRecord});
        Test.stopTest();
    }
}