@isTest
public class ICRA_OppDateAligBatch_TB_schedulerTest {
 @isTest
    public static void testschedule() {
		Test.StartTest();
		ICRA_OppDateAlignmentBatch_TB_scheduler testsched = new ICRA_OppDateAlignmentBatch_TB_scheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		Test.stopTest();
	}
}