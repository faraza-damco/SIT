@isTest
public with sharing class ICRA_PIGenrationScheduleTest {
    @isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_ProformaInvoiceGenrationSchedule testsched = new ICRA_ProformaInvoiceGenrationSchedule();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest(); 
	}
}