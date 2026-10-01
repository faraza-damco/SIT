/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-19-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   02-19-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

@isTest 
public class ICRA_PopulateContactHandler_Test {
    private static final String INVOICEROLE = 'Name on Invoice';
    @isTest
    public static void isBeforeInsert_Test(){ 
        Test.startTest();
            ICRA_TestDataFactory.loadCustomeSetting();
            Account accountRecord =  ICRA_TestDataFactory.CreateAccount('Name', 'Issuer', null); 
        	accountRecord.PAN_Number__c = 'AAACI0218B';
        	accountRecord.GST_Number__c = '24AAACI0218B1ZG';
            Insert accountRecord;
            Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountRecord.Id); 
            insert contactRecord;
            Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('name', 'New Business', accountRecord.Id); 
            opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        	opportunityRecord.StageName = 'L1 Meeting';
        	insert opportunityRecord; 
            List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
                                                            new OpportunityContactRole(
                                                                ContactId = contactRecord.Id,
                                                                OpportunityId = opportunityRecord.Id,
                                                                IsPrimary = true,
                                                                Role = INVOICEROLE)};
            Insert optyConRoles;
            Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id, null,null);  
            insert invoiceRecord;
            Invoice_Line_Item__c invoiceLineRecord =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opportunityRecord.Id);
        Test.stopTest();
        System.assertEquals(optyConRoles.size(),1);
    }
    
}