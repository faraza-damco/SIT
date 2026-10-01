@isTest
public class MergeBankLoanRatingOppTest {
    
    @isTest
    Public static void blrTestunit(){
        String INVOICEROLE = 'Name on Invoice';

        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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
        
        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'testGroup';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.ofac_check__c =true;
        accountRecord.Account_Status__c ='Active';
        accountRecord.OFAC_Document_Received__c=true;
        accountRecord.ISIN_Not_Available__c='Yes';
        accountRecord.Constitution_Type_Picklist__c='other';
        Insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;

        Billing_Date__c billing_Date = new Billing_Date__c(
        Instrument_type_1__c = 'Non Structured Finance',  
        Instrument_type_2__c = 'Rating - Bank Loan Rating',  
        Instrument_Type_3__c = 'Bank Loan Rating',           
        Instrument_Type_4__c = 'Bank Loan Rating Fresh',     
        Start_Date__c = Date.today(),         
        End_date__c = Date.newInstance(2099,04,01),            
        Alignment_Logic__c = '12 Months'                   
        );
        insert billing_Date;

        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id); 
        opportunityRecord.Instrument_type_1__c ='Non Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c ='Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c ='Bank Loan Rating Fresh';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.Bill_To__c =accountRecord.Id;
        opportunityRecord.Billing_Start_Date__c =null;
        opportunityRecord.Billing_End_Date__c =null;
        Insert opportunityRecord; 
        
