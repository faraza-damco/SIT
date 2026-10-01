global class ICRA_GenerateIRNandQRSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ICRA_GenerateIRNandQRBatch GenerateIRNcheckbox = new ICRA_GenerateIRNandQRBatch(); 
        database.executebatch(GenerateIRNcheckbox,1);
    }
}