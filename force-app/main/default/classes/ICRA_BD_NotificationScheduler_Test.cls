@isTest
public class ICRA_BD_NotificationScheduler_Test {
@isTest
    public static void ICRA_BD_NotificationScheduler_Test(){
        ICRA_BD_NotificationScheduler bdnotification = new ICRA_BD_NotificationScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, bdnotification);
    }
}