global class ICRA_CreateRollingOpportunitySchedule implements Schedulable  {
    
    global void execute(SchedulableContext sc) {
        ICRA_CreateRollingOpportunityBatch opp = new ICRA_CreateRollingOpportunityBatch(); 
        database.executebatch(opp,50); 
    } 
}