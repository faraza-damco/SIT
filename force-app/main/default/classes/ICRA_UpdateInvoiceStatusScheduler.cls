global class ICRA_UpdateInvoiceStatusScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        ICRA_UpdateInvoiceStatusBatch invoiceStatus = new ICRA_UpdateInvoiceStatusBatch();  
        database.executebatch(invoiceStatus,1); 
    }
}