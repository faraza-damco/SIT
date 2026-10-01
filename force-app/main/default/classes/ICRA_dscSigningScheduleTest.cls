@isTest
public with sharing class ICRA_dscSigningScheduleTest {
    @isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_dscSigningSchedule testsched = new ICRA_dscSigningSchedule();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest(); 
	}
}