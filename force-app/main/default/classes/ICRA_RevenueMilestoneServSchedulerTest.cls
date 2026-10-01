@isTest
public with sharing class ICRA_RevenueMilestoneServSchedulerTest {
	@isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_RevenueMilestoneServScheduler testsched = new ICRA_RevenueMilestoneServScheduler();
		String sch = '0 0 12 * * ?';
		system.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	}
}