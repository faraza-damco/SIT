@isTest
public class ICRA_Proposal_new_ExtensionClass_Test {
    static testMethod void CoverClass(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;

        Branch__c branchRecord = new Branch__c();
        branchRecord.Name = 'Gurugram';
        branchRecord.City__c ='Gurugram';
        branchRecord.Street__c ='Gurugram';
        branchRecord.GSTIN__c ='06AAACI0218B1ZG';
        branchRecord.PAN__c ='AAACI0218B';
        branchRecord.State__c ='Haryana';
        branchRecord.State_Code__c ='06';
        branchRecord.Authorized_Signatory__c=usrLH.Id;
        insert branchRecord;
        
        Business_Sector__c businessSector2 = new Business_Sector__c();
        businessSector2.Name = 'Infrastructure';
        businessSector2.Business_Head__c =  usrLH.Id; 
        businessSector2.OFAC_Approver__c = usrLH.Id; 
        businessSector2.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector2;
        Account Acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME2', 'Issuer', null); 
        Acc.PAN_Number__c = 'AAFCR5512P';
        Acc.GST_Number__c = '';
        Acc.Group_Name__c = 'testDamco';
        Acc.Business_Sector__c= businessSector2.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Insert Acc;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512P1ZQ';               
        billingAddr.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Acc.Billing_Address__c= billingAddr.Id;
        Acc.Account_Status__c= 'Active';
        update Acc;

        List<Contact> conList= new List<Contact>();
        Contact con = new Contact(firstName='conFirst', lastName= 'conTest',Salutation='Mr.', Email='testemail@testing.com', accountId=Acc.Id, Designation__c='Developer');
        //insert con;
        Contact con2 = new Contact(firstName='conSecond', lastName= 'conTest2',Salutation='Mr.', Email='testingemail@testing.com', accountId=acc.Id, Designation__c='Asst. Mngr');
        //insert con2;
        conList.add(con);
        conList.add(con2);
        insert conList;
        System.assertNotEquals(0, conList.size());
        //System.assert(con.id != null);
        String OpprecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opty = TestFactory.CreateOpportunityNonstructured_FFF('TestOpty', OpprecordType, acc.Id, false);
        opty.Contact__c= conList[0].Id;
        opty.CloseDate= system.today()+1;
        insert opty;
        
        List<OpportunityContactRole> OptyConRoleList = new List<OpportunityContactRole>();
        OptyConRoleList.add(new OpportunityContactRole(OpportunityId = opty.Id, ContactId = conList[1].Id, Role = 'Name on Invoice'));
        OptyConRoleList.add(new OpportunityContactRole(OpportunityId = opty.Id, ContactId = conList[0].Id, Role = 'Proposal Primary Contact'));
        insert OptyConRoleList;
        System.assertNotEquals(0, OptyConRoleList.size());
        Test.startTest();
        PageReference pageRef = Page.ICRA_Proposal_new;
        //pageRef.getParameters().put('Id', String.ValueOf(opty.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', opty.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        ICRA_Proposal_new_ExtensionClass proposalClass = new ICRA_Proposal_new_ExtensionClass(sc);
        Test.stopTest();

    }

    static testMethod void Cover_SendReview_MPRA_Doc(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        
        usrLH.City='Gurugram';
        update usrLH;
        Branch__c branchRecord = new Branch__c();
        branchRecord.Name = 'Gurugram';
        branchRecord.City__c ='Gurugram';
        branchRecord.Street__c ='Gurugram';
        branchRecord.GSTIN__c ='06AAACI0218B1ZG';
        branchRecord.PAN__c ='AAACI0218B';
        branchRecord.State__c ='Haryana';
        branchRecord.State_Code__c ='06';
        branchRecord.Authorized_Signatory__c=usrLH.Id;
        insert branchRecord;


        Business_Sector__c businessSector2 = new Business_Sector__c();
        businessSector2.Name = 'Infrastructure';
        businessSector2.Business_Head__c =  usrLH.Id; 
        businessSector2.OFAC_Approver__c = usrLH.Id; 
        businessSector2.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector2;
        Account Acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME2', 'Issuer', null); 
        Acc.PAN_Number__c = 'AAFCR5512P';
        Acc.GST_Number__c = '';
        Acc.Group_Name__c = 'testDamco';
        Acc.Business_Sector__c= businessSector2.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Insert Acc;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512P1ZQ';               
        billingAddr.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Acc.Billing_Address__c= billingAddr.Id;
        Acc.Account_Status__c= 'Active';
        update Acc;

        List<Contact> conList= new List<Contact>();
        Contact con = new Contact(firstName='conFirst', lastName= 'conTest',Salutation='Mr.', Email='testemail@testing.com', accountId=Acc.Id, Designation__c='Developer');
        //insert con;
        Contact con2 = new Contact(firstName='conSecond', lastName= 'conTest2',Salutation='Mr.', Email='testingemail@testing.com', accountId=acc.Id, Designation__c='Asst. Mngr');
        //insert con2;
        conList.add(con);
        conList.add(con2);
        insert conList;
        System.assertNotEquals(0, conList.size());
        //System.assert(con.id != null);
        String OpprecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opty = TestFactory.CreateOpportunityNonstructured_FFF('TestOpty', OpprecordType, acc.Id, false);
        opty.Contact__c= conList[0].Id;
        opty.Send_MPRA__c=true;
        opty.Send_SOW__c=true;
        opty.MPRA_Sent_Date__c=System.Today();
        opty.SOW_Effective_Date__c=System.Today();
        opty.CloseDate= system.today()+1;
        insert opty;
        List<OpportunityContactRole> OptyConRoleList = new List<OpportunityContactRole>();
        OptyConRoleList.add(new OpportunityContactRole(OpportunityId = opty.Id, ContactId = conList[1].Id, Role = 'MPRA/SOW'));
        OptyConRoleList.add(new OpportunityContactRole(OpportunityId = opty.Id, ContactId = conList[0].Id, Role = 'Proposal Primary Contact'));
        insert OptyConRoleList;
        //System.assertNotEquals(0, OptyConRoleList.size());
        Test.startTest();
        PageReference pageRef = Page.Send_Review_MPRA_Doc;
        //pageRef.getParameters().put('Id', String.ValueOf(opty.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', opty.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        Send_Review_MPRA_Doc_ExtensionClass proposalClass = new Send_Review_MPRA_Doc_ExtensionClass(sc);
        proposalClass.updateDates();
        proposalClass.isMPRAChecked= true;
        proposalClass.isSOWChecked= true;
        proposalClass.updateEffectiveDatesOnSend();
        Test.stopTest();
    }
}