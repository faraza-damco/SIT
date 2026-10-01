@isTest
public with sharing class PromotorCompaniesList_Test {
    @isTest 
    public static void coverPromotorList_Label(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Moodys','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'Active';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='OFAC Pending';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AAFCR5514B';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012344';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A007';

        Test.startTest();
        try {
            Insert accountReccord;
            System.assert(false, 'Invalid account insertion succeeded'); // Ensure it fails
        } catch (DmlException e) {
            System.assertEquals('ICRA cannot take up mandates from Promoter Companies.', e.getDmlMessage(0));
        }
        Test.stopTest();
    }
    @isTest 
    public static void coverPromotorList_Name(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('MIS Quality Management Corp.','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='OFAC Pending';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AAFCR5514D';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012341';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A001';
        //accountReccord.OFAC_Check__c = true;
        Test.startTest();
        try {
            Insert accountReccord;
            System.assert(false, 'Invalid account insertion succeeded'); // Ensure it fails
        } catch (DmlException e) {

            System.assertEquals('ICRA cannot take up mandates from Promoter Companies.', e.getDmlMessage(0));
        }
        Test.stopTest();       
    }
    @isTest 
    public static void coverPromotorList_PAN(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Account_Status__c = 'OFAC Pending';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='OFAC Pending';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AAFCR5514V';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012341';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A001';
        //accountReccord.OFAC_Check__c = true;
        Test.startTest();
        try {
            Insert accountReccord;
            System.assert(false, 'Invalid account insertion succeeded'); // Ensure it fails
        } catch (DmlException e) {

            System.assertEquals('ICRA cannot take up mandates from Promoter Companies.', e.getDmlMessage(0));
        }
        Test.stopTest(); 
    }
    @isTest 
    public static void coverPromotorList_CIN(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Acc1','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='OFAC Pending';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AAFCR5514D';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012344';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A001';
        //accountReccord.OFAC_Check__c = true;
        Test.startTest();
        try {
            Insert accountReccord;
            System.assert(false, 'Invalid account insertion succeeded'); // Ensure it fails
        } catch (DmlException e) {
            System.assertEquals('ICRA cannot take up mandates from Promoter Companies.', e.getDmlMessage(0));
        }
        Test.stopTest(); 
    }
    @isTest 
    public static void coverPromotorList_LEI(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
        accountReccord.Group_Name__c = 'Test Group';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.BillingCity = 'Delhi';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        accountReccord.Account_Status__c ='OFAC Pending';
        accountReccord.Account_Classification__c = 'SEZ';
        accountReccord.PAN_Number__c = 'AAFCR5514D';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012341';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A007';
        //accountReccord.OFAC_Check__c = true;
        Test.startTest();
        try {
            Insert accountReccord;
            System.assert(false, 'Invalid account insertion succeeded'); // Ensure it fails
        } catch (DmlException e) {
            System.assertEquals('ICRA cannot take up mandates from Promoter Companies.', e.getDmlMessage(0));
        }
        Test.stopTest(); 
    }
    @isTest 
    public static void coverPromotorList_Name_Update(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
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
        accountReccord.PAN_Number__c = 'ACDBE4615O';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012357';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A023';
        accountReccord.OFAC_Check__c = true;
        Insert accountReccord;
        accountReccord.Name='MIS Quality Management Corp.';
        update accountReccord;
    }
    @isTest 
    public static void coverPromotorList_Label_Update(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
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
        accountReccord.PAN_Number__c = 'ACDBE4615O';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012357';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A023';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        accountReccord.Name='Moodys';
        update accountReccord;
    }
    @isTest 
    public static void coverPromotorList_PAN_Update(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
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
        accountReccord.PAN_Number__c = 'ACDBE4615O';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012357';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A023';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        accountReccord.PAN_Number__c='ACDBE4612P';
        update accountReccord;
    }
    @isTest 
    public static void coverPromotorList_CIN_Update(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
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
        accountReccord.PAN_Number__c = 'AAFCR5514D';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012346';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A023';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        accountReccord.CIN_Number__c='U01234Az0123AaZ012344';
        update accountReccord;
    }
    @isTest 
    public static void coverPromotorList_LEI_Update(){
        List<Account> accList= new List<Account>();
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.PromotorCompany__c= true;
        insert tg_status;

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
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account2','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Related_Party__c = 'No';
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
        accountReccord.PAN_Number__c = 'AAFCR5514D';
        accountReccord.CIN_Number__c = 'U01234Az0123AaZ012341';
        accountReccord.LEI_Number__c = '012300A0A0A0A0A0A001';
        accountReccord.OFAC_Check__c = true;
        //accountReccord.Billing_Address__c = billingAddr.Id;
        Insert accountReccord;
        accountReccord.LEI_Number__c='012300A0A0A0A0A0A007';
        update accountReccord;
    }
}