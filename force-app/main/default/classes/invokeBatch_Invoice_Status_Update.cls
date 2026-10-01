public class invokeBatch_Invoice_Status_Update{
    @InvocableMethod(label='Invoke-ICRA_Invoice_Status_Update_Batch')
    public static void invokeBatch(){
        Database.executeBatch(new ICRA_Invoice_Status_Update_Batch(),1);
    }
}