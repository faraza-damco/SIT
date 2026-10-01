public class InvokeBatch_AlreadyBilledOpty {
    @InvocableMethod(label='Invoke-CreateRolloverForAlreadyBilledOpty')
    public static void invokeBatch() {
        Database.executeBatch(new CreateRolloverForAlreadyBilledOpty());
    }
}