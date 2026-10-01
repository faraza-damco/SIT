@isTest
public with sharing class ICRA_ManualInvoiceISD_Test {
@testsetup 
    public static void isDataSetup(){
     Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Test Branch');
     Manual_Invoice__c manualISD = ICRA_TestDataFactory.createISDrecord('ISD',branchRecord.Id);
    }
    @isTest
    public static void manualISDcontrollerTest(){
        Manual_Invoice__c manualISD = [SELECT Id,Name FROM Manual_Invoice__c LIMIT 1];
        PageReference pageRef = Page.ICRA_ManualInvoice_ISD_pdf;
        ApexPages.currentPage().getParameters().put('id',manualISD.Id);
        ICRA_Controller_ManualInvoice_ISD manualISDpdf = new ICRA_Controller_ManualInvoice_ISD(new ApexPages.StandardController(manualISD));
        manualISDpdf.savePDF();

    } 
    
}