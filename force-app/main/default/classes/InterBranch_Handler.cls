public class InterBranch_Handler {
    public static void generateBillingNumber(List<Manual_Invoice__c> manualInvoices) {
        Set<Id> branchIds = new Set<Id>();
        for(Manual_Invoice__c invoice : manualInvoices){
            if (invoice.Source_Branch_1__c != null) {
                branchIds.add(invoice.Source_Branch_1__c);           
            }
        }
        if (branchIds.isEmpty()) return;

        Map<Id, Branch__c> branchMap = new Map<Id, Branch__c>([SELECT Id, Inter_Branch_Sequence_MI__c FROM Branch__c WHERE Id IN :branchIds FOR UPDATE]);
        Map<Id, Decimal> tempCounterMap = new Map<Id, Decimal>();

        Set<Id> recordTypeIds = new Set<Id>();
        for (Manual_Invoice__c inv : manualInvoices) {
            if (inv.RecordTypeId != null) {
                recordTypeIds.add(inv.RecordTypeId);
            }
        }
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE Id IN :recordTypeIds]);

        for (Manual_Invoice__c inv : manualInvoices) {
            String developerName = recordTypeMap.get(inv.RecordTypeId).DeveloperName;
            if (inv.Source_Branch_1__c != null && branchMap.containsKey(inv.Source_Branch_1__c) && developerName =='Inter_Branch_Invoice' && (inv.Billing_Number__c==0 || inv.Billing_Number__C==null)) {
                System.Debug('====RecordType===='+inv.recordType.DeveloperName+'   ====Source_Branch_Seq No====  '+inv.Source_Branch_1__r.Inter_Branch_Sequence_MI__c+ '   ====Billing No No====  '+inv.Billing_Number__c);
                Branch__c branch = branchMap.get(inv.Source_Branch_1__c);
                Decimal currentValue;

                if (!tempCounterMap.containsKey(branch.Id)){
                    currentValue = branch.Inter_Branch_Sequence_MI__c != null ? branch.Inter_Branch_Sequence_MI__c : 0;
                } else {
                    currentValue = tempCounterMap.get(branch.Id);
                }

                currentValue++; 
                inv.Billing_Number__c = currentValue;
                tempCounterMap.put(branch.Id, currentValue);
            }
        }

        for (Id branchId : tempCounterMap.keySet()) {
            branchMap.get(branchId).Inter_Branch_Sequence_MI__c = tempCounterMap.get(branchId);
        }

        update branchMap.values();
    }
}