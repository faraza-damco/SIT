global class ICRA_OpportunityDateAlignmentSchedule  implements Schedulable  { 
    global void execute(SchedulableContext sc) {
        ICRA_OpportunityDateAlignmentBatch opp = new ICRA_OpportunityDateAlignmentBatch(); 
        database.executebatch(opp,20);
    }
}