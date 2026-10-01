global class ICRA_BD_NotificationScheduler implements Schedulable  {
     global void execute(SchedulableContext sc) {
      ICRA_BD_Notification_Before3months bdNotification = new ICRA_BD_Notification_Before3months(); 
      database.executebatch(bdNotification,2000);
    }
}