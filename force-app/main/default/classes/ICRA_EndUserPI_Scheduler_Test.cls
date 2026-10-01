@isTest
public class ICRA_EndUserPI_Scheduler_Test {
    @isTest
    public static void ICRA_EndUserPI_Scheduler_Test(){
      ICRA_EndUserProformaInvoice_Scheduler endusersheduler = new ICRA_EndUserProformaInvoice_Scheduler();
         String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, endusersheduler);
        
    }
    
}