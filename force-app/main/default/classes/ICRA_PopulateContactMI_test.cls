@isTest
public with sharing class ICRA_PopulateContactMI_test {
@isTest
    public static void isBeforeInsert_Test(){
         ICRA_TestDataFactory.loadCustomeSetting();
        Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id); 
        Manual_Invoice__c manualInvoice = ICRA_TestDataFactory.createManualInvoice('OPE',accountRecord.Id,contactRecord.Id,'hy6567','jybfvyg');
        Manual_Invoice_Line_Item__c manualLineItemRecord  = ICRA_TestDataFactory.createManualInvoiceLineItem(manualInvoice.Id);
    }
}