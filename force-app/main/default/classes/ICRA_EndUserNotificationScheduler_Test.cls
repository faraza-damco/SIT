@isTest
public class ICRA_EndUserNotificationScheduler_Test {
    @isTest
    public static void ICRA_EndUserNotificationScheduler_Test(){
     ICRA_EndUserNotificationScheduler endusernoti = new ICRA_EndUserNotificationScheduler();
         String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, endusernoti);
        
    }
    
}