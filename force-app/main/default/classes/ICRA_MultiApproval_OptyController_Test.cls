@isTest 
public class ICRA_MultiApproval_OptyController_Test {
    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String PROPOSALPRIMARY_ROLE = 'Proposal Primary Contact';
    private static final String MPRA_ROLE = 'MPRA/SOW';
    private static final String MPRA_Sent = 'MPRA & SoW / Subscription Form Sent';
    private static final String EMAILROLE = 'Email Recipient';
    private static final String CONEMAIL = 'testcontactrole@abc.com';
    private static final String CONEMAIL2 = 'test@abcxyz.com';
    private static final String ISSUER = 'Issuer';
    private static final String CLOSEDSTAGE = 'Closed Won';
    private static final String FIRSTSTAGE = 'L1 Meeting';
    private static final String NEWBUSINESS = 'New Business'; 
    private static final String SURVEILLANCE = 'Surveillance'; 
    private static final String TESTNAME1 = 'ConRoleTest';   
    private static final String TESTNAME2 = 'TestNameRole';
    private static final String TESTNAME3 = 'TestRole';
    private static final String TESTNAME4 = 'NameRole';
    private static final String DESIGNATION = 'Asst Mngr';
    private static final String DESIGNATION2 = 'A M';
    private static final String EMAIL = 'test@testing.com';
    //Test setup
    @testSetup 
    static void testSetup(){
        
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.OpportunityTrigger__c= true;
        tg_status.PromotorCompany__c= true;
        tg_status.Fee_Calculation__c= true;
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
        businessSector.ICRA_Branch__c =branchRecord.id;
        businessSector.CurrencyIsoCode = 'INR';
        insert businessSector;
        
        Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, ISSUER, null); 
        acc.PAN_Number__c = 'AAFCR5512V';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.ofac_check__c =true;
        Acc.Account_Status__c ='Active';
        Acc.OFAC_Approval_Status__c ='Approved';
        Acc.Branch__c =branchRecord.Id;
        Acc.OFAC_Document_Received__c=true;
        Acc.Ofac_Approved__c=true;
        Acc.Constitution_Type_Picklist__c='other';
        Acc.Bypass__c=true;
        Insert acc;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = Acc.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;
        billingAddr.Tax_GST_Classification__c = 'SEZ';
        insert billingAddr;
        
        // Acc.Billing_Address__c= billingAddr.Id;
        // update Acc;
        
