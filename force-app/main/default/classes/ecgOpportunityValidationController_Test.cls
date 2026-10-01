@isTest
public class ecgOpportunityValidationController_Test {
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
        acc.PAN_Number__c = 'AAFCR5512V';
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
        
         Opportunity opt = ICRA_TestDataFactory.creatOpportunity('Name', 'New Business', acc.Id); 
        opt.Instrument_type_1__c = 'Non Structured Finance';
        opt.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opt.Instrument_type_3__c = 'Bank Loan Rating';
        opt.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opt.Customer_Fee_Type__c = 'Non - Cap';
        opt.StageName = 'L1 Meeting';
        opt.Mandate_Type__c = 'Fresh From Existing';
        //opt.Scheme_Trust_Name__c = 'Mutual Fund';
        opt.Bypass_Validation__c = true;
        opt.Billing_Start_Date__c = null;
        insert opt;
    }
        private static testmethod void method1(){
            Opportunity Opp = [SELECT Id, Name FROM Opportunity LIMIT 1];       
             Test.startTest();
           ecgOpportunityValidationController.oppData(opp.Id);
            Test.StopTest();
        }

}