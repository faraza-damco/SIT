@isTest
public with sharing class ICRA_CreateRollingOppScheduleTest {
    @isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_CreateRollingOpportunitySchedule testsched = new ICRA_CreateRollingOpportunitySchedule();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	}
}