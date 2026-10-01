public class InvokeBatch_Surveillance_T_Logic{
    @InvocableMethod(label='Invoke-ICRA_CreateRollover_T_Logic')
    public static void invokeBatch(){
        Database.executeBatch(new ICRA_CreateRollover_T_Logic(),1);
    }
}