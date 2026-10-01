@isTest
public with sharing class ICRA_InvoiceGenrationSchedulerTest {
    @isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_InvoiceGenrationScheduler testsched = new ICRA_InvoiceGenrationScheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched ); 
		Test.stopTest(); 
	}
}