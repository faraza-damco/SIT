@isTest
public class InterBranch_Manual_Invoice_Test {
    @isTest
    static void testAssignInterInvoiceNumbers() {

        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.InterBranch_Manual_Invoice__c= true;
        insert tg_status;

        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        List<Manual_Invoice_Line_Item__c> linelist = new List<Manual_Invoice_Line_Item__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        branchrecord.Inter_Branch_Sequence_MI__c = 0;
        update branchrecord;
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        insert businessSector;
        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountRecord.OFAC_Document_Received__c = true;
        accountRecord.Related_Party__c = 'No';
        accountRecord.Group_Name__c = 'Test Group';
        accountRecord.Account_Status__c = 'Active';
        accountRecord.OFAC_Check__c = true;
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.BillingCity = 'Delhi';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Classification__c = 'SEZ';
        accountRecord.PAN_Number__c = 'ABCDE1234A';
        accountRecord.Constitution_Type_Picklist__c = 'other';
        insert accountRecord;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '06ABCDE1234A1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;  


        Manual_Invoice__c invoiceRecord3 = ICRA_TestDataFactory.createManualInvoice('Inter-Branch Invoice', accountRecord.Id, contactRecord.Id,null,null);
        invoiceRecord3.Invoice_Created_Date__c=System.Today();
        invoiceRecord3.Invoice_Date__c=System.Today();
        invoiceRecord3.Billing_Number__C= 0;
        invoiceRecord3.Source_Branch_1__c= branchrecord.Id;
        update invoiceRecord3;
    }
}