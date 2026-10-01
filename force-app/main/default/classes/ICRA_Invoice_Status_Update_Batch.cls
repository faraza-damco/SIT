public class ICRA_Invoice_Status_Update_Batch implements Database.Batchable<sObject>, Database.Stateful {
       
    private Date processDate;
    public ICRA_Invoice_Status_Update_Batch(){
        processDate = System.today();
    }

    /* =======       START     ======== */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, Updated_Surveillance_fees_Sequence__c FROM Branch__c]
        );
    }

    /* ==========     EXECUTE      ============= */
    public void execute(Database.BatchableContext bc, List<Branch__c> scope) {
        // Batch size MUST be 1
        Branch__c branch = scope[0];
        System.Debug('Executing ICRA_Invoice_Status_Update_Batch for branch Id: ' + scope[0].Id);
        Date taxInvoiceDate = processDate.addDays((Integer.valueOf(System.Label.Tax_Invoice_Generation)));
        Id surveillance_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
        Savepoint sp = Database.setSavepoint();
        // 🔒 Lock branch row to prevent race conditions
        branch = [SELECT Id, Updated_Surveillance_fees_Sequence__c FROM Branch__c WHERE Id = :branch.Id FOR UPDATE];
        List<Invoice__c> invList = [SELECT Id, Billing_Number__c, Invoice_Status__c, Skip_PB__c, Opportunity_Name__c, CreatedDate FROM Invoice__c
                                    WHERE Opportunity_Name__r.Opp_ICRA_Branch__c = :branch.Id
                                      AND Billing_Number__c = NULL
                                      AND Invoice_Status__c = 'Proforma Invoice'
                                      AND Proforma_Invoice_Status__c!= 'PI Rejected'
                                      AND Proforma_Invoice_Status__c!= 'PI Pending with Finance'
                                      AND Opportunity_Name__r.Billing_Start_Date__c<= :taxInvoiceDate
                                      AND Opportunity_Name__r.Billing_Start_Date__c>= :processDate
                                      AND Opportunity_Name__r.RecordTypeId = :surveillance_recordType Order by createdDate ASC];
        System.debug('Invoices to update: ' + invList.size());
        Integer runningCounter = branch.Updated_Surveillance_fees_Sequence__c == null ? 0 : Integer.valueOf(branch.Updated_Surveillance_fees_Sequence__c);

        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
        if (invList.isEmpty()) {
            return;
        }
        for (Invoice__c inv : invList){
            //runningCounter++;
            //inv.Billing_Number__c = runningCounter;
            inv.Invoice_Status__c = 'Initiate Tax Invoice';
            inv.Skip_PB__c = true;
            invoicesToUpdate.add(inv);
        }
        List<Invoice__c> invoicesToUpdateWithCounter = new List<Invoice__c>();
        // Then update invoices
        if (!invoicesToUpdate.isEmpty()) {
        Database.SaveResult[] results = Database.update(invoicesToUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    Invoice__c inv = invoicesToUpdate[i];
                    for (Database.Error err : results[i].getErrors()) {
                        ICRA_TransactionLogHandler.addLog('ICRA_Invoice_Status_Update_Batch', invoicesToUpdate[i].Opportunity_Name__c, invoicesToUpdate[i].Id, 'Invoice Status Update Failed: Proforma Invoice to Initiate Tax Invoice', err.getMessage());
                    }
                }else{
                    runningCounter++;
                    invoicesToUpdate[i].Billing_Number__c = runningCounter;
                    invoicesToUpdateWithCounter.add(invoicesToUpdate[i]);
                }
            }
        }

        if(!invoicesToUpdateWithCounter.isEmpty()){
            update invoicesToUpdateWithCounter;
        }
        // Update branch counter 
        if(branch.Updated_Surveillance_fees_Sequence__c != runningCounter){
            branch.Updated_Surveillance_fees_Sequence__c = runningCounter;
        update branch;
        }

        ICRA_TransactionLogHandler.saveLogs();
    }

    /* ===========     FINISH   ========= */
    public void finish(Database.BatchableContext bc) {
        System.debug('Finished ICRA_Invoice_Status_Update_Batch at ' + System.now());
    }
}