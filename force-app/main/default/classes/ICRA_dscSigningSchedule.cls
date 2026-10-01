global class ICRA_dscSigningSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ICRA_dscSigningBatch dscSigning = new ICRA_dscSigningBatch(); 
        database.executebatch(dscSigning,1);
    }
}