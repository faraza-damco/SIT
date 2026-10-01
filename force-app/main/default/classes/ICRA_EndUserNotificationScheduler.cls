global class ICRA_EndUserNotificationScheduler implements Schedulable {
 global void execute(SchedulableContext sc) {
        EndUser_Notification_Invoices_PI endUserNotification = new EndUser_Notification_Invoices_PI(); 
        database.executebatch(endUserNotification,200);
}
}