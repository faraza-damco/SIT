@isTest
public with sharing class ICRA_RevenueMilestoneServBatchTest {
    @isTest
    public static void servbatchtest() {

        Date endDate=Date.newInstance(2021, 12, 31);
        Date prDate=Date.newInstance(2021, 11, 30);
        Date lastInvoicedt=Date.newInstance(2021, 11, 30);

        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test','Issuer', branchrecord.Id);
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test1', 'Surveillance', accountReccord.Id);
        opportunityRecord.Generate_Revenue_Milestone__c=False;
        opportunityRecord.Actual_Surveillance_Fee__c=100000;
        opportunityRecord.Additional_Discount_Approved__c=True;
        opportunityRecord.Already_Invoiced__c='Yes';
        opportunityRecord.Amount_Outstanding_In_Rs__c=100000;
        opportunityRecord.Is_Hold__c=False;
        opportunityRecord.Is_Revenue_Milestone__c=True;
        opportunityRecord.Past_Invoice_Number__c='1234567890';
        opportunityRecord.Last_Invoice_Date__c=lastInvoicedt;
        opportunityRecord.PR_Date__c=prDate; 
        opportunityRecord.Billing_End_date__c=endDate;
        opportunityRecord.Customer_Fee_Type__c='Cap';
        opportunityRecord.Subscription_End_Date__c=endDate;
        opportunityRecord.Subscription_Start_Date__c=System.today();
        insert opportunityRecord;

        Test.startTest();
        ICRA_RevenueMilestoneServBatch rmsBatch=new ICRA_RevenueMilestoneServBatch();
        Database.executeBatch(rmsBatch,1);
    }
}