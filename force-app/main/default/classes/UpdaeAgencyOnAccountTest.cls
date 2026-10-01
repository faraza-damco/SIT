@isTest
public class UpdaeAgencyOnAccountTest {
    
   static testMethod void positiveDataInsert()
    {
        Test.startTest();
        Account Acc=TestFactory.getAccount('XYZ', true);
        Live_Rating__c LR=TestFactory.generateLiveRating(Acc.Id);
        Live_Rating__c LR1=TestFactory.generateLiveRating(Acc.Id);
        Live_Rating__c LR3=TestFactory.generateLiveRating(Acc.Id);
        Live_Rating__c LR4=TestFactory.generateLiveRating(Acc.Id);
        
        LR.Client_Status__c='Withdrawn';
        update LR;
        LR1.Client_Status__c='Withdrawn';
        update LR1;
        Live_Rating__c[] LRlist=TestFactory.generateLiveRatingBulk(Acc.Id);
        LRlist[0].agency__C='CARE';
        LRlist[1].agency__C='CARE';
        LRlist[2].agency__C='Brickwork';
        LRlist[3].agency__C='Brickwork';
        LRlist[4].agency__C='Brickwork';
        LRlist[5].agency__C='Brickwork';
        insert LRlist;
        LRlist[0].Client_Status__c='Withdrawn';
        LRlist[1].Client_Status__c='Withdrawn';
        LRlist[2].Client_Status__c='Withdrawn';
        LRlist[3].Client_Status__c='Withdrawn';
        LRlist[4].Client_Status__c='Withdrawn';
        LRlist[5].Client_Status__c='Withdrawn';
        update LRlist;
        Live_Rating__c[] LRlist1=TestFactory.generateLiveRatingBulk(Acc.Id);
        LRlist1[0].agency__C='CRISIL';                                                            
        LRlist1[0].Client_Status__c='Withdrawn';
         insert LRlist1;      
      
        
        
    }
    static testMethod void positiveDataInsert1()
    {
        Test.startTest();
        Account Acc=TestFactory.getAccount('XYZ', true);
        Live_Rating__c[] LRlist1=TestFactory.generateLiveRatingBulk(Acc.Id);
        LRlist1[0].agency__C='CRISIL';                                                            
        LRlist1[0].Client_Status__c='Withdrawn';
        insert LRlist1; 
        
         Live_Rating__c[] LRlist2=TestFactory.generateLiveRatingBulk(Acc.Id);
        LRlist2[0].agency__C='CRISIL';                                                            
        LRlist2[0].Client_Status__c='Withdrawn';
        insert LRlist2; 
       
      
        
        
    }


}