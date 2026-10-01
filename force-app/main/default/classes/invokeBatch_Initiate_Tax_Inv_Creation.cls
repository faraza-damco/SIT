public class invokeBatch_Initiate_Tax_Inv_Creation{
    @InvocableMethod(label='Invoke-ICRA_Generate_Tax_Invoice_Batch')
    public static void invokeBatch(){
        Database.executeBatch(new ICRA_Generate_Tax_Invoice_Batch(),1);
    }
}