        List<Contact> conList = new List<Contact>{TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME1,true),
            TestFactory.getContact(acc.Id,TESTNAME1,TESTNAME2,true),
            TestFactory.getContact(acc.Id,TESTNAME2,TESTNAME1,true),
            TestFactory.getContact(acc.Id,TESTNAME2,TESTNAME2,true),
            TestFactory.getContact(acc.Id,TESTNAME3,TESTNAME3,true),
            TestFactory.getContact(acc.Id,TESTNAME4,TESTNAME4,true)};
                
                conList[0].Email = CONEMAIL;
        conList[0].Designation__c = DESIGNATION;
        conList[0].Account = acc;
        conList[1].Email = CONEMAIL;
        conList[1].Designation__c = DESIGNATION;
        conList[1].Account = acc;
        conList[2].Email = CONEMAIL2;
        conList[2].Designation__c = DESIGNATION2;
        conList[2].Account = acc;
        conList[3].Email = CONEMAIL;
        conList[3].Designation__c = DESIGNATION;
        conList[3].Account = acc;
        //conList[3].Inactive__c = true;
        conList[4].Designation__c = DESIGNATION;
        conList[4].Email = EMAIL;
        conList[4].Account = acc;
        conList[5].Email = EMAIL;
        conList[5].Designation__c = DESIGNATION;
        conList[5].Account = acc;
        update conList;
        
        Opportunity opt = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, NEWBUSINESS, acc.Id); 
        opt.Instrument_type_1__c = 'Non Structured Finance';
        opt.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opt.Instrument_type_3__c = 'Bank Loan Rating';
        opt.Instrument_type_4__c = 'Bank Loan Rating';
        opt.Customer_Fee_Type__c = 'Non - Cap';
        opt.StageName = 'L1 Meeting';
        opt.Mandate_Type__c = 'Fresh From Existing';
        //opt.Scheme_Trust_Name__c = 'Mutual Fund';
        opt.Bypass_Validation__c = true;
        opt.Billing_Start_Date__c = null;
        opt.Defer_Billing_or_Exit_Case__c = '';
        opt.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opt;
        Test.startTest();
        Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, NEWBUSINESS, acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Others';
        opty.Instrument_type_3__c = 'Mutual Fund';
        opty.Instrument_type_4__c = 'Mutual Fund Rating';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='Other';
        opty.Other__c=5;
        opty.Commercial_Head__c=usrLH.Id;
        opty.ASF_Agreement_with_Client__c='In BPS';
        opty.Minimum_ASF__c=100;
        opty.Scheme_Trust_Name__c='Pika';
        opty.Bill_To__c=acc.Id;
        opty.Bypass_Validation__c=true;
        opty.Billing_Start_Date__c = null;
        opty.Defer_Billing_or_Exit_Case__c = '';
        opty.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opty; 
        opty.OFAC_Approved__c=true;
        opty.SOW_Effective_Date__c=system.today();
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = conList[0].Id,
                OpportunityId = opty.Id,
                IsPrimary = true,
                Role = EMAILROLE),
                new OpportunityContactRole(
                    ContactId = conList[4].Id,
                    OpportunityId = opty.Id,
                    Role = PROPOSALPRIMARY_ROLE),
                new OpportunityContactRole(
                    ContactId = conList[1].Id,
                    OpportunityId = opty.Id,
                    IsPrimary = true,
                    Rollover_Check__c = true,
                    Role = INVOICEROLE)};
                        try{
                            Insert optyConRoles;//Expecting No Email on Contact Error
                        }catch(Exception ex){
                            System.debug('%%%Exception- '+ex.getMessage());
                        }
        
        opty.OFAC_Approved__c=true;
        opty.OFAC_Approver__c=usrLH.Id;
        opty.Commercial_Head__c=usrLH.Id;
        opty.Rolling_and_Date_Alignmnet__c = true;
        opty.Instrument_type_3__c = 'Others';
        opty.Instrument_type_4__c = 'Monitoring Activity';

        opty.Instrument_type_3__c = 'Mutual Fund';
        opty.Instrument_type_4__c = 'Mutual Fund Rating';
        opty.StageName = 'Negotiation';
        opty.Pricing_Not_Auto_Approved__c=true;
        opty.Proposed_Rating_Fee__c=1000;
        opty.Proposed_Surveillance_Fee__c=1000; 
        opty.Pricing_Approved_by_Business_Head__c=true;
        opty.Approved_by_Commercial_Head__c=true;
        opty.Approved_by_MD_CEO_Group__c=true;
        opty.Pricing_Approved_by_CEO__c=true;
        opty.Pricing_Approved_by_Commercial_Head__c=true;
        opty.BD_Approve__c=true;
        opty.Billing_Approval__c='Accept';
        opty.Write_off_Approval__c='Accept';
        opty.Pricing_Auto_Approved__c=true;

        opty.Instrument_type_3__c = 'Others';
        opty.Instrument_type_4__c = 'AIF';

        opty.Proposed_Rating_Fee__c=1000;
        opty.Proposed_Surveillance_Fee__c=1000;

        opty.StageName = 'Discount Approved';
        opty.Statement_of_Work_No__c = '12';
        opty.Mandate_Received_Date__c= System.Today()-1;
        opty.Pricing_Not_Auto_Approved__c= false;
        opty.Pricing_Approved_by_Commercial_Head__c=true;
        opty.Pricing_Approved_by_CEO__c =true;
        opty.No_Change_required_in_Commercial_clauses__c=true;

        opty.StageName = 'Proposal Submission';
        opty.ASF_Agreement_with_Client__c = 'In Absolute';

        opty.StageName = 'Executive Meeting';
        opty.Minimum_ASF__c=null;

        opty.StageName='Commercial Head Approval Pending';
        opty.No_Change_required_in_Commercial_clauses__c = true;

        opty.StageName = 'Commercial Head Approved';
        opty.Comm_Legal_Approval_Status__c='Approved';
        opty.Approved_by_Commercial_Head__c=true;
        opty.MPRA_Sent_Date__c = System.today();
        opty.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';

        opty.Comm_Legal_Approval_Status__c='Approved';
        opty.Approved_by_Commercial_Head__c=true;

        opty.StageName = 'MPRA & SoW / Subscription Form Sent';
        opty.MPRA_Sent_Date__c = System.today();

        opty.StageName = 'Legal Approval Pending';
        opty.Approved_by_Commercial_Head__c = false;

        opty.StageName = 'Legal Approved';
        opty.Legal_Compliance_Approval__c = true;

        opty.StageName = 'MPRA & SoW /  Subscription Form Received';
        opty.Mandate_Received_Date__c = System.today()-1;
        
        // Query ProcessInstance records related to the record
        List<ProcessInstance> processInstances = [SELECT Id, Status, ProcessDefinitionId 
                                                  FROM ProcessInstance 
                                                  WHERE TargetObjectId = :opty.Id AND Status = 'Pending'];
        
        // Iterate through the process instances
        for (ProcessInstance instance : processInstances) {
            // Query ProcessDefinition to get the approval process name
            ProcessDefinition processDef = [SELECT Id, DeveloperName 
                                            FROM ProcessDefinition 
                                            WHERE Id = :instance.ProcessDefinitionId];
            
            if (processDef != null) {
                System.debug('Record is in approval process: ' + processDef.DeveloperName);
                // Optionally, you can perform additional actions based on the approval process
            }
        }
        opty.StageName = 'Internal Control Approval';
        
        //update opty;
        opty.StageName = 'Closed Won';
        opty.PR_Date__c = System.Today();
        //update opty;
        
        Opportunity SurvOpty = ICRA_TestDataFactory.creatOpportunity('Surveillance_Opty', SURVEILLANCE, acc.Id);
        SurvOpty.Parent_Opportunity__c = opty.Id;
        SurvOpty.Rollover_Check__c = true;
        SurvOpty.Ready_for_Approval__c = true;
        SurvOpty.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        SurvOpty.Commercial_Head__c=usrLH.Id;
        SurvOpty.Mandate_ID__c= '212200099';
        insert SurvOpty;

        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setObjectId(SurvOpty.Id);
        Approval.ProcessResult result = Approval.process(submitReq);
        Test.stopTest();
    }

    static testMethod void OpportunityApprovalController(){
        List<Account> accList= [select id, name from account];

        Test.startTest();
        ICRA_MultiApproval_OptyController.getOpportunitiesForAccount(accList[0].Id);
        //ICRA_MultiApproval_OptyController.submitForApproval(accList[0].Id, 'Submitting for Approval');
        Test.stopTest();
    }

    static testMethod void OpportunityApprovalController_Approve(){
        List<Account> accList= [select id, name from account];
        List<ProcessInstanceWorkitem> wItems = [SELECT Id FROM ProcessInstanceWorkitem LIMIT 1];
        Test.startTest();
        ICRA_MultiApproval_OptyController.processApprovals(new List<Id>{ wItems[0].Id },'Approve','Approving via Test');
        Test.stopTest();
    }

    static testMethod void OpportunityApprovalController_Reject(){
        List<Account> accList= [select id, name from account];
        List<ProcessInstanceWorkitem> wItems = [
            SELECT Id FROM ProcessInstanceWorkitem LIMIT 1
        ];
        Test.startTest();
        ICRA_MultiApproval_OptyController.processApprovals(new List<Id>{ wItems[0].Id },'Reject','Rejecting via Test');
        Test.stopTest();
    }

    static testMethod void OpportunityApprovalController_Email(){
        List<Account> accList= [select id, name from account];
        List<Opportunity> oppList= [select id, name, accountId, account.name, Account.Business_Sector__r.Business_Head__r.Email, Account.Business_Sector__r.Business_Head__c, 
        Account.Owner.Name, Account.Owner.Email,Account.CurrencyIsoCode, Team_Leader__c, Team_Leader__r.Email,Account.Business_Sector__c,BD_Head__r.Email,BD_Head__c,
        Opportunity.Commercial_Head__r.Email,Commercial_Head__c,Opportunity.Owner.Name,Opportunity.Owner.Email, Instrument_type_1__c, Instrument_Category__c
        from opportunity where AccountId= :accList[0].Id AND RecordType.DeveloperName='Surveillance'];
        List<ProcessInstanceWorkitem> wItems = [SELECT Id FROM ProcessInstanceWorkitem LIMIT 1];
        User usr = [SELECT Id, Name, Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        Map<Id, List<Id>> approverToOppIds = new Map<Id, List<Id>>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> pendingOpps = new Set<Id>();
        Set<Id> processInstanceIds = new Set<Id>();
        String comments = 'Test Comments';
        approverToOppIds.put(usr.Id, new List<Id>{oppList[0].Id});
        oppMap.put(oppList[0].Id, oppList[0]);
        pendingOpps.add(oppList[0].Id);
        List<ProcessInstanceWorkitem> workItems = [SELECT Id,ProcessInstanceId,ActorId,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type,ProcessInstance.ProcessDefinition.Name
            FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN : pendingOpps/* AND ProcessInstance.Status = 'Pending'*/];
        for(ProcessInstanceWorkitem wi : workItems){
            processInstanceIds.add(wi.ProcessInstanceId);
        }
        /*
        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setObjectId(SurvOpty.Id);
        Approval.ProcessResult result = Approval.process(submitReq);*/
        Test.startTest();
        ICRA_MultiApproval_OptyController.sendConsolidatedEmailToApprovers(approverToOppIds, oppMap, pendingOpps,/*comments,*/processInstanceIds);
        Test.stopTest();
    }
}