global class ICRA_DebtorEmail_1to3Months_Scheduler implements Schedulable {
 global void execute(SchedulableContext sc) {
        ICRA_DebtorEmailBatch_1to3months Debtor1to3MonthsBatch = new ICRA_DebtorEmailBatch_1to3months(); 
        database.executebatch(Debtor1to3MonthsBatch,200);
    }
}