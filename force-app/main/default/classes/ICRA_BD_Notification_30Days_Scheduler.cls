global class ICRA_BD_Notification_30Days_Scheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
        BD_Notification_Batch_Execution_30Days bd30Days = new BD_Notification_Batch_Execution_30Days(); 
        database.executebatch(bd30Days,200);
}  

}