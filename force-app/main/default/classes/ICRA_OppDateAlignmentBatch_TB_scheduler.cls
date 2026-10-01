global class ICRA_OppDateAlignmentBatch_TB_scheduler implements Schedulable {
 global void execute(SchedulableContext sc) {
        ICRA_OpportunityDateAlignmentBatch_TB opp = new ICRA_OpportunityDateAlignmentBatch_TB(); 
        database.executebatch(opp,20); 
    } 
}