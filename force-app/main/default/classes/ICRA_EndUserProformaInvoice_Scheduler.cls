global class ICRA_EndUserProformaInvoice_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ICRA_EndUserProformaInvoice_Notification bd90Days = new ICRA_EndUserProformaInvoice_Notification(); 
        database.executebatch(bd90Days,2000);
    }  
}