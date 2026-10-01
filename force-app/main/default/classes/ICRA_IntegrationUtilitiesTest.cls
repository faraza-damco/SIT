@isTest
public with sharing class ICRA_IntegrationUtilitiesTest {
    private static final String INVOICEROLE = 'Name on Invoice';
    @isTest
    public static void IntegrationUtilitiesTest() {
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        insert businessSector;

        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountRecord.OFAC_Document_Received__c = true;
        accountRecord.Related_Party__c = 'No';
        accountRecord.Group_Name__c = 'Test Group';
        accountRecord.OFAC_Check__c = true;
        accountRecord.Account_Status__c = 'Active';
        //accountRecord.BillingCity = 'Delhi';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.Account_Classification__c = 'SEZ';
        accountRecord.PAN_Number__c = 'ABCDE1234A';
        accountRecord.Constitution_Type_Picklist__c = 'Other';
        insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '06ABCDE1234A1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;

        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecord.ASF_Final_Amount__c = 10; 
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.OFAC_Approver__c = username.Id;
        opportunityRecord.OFAC_Approved__c = true;
        opportunityRecord.GST_Not_Applicable__c = false;
        opportunityRecord.PAN_not_applicable__c = false;
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.Billing_Start_Date__c = null;        
        insert opportunityRecord;
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
        
        opportunityRecord.Proposed_Rating_Fee__c = 5;
        opportunityRecord.Proposed_Surveillance_Fee__c = 5;
        opportunityRecord.StageName = 'Negotiation';
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        update opportunityRecord;
        opportunityRecord.Statement_of_Work_No__c = '12';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        opportunityRecord.No_Change_required_in_Commercial_clauses__c=true;
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
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        update opportunityRecord;
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;

        Test.startTest();
        ICRA_IntegrationUtilities.createJSONRequest(invoiceRecord.Id);
        ICRA_IntegrationUtilities.CancelJson(invoiceRecord.IRN_Number__c,null);
        Test.stopTest();
    }

    @isTest
    public static void IntegrationUtilitiesTest1() {
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        List<Invoice_Line_Item__c> linelist = new List<Invoice_Line_Item__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        insert businessSector;
        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountRecord.OFAC_Document_Received__c = true;
        accountRecord.Related_Party__c = 'No';
        accountRecord.Group_Name__c = 'Test Group';
        accountRecord.OFAC_Check__c = true;
        accountRecord.Account_Status__c = 'Active';
        accountRecord.BillingCity = 'Delhi';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.Account_Classification__c = 'SEZ';
        accountRecord.PAN_Number__c = 'ABCDE1234A';
        accountRecord.Constitution_Type_Picklist__c = 'Other';
        insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '06ABCDE1234A1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;
        
        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;

        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecord.ASF_Final_Amount__c = 10; 
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.OFAC_Approver__c = username.Id;
        opportunityRecord.OFAC_Approved__c = true;
        opportunityRecord.GST_Not_Applicable__c = false;
        opportunityRecord.PAN_not_applicable__c = false;
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.Billing_Start_Date__c = null; 
        insert opportunityRecord;
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
        
        opportunityRecord.Proposed_Rating_Fee__c = 5;
        opportunityRecord.Proposed_Surveillance_Fee__c = 5;
        opportunityRecord.StageName = 'Negotiation';
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        update opportunityRecord;
        opportunityRecord.Statement_of_Work_No__c = '12';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        opportunityRecord.No_Change_required_in_Commercial_clauses__c=true;
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
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        update opportunityRecord;
        
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord;
        
        Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id,opportunityRecord.Id);
        linelist.add(lineRecord);

        Test.startTest();
        ICRA_IntegrationUtilities.lineJSON(linelist);
        Test.stopTest();
    }

    @isTest
    public static void IntegrationUtilitiesTest2() {
        User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
        List<Invoice_Line_Item__c> linelist = new List<Invoice_Line_Item__c>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
        insert businessSector;
        Account accountRecord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountRecord.OFAC_Document_Received__c = true;
        accountRecord.Related_Party__c = 'No';
        accountRecord.Group_Name__c = 'Test Group';
        accountRecord.OFAC_Check__c = true;
        accountRecord.Account_Status__c = 'Active';
        accountRecord.Business_Sector__c = businessSector.Id;
        accountRecord.BillingCity = 'Delhi';
        accountRecord.ShippingCity ='Delhi';
        accountRecord.ShippingStreet ='Office No. 01, 28th Floor';
        accountRecord.ShippingPostalCode ='110001';
        accountRecord.ShippingState ='Delhi';
        accountRecord.ShippingCountry ='India';
        accountRecord.Account_Classification__c = 'SEZ';
        accountRecord.PAN_Number__c = 'ABCDE1234A';
        accountRecord.Constitution_Type_Picklist__c = 'Other';
        insert accountRecord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountRecord.Id;           
        billingAddr.Billing_City__c = 'Gurgaon';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Haryana';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '06ABCDE1234A1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        accountRecord.Billing_Address__c= billingAddr.Id;
        update accountRecord;

        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= new List<Transaction_Details_Sub_Type__c>();
        Transaction_Details_Sub_Type__c trans_Det_Sub = new Transaction_Details_Sub_Type__c();
        trans_Det_Sub.Account_Classification__c='SEZ';
        trans_Det_Sub.TranDtls_SupTyp__c='B2B';
        transDetailSubTypeList.add(trans_Det_Sub);
        insert transDetailSubTypeList;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('Test Contact', 'Yes', 'Account Contact', accountRecord.Id);
        insert contactRecord;
        
        Opportunity opportunityRecord = ICRA_TestDataFactory.creatOpportunity('Test Opportunity', 'New Business', accountRecord.Id);
        opportunityRecord.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c = 'Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c = 'Bank Loan Rating Fresh';  
        opportunityRecord.ASF_Final_Amount__c = 10; 
        opportunityRecord.StageName = 'L1 Meeting';
        opportunityRecord.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord.OFAC_Approver__c = username.Id;
        opportunityRecord.OFAC_Approved__c = true;
        opportunityRecord.GST_Not_Applicable__c = false;
        opportunityRecord.PAN_not_applicable__c = false;
        opportunityRecord.Defer_Billing_or_Exit_Case__c = '';
        opportunityRecord.Billing_Start_Date__c = null; 
        insert opportunityRecord;
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
        opportunityRecord.Proposed_Rating_Fee__c = 5;
        opportunityRecord.Proposed_Surveillance_Fee__c = 5;
        opportunityRecord.StageName = 'Negotiation';
        update opportunityRecord;
        opportunityRecord.StageName = 'Discount Approved';
        update opportunityRecord;
        opportunityRecord.Statement_of_Work_No__c = '12';
        opportunityRecord.Mandate_Received_Date__c= System.Today()-1;
        opportunityRecord.Pricing_Not_Auto_Approved__c= false;
        opportunityRecord.Pricing_Approved_by_Commercial_Head__c=true;
        opportunityRecord.Pricing_Approved_by_CEO__c =true;
        opportunityRecord.No_Change_required_in_Commercial_clauses__c=true;
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
        update opportunityRecord;
        opportunityRecord.StageName = 'Legal Approved';
        opportunityRecord.Legal_Compliance_Approval__c = true;
        update opportunityRecord;
        opportunityRecord.StageName = 'MPRA & SoW /  Subscription Form Received';
        opportunityRecord.Mandate_Received_Date__c = System.today()-1;
        update opportunityRecord;
        opportunityRecord.StageName = 'Internal Control Approval';
        update opportunityRecord;
        opportunityRecord.StageName = 'Closed Won';
        update opportunityRecord;
        
        
        
        Invoice__c invoiceRecord2 = ICRA_TestDataFactory.createInvoice('Invoice',opportunityRecord.Id,null,null);
        insert invoiceRecord2;
       
        Invoice_Line_Item__c lineRecord = ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord2.Id,opportunityRecord.Id);
        linelist.add(lineRecord);
        
        Invoice__c invoiceRecord = ICRA_TestDataFactory.createInvoice('Credit Note',opportunityRecord.Id,null,null);
        invoiceRecord.Invoice_No__c = invoiceRecord2.ID;
        insert invoiceRecord;
        
        Test.startTest();
        ICRA_IntegrationUtilities.createJSONRequest(invoiceRecord2.Id);
        ICRA_IntegrationUtilities.createJSONRequest(invoiceRecord.Id);
        Test.stopTest();
    }
}