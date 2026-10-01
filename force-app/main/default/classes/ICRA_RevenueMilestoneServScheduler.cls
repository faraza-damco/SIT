global class ICRA_RevenueMilestoneServScheduler  implements Schedulable {
    global void execute(SchedulableContext sc) {
        ICRA_RevenueMilestoneServBatch revenueMilestoneServBatch = new ICRA_RevenueMilestoneServBatch(); 
        database.executebatch(revenueMilestoneServBatch,1);
    }
}