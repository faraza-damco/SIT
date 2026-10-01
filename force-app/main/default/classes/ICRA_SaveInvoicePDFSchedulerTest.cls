@isTest
public class ICRA_SaveInvoicePDFSchedulerTest {
    @isTest
    public static void ICRA_EndUserPI_Scheduler_Test(){
      ICRA_SaveInvoicePDFSchedule savePDF = new ICRA_SaveInvoicePDFSchedule();
         String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, savePDF);
        
    }
    
}