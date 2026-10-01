@isTest
private class ICRA_Create_Opp_DataOne_T_Logic_Test {
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

    @isTest
    static void testCreateSurveillanceOpportunityDataOne1() {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
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
        businessSector.ICRA_Branch__c = branchrecord.Id; 
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME1', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	acc.Branch__c = branchrecord.Id; 
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.ofac_check__c =true;
        Acc.Account_Status__c ='Active';
        Acc.Constitution_Type_Picklist__c ='Other';
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
        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';      
        insert billingAddr;

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Commercial_Head__c=usrLH.Id;
        opty.Mandate_ID__c = '232400999';
        opty.Execution_Status_new__c = 'Initial Status';
        opty.Date_of_Non_Acceptance_of_Rating__c = Date.newInstance(2024, 3, 4);
        opty.Analyst__c = 'Analyst';
        opty.Sector_Head__c = 'Sector_Head';
        opty.Co_Analyst__c = 'Co_Analyst';
        opty.Group_Head__c = 'Group_Head';
        opty.Quality_Analyst__c = 'LCG';
        opty.Rated_Entity__c = acc.Id;
        opty.Billing_Start_Date__c = null;
        opty.Billing_End_date__c = null;
        opty.Defer_Billing_or_Exit_Case__c = '';
        insert opty;  

        ICRA_Create_Opportunity_DataOne.ResponseWrapper expectedResponse = new ICRA_Create_Opportunity_DataOne.ResponseWrapper();

        ICRA_Create_Opportunity_Wrapper.Data testData = new ICRA_Create_Opportunity_Wrapper.Data();
        testData.mandate_Id = '232400999';
        testData.pr_date = '';
        testData.date_of_communication = '';//String.valueOf(System.today());
        testData.surveillance_Id = '110011';
        testData.trust_name = 'Scheme Trust';
        testData.client_status = 'Live';
        testData.rated_VOD = '110';


        ICRA_Create_Opportunity_Wrapper testWrapper = new ICRA_Create_Opportunity_Wrapper();
        testWrapper.data = new List<ICRA_Create_Opportunity_Wrapper.Data>{testData};    
        String jsonRequest = JSON.serialize(testWrapper);
        
        String sampleJson = '{'+
            '"data": ['+
                '{'+
                    '"manId": "232400999",'+
                    '"SurvId": "110011",'+
                    '"trust": "Scheme Trust",'+
                    '"rated_vod": "110",'+
                    '"pr_date": "",'+
                    '"date_of_communication": "",'+
                    '"client_status": "Live"'+
                '}'+
            ']'+
        '}';
        
        ICRA_Create_Opportunity_Wrapper wrapperObj = ICRA_Create_Opportunity_Wrapper.parse(sampleJson);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateSurveillanceOpportunityDataOne';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);

        Test.startTest();
        ICRA_Create_Opportunity_DataOne.ResponseWrapper actualResponse = ICRA_Create_Opportunity_DataOne.createSurvOpportunity();
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
    @isTest
    static void testCreateSurveillanceOpportunityDataOne2() {
        // Test data setup
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
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
        businessSector.ICRA_Branch__c = branchrecord.Id; 
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME1', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	acc.Branch__c = branchrecord.Id;
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Account_Status__c ='Active';
        Acc.ofac_check__c =true;
        //Acc.Related_Party__c ='';
        Acc.Constitution_Type_Picklist__c ='Other';
        Acc.Ofac_Approved__c =true;
        Acc.OFAC_Document_Received__c =true;
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
        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';      
        insert billingAddr;

        Billing_Date__c billing = new Billing_Date__c();
        billing.Alignment_Logic__c= '12 Months';
        billing.Instrument_type_1__c= 'Non Structured Finance';
        billing.Instrument_type_2__c= 'Others';
        billing.Instrument_Type_3__c= 'Others';
        billing.Instrument_Type_4__c= 'Issuer Rating';
        billing.Start_Date__c= Date.Today();
        billing.End_date__c= Date.Today()+30;
        insert billing;

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

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Others';
        opty.Instrument_type_3__c = 'Others';
        opty.Instrument_type_4__c = 'Issuer Rating';
        opty.Instrument_Category__c = 'Issuer Rating';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Commercial_Head__c=usrLH.Id;
        opty.Mandate_ID__c = '262700999';
        opty.Mandate_Serial_No__c = '999';
        opty.Execution_Status_new__c = 'Initial Status';
        opty.Rated_Entity__c = acc.Id;
        opty.Billing_Start_Date__c = null;
        opty.Billing_End_date__c = null;
        opty.MPRA_SoW_Reference_No_Generated__c = true;
        opty.Surveillance_Created_via_DataOne__c = false;
        opty.CloseDate = Date.today();
        opty.Defer_Billing_or_Exit_Case__c = '';
        insert opty;  
        opty.OFAC_Approved__c=true;
        opty.SOW_Effective_Date__c=system.today();
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        update opty;

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
            Insert optyConRoles;
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opty.OFAC_Approved__c=true;
        opty.OFAC_Approver__c=usrLH.Id;
        opty.Commercial_Head__c=usrLH.Id;
        opty.Rolling_and_Date_Alignmnet__c = true;
        update opty;
        Test.startTest();
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
            update opty;
            opty.Proposed_Rating_Fee__c=1000;
            opty.Proposed_Surveillance_Fee__c=1000;
            //update opty;
            opty.StageName = 'Discount Approved';
            opty.Statement_of_Work_No__c = '12';
            //opty.Mandate_Received_Date__c= System.Today()-1;
        	opty.Pricing_Not_Auto_Approved__c= false;
        	opty.Pricing_Approved_by_Commercial_Head__c=true;
        	opty.Pricing_Approved_by_CEO__c =true;
            opty.No_Change_required_in_Commercial_clauses__c=true;
            update opty;
            opty.StageName = 'Proposal Submission';
            opty.ASF_Agreement_with_Client__c = 'In Absolute';
            update opty;
            opty.StageName = 'Executive Meeting';
            opty.Minimum_ASF__c=null;
            update opty;
            opty.StageName='Commercial Head Approval Pending';
            opty.No_Change_required_in_Commercial_clauses__c = true;
            update opty;
            opty.StageName = 'Commercial Head Approved';
            opty.Comm_Legal_Approval_Status__c='Approved';
            opty.Approved_by_Commercial_Head__c=true;
            opty.MPRA_Sent_Date__c = System.today();
            opty.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
            update opty;
            opty.Comm_Legal_Approval_Status__c='Approved';
            opty.Approved_by_Commercial_Head__c=true;
            update opty;
            opty.StageName = 'MPRA & SoW / Subscription Form Sent';
            opty.MPRA_Sent_Date__c = System.today();
            update opty;
            opty.StageName = 'Legal Approval Pending';
            opty.Approved_by_Commercial_Head__c = false;
            update opty;
            opty.StageName = 'Legal Approved';
            opty.Legal_Compliance_Approval__c = true;
            update opty;
            opty.StageName = 'MPRA & SoW /  Subscription Form Received';
            opty.Mandate_Received_Date__c = System.today()-1;
            update opty;

        List<ProcessInstance> processInstances = [SELECT Id, Status, ProcessDefinitionId 
                                                FROM ProcessInstance 
                                                WHERE TargetObjectId = :opty.Id AND Status = 'Pending'];

        for (ProcessInstance instance : processInstances) {
            ProcessDefinition processDef = [SELECT Id, DeveloperName 
                                            FROM ProcessDefinition 
                                            WHERE Id = :instance.ProcessDefinitionId];
            
            if (processDef != null) {
                System.debug('Record is in approval process: ' + processDef.DeveloperName);
            }
        }
        opty.StageName = 'Internal Control Approval';
        update opty;
        opty.StageName = 'Closed Won';
        opty.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        update opty;
        opty.PR_Date__c = Date.Today();
        update opty;

        ICRA_Create_Opportunity_DataOne.ResponseWrapper expectedResponse = new ICRA_Create_Opportunity_DataOne.ResponseWrapper();

        ICRA_Create_Opportunity_Wrapper.Data testData = new ICRA_Create_Opportunity_Wrapper.Data();
        testData.mandate_Id = '';
        testData.Account_Id = acc.Id;
        testData.instrument_category = 'Issuer Rating';
        testData.pr_date = '';
        testData.date_of_communication = '';//String.valueOf(System.today());
        testData.surveillance_Id = '110011';
        testData.trust_name = 'Scheme Trust';
        testData.client_status = 'Live';
        testData.rated_VOD = '110';

        ICRA_Create_Opportunity_Wrapper testWrapper = new ICRA_Create_Opportunity_Wrapper();
        testWrapper.data = new List<ICRA_Create_Opportunity_Wrapper.Data>{testData};
        String jsonRequest = JSON.serialize(testWrapper);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateSurveillanceOpportunityDataOne';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);

        ICRA_Create_Opportunity_DataOne.ResponseWrapper actualResponse = ICRA_Create_Opportunity_DataOne.createSurvOpportunity();
        InvokeBatch_Surveillance_T_Logic.invokeBatch();
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
    @isTest
    static void testCreateSurveillanceOpportunityTLogic(){
        // Test data setup
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurugram');
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
        businessSector.ICRA_Branch__c = branchrecord.Id; 
        insert businessSector;

        Account acc =  ICRA_TestDataFactory.CreateAccount('TESTNAME1', 'Issuer', null); 
        acc.PAN_Number__c = 'AAFCR5512V';
       	acc.Branch__c = branchrecord.Id;
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Account_Status__c ='Active';
        Acc.ofac_check__c =true;
        Acc.Constitution_Type_Picklist__c ='Other';
        Acc.Ofac_Approved__c =true;
        Acc.OFAC_Document_Received__c =true;
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
        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';           
        insert billingAddr;

        Billing_Date__c billing = new Billing_Date__c();
        billing.Alignment_Logic__c= '12 Months';
        billing.Instrument_type_1__c= 'Non Structured Finance';
        billing.Instrument_type_2__c= 'Others';
        billing.Instrument_Type_3__c= 'Others';
        billing.Instrument_Type_4__c= 'Issuer Rating';
        billing.Start_Date__c= Date.Today();
        billing.End_date__c= Date.Today()+30;
        insert billing;
    
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

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity('TestOpty', 'New Business', acc.Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Others';
        opty.Instrument_type_3__c = 'Others';
        opty.Instrument_type_4__c = 'Issuer Rating';
        opty.Instrument_Category__c = 'Issuer Rating';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.StageName = 'L1 Meeting';
        opty.Payment_Terms__c=30;
        opty.Delayed_Payment_Interest_Rate__c=18;
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Commercial_Head__c=usrLH.Id;
        opty.Mandate_ID__c = '262700996';
        opty.Mandate_Serial_No__c = '996';
        opty.Execution_Status_new__c = 'Initial Status';
        opty.Rated_Entity__c = acc.Id;
        opty.Billing_Start_Date__c = null;
        opty.Billing_End_date__c = null;
        //opty.ASF_Final_Amount__c = 10000;
        opty.MPRA_SoW_Reference_No_Generated__c = true;
        opty.CloseDate = Date.today();
        opty.Defer_Billing_or_Exit_Case__c = '';
        insert opty;  
        opty.OFAC_Approved__c=true;
        opty.SOW_Effective_Date__c=system.today();
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        update opty;

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
            Insert optyConRoles;
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opty.OFAC_Approved__c=true;
        opty.OFAC_Approver__c=usrLH.Id;
        opty.Commercial_Head__c=usrLH.Id;
        opty.Rolling_and_Date_Alignmnet__c = true;
        update opty;
        Test.startTest();
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
            update opty;
            opty.Proposed_Rating_Fee__c=1000;
            opty.Proposed_Surveillance_Fee__c=1000;
            //update opty;
            opty.StageName = 'Discount Approved';
            opty.Statement_of_Work_No__c = '12';
            //opty.Mandate_Received_Date__c= System.Today()-1;
        	opty.Pricing_Not_Auto_Approved__c= false;
        	opty.Pricing_Approved_by_Commercial_Head__c=true;
        	opty.Pricing_Approved_by_CEO__c =true;
            opty.No_Change_required_in_Commercial_clauses__c=true;
            update opty;
            opty.StageName = 'Proposal Submission';
            opty.ASF_Agreement_with_Client__c = 'In Absolute';
            update opty;
            opty.StageName = 'Executive Meeting';
            opty.Minimum_ASF__c=null;
            update opty;
            opty.StageName='Commercial Head Approval Pending';
            opty.No_Change_required_in_Commercial_clauses__c = true;
            update opty;
            opty.StageName = 'Commercial Head Approved';
            opty.Comm_Legal_Approval_Status__c='Approved';
            opty.Approved_by_Commercial_Head__c=true;
            opty.MPRA_Sent_Date__c = System.today();
            opty.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
            update opty;
            opty.Comm_Legal_Approval_Status__c='Approved';
            opty.Approved_by_Commercial_Head__c=true;
            update opty;
            opty.StageName = 'MPRA & SoW / Subscription Form Sent';
            opty.MPRA_Sent_Date__c = System.today();
            update opty;
            opty.StageName = 'Legal Approval Pending';
            opty.Approved_by_Commercial_Head__c = false;
            update opty;
            opty.StageName = 'Legal Approved';
            opty.Legal_Compliance_Approval__c = true;
            update opty;
            opty.StageName = 'MPRA & SoW /  Subscription Form Received';
            opty.Mandate_Received_Date__c = System.today()-1;
            update opty;

        List<ProcessInstance> processInstances = [SELECT Id, Status, ProcessDefinitionId 
                                                FROM ProcessInstance 
                                                WHERE TargetObjectId = :opty.Id AND Status = 'Pending'];

        for (ProcessInstance instance : processInstances) {
            ProcessDefinition processDef = [SELECT Id, DeveloperName 
                                            FROM ProcessDefinition 
                                            WHERE Id = :instance.ProcessDefinitionId];
            
            if (processDef != null) {
                System.debug('Record is in approval process: ' + processDef.DeveloperName);
            }
        }
        opty.StageName = 'Internal Control Approval';
        update opty;
        opty.StageName = 'Closed Won';
        opty.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        update opty;
        opty.PR_Date__c = Date.Today();
        opty.Billing_Start_Date__c = System.Today();
        opty.Billing_End_date__c = System.Today().addDays(60);
        update opty;
        opty.Revised_Billing_End_Date__c= System.Today().addDays(90);    //to match the T-Logic Date
        update opty;
        //opty.Bypass_Validation__c=true;
        opty.Defer_Billing_or_Exit_Case__c = 'Already Billed';
        update opty;
        InvokeBatch_Surveillance_T_Logic.invokeBatch();
        ICRA_CreateRollover_T_Logic_Manual manualBatch= new ICRA_CreateRollover_T_Logic_Manual(String.ValueoF(opty.Id));
        Database.executeBatch(manualBatch, 1);
        /*ICRA_Create_Manual_Surveillance_Button.Request request = new ICRA_Create_Manual_Surveillance_Button.Request();
        request.opportunityId = opty.Id;
        List<ICRA_Create_Manual_Surveillance_Button.Request> requests = new List<ICRA_Create_Manual_Surveillance_Button.Request>{ request };
        List<Opportunity> result = ICRA_Create_Manual_Surveillance_Button.Create_Manual_Surveillance_Button(requests);*/
        Test.stopTest();

        // Assert the expected response message
        //System.assertEquals(expectedResponse.StatusMessage, actualResponse.StatusMessage);
    }
}