@IsTest
private class ICRA_BulkRecallController_Test{

    @TestSetup
    static void setupData(){

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
        
        Account acc =  ICRA_TestDataFactory.CreateAccount('Test Recall Account', 'Issuer', null); 
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
        
        List<Contact> conList = new List<Contact>{
            TestFactory.getContact(acc.Id,'ConRoleTest', 'ConRoleTest', true),
            TestFactory.getContact(acc.Id,'ConRoleTest', 'TestNameRole', true),
            TestFactory.getContact(acc.Id,'TestNameRole', 'ConRoleTest', true),
            TestFactory.getContact(acc.Id,'TestNameRole', 'TestNameRole', true),
            TestFactory.getContact(acc.Id,'TestRole', 'TestRole', true),
            TestFactory.getContact(acc.Id,'NameRole', 'NameRole', true)
        };
                
        conList[0].Email = 'test1@test.com';
        conList[0].Designation__c = 'AM';
        conList[0].Account = acc;
        conList[1].Email = 'test1@test.com';
        conList[1].Designation__c = 'AM';
        conList[1].Account = acc;
        conList[2].Email = 'test2@test.com';
        conList[2].Designation__c = 'DM';
        conList[2].Account = acc;
        conList[3].Email = 'test1@test.com';
        conList[3].Designation__c = 'AM';
        conList[3].Account = acc;
        //conList[3].Inactive__c = true;
        conList[4].Designation__c = 'AM';
        conList[4].Email = 'test3@test.com';
        conList[4].Account = acc;
        conList[5].Email = 'test4@test.com';
        conList[5].Designation__c = 'AM';
        conList[5].Account = acc;
        update conList;
        
        Opportunity opt = ICRA_TestDataFactory.creatOpportunity('ConRoleTest', 'New Business', acc.Id); 
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
        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('ConRoleTest', 'New Business', acc.Id); 
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
        //update opty;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = conList[0].Id,
                OpportunityId = opty.Id,
                IsPrimary = true,
                Role = 'Email Recipient'),
            new OpportunityContactRole(
                ContactId = conList[4].Id,
                OpportunityId = opty.Id,
                Role = 'Proposal Primary Contact'),
            new OpportunityContactRole(
                ContactId = conList[1].Id,
                OpportunityId = opty.Id,
                IsPrimary = true,
                Rollover_Check__c = true,
                Role = 'Name on Invoice')
        };
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
        //update opty;

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
        //update opty;
        opty.Instrument_type_3__c = 'Others';
        opty.Instrument_type_4__c = 'AIF';
        //update opty;
        opty.Proposed_Rating_Fee__c=1000;
        opty.Proposed_Surveillance_Fee__c=1000;
        //update opty;
        opty.StageName = 'Discount Approved';
        opty.Statement_of_Work_No__c = '12';
        opty.Mandate_Received_Date__c= System.Today()-1;
        opty.Pricing_Not_Auto_Approved__c= false;
        opty.Pricing_Approved_by_Commercial_Head__c=true;
        opty.Pricing_Approved_by_CEO__c =true;
        opty.No_Change_required_in_Commercial_clauses__c=true;
        //update opty;
        opty.StageName = 'Proposal Submission';
        opty.ASF_Agreement_with_Client__c = 'In Absolute';
        //update opty;
        opty.StageName = 'Executive Meeting';
        opty.Minimum_ASF__c=null;
        //update opty;
        opty.StageName='Commercial Head Approval Pending';
        opty.No_Change_required_in_Commercial_clauses__c = true;
        //update opty;
        opty.StageName = 'Commercial Head Approved';
        opty.Comm_Legal_Approval_Status__c='Approved';
        opty.Approved_by_Commercial_Head__c=true;
        opty.MPRA_Sent_Date__c = System.today();
        opty.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        //update opty;
        opty.Comm_Legal_Approval_Status__c='Approved';
        opty.Approved_by_Commercial_Head__c=true;
        //update opty;
        opty.StageName = 'MPRA & SoW / Subscription Form Sent';
        opty.MPRA_Sent_Date__c = System.today();
        //update opty;
        opty.StageName = 'Legal Approval Pending';
        opty.Approved_by_Commercial_Head__c = false;
        //update opty;
        opty.StageName = 'Legal Approved';
        opty.Legal_Compliance_Approval__c = true;
        //update opty;
        opty.StageName = 'MPRA & SoW /  Subscription Form Received';
        opty.Mandate_Received_Date__c = System.today()-1;
        //update opty;
        
        opty.StageName = 'Internal Control Approval';
        
        //update opty;
        opty.StageName = 'Closed Won';
        opty.PR_Date__c = System.Today();
        //update opty;
        
        Opportunity SurvOpty = ICRA_TestDataFactory.creatOpportunity('Surveillance_Opty', 'Surveillance', acc.Id);
        SurvOpty.Parent_Opportunity__c = opty.Id;
        SurvOpty.Rollover_Check__c = true;
        SurvOpty.Ready_for_Approval__c = true;
        SurvOpty.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        SurvOpty.Others_Comment__c = 'Test Comment';
        SurvOpty.Mandate_ID__c = '999900009';
        insert SurvOpty;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(SurvOpty.Id);
        req.setComments('Submitting for approval');
        Approval.ProcessResult result = Approval.process(req);
        // Query ProcessInstance records related to the record
        List<ProcessInstance> processInstances = [SELECT Id, Status, ProcessDefinitionId FROM ProcessInstance WHERE TargetObjectId = :SurvOpty.Id AND Status = 'Pending'];
        
        // Iterate through the process instances
        for (ProcessInstance instance : processInstances){
            // Query ProcessDefinition to get the approval process name
            ProcessDefinition processDef = [SELECT Id, DeveloperName FROM ProcessDefinition WHERE Id = :instance.ProcessDefinitionId];
            
            if (processDef != null){
                System.debug('Record is in approval process: ' + processDef.DeveloperName);
                // Optionally, you can perform additional actions based on the approval process
            }
        }
        Test.stopTest();
    }


    @IsTest
    static void testGetPendingApprovalOpportunities_NullAccount(){
        Test.startTest();
        List<ICRA_BulkRecallController.PendingApprovalWrapper> result = ICRA_BulkRecallController.getPendingApprovalOpportunities(null);
        Test.stopTest();
        System.assertNotEquals(null, result,'Account should not be null');
        System.assertEquals(0,result.size(),'No records should be returned when Account Id is null');
    }


    @IsTest
    static void testGetPendingApprovalOpportunities_NoPendingRecords(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Recall Account' LIMIT 1 ];
        Test.startTest();
        List<ICRA_BulkRecallController.PendingApprovalWrapper> result = ICRA_BulkRecallController.getPendingApprovalOpportunities(acc.Id);
        Test.stopTest();
        System.assertNotEquals(null,result,'Result should not be null');
    }


    @IsTest
    static void testRecallApproval_BlankComments(){
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Recall Account' LIMIT 1 ];
        Test.startTest();
        try{
            ICRA_BulkRecallController.recallApproval(
                acc.Id,
                ''
            );
            System.assert(
                false,
                'Expected AuraHandledException for blank comments'
            );
        }catch(AuraHandledException e){
            System.debug('Exception Message: ' + e.getMessage());
        }
        Test.stopTest();
    }


    @IsTest
    static void testRecallApproval_NullComments(){

    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Recall Account' LIMIT 1 ];
        Test.startTest();
        try{

            ICRA_BulkRecallController.recallApproval(
                acc.Id,
                null
            );

            System.assert(
                false,
                'Expected AuraHandledException for null comments'
            );
        } catch (AuraHandledException e) {
            System.debug('Exception Message: ' + e.getMessage());
        }
        Test.stopTest();
    }


    @IsTest
    static void testRecallApproval_NoPendingRecords(){

    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Recall Account' LIMIT 1 ];
        Test.startTest();
        try{
            ICRA_BulkRecallController.recallApproval(
                acc.Id,
                'Test recall comment'
            );

            /*System.assert(
                false,
                'Expected exception because there are no pending approval records'
            );*/
        }catch (AuraHandledException e){
            System.debug('Exception Message: ' + e.getMessage());
        }
        Test.stopTest();
    }


    @IsTest
    static void testPendingApprovalAndRecall(){

    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Recall Account' LIMIT 1 ];
    Opportunity opp = [SELECT Id,Name,AccountId,RecordType.Name,Instrument_Type_4__c,Billing_Start_Date__c,Billing_End_Date__c,Defer_Billing_or_Exit_Case__c FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];

    Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
    submitRequest.setObjectId(opp.Id);

    Test.startTest();
    Approval.ProcessResult submitResult = Approval.process(submitRequest);
    //Test.stopTest();

    System.assert(
        submitResult.isSuccess(),
        'Opportunity should be successfully submitted for approval'
    );

    ProcessInstanceWorkitem workItem = [SELECT Id,ProcessInstanceId,ActorId,Actor.Name,ProcessInstance.TargetObjectId,ProcessInstance.Status,ProcessInstance.CreatedDate FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.Id LIMIT 1];

    System.assertNotEquals(
        null,
        workItem,
        'A ProcessInstanceWorkitem should have been created'
    );

    List<ICRA_BulkRecallController.PendingApprovalWrapper> pendingRecords = ICRA_BulkRecallController.getPendingApprovalOpportunities(acc.Id);
    ICRA_BulkRecallController.PendingApprovalWrapper wrapper = pendingRecords[0];

    String recallComment = 'Testing bulk recall functionality';

    List<ICRA_BulkRecallController.RecallResultWrapper> recallResults = ICRA_BulkRecallController.recallApproval(acc.Id,recallComment);
    Test.stopTest();

    System.assertNotEquals(
        null,
        recallResults,
        'Recall result should not be null'
    );

    System.assertEquals(
        1,
        recallResults.size(),
        'One recall result should be returned'
    );

    ICRA_BulkRecallController.RecallResultWrapper recallResult = recallResults[0];
    List<ProcessInstanceWorkitem> remainingWorkItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.Id];
    ProcessInstance recalledProcess = [SELECT Id,Status FROM ProcessInstance WHERE TargetObjectId = :opp.Id ORDER BY CreatedDate DESC LIMIT 1];
    List<ProcessInstanceStep> approvalSteps = [SELECT Id,StepStatus,Comments FROM ProcessInstanceStep WHERE ProcessInstanceId = :recalledProcess.Id ORDER BY CreatedDate DESC ];
    Boolean commentFound = false;

        for(ProcessInstanceStep step : approvalSteps){
            if (step.Comments == recallComment) {
                commentFound = true;
                break;
            }
        }
    }
}