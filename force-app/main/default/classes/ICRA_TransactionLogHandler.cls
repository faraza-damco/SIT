public with sharing class ICRA_TransactionLogHandler{

    private static List<Transaction_Log__c> logs = new List<Transaction_Log__c>();

    public static void addLog(String batchName, Id oppId, Id invoiceId, String operation, String message) {
        Transaction_Log__c errorLog = new Transaction_Log__c();
        errorLog.Batch_Process__c = batchName;
        errorLog.Opportunity__c = oppId;
        errorLog.Invoice__c = invoiceId;
        errorLog.Operation__c = operation;
        errorLog.Error_Message__c = message;
        errorLog.Status__c = 'Failed';
        logs.add(errorLog);
    }

    public static void saveLogs(){
        if (!logs.isEmpty()) {
            insert logs;
            logs.clear(); 
        }
    }
}