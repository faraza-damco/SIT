global class ICRA_DebtorEmail_3to6Months_Scheduler implements Schedulable{
global void execute(SchedulableContext sc) {
        ICRA_DebtorEmailBatch_3to6months Debtor3to6MonthsBatch = new ICRA_DebtorEmailBatch_3to6months(); 
        database.executebatch(Debtor3to6MonthsBatch,200);
    }
}