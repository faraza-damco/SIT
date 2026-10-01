@isTest
public with sharing class ICRA_GenerateIRNandQRScheduleTest {
    @isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_GenerateIRNandQRSchedule testsched = new ICRA_GenerateIRNandQRSchedule();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest(); 
	}
}