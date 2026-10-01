global class ICRA_InvoiceGenrationScheduler implements Schedulable  {
     global void execute(SchedulableContext sc) {  
      ICRA_InvoiceGenrationBatch invoiceGenrationBatch = new ICRA_InvoiceGenrationBatch(); 
      database.executebatch(invoiceGenrationBatch,1); 
   }
}