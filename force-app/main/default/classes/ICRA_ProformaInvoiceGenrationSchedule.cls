global class ICRA_ProformaInvoiceGenrationSchedule implements Schedulable  { 
    global void execute(SchedulableContext sc) {
        ICRA_ProformaInvoiceGenrationBatch piInvoice = new ICRA_ProformaInvoiceGenrationBatch(); 
        database.executebatch(piInvoice,1); 
    }
}