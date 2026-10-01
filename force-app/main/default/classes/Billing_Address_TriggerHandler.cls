public class Billing_Address_TriggerHandler {
    public static boolean isExecuting = false;
    public static void preventMultiplePrimaryAddr(List<Billing_Address__c> billingList){
        if(!isExecuting){
            Set<Id> accList= new Set<Id>();
            Map<String,Boolean> accountIdvsIs_Primary = new Map<String,Boolean>();
            //List<Billing_Address__c> billingListToUpdate = new List<Billing_Address__c>();
            List<Billing_Address__c> billingAddrList = new List<Billing_Address__c>();

            for(Billing_Address__c billingAddr: billingList){
                accList.add(billingAddr.Account_Name__c);
            }
            system.debug('accList====>>'+accList);
            if(!accList.isEmpty()){
                    billingAddrList= [select id, Account_Name__c,Is_Primary_Billing_Address__c from Billing_Address__c where Is_Primary_Billing_Address__c=true AND Account_Name__c IN: accList AND Id NOT IN: billingList];
                for(Billing_Address__c existBillingAddr: billingAddrList){
                    system.debug('existBillingAddr====>>'+existBillingAddr);
                    if(!accountIdvsIs_Primary.ContainsKey(existBillingAddr.Account_Name__c)){
                        system.debug('Inside Existing Record Query');
                        accountIdvsIs_Primary.put(existBillingAddr.Account_Name__c, existBillingAddr.Is_Primary_Billing_Address__c);
                    }
                }
            }
                system.debug('accountIdvsIs_Primary=====>>'+accountIdvsIs_Primary);
                for(Billing_Address__c billingAddr: billingList){
                    if(billingAddr.Is_Primary_Billing_Address__c==true && accountIdvsIs_Primary.ContainsKey(billingAddr.Account_Name__c)){
                        system.debug('Inside Fresh Record Insertion with is_Primary true');
                        billingAddr.Is_Primary_Billing_Address__c.addError('There is already one primary billing address under this account.');
                    }
                }
            isExecuting=false;
        }
    }
}