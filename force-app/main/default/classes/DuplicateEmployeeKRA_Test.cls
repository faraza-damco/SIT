@isTest
public class DuplicateEmployeeKRA_Test {
      static testMethod void positiveDataInsert1()
    {
        Test.startTest();
        Employee_KRA__c EK=new Employee_KRA__c(Status__c='Approved',Financial_Year__c='2022-2023',Quarter__c='Q1-April-June	');
            insert EK;
        
         PageReference pageRef = Page.CallKRABatch;
         Test.setCurrentPage(pageRef);

     pageRef.getParameters().put('Id', String.valueOf(EK.Id));
     ApexPages.StandardController sc = new ApexPages.StandardController(EK);
     CallKRABatch testAccPlan = new CallKRABatch(sc);
        testAccPlan.CalculateKra();
        Test.stopTest();
    }

}