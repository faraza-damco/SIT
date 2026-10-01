@isTest
public class ICRA_BD_Notifi_30Days_Scheduler_Test {
  @isTest
    public static void ICRA_BD_Notifi_30Days_Scheduler_Test(){
        ICRA_BD_Notification_30Days_Scheduler bdNotifi30Days = new ICRA_BD_Notification_30Days_Scheduler();
         String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, bdNotifi30Days);
    }
}