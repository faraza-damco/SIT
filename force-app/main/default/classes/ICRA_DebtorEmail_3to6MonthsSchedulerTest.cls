@isTest
public class ICRA_DebtorEmail_3to6MonthsSchedulerTest {
@isTest
    public static void testSchedule() {
		Test.StartTest();
		ICRA_DebtorEmail_3to6Months_Scheduler testsched = new ICRA_DebtorEmail_3to6Months_Scheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest(); 
	}
}