        List<OpportunityContactRole> optyConRoles2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord.OFAC_Approved__c=true;
        //opportunityRecord.SOW_Effective_Date__c=system.today();
        update opportunityRecord;
        opportunityRecord.Proposed_Rating_Fee__c = 100;
        opportunityRecord.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord.StageName = 'Negotiation';
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Proposal Submission';
        opportunityRecord.ASF_Agreement_with_Client__c = 'In Absolute';
        update opportunityRecord;
        opportunityRecord.StageName = 'Executive Meeting';
        opportunityRecord.Minimum_ASF__c=null;
        update opportunityRecord;
        opportunityRecord.StageName='Commercial Head Approval Pending';
        opportunityRecord.No_Change_required_in_Commercial_clauses__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Commercial Head Approved';
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opportunityRecord;
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW / Subscription Form Sent';
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approval Pending';
        opportunityRecord.Approved_by_Commercial_Head__c = false;
        //opty.Comm_Legal_Approval_Status__c = 'Approved';
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        opportunityRecord.GST_Not_Applicable__c = false;
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        update opportunityRecord;
        Test.startTest();
        opportunityRecord.PR_Date__c = System.Today();
        Update opportunityRecord;
        Test.stopTest(); 
    }
    
   @isTest
    Public static void mmTestunit(){
        String INVOICEROLE = 'Name on Invoice';
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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

        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'testGroup';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.ofac_check__c =true;
        accountRecord.Account_Status__c ='Active';
        accountRecord.OFAC_Document_Received__c=true;
        accountRecord.ISIN_Not_Available__c='Yes';
        accountRecord.Constitution_Type_Picklist__c='other';
        Insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;

        Billing_Date__c billing_Date = new Billing_Date__c(
            Instrument_type_1__c = 'Structured Finance',  
            Instrument_type_2__c = 'Rating - Money Market (SF)',  
            Instrument_Type_3__c = 'Asset Backed Security',           
            Instrument_Type_4__c = 'Assignee Payout',     
            Start_Date__c = Date.today(),         
            End_date__c = Date.newInstance(2099,04,01),            
            Alignment_Logic__c = 'Financial Year'                   
            );
            insert billing_Date;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c ='Asset Backed Security';
        opportunityRecord.Instrument_type_4__c ='Assignee Payout';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.Bill_To__c =accountRecord.Id;
        opportunityRecord.Billing_Start_Date__c =null;
        opportunityRecord.Billing_End_Date__c =null;
        Insert opportunityRecord; 
        
        List<OpportunityContactRole> optyConRoles2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord.OFAC_Approved__c=true;
        //opportunityRecord.SOW_Effective_Date__c=system.today();
        update opportunityRecord;

        opportunityRecord.StageName = 'Negotiation';
        opportunityRecord.Proposed_Rating_Fee__c = 100;
        opportunityRecord.Proposed_Surveillance_Fee__c = 100;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Proposal Submission';
        opportunityRecord.ASF_Agreement_with_Client__c = 'In Absolute';
        update opportunityRecord;
        opportunityRecord.StageName = 'Executive Meeting';
        opportunityRecord.Minimum_ASF__c=null;
        update opportunityRecord;
        opportunityRecord.StageName='Commercial Head Approval Pending';
        opportunityRecord.No_Change_required_in_Commercial_clauses__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Commercial Head Approved';
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opportunityRecord;
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW / Subscription Form Sent';
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approval Pending';
        opportunityRecord.Approved_by_Commercial_Head__c = false;
        //opty.Comm_Legal_Approval_Status__c = 'Approved';
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        opportunityRecord.GST_Not_Applicable__c = false;
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        update opportunityRecord;
        
        Test.startTest();
        opportunityRecord.PR_Date__c = System.Today();
        Update opportunityRecord;
        Test.stopTest(); 
    }
    
    @isTest
    Public static void otherTestunit(){
        String INVOICEROLE = 'Name on Invoice';
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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

        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'testGroup';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.ofac_check__c =true;
        accountRecord.Account_Status__c ='Active';
        accountRecord.OFAC_Document_Received__c=true;
        accountRecord.ISIN_Not_Available__c='Yes';
        accountRecord.Constitution_Type_Picklist__c='other';
        Insert accountRecord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Non Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Others';
        opportunityRecord.Instrument_type_3__c ='Mutual Fund';
        opportunityRecord.Instrument_type_4__c ='Mutual Fund Rating';
        opportunityRecord.Scheme_Trust_Name__c ='Mutual Fund Rating';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.Bill_To__c =accountRecord.Id;
        opportunityRecord.Billing_Start_Date__c =null;
        opportunityRecord.Billing_End_Date__c =null;
        Insert opportunityRecord; 
        
        List<OpportunityContactRole> optyConRoles2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord.OFAC_Approved__c=true;
        //opportunityRecord.SOW_Effective_Date__c=system.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Negotiation';
        opportunityRecord.Proposed_Rating_Fee__c = 100;
        opportunityRecord.Proposed_Surveillance_Fee__c = 100;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Proposal Submission';
        opportunityRecord.ASF_Agreement_with_Client__c = 'In Absolute';
        update opportunityRecord;
        opportunityRecord.StageName = 'Executive Meeting';
        opportunityRecord.Minimum_ASF__c=null;
        update opportunityRecord;
        opportunityRecord.StageName='Commercial Head Approval Pending';
        opportunityRecord.No_Change_required_in_Commercial_clauses__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Commercial Head Approved';
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opportunityRecord;
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW / Subscription Form Sent';
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approval Pending';
        opportunityRecord.Approved_by_Commercial_Head__c = false;
        //opty.Comm_Legal_Approval_Status__c = 'Approved';
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        opportunityRecord.GST_Not_Applicable__c = false;
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        update opportunityRecord;
        
        
        Test.startTest();
        opportunityRecord.PR_Date__c = System.Today();
        Update opportunityRecord;
        Test.stopTest();  
    }  
    
    @isTest
    Public static void otherTestunit2(){
        String INVOICEROLE = 'Name on Invoice';
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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

        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'testGroup';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.ofac_check__c =true;
        accountRecord.Account_Status__c ='Active';
        accountRecord.OFAC_Document_Received__c=true;
        accountRecord.ISIN_Not_Available__c='Yes';
        accountRecord.Constitution_Type_Picklist__c='other';
        Insert accountRecord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Non Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Others';
        opportunityRecord.Instrument_type_3__c ='Others';
        opportunityRecord.Instrument_type_4__c ='Issuer Rating';
        opportunityRecord.Scheme_Trust_Name__c ='Issuer Rating';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.Bill_To__c =accountRecord.Id;
        opportunityRecord.Billing_Start_Date__c =null;
        opportunityRecord.Billing_End_Date__c =null;
        Insert opportunityRecord; 
        
        List<OpportunityContactRole> optyConRoles2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord.OFAC_Approved__c=true;
        //opportunityRecord.SOW_Effective_Date__c=system.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Negotiation';
        opportunityRecord.Proposed_Rating_Fee__c = 100;
        opportunityRecord.Proposed_Surveillance_Fee__c = 100;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Proposal Submission';
        opportunityRecord.ASF_Agreement_with_Client__c = 'In Absolute';
        update opportunityRecord;
        opportunityRecord.StageName = 'Executive Meeting';
        opportunityRecord.Minimum_ASF__c=null;
        update opportunityRecord;
        opportunityRecord.StageName='Commercial Head Approval Pending';
        opportunityRecord.No_Change_required_in_Commercial_clauses__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Commercial Head Approved';
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opportunityRecord;
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW / Subscription Form Sent';
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approval Pending';
        opportunityRecord.Approved_by_Commercial_Head__c = false;
        //opty.Comm_Legal_Approval_Status__c = 'Approved';
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        opportunityRecord.GST_Not_Applicable__c = false;
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        update opportunityRecord;
        
        
        Test.startTest();
        opportunityRecord.PR_Date__c = System.Today();
        Update opportunityRecord;
        Test.stopTest();  
    } 

    @isTest
    Public static void otherTestunit3(){
        String INVOICEROLE = 'Name on Invoice';
        Branch__c branch = ICRA_TestDataFactory.createBranchRecord('Gurugram');
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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

        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account', 'Issuer', branch.Id);
        accountRecord.Group_Name__c = 'testGroup';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.PAN_Number__c = 'AAFCR5512V';
        accountRecord.TAN_Number__c = 'DELC06851F';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.ofac_check__c =true;
        accountRecord.Account_Status__c ='Active';
        accountRecord.OFAC_Document_Received__c=true;
        accountRecord.ISIN_Not_Available__c='Yes';
        accountRecord.Constitution_Type_Picklist__c='other';
        Insert accountRecord;
        
        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512V1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity','New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c ='Non Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (Non-SF)';
        opportunityRecord.Instrument_type_3__c ='Commercial Paper/Certificate of Deposit/Short-term Debt';
        opportunityRecord.Instrument_type_4__c ='Commercial Paper';
        opportunityRecord.Scheme_Trust_Name__c ='Commercial Paper';
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        //opportunityRecord.ASF_Final_Amount__c = 100;
        opportunityRecord.CloseDate = System.Today();
        opportunityRecord.Mandate_Received_Date__c =System.today()-1;
        opportunityRecord.Bill_To__c =accountRecord.Id;
        opportunityRecord.Billing_Start_Date__c =null;
        opportunityRecord.Billing_End_Date__c =null;
        Insert opportunityRecord; 
        
        List<OpportunityContactRole> optyConRoles2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord.OFAC_Approved__c=true;
        //opportunityRecord.SOW_Effective_Date__c=system.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Negotiation';
        opportunityRecord.Proposed_Rating_Fee__c = 100;
        opportunityRecord.Proposed_Surveillance_Fee__c = 100;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Proposal Submission';
        opportunityRecord.ASF_Agreement_with_Client__c = 'In Absolute';
        update opportunityRecord;
        opportunityRecord.StageName = 'Executive Meeting';
        opportunityRecord.Minimum_ASF__c=null;
        update opportunityRecord;
        opportunityRecord.StageName='Commercial Head Approval Pending';
        opportunityRecord.No_Change_required_in_Commercial_clauses__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'Commercial Head Approved';
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        opportunityRecord.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opportunityRecord;
        opportunityRecord.Comm_Legal_Approval_Status__c='Approved';
        opportunityRecord.Approved_by_Commercial_Head__c=true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW / Subscription Form Sent';
        opportunityRecord.MPRA_Sent_Date__c = System.today();
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approval Pending';
        opportunityRecord.Approved_by_Commercial_Head__c = false;
        //opty.Comm_Legal_Approval_Status__c = 'Approved';
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        opportunityRecord.GST_Not_Applicable__c = false;
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        opportunityRecord.Defer_Billing_or_Exit_Case__c ='To Be Billed';
        update opportunityRecord;
        
        
        Test.startTest();
        opportunityRecord.PR_Date__c = System.Today();
        Update opportunityRecord;
        Test.stopTest();  
    } 
}