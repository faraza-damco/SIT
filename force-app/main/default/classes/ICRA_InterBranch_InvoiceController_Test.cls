@isTest
public class ICRA_InterBranch_InvoiceController_Test {
    @testsetup 
    public static void isDataSetup(){
          ICRA_TestDataFactory.loadCustomeSetting();
        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Test Branch');
        Branch__c branchRecord2 = ICRA_TestDataFactory.createBranchRecord('Testing Branch');
        Manual_Invoice__c manualInterBranchRecord = ICRA_TestDataFactory.createInterBranch('Inter-Branch Invoice',branchRecord.Id,branchRecord2.Id);
        manualInterBranchRecord.Description_of_Service__c='Test';
        
    }
    @isTest
    public static void ICRA_InterBranch_Controller_Test(){
         Manual_Invoice__c manualInterBranchRecord = [SELECT Id,Name FROM Manual_Invoice__c LIMIT 1];
        PageReference pageRef = Page.ICRA_InterBranch_Invoice;
        ApexPages.currentPage().getParameters().put('id',manualInterBranchRecord.Id);
        ICRA_Interbranch_InvoiceController manualInterBranch = new ICRA_Interbranch_InvoiceController(new ApexPages.StandardController(manualInterBranchRecord));
        manualInterBranch.savePDF();

    }
}