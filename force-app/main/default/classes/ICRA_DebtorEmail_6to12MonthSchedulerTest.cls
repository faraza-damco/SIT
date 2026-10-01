@isTest
public class ICRA_DebtorEmail_6to12MonthSchedulerTest {
@isTest
    public static void testSchedule() {
		Test.StartTest();
		ICRA_DebtorEmail_6to12Months_Scheduler testsched = new ICRA_DebtorEmail_6to12Months_Scheduler();
		String sch = '0 0 11 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest(); 
	}
}