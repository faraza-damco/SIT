@isTest
public class Billing_Address_TriggerHandler_Test {

    @isTest
    static void testBillingAddressInsert() {
        List<Billing_Address__c> billingList= new List<Billing_Address__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account3','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'Yes';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='Active';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'ABCDE1234A';
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '06ABCDE1234A1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = false;      
        //insert billingAddr;
        Test.startTest();
        billingList.add(billingAddr);
        insert billingList;
        Test.stopTest();

        accountReccord.Billing_Address__c = billingAddr.Id;   
        update accountReccord;
        
        Billing_Address_TriggerHandler.preventMultiplePrimaryAddr(billingList);
        
        // Add assertions as needed to verify the behavior
        System.assertEquals(0, [SELECT COUNT() FROM Billing_Address__c WHERE Is_Primary_Billing_Address__c = true]);
    }
    
    @isTest
    static void testBillingAddressUpdate() {
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.Billing_Address__c=true;
        insert tg_status;
        List<Billing_Address__c> billingList= new List<Billing_Address__c>();
        Map<Id,Billing_Address__c> map_billingList= new Map<Id,Billing_Address__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account3','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'Yes';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='Active';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'ABCDE1234A';
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '06ABCDE1234A1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        //insert billingAddr;
        //Test.startTest();
        //insert billingAddr;
        //Test.stopTest();
        billingList.add(billingAddr);
        
        // accountReccord.Billing_Address__c = billingList[0].Id;   
        // update accountReccord;

        
        Billing_Address__c billingAddr1 = new Billing_Address__c();
        billingAddr1.Name = 'Damco Test 1';                     
        billingAddr1.Account_Name__c = accountReccord.Id;           
        billingAddr1.Billing_City__c = 'Gurgaon';                 
        billingAddr1.BillingCountry__c = 'India';                  
        billingAddr1.BillingState__c = 'Haryana';                  
        billingAddr1.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr1.GSTN__c = '06ABCDE1234A1ZQ';               
        billingAddr1.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr1.Is_Primary_Billing_Address__c = false;      
        //insert billingAddr;
        //Test.startTest();
        //insert billingAddr1;
        //Test.stopTest();
        billingList.add(billingAddr1);

        
        Test.startTest();
        insert billingList;
        map_billingList.put(billingList[1].Id, billingList[1]);
        billingList[1].Is_Primary_Billing_Address__c = true;
        update billingList;
        accountReccord.Billing_Address__c = billingList[1].Id;   
        update accountReccord;
        Billing_Address_TriggerHandler.preventMultiplePrimaryAddr(billingList);
        Test.stopTest();
        
        // Add assertions as needed to verify the behavior
        System.assertEquals(2, [SELECT COUNT() FROM Billing_Address__c WHERE Is_Primary_Billing_Address__c = true]);
    }
}