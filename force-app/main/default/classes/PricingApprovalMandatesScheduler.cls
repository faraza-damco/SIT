global class PricingApprovalMandatesScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        PricingApprovalMandatesBatch b = new PricingApprovalMandatesBatch(); 
       database.executebatch(b);
    }
}