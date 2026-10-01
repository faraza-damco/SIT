@isTest
public class UpdateSalesTeamBatchwithListTest {
    static testMethod void positiveDataInsert()
    {
        Test.startTest();
        Set<Id> ids=new Set<Id>();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        UserRole urTMem = new UserRole(Name = 'Team Member');insert urTMem;
        UserRole urTM = new UserRole(Name = 'Team Manager');insert urTM;
        UserRole urTL = new UserRole(Name = 'Team Leader');insert urTL;
        UserRole urLH = new UserRole(Name = 'Location Head');insert urLH;
        
        User usrLH = TestFactory.createTestUser(urLH.Id, pf.Id, 'Test FirstName', 'Test LastName',null);
        User usrTL = TestFactory.createTestUser(urTL.Id, pf.Id, 'Test FirstName', 'Test LastName',usrLH.Id);
        User usrTM = TestFactory.createTestUser(urTM.id, pf.Id, 'team', 'Leader',usrTL.Id);
        User usrTMem = TestFactory.createTestUser(urTMem.id, pf.Id, 'Team Member', 'Member',usrTM.Id);
        
        
        // UpdateSalesTeam.Mtd_UpdateSalesTeam(usrTMem.id);
        System.runAs(usrTMem)
        {
            // system.debug('usrTM '+usrTM);
            system.debug('usrTMem '+usrTMem.UserRole);
            Account Acc=TestFactory.getAccount('XYZ', true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50,1);
           	insert Opp;
            Branch__c B=TestFactory.generateBranch('Noida');
            //Lead l=TestFactory.generateLead('ABC', 'XYZA',B.Id);
           // Market_Share__c MS=TestFactory.generateMarketshare(Acc.Id);
        }
        System.runAs(usrTM)
        {
            Account Acc=TestFactory.getAccount('XYZA', true);
            List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,50,1);
           
            insert Opp;
            for(Opportunity op:Opp)
            {
               ids.add(op.Id) ;
            }
            Branch__c B=TestFactory.generateBranch('Noida');
            //Lead l=TestFactory.generateLead('ABC', 'XYZB',B.Id);
            ////Market_Share__c MS=TestFactory.generateMarketshare(Acc.Id);
            string query='select id,ownerid from opportunity';
 			UpdateSalesTeamBatchwithList shn = new UpdateSalesTeamBatchwithList(ids,'Opportunity'); 
        	database.executeBatch(shn ); 

        }
       
        Test.stopTest();


    }
}