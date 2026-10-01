public class invokeBatch_Proforma_Invoice_Creation{
    @InvocableMethod(label='Invoke-ICRA_Generate_Proforma_Invoice_Batch')
    public static void invokeBatch(){
        Database.executeBatch(new ICRA_Generate_Proforma_Invoice_Batch(),1);
    }
}