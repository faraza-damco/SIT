@isTest
public class Fee_calculation_Test {
    private static final String NEWBUSINESS = 'New Business';
    //private static final String TESTNAME1 = 'Pricing Test';
    private static final String ICGSTR = 'ICG';
    private static final String SECGSTR = 'SECG';
    private static final string oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
    private static final string survRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();
    private static final string SectorreRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('Sector Master').getRecordTypeId();
    private static final string LocationeRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('Location Master').getRecordTypeId();
    private static final string SFreRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('SF Master').getRecordTypeId();
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
    private static final String SURVEILLANCE = 'Surveillance'; 
    private static final String TESTNAME1 = 'ConRoleTest';   
    private static final String TESTNAME2 = 'TestNameRole';
    private static final String TESTNAME3 = 'TestRole';
    private static final String TESTNAME4 = 'NameRole';
    private static final String TESTNAME5 = 'Test 5';
    private static final String TESTNAME6 = 'Test 6';
    private static final String DESIGNATION = 'Asst Mngr';
    private static final String DESIGNATION2 = 'A M';
    private static final String EMAIL = 'test@testing.com';
    //Test setup
    @testSetup 
    static void testSetup(){
        
        Triggers_status__c tg_status= new Triggers_status__c();
        tg_status.OpportunityTrigger__c= false;
        tg_status.PromotorCompany__c= false;
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
        Acc.Ownership_Type_Picklist__c='Private - Domestic';
        acc.Classification__c = SECGSTR;
        acc.Related_Party__c='No';
        acc.Strick_Off_Data_from_MCA__c=System.today();
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
        opt.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opt.Customer_Fee_Type__c = 'Non - Cap';
        opt.StageName = 'L1 Meeting';
        opt.Mandate_Type__c = 'Fresh From Existing';
        //opt.Scheme_Trust_Name__c = 'Mutual Fund';
        opt.Bypass_Validation__c = true;
        opt.Billing_Start_Date__c = null;
        opt.Defer_Billing_or_Exit_Case__c = '';
        opt.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opt;

        Opportunity opt_DA = ICRA_TestDataFactory.creatOpportunity(TESTNAME6, NEWBUSINESS, acc.Id); 
        opt_DA.Instrument_type_1__c = 'Structured Finance';
        opt_DA.Instrument_type_2__c = 'Rating - Money Market (SF)';
        opt_DA.Instrument_type_3__c = 'Security Receipts';
        opt_DA.Instrument_type_4__c = 'Loss Estimation/Direct Assignment';
        opt_DA.Customer_Fee_Type__c = 'Non - Cap';
        opt_DA.StageName = 'L1 Meeting';
        opt_DA.Mandate_Type__c = 'Fresh From Existing';
        //opt.Scheme_Trust_Name__c = 'Mutual Fund';
        opt_DA.Bypass_Validation__c = true;
        opt_DA.Billing_Start_Date__c = null;
        opt_DA.Defer_Billing_or_Exit_Case__c = '';
        opt_DA.Non_Cooperation_Withdrawal_Reason__c='Other reasons';
        insert opt_DA;

        Test.startTest();
        Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME5, NEWBUSINESS, acc.Id); 
        opty.Instrument_type_1__c = 'Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Money Market (SF)';
        opty.Instrument_type_3__c = 'Security Receipts';
        opty.Instrument_type_4__c = 'Pass Through Certificates';
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
        opty.Closed_Won_Date__c = System.Today();
       
