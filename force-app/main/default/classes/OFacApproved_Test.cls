@isTest
public class OFacApproved_Test {
   private static final String INVOICEROLE = 'Name on Invoice';
    private static final String EMAILROLE = 'Email Recipient';
    private static final String CONEMAIL = 'testcontactrole@abc.com';
    private static final String ISSUER = 'Issuer';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String FIRSTSTAGE = 'L1 Meeting';
    private static final String NEWBUSINESS = 'New Business';
    private static final String TESTNAME1 = 'ConRoleTest';
    private static final String TESTNAME2 = 'TestNameRole';
 static testMethod void validateBilledOptyLock() {
        try{
        Test.startTest();
            Triggers_status__c tg_status= new Triggers_status__c();
            tg_status.OpportunityTrigger__c= true;
            tg_status.PromotorCompany__c= true;
            tg_status.Fee_Calculation__c= true;
            tg_status.OFAC_Trigger__c= true;
            insert tg_status;
    
            Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
            Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            //ICRA_TestDataFactory
            User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
            usrLH.MobilePhone='1234567890';
            usrLH.Branch__c='Gurugram';
            usrLH.Designation__c='VP';
            usrLH.City='Gurugram';
            update usrLH;
    
            Business_Sector__c businessSector = new Business_Sector__c();
            businessSector.Name = 'Infrastructure';
            businessSector.Business_Head__c =  usrLH.Id; 
            businessSector.OFAC_Approver__c = usrLH.Id; 
            businessSector.Opportunity_Checker__c = usrLH.Id; 
            insert businessSector;

            Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, ISSUER, null); 
            acc.PAN_Number__c = 'AAACI0218B';
            //acc.GST_Number__c = '24AAACI0218B1ZG';
            acc.ShippingCountry = 'India';
            acc.ShippingState = 'Maharashtra';
            acc.Group_Name__c = 'NA';
            Insert acc;

            Billing_Address__c billingAddr = new Billing_Address__c();
            billingAddr.Name = 'Damco Test 1';                     
            billingAddr.Account_Name__c = Acc.Id;           
            billingAddr.Billing_City__c = 'Mumbai';                 
            billingAddr.BillingCountry__c = 'India';                  
            billingAddr.BillingState__c = 'Maharashtra';                  
            billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
            billingAddr.GSTN__c = '27AAACI0218B1ZP';               
            billingAddr.Billing_Zip_Postal_Code__c = '554410';        
            billingAddr.Is_Primary_Billing_Address__c = true;      
            insert billingAddr;

            List<Contact> conList = new List<Contact>{TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME1,true),
                                                        TestFactory.getContact(acc.Id,TESTNAME2,TESTNAME1,true)};
            conList[0].Email = CONEMAIL;
            conList[1].Email = CONEMAIL;
            Update conList;
            Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, NEWBUSINESS, acc.Id); 
            opty.Instrument_type_1__c = 'Non Structured Finance';
            opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
            opty.Instrument_type_3__c = 'Bank Loan Rating';
            opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
            opty.Customer_Fee_Type__c = 'Non - Cap';
            opty.StageName = 'L1 Meeting';
            
            insert opty; 
            opty.OFAC_Approved__c=true;
            update opty;
        	List<Opportunity> optyList = [Select Id,AccountId,StageName,Name,CloseDate from Opportunity];
            Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',optyList[0].Id, null,null);
        	invoiceRecord.Invoice_Status__c = 'Tax Invoice';
        	invoiceRecord.PI_Send__c = false;
            insert invoiceRecord;
            optyList[0].StageName = CLOSEDSTAGE;
            OFacApproved_Recursion.isFirstTime=true;
            optyList[0].OFAC_Approved__c =true;
            Update optyList;
            Test.stopTest();
        System.assertEquals(optyList.size(),1);
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
    }
}