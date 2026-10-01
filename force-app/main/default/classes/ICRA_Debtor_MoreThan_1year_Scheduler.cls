global class ICRA_Debtor_MoreThan_1year_Scheduler implements Schedulable{
global void execute(SchedulableContext sc) {
        EmailReminder_Debtors_Batch_More_1year Debtor1YearBatch = new EmailReminder_Debtors_Batch_More_1year(); 
        database.executebatch(Debtor1YearBatch,200);
    }

}