        Test.stopTest();
    }
    static testMethod void oppnonstruscegNonSF_FFF(){        
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SectorreRecordTypeId,true);
        Sector_Location_Master__c slm1=TestFactory.createsectorlocation(LocationeRecordTypeId,true);
        
       //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(SECGSTR,true);
        
        Account acc = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];

        // Create Opportunity
        Opportunity opportunityRecord1=TestFactory.CreateOpportunityNonstructured_FFF('ABCD Int',oppRecordTypeId,acc.Id,true);
         opportunityRecord1.CloseDate = system.today();
        //opportunityRecord1.StageName='OFAC Initiation';
        //update opportunityRecord1;
        opportunityRecord1.StageName='Negotiation';
        opportunityRecord1.Proposed_Rating_Fee__c=8000000;
        opportunityRecord1.Proposed_Surveillance_Fee__c=500000;
        update opportunityRecord1;
      
        
    }

    static testMethod void oppnonstruscegSF_FFF(){
        Account acc = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SFreRecordTypeId,false);
        slm.Target_ASF_Increase__c='100';
        slm.Min_IRF_Amount__c=20;
        slm.Min_ASF_Amount__c=10;
        slm.Min_ASF_Yield__c=1;
        insert slm;
       //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(SECGSTR,true);
        // Create Opportunity
        Opportunity opportunityRecord2=TestFactory.CreateOpportunitystructured_FFF('ABCDE Int',oppRecordTypeId,acc.Id,true);
        //opportunityRecord2.StageName = 'OFAC Initiation';
        opportunityRecord2.CloseDate = system.today();
        //update opportunityRecord2;
        opportunityRecord2.StageName='Negotiation';
        opportunityRecord2.Proposed_Rating_Fee__c=8000000;
        opportunityRecord2.Proposed_Surveillance_Fee__c=500000;
        update opportunityRecord2;
    }
    
      static testMethod void oppnonstruscegnonSF_FFE(){   
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SFreRecordTypeId,true);
        Account acc = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];
        Opportunity survRecord=TestFactory.CreateOpportunityNonstructured_FFF('ABCPH Int',survRecordTypeId,acc.Id,false);
        survRecord.ASF_Final_Amount__c =100000;
        survRecord.StageName ='Closed Won';
        survRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        survRecord.Instrument_type_4__c ='Bank Loan Rating';
        survRecord.CloseDate = system.today();
        insert survRecord;
       //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(SECGSTR,true);
        // Create Opportunity
        Opportunity opportunityRecord3=TestFactory.CreateOpportunityNonstructured_FFF('ABCDEF Int',oppRecordTypeId,acc.Id,False);
        opportunityRecord3.RecordTypeId =oppRecordTypeId;
        opportunityRecord3.Name = 'ABCDEF Int';
        opportunityRecord3.AccountId = acc.Id;
        opportunityRecord3.Customer_Fee_Type__c='Non - Cap';
        opportunityRecord3.Business_Segment__c = 'Rating';
        opportunityRecord3.Mandate_Type__c = 'Fresh From Existing';
        opportunityRecord3.Type_Tender__c = 'Non - Tender';
        opportunityRecord3.StageName ='L1 Meeting';
        opportunityRecord3.Conversion_Probability__c = 'High';
        opportunityRecord3.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRecord3.Instrument_type_1__c ='Non Structured Finance';
        opportunityRecord3.Instrument_type_2__c ='Rating - Bank Loan Rating';
        opportunityRecord3.Instrument_type_3__c ='Bank Loan Rating';
        opportunityRecord3.Instrument_type_4__c ='Bank Loan Rating Fresh';
        opportunityRecord3.VoD_in_crore__c =20;
        opportunityRecord3.CurrencyIsoCode = 'INR';
        opportunityRecord3.Mandate_Received_Date__c =System.today();
        opportunityRecord3.GST_Not_Applicable__c = false;
        opportunityRecord3.CloseDate= date.newInstance(2022, 03, 31);
        opportunityRecord3.CloseDate = system.today();
        Insert opportunityRecord3; 

        opportunityRecord3.StageName='Negotiation';
        opportunityRecord3.Proposed_Rating_Fee__c=8000000;
        opportunityRecord3.Proposed_Surveillance_Fee__c=500000;
        update opportunityRecord3;        
    }
    
     static testMethod void oppnonstruscegSF_FFE(){
        Account acc = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];
        //Then create a primary contact
		Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = acc.id;
        c.Email='ask123@gmail.com';
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Lucknow';
		c.MailingState = 'Uttar Pradesh';
		c.MailingPostalCode = '72201';
		insert c;
		System.debug('created primary contact');
        
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SFreRecordTypeId,false);
        slm.Target_ASF_Increase__c='100';
        slm.Min_IRF_Amount__c=20;
        slm.Min_ASF_Amount__c=10;
        slm.Min_ASF_Yield__c=1;
        insert slm;
        Opportunity opt = [SELECT Id, Name FROM Opportunity WHERE Name =:TESTNAME1 LIMIT 1];
        //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(SECGSTR,true);

         // create Existing Opportunity
        Opportunity opportunityRecordOld1=TestFactory.CreateOpportunitystructured_FFF('ABCSD Int',oppRecordTypeId,acc.Id,false);
        opportunityRecordOld1.RecordTypeId =oppRecordTypeId;
        opportunityRecordOld1.Name = 'ABCSD Int';
        opportunityRecordOld1.AccountId = acc.Id;
        opportunityRecordOld1.Customer_Fee_Type__c='Non - Cap';
        opportunityRecordOld1.Business_Segment__c = 'Rating';
        opportunityRecordOld1.Mandate_Type__c = 'Fresh From Fresh';
        opportunityRecordOld1.Type_Tender__c = 'Non - Tender';
        opportunityRecordOld1.StageName ='L1 Meeting';
        opportunityRecordOld1.Conversion_Probability__c = 'High';
        opportunityRecordOld1.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRecordOld1.Instrument_type_1__c ='Structured Finance';
        opportunityRecordOld1.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecordOld1.Instrument_type_3__c ='Security Receipts';
        opportunityRecordOld1.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRecordOld1.VoD_in_crore__c =100;
        opportunityRecordOld1.CurrencyIsoCode = 'INR';
        opportunityRecordOld1.Mandate_Received_Date__c =System.today();
        opportunityRecordOld1.GST_Not_Applicable__c = false;
        opportunityRecordOld1.Update_Opportunity_Checker__c=true;
        opportunityRecordOld1.Pricing_Approved_by_Business_Head__c=false;
        opportunityRecordOld1.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityRecordOld1.Pricing_Approved_by_CEO__c=false;
        opportunityRecordOld1.Pricing_Rejected_by_Business_Head__c=false;
        opportunityRecordOld1.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityRecordOld1.Pricing_Rejected_by_CEO__c=false;
        //opportunityRecordOld1.CloseDate= date.newInstance(2022, 03, 31);
        opportunityRecordOld1.CloseDate = system.today();
        Test.startTest();
        Insert opportunityRecordOld1;
        
        //Now update the OCR for the primary contact
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = opportunityRecordOld1.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Name on Invoice';
		insert ocr;

		System.debug('created opportunity contact role for primary');
        system.debug('opportunityRecordOld1 before update pro->'+opportunityRecordOld1);
        opportunityRecordOld1.StageName='Negotiation';
        opportunityRecordOld1.Proposed_Rating_Fee__c=800000;
        opportunityRecordOld1.Proposed_Surveillance_Fee__c=500000;
        update opportunityRecordOld1;

        // Create Opportunity
        Opportunity opportunityRec1=TestFactory.CreateOpportunitystructured_FFF('ABC Int1',oppRecordTypeId,acc.Id,False);
        opportunityRec1.RecordTypeId =oppRecordTypeId;
        opportunityRec1.Name = 'ABC Int1';
        opportunityRec1.AccountId = acc.Id;
        opportunityRec1.Customer_Fee_Type__c='Non - Cap';
        opportunityRec1.Business_Segment__c = 'Rating';
        opportunityRec1.Mandate_Type__c = 'Fresh From Existing';
        opportunityRec1.Type_Tender__c = 'Non - Tender';
        opportunityRec1.StageName ='L1 Meeting';
        opportunityRec1.Conversion_Probability__c = 'High';
        opportunityRec1.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRec1.Instrument_type_1__c ='Structured Finance';
        opportunityRec1.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRec1.Instrument_type_3__c ='Security Receipts';
        opportunityRec1.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRec1.VoD_in_crore__c =20;
        opportunityRec1.CurrencyIsoCode = 'INR';
        opportunityRec1.Mandate_Received_Date__c =System.today();
        opportunityRec1.GST_Not_Applicable__c = false;
        opportunityRec1.CloseDate= system.today();
        opportunityRec1.Pricing_Approved_by_Business_Head__c=false;
        opportunityRec1.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityRec1.Pricing_Approved_by_CEO__c=false;
        opportunityRec1.Pricing_Rejected_by_Business_Head__c=false;
        opportunityRec1.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityRec1.Pricing_Rejected_by_CEO__c=false;
        Insert opportunityRec1;  

        opportunityRec1.StageName='Negotiation';
        opportunityRec1.Proposed_Rating_Fee__c=800000;
        opportunityRec1.Proposed_Surveillance_Fee__c=500000;
        update opportunityRec1;
        system.debug('opportunityRec1->'+opportunityRec1);
        Test.stopTest();
    }
    
    
    static testMethod void oppnonstruIcgSF_FFF(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];
        //Then create a primary contact
		Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = acc.id;
        c.Email='ask123@gmail.com';
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Lucknow';
		c.MailingState = 'Uttar Pradesh';
		c.MailingPostalCode = '72201';
		insert c;
		System.debug('created primary contact');
        
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SFreRecordTypeId,false);
        slm.Target_ASF_Increase__c='100';
        slm.Min_IRF_Amount__c=20;
        slm.Min_ASF_Amount__c=10;
        slm.Min_ASF_Yield__c=1;
        insert slm;

       //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(ICGSTR,true);
        
         // create Existing Opportunity
        Opportunity opportunityOldRec1=TestFactory.CreateOpportunitystructured_FFF('ABCyu Int',oppRecordTypeId,acc.Id,false);
        opportunityOldRec1.RecordTypeId =oppRecordTypeId;
        opportunityOldRec1.Name = 'ABCyu Int';
        opportunityOldRec1.AccountId = acc.Id;
        opportunityOldRec1.Customer_Fee_Type__c='Non - Cap';
        opportunityOldRec1.Business_Segment__c = 'Rating';
        opportunityOldRec1.Mandate_Type__c = 'Fresh From Fresh';
        opportunityOldRec1.Type_Tender__c = 'Non - Tender';
        opportunityOldRec1.StageName ='L1 Meeting';
        opportunityOldRec1.Conversion_Probability__c = 'High';
        opportunityOldRec1.Likely_Initial_Rating_Fee__c =1000000;
        opportunityOldRec1.Instrument_type_1__c ='Structured Finance';
        opportunityOldRec1.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityOldRec1.Instrument_type_3__c ='Security Receipts';
        opportunityOldRec1.Instrument_type_4__c ='Pass Through Certificates';
        opportunityOldRec1.VoD_in_crore__c =100;
        opportunityOldRec1.CurrencyIsoCode = 'INR';
        opportunityOldRec1.Mandate_Received_Date__c =System.today();
        opportunityOldRec1.GST_Not_Applicable__c = false;
        opportunityOldRec1.CloseDate= date.newInstance(2022, 03, 31);
        opportunityOldRec1.CloseDate = system.today();      
        opportunityOldRec1.Pricing_Approved_by_Business_Head__c=false;
        opportunityOldRec1.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityOldRec1.Pricing_Approved_by_CEO__c=false;
        opportunityOldRec1.Pricing_Rejected_by_Business_Head__c=false;
        opportunityOldRec1.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityOldRec1.Pricing_Rejected_by_CEO__c=false;  
        Insert opportunityOldRec1;
        
        //Now update the OCR for the primary contact
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = opportunityOldRec1.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Name on Invoice';
		insert ocr;
		System.debug('created opportunity contact role for primary');
        
        system.debug('opportunityOldRec1 before update pro->'+opportunityOldRec1);
        opportunityOldRec1.StageName='Negotiation';
        opportunityOldRec1.Proposed_Rating_Fee__c=800000;
        opportunityOldRec1.Proposed_Surveillance_Fee__c=500000;
        update opportunityOldRec1;
        Test.stopTest();
    }
    
       static testMethod void oppnonstruIcgSF_FFE(){
        
        Account acc = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];
        Opportunity opty = [select id,AccountId,RecordType.Name, Sector__c, Client_Status__c, Customer_Fee_Type__c, Branch__c, Line_of_Business__c, Sub_Sector__c, Focus_Group__c, Name, Parent_Opportunity__c, 
                                  Business_Segment__c, StageName, Contact__c,Opportunity_Closed_Date__c,
                                  OwnerId, RecordTypeId, Instrument_type_1__c, Instrument_type_3__c,Instrument_type_2__c, Instrument_type_4__c, Remarks_If_any__c, Volume_of_Debt_1_amount__c,
                                  Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,Fiscal_Year__c,
                                  CurrencyIsoCode, Volume_of_Debt_Category__c, VoD_in_crore__c,Closed_Won_Date__c FROM Opportunity WHERE Name =:TESTNAME5 LIMIT 1];
        User usrLH2 = [SELECT Id, Name FROM User WHERE FirstName ='Test FirstName' LIMIT 1];
        List<Contact> conList = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId =:acc.Id AND (FirstName IN (:TESTNAME1, :TESTNAME2, :TESTNAME3, :TESTNAME4))];

        //Then create a primary contact
		Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = acc.id;
        c.Email='ask123@gmail.com';
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Lucknow';
		c.MailingState = 'Uttar Pradesh';
		c.MailingPostalCode = '72201';
		insert c;
		System.debug('created primary contact');
        
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SFreRecordTypeId,false);
        slm.Target_ASF_Increase__c='100';
        slm.Min_IRF_Amount__c=20;
        slm.Min_ASF_Amount__c=10;
        slm.Min_ASF_Yield__c=1;
        insert slm;
        
       //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(ICGSTR,true);
        
        // create Existing Opportunity
        Opportunity opportunityOldRec3=TestFactory.CreateOpportunitystructured_FFF('ABC2 Int',oppRecordTypeId,acc.Id,false);
        opportunityOldRec3.RecordTypeId =oppRecordTypeId;
        opportunityOldRec3.Name = 'ABC2 Int';
        opportunityOldRec3.AccountId = acc.Id;
        opportunityOldRec3.Customer_Fee_Type__c='Non - Cap';
        opportunityOldRec3.Business_Segment__c = 'Rating';
        opportunityOldRec3.Mandate_Type__c = 'Fresh From Fresh';
        opportunityOldRec3.Type_Tender__c = 'Non - Tender';
        opportunityOldRec3.StageName ='L1 Meeting';
        opportunityOldRec3.Conversion_Probability__c = 'High';
        opportunityOldRec3.Likely_Initial_Rating_Fee__c =1000000;
        opportunityOldRec3.Instrument_type_1__c ='Structured Finance';
        opportunityOldRec3.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityOldRec3.Instrument_type_3__c ='Security Receipts';
        opportunityOldRec3.Instrument_type_4__c ='Pass Through Certificates';
        opportunityOldRec3.VoD_in_crore__c =100;
        opportunityOldRec3.CurrencyIsoCode = 'INR';
        opportunityOldRec3.Mandate_Received_Date__c =System.today();
        opportunityOldRec3.GST_Not_Applicable__c = false;
        opportunityOldRec3.CloseDate= system.today();
        opportunityOldRec3.Pricing_Approved_by_Business_Head__c=false;
        opportunityOldRec3.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityOldRec3.Pricing_Approved_by_CEO__c=false;
        opportunityOldRec3.Pricing_Rejected_by_Business_Head__c=false;
        opportunityOldRec3.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityOldRec3.Pricing_Rejected_by_CEO__c=false;  
        Insert opportunityOldRec3;/** */
        
        //Now update the OCR for the primary contact
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = opportunityOldRec3.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Name on Invoice';
		insert ocr;
		System.debug('created opportunity contact role for primary');
        
        system.debug('opportunityOldRec3 before update pro->'+opportunityOldRec3);
        opportunityOldRec3.StageName='Negotiation';
        opportunityOldRec3.Proposed_Rating_Fee__c=800000;
        opportunityOldRec3.Proposed_Surveillance_Fee__c=500000;
        update opportunityOldRec3;

        Test.startTest();
        opty.OFAC_Approved__c=true;
        opty.SOW_Effective_Date__c=system.today();
        opty.Surveillance_Fee_Revision_Maximum_new__c='5%';
        //update opty;
        
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
        opty.OFAC_Approver__c=usrLH2.Id;
        opty.Commercial_Head__c=usrLH2.Id;
        opty.Rolling_and_Date_Alignmnet__c = true;
        //update opty;
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
        opty.Proposed_Rating_Fee__c=1000;
        opty.Proposed_Surveillance_Fee__c=1000;
        update opty;
        opty.StageName = 'Discount Approved';
        opty.Statement_of_Work_No__c = '12';
        opty.Mandate_Received_Date__c= System.Today()-1;
        opty.Pricing_Not_Auto_Approved__c= false;
        opty.Pricing_Approved_by_Commercial_Head__c=true;
        opty.Pricing_Approved_by_CEO__c =true;
        opty.No_Change_required_in_Commercial_clauses__c=true;
        update opty;
        opty.StageName = 'Proposal Submission';
        opty.ASF_Agreement_with_Client__c = 'In Absolute';
        opty.Minimum_ASF__c=null;
        update opty;
        opty.StageName = 'Executive Meeting';
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
        opty.StageName = 'Internal Control Approval';
        update opty;
        opty.StageName = 'Closed Won';
        opty.CloseDate = System.Today();
        opty.Closed_Won_Date__c = System.Today().addDays(-100);
        update opty;
        System.Debug('opty after all updates->'+opty);

        // Create Opportunity
        Opportunity opportunityRec7=TestFactory.CreateOpportunitystructured_FFF('ABC3 Int1',oppRecordTypeId,acc.Id,False);
        opportunityRec7.RecordTypeId =oppRecordTypeId;
        opportunityRec7.Name = 'ABC3 Int1';
        opportunityRec7.AccountId = acc.Id;
        opportunityRec7.Customer_Fee_Type__c='Non - Cap';
        opportunityRec7.Business_Segment__c = 'Rating';
        opportunityRec7.Mandate_Type__c = 'Fresh From Existing';
        opportunityRec7.Type_Tender__c = 'Non - Tender';
        opportunityRec7.StageName ='L1 Meeting';
        opportunityRec7.Conversion_Probability__c = 'High';
        opportunityRec7.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRec7.Instrument_type_1__c ='Structured Finance';
        opportunityRec7.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRec7.Instrument_type_3__c ='Security Receipts';
        opportunityRec7.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRec7.VoD_in_crore__c =20;
        opportunityRec7.CurrencyIsoCode = 'INR';
        opportunityRec7.Mandate_Received_Date__c =System.today();
        opportunityRec7.GST_Not_Applicable__c = false;
        opportunityRec7.CloseDate = system.today();
        opportunityRec7.Pricing_Approved_by_Business_Head__c=false;
        opportunityRec7.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityRec7.Pricing_Approved_by_CEO__c=false;
        opportunityRec7.Pricing_Rejected_by_Business_Head__c=false;
        opportunityRec7.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityRec7.Pricing_Rejected_by_CEO__c=false;  
        Insert opportunityRec7;  

        opportunityRec7.StageName='Negotiation';
        opportunityRec7.Proposed_Rating_Fee__c=800000;
        opportunityRec7.Proposed_Surveillance_Fee__c=500000;
        update opportunityRec7;
        system.debug('opportunityRec7->'+opportunityRec7);
        Test.stopTest();
    }

       static testMethod void oppnonstruIcgSF_FFE_DA(){
        
        Account acco = [SELECT Id FROM Account WHERE Name =:TESTNAME1 LIMIT 1];
        Opportunity opty2 = [select id,AccountId,RecordType.Name, Sector__c, Client_Status__c, Customer_Fee_Type__c, Branch__c, Line_of_Business__c, Sub_Sector__c, Focus_Group__c, Name, Parent_Opportunity__c, 
                                  Business_Segment__c, StageName, Contact__c,Opportunity_Closed_Date__c,
                                  OwnerId, RecordTypeId, Instrument_type_1__c, Instrument_type_3__c,Instrument_type_2__c, Instrument_type_4__c, Remarks_If_any__c, Volume_of_Debt_1_amount__c,
                                  Volume_of_Debt_2_Amount__c, Volume_of_Debt_3_amount__c, Volume_of_Debt_4_amount__c, Volume_of_Debt_5_amount__c,Initial_Rating_Fee_as_per_Agreement_BPS__c,ASF_as_per_Agreement_BPS__c,Fiscal_Year__c,
                                  CurrencyIsoCode, Volume_of_Debt_Category__c, VoD_in_crore__c,Closed_Won_Date__c FROM Opportunity WHERE Name =:TESTNAME6 LIMIT 1];
        User usrLH = [SELECT Id, Name FROM User WHERE FirstName ='Test FirstName' LIMIT 1];
        List<Contact> conList = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId =:acco.Id AND (FirstName IN (:TESTNAME1, :TESTNAME2, :TESTNAME3, :TESTNAME4))];

        //Then create a primary contact
		Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = acco.id;
        c.Email='ask123@gmail.com';
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Lucknow';
		c.MailingState = 'Uttar Pradesh';
		c.MailingPostalCode = '72201';
		insert c;
		System.debug('created primary contact');
        
        // create Sector Location Master
        Sector_Location_Master__c slm=TestFactory.createsectorlocation(SFreRecordTypeId,false);
        slm.Target_ASF_Increase__c='100';
        slm.Min_IRF_Amount__c=20;
        slm.Min_ASF_Amount__c=10;
        slm.Min_ASF_Yield__c=1;
        insert slm;
        
       //create Pricing_Structure__c
        Pricing_Structure__c prs=TestFactory.createPricestructure(ICGSTR,true);
        
        // create Existing Opportunity
        Opportunity opportunityOldRec4=TestFactory.CreateOpportunitystructured_FFF('ABC6 Int',oppRecordTypeId,acco.Id,false);
        opportunityOldRec4.RecordTypeId =oppRecordTypeId;
        opportunityOldRec4.Name = 'ABC6 Int';
        opportunityOldRec4.AccountId = acco.Id;
        opportunityOldRec4.Customer_Fee_Type__c='Non - Cap';
        opportunityOldRec4.Business_Segment__c = 'Rating';
        opportunityOldRec4.Mandate_Type__c = 'Fresh From Fresh';
        opportunityOldRec4.Type_Tender__c = 'Non - Tender';
        opportunityOldRec4.StageName ='L1 Meeting';
        opportunityOldRec4.Conversion_Probability__c = 'High';
        opportunityOldRec4.Likely_Initial_Rating_Fee__c =1000000;
        opportunityOldRec4.Instrument_type_1__c ='Structured Finance';
        opportunityOldRec4.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityOldRec4.Instrument_type_3__c ='Security Receipts';
        opportunityOldRec4.Instrument_type_4__c ='Loss Estimation/Direct Assignment';
        opportunityOldRec4.VoD_in_crore__c =100;
        opportunityOldRec4.CurrencyIsoCode = 'INR';
        opportunityOldRec4.Mandate_Received_Date__c =System.today();
        opportunityOldRec4.GST_Not_Applicable__c = false;
        opportunityOldRec4.CloseDate= system.today();
        opportunityOldRec4.Pricing_Approved_by_Business_Head__c=false;
        opportunityOldRec4.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityOldRec4.Pricing_Approved_by_CEO__c=false;
        opportunityOldRec4.Pricing_Rejected_by_Business_Head__c=false;
        opportunityOldRec4.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityOldRec4.Pricing_Rejected_by_CEO__c=false;  
        Insert opportunityOldRec4;
        
        //Now update the OCR for the primary contact
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = opportunityOldRec4.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Name on Invoice';
		insert ocr;
		System.debug('created opportunity contact role for primary');
        
        system.debug('opportunityOldRec4 before update pro->'+opportunityOldRec4);
        opportunityOldRec4.StageName='Negotiation';
        opportunityOldRec4.Proposed_Rating_Fee__c=800000;
        opportunityOldRec4.Proposed_Surveillance_Fee__c=500000;
        update opportunityOldRec4;

        Test.startTest();
        opty2.OFAC_Approved__c=true;
        opty2.SOW_Effective_Date__c=system.today();
        opty2.Surveillance_Fee_Revision_Maximum_new__c='5%';
        //update opty2;
        
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = conList[0].Id,
                OpportunityId = opty2.Id,
                IsPrimary = true,
                Role = EMAILROLE),
                new OpportunityContactRole(
                    ContactId = conList[4].Id,
                    OpportunityId = opty2.Id,
                    Role = PROPOSALPRIMARY_ROLE),
                new OpportunityContactRole(
                    ContactId = conList[1].Id,
                    OpportunityId = opty2.Id,
                    IsPrimary = true,
                    Rollover_Check__c = true,
                    Role = INVOICEROLE)};
                        try{
                            Insert optyConRoles;//Expecting No Email on Contact Error
                        }catch(Exception ex){
                            System.debug('%%%Exception- '+ex.getMessage());
                        }
        
        opty2.OFAC_Approved__c=true;
        opty2.OFAC_Approver__c=usrLH.Id;
        opty2.Commercial_Head__c=usrLH.Id;
        opty2.Rolling_and_Date_Alignmnet__c = true;
        //update opty2;
        opty2.StageName = 'Negotiation';
        opty2.Pricing_Not_Auto_Approved__c=true;
        opty2.Proposed_Rating_Fee__c=1000;
        opty2.Proposed_Surveillance_Fee__c=1000; 
        opty2.Pricing_Approved_by_Business_Head__c=true;
        opty2.Approved_by_Commercial_Head__c=true;
        opty2.Approved_by_MD_CEO_Group__c=true;
        opty2.Pricing_Approved_by_CEO__c=true;
        opty2.Pricing_Approved_by_Commercial_Head__c=true;
        opty2.BD_Approve__c=true;
        opty2.Billing_Approval__c='Accept';
        opty2.Write_off_Approval__c='Accept';
        opty2.Pricing_Auto_Approved__c=true;
        opty2.Proposed_Rating_Fee__c=1000;
        opty2.Proposed_Surveillance_Fee__c=1000;
        update opty2;
        opty2.StageName = 'Discount Approved';
        opty2.Statement_of_Work_No__c = '12';
        opty2.Mandate_Received_Date__c= System.Today()-1;
        opty2.Pricing_Not_Auto_Approved__c= false;
        opty2.Pricing_Approved_by_Commercial_Head__c=true;
        opty2.Pricing_Approved_by_CEO__c =true;
        opty2.No_Change_required_in_Commercial_clauses__c=true;
        update opty2;
        opty2.StageName = 'Proposal Submission';
        opty2.ASF_Agreement_with_Client__c = 'In Absolute';
        opty2.Minimum_ASF__c=null;
        update opty2;
        opty2.StageName = 'Executive Meeting';
        update opty2;
        opty2.StageName='Commercial Head Approval Pending';
        opty2.No_Change_required_in_Commercial_clauses__c = true;
        update opty2;
        opty2.StageName = 'Commercial Head Approved';
        opty2.Comm_Legal_Approval_Status__c='Approved';
        opty2.Approved_by_Commercial_Head__c=true;
        opty2.MPRA_Sent_Date__c = System.today();
        opty2.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opty2;
        opty2.Comm_Legal_Approval_Status__c='Approved';
        opty2.Approved_by_Commercial_Head__c=true;
        update opty2;
        opty2.StageName = 'MPRA & SoW / Subscription Form Sent';
        opty2.MPRA_Sent_Date__c = System.today();
        update opty2;
        opty2.StageName = 'Legal Approval Pending';
        opty2.Approved_by_Commercial_Head__c = false;
        update opty2;
        opty2.StageName = 'Legal Approved';
        opty2.Legal_Compliance_Approval__c = true;
        update opty2;
        opty2.StageName = 'MPRA & SoW /  Subscription Form Received';
        opty2.Mandate_Received_Date__c = System.today()-1;
        update opty2;
        opty2.StageName = 'Internal Control Approval';
        update opty2;
        opty2.StageName = 'Closed Won';
        opty2.CloseDate = System.Today();
        opty2.Closed_Won_Date__c = System.Today().addDays(-100);
        update opty2;
        System.Debug('opty2 after all updates->'+opty2);

        // Create Opportunity
        Opportunity opportunityRecord=TestFactory.CreateOpportunitystructured_FFF('ABC Int12',oppRecordTypeId,acco.Id,False);
        opportunityRecord.RecordTypeId =oppRecordTypeId;
        opportunityRecord.Name = 'ABC Int12 ';
        opportunityRecord.AccountId = acco.Id;
        opportunityRecord.Customer_Fee_Type__c='Non - Cap';
        opportunityRecord.Business_Segment__c = 'Rating';
        opportunityRecord.Mandate_Type__c = 'Fresh From Existing';
        opportunityRecord.Type_Tender__c = 'Non - Tender';
        opportunityRecord.StageName ='L1 Meeting';
        opportunityRecord.Conversion_Probability__c = 'High';
        opportunityRecord.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRecord.Instrument_type_1__c ='Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c ='Security Receipts';
        opportunityRecord.Instrument_type_4__c ='Loss Estimation/Direct Assignment';
        opportunityRecord.VoD_in_crore__c =20;
        opportunityRecord.CurrencyIsoCode = 'INR';
        opportunityRecord.Mandate_Received_Date__c =System.today();
        opportunityRecord.GST_Not_Applicable__c = false;
        opportunityRecord.CloseDate = system.today();
        opportunityRecord.Pricing_Approved_by_Business_Head__c=false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=false;
        opportunityRecord.Pricing_Approved_by_CEO__c=false;
        opportunityRecord.Pricing_Rejected_by_Business_Head__c=false;
        opportunityRecord.Pricing_Rejected_by_Commercial_Head__c=false;
        opportunityRecord.Pricing_Rejected_by_CEO__c=false;  
        Insert opportunityRecord;  

        opportunityRecord.StageName='Negotiation';
        opportunityRecord.Proposed_Rating_Fee__c=800000;
        opportunityRecord.Proposed_Surveillance_Fee__c=500000;
        update opportunityRecord;
        system.debug('opportunityRecord->'+opportunityRecord);
        Test.stopTest();
    }
}