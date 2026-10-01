@isTest
private class ICRA_SendToClient_Test{
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
    @testSetup
    static void setupData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Mumbai');

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
        opty.ownerId= usrLH.Id;
        opty.Defer_Billing_or_Exit_Case__c = '';
        insert opty;  
        opty.OFAC_Approved__c=true;
        opty.SOW_Effective_Date__c=system.today();
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        opty.Client_Mail_Address_To__c=CONEMAIL;
        opty.Client_Mail_Address_CC__c=EMAIL;
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
        //opty.PR_Date__c = Date.Today();
        opty.Billing_Start_Date__c = Date.Today().addDays(10);
        opty.Billing_End_Date__c = Date.Today().addDays(10).addMonths(12);
        update opty;

        Opportunity SurvOptyProforma = ICRA_TestDataFactory.creatOpportunity('Surveillance_Proforma', SURVEILLANCE, acc.Id);
        SurvOptyProforma.Parent_Opportunity__c = opty.Id;
        SurvOptyProforma.BillingAddress__c = billingAddr.Id;
        SurvOptyProforma.Opp_ICRA_Branch__c = branchrecord.Id;
        SurvOptyProforma.Instrument_Category__c = 'Issuer Rating';
        SurvOptyProforma.Proforma_Invoice_Generated__c = false;
        SurvOptyProforma.Proforma_Invoice_Required_Surv__c = true;
        SurvOptyProforma.StageName = 'Closed Won';
        SurvOptyProforma.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        SurvOptyProforma.Billing_Start_Date__c = Date.Today().addDays(32);
        SurvOptyProforma.Billing_End_Date__c = Date.Today().addDays(32).addMonths(12);
        SurvOptyProforma.Client_Mail_Address_To__c=CONEMAIL;
        insert SurvOptyProforma;

        List<OpportunityContactRole> survOptyConRolesProforma = new List<OpportunityContactRole>{
        new OpportunityContactRole(
        ContactId = conList[0].Id,
        OpportunityId = SurvOptyProforma.Id,
        IsPrimary = true,
        Role = EMAILROLE),
        new OpportunityContactRole(
        ContactId = conList[4].Id,
        OpportunityId = SurvOptyProforma.Id,
        Role = PROPOSALPRIMARY_ROLE),
        new OpportunityContactRole(
        ContactId = conList[1].Id,
        OpportunityId = SurvOptyProforma.Id,
        IsPrimary = true,
        Rollover_Check__c = true,
        Role = INVOICEROLE)};
        try{
        Insert survOptyConRolesProforma;
        }catch(Exception ex){
        System.debug('%%%Exception- '+ex.getMessage());
        }

        Opportunity SurvOptyTax = ICRA_TestDataFactory.creatOpportunity('Surveillance_Tax', SURVEILLANCE, acc.Id);
        SurvOptyTax.Parent_Opportunity__c = opty.Id;
        SurvOptyTax.BillingAddress__c = billingAddr.Id;
        SurvOptyTax.Opp_ICRA_Branch__c = branchrecord.Id;
        SurvOptyTax.Instrument_Category__c = 'Issuer Rating';
        SurvOptyTax.Initiate_Tax_Invoice_Generated__c = false;
        SurvOptyTax.Proforma_Invoice_Required_Surv__c = false;
        SurvOptyTax.StageName = 'Closed Won';
        SurvOptyTax.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        SurvOptyTax.Billing_Start_Date__c = Date.Today().addDays(10);
        SurvOptyTax.Billing_End_Date__c = Date.Today().addDays(10).addMonths(12);
        SurvOptyTax.Client_Mail_Address_To__c=CONEMAIL;
        insert SurvOptyTax;

        List<OpportunityContactRole> survOptyConRolesTax = new List<OpportunityContactRole>{
        new OpportunityContactRole(
        ContactId = conList[1].Id,
        OpportunityId = SurvOptyTax.Id,
        IsPrimary = true,
        Rollover_Check__c = true,
        Role = INVOICEROLE)};
        try{
        Insert survOptyConRolesTax;
        }catch(Exception ex){
        System.debug('%%%Exception- '+ex.getMessage());
        }

        Invoice__c proformaInvoice = new Invoice__c();
        proformaInvoice.RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        proformaInvoice.Opportunity_Name__c = SurvOptyProforma.Id;
        proformaInvoice.Invoice_Status__c = 'Proforma Invoice';
        insert proformaInvoice;

        Invoice_Line_Item__c proformaINVLI= ICRA_TestDataFactory.createInvoiceLineItem(proformaInvoice.Id, SurvOptyProforma.Id);

        Invoice__c taxInvoice = new Invoice__c();
        taxInvoice.RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        taxInvoice.Opportunity_Name__c = SurvOptyTax.Id;
        taxInvoice.Invoice_Status__c = 'Initiate Tax Invoice';
        insert taxInvoice;

        //Invoice_Line_Item__c initiateTaxINVLI= ICRA_TestDataFactory.createInvoiceLineItem(taxInvoice.Id, SurvOptyTax.Id);

    }

    @isTest 
    static void sendToClientProformaTest(){
        Invoice__c proformaInvoice = [SELECT Id, Client_Mail_Address_To__c, Client_Mail_Address_CC__c FROM Invoice__c WHERE Invoice_Status__c = 'Proforma Invoice' LIMIT 1];
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test File';
        cv.PathOnClient = 'testfile.pdf';
        cv.VersionData = Blob.valueOf('This is a test file content');
        insert cv;

        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedCV.ContentDocumentId;
        cdl.LinkedEntityId = proformaInvoice.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        Test.startTest();
        ICRA_SendToClient.reviewPDF(proformaInvoice.Id);
        ICRA_SendToClient.sendPDF(proformaInvoice.Id);
        ICRA_SendToClient.displayInfo(proformaInvoice.Id);
        Test.stopTest();
    }

    @istest
    static void sendToClientInitiateTaxTest(){
        Invoice__c taxInvoice = [SELECT Id, Client_Mail_Address_To__c, Client_Mail_Address_CC__c FROM Invoice__c WHERE Invoice_Status__c = 'Initiate Tax Invoice' LIMIT 1];
        taxInvoice.Invoice_Status__c = 'Tax Invoice';
        update taxInvoice;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test File Signed';
        cv.PathOnClient = 'testfile.pdf';
        cv.VersionData = Blob.valueOf('This is a test file content');
        insert cv;

        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedCV.ContentDocumentId;
        cdl.LinkedEntityId = taxInvoice.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        Test.startTest();
        ICRA_SendToClient.reviewPDF(taxInvoice.Id);
        ICRA_SendToClient.sendPDF(taxInvoice.Id);
        Test.stopTest();
    }
}