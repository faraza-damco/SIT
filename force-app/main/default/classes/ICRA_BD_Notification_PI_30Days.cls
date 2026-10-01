global class ICRA_BD_Notification_PI_30Days implements Schedulable {

    global void execute(SchedulableContext sc) {
      ICRA_BD_Notification_Before30Days bdNotification30Days = new ICRA_BD_Notification_Before30Days(); 
      database.executebatch(bdNotification30Days,200);
     
   }
}