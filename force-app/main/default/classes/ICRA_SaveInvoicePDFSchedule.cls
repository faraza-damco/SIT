global class ICRA_SaveInvoicePDFSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ICRA_SaveInvoicePDFBatch SaveInvoicePDFBatch = new ICRA_SaveInvoicePDFBatch(); 
        database.executebatch(SaveInvoicePDFBatch,1);
    }  
}