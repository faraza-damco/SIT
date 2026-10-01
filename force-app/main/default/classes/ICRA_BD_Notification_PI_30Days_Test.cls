@isTest
public class ICRA_BD_Notification_PI_30Days_Test {
   @isTest
    public static void ICRA_BD_Notification_PI_30Days_Test(){
        ICRA_BD_Notification_PI_30Days pi30Days = new ICRA_BD_Notification_PI_30Days();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, pi30Days);
    }
}