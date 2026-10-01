global class ICRA_DebtorEmail_6to12Months_Scheduler implements Schedulable{
global void execute(SchedulableContext sc) {
        ICRA_DebtorEmail_6to12months Debtor6to12MonthsBatch = new ICRA_DebtorEmail_6to12months(); 
        database.executebatch(Debtor6to12MonthsBatch,200);
    }

}