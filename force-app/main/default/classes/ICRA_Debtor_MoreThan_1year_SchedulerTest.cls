@isTest
public class ICRA_Debtor_MoreThan_1year_SchedulerTest {
@isTest
    public static void testSchedule() {
		Test.StartTest();
		ICRA_Debtor_MoreThan_1year_Scheduler testsched = new ICRA_Debtor_MoreThan_1year_Scheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest(); 
	}
}