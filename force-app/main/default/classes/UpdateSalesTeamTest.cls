@isTest
public class UpdateSalesTeamTest {
    static testMethod void positiveDataInsert1()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        UserRole urTMem = new UserRole(Name = 'Team Member');insert urTMem;
        UserRole urTM = new UserRole(Name = 'Team Manager');insert urTM;
        UserRole urTL = new UserRole(Name = 'Team Leader');insert urTL;
        UserRole urLH = new UserRole(Name = 'Location Head');insert urLH;
        
        User usrLH = TestFactory.createTestUser(urLH.Id, pf.Id, 'Test FirstName', 'Test LastName',null);
        User usrTL = TestFactory.createTestUser(urTL.Id, pf.Id, 'Test FirstName', 'Test LastName',usrLH.Id);
        User usrTM = TestFactory.createTestUser(urTM.id, pf.Id, 'team', 'Leader',usrTL.Id);
        User usrTMem = TestFactory.createTestUser(urTMem.id, pf.Id, 'Team Member', 'Member',usrTM.Id);
        
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTMem.id);
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTM.id);
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTL.id);
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrLH.id);
        
        // UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTMem.id);
        System.runAs(usrTMem)
        {
            // system.debug('usrTM '+usrTM);
            system.debug('usrTMem '+usrTMem.UserRole);
            Account Acc=TestFactory.getAccount('XYZ', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,1);
            insert Opp;
           	RecursiveTriggerHandler.isFirstTime = true;
            Branch__c B=TestFactory.generateBranch('Noida');
            Lead l=TestFactory.generateLead('ABC', 'XYZA',B.Id);
            
            RecursiveTriggerHandler.isFirstTime = true;
           Market_Share__c MS=TestFactory.generateMarketshare(Acc.Id);
           
           
        }
        System.runAs(usrTM)
        {
            Account Acc=TestFactory.getAccount('XYZA', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,1);
            insert Opp;
            RecursiveTriggerHandler.isFirstTime = true;
            Branch__c B=TestFactory.generateBranch('Noida');
            Lead l=TestFactory.generateLead('ABC', 'XYZB',B.Id);
            RecursiveTriggerHandler.isFirstTime = true;
            Market_Share__c MS=TestFactory.generateMarketshare(Acc.Id);
           
        }
        System.runAs(usrTL)
        {
            Account Acc=TestFactory.getAccount('XYZB', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,1);
            insert Opp;
            Branch__c B=TestFactory.generateBranch('Noida');
            RecursiveTriggerHandler.isFirstTime = true;
            Lead l=TestFactory.generateLead('ABC', 'XYZC',B.Id);
            RecursiveTriggerHandler.isFirstTime = true;
            Market_Share__c MS=TestFactory.generateMarketshare(Acc.Id);
            
        }
        System.runAs(usrLH)
        {
            Account Acc=TestFactory.getAccount('XYZC', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,1);
            insert Opp;
            Branch__c B=TestFactory.generateBranch('Noida');
            RecursiveTriggerHandler.isFirstTime = true;
            Lead l=TestFactory.generateLead('ABC', 'XYZD',B.Id);
            RecursiveTriggerHandler.isFirstTime = true;
            Market_Share__c MS=TestFactory.generateMarketshare(Acc.Id);
           
        }
        Test.stopTest();
        
        
    }
     static testMethod void positiveDataInsert2()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        UserRole urTMem = new UserRole(Name = 'Team Member');insert urTMem;
        UserRole urTM = new UserRole(Name = 'Team Manager');insert urTM;
        UserRole urTL = new UserRole(Name = 'Team Leader');insert urTL;
        UserRole urLH = new UserRole(Name = 'Location Head');insert urLH;
        
        User usrLH = TestFactory.createTestUser(urLH.Id, pf.Id, 'Test FirstName', 'Test LastName',null);
        User usrTL = TestFactory.createTestUser(urTL.Id, pf.Id, 'Test FirstName', 'Test LastName',usrLH.Id);
        User usrTM = TestFactory.createTestUser(urTM.id, pf.Id, 'team', 'Leader',usrTL.Id);
        User usrTMem = TestFactory.createTestUser(urTMem.id, pf.Id, 'Team Member', 'Member',usrTM.Id);
        
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTMem.id);
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTM.id);
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTL.id);
        UpdateSalesTeam.Mtd_UpdateSalesTeam(usrLH.id);
        
        // UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTMem.id);
        System.runAs(usrTMem)
        {
            // system.debug('usrTM '+usrTM);
            system.debug('usrTMem '+usrTMem.UserRole);
            Account Acc=TestFactory.getAccount('XYZ', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp1=TestFactory.generateOppsForAccount(Acc.Id,50000,10);
            insert Opp1;
            Branch__c B=TestFactory.generateBranch('Noida');
          
            Lead[] lds=TestFactory.generateLeadBulk('ABC1', 'XYZA1',B.Id);
           // insert lds;
            Market_Share__c[] MSlst=TestFactory.generateMarketshareBulk(Acc.Id);
            //insert MSlst;
        }
        System.runAs(usrTM)
        {
            Account Acc=TestFactory.getAccount('XYZA', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,10);
            insert Opp;
            Branch__c B=TestFactory.generateBranch('Noida');
          
            Lead[] lds=TestFactory.generateLeadBulk('ABC', 'XYZA',B.Id);
           // insert lds;
            Market_Share__c[] MSlst=TestFactory.generateMarketshareBulk(Acc.Id);
            //insert MSlst;
        }
        System.runAs(usrTL)
        {
            Account Acc=TestFactory.getAccount('XYZB', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,10);
            insert Opp;
            Branch__c B=TestFactory.generateBranch('Noida');
           
            Lead[] lds=TestFactory.generateLeadBulk('ABC', 'XYZA',B.Id);
            //insert lds;
            Market_Share__c[] MSlst=TestFactory.generateMarketshareBulk(Acc.Id);
            //insert MSlst;
        }
        System.runAs(usrLH)
        {
            Account Acc=TestFactory.getAccount('XYZC', true);
            Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50000,10);
            insert Opp;
            Branch__c B=TestFactory.generateBranch('Noida');
           
            Lead[] lds=TestFactory.generateLeadBulk('ABC', 'XYZA',B.Id);
            //insert lds;
            Market_Share__c[] MSlst=TestFactory.generateMarketshareBulk(Acc.Id);
            //insert MSlst;
        }
        Test.stopTest();
        
        
    }
}