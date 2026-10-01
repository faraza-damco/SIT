@isTest
public class MultiRecordsApprovalController_full_Test {
    
    private static final String TESTNAME1 = 'ConRoleTest';
    private static final String SURVEILLANCE = 'Surveillance'; 
    private static final String ISSUER = 'Issuer';
    private static final String INVOICEROLE = 'Name on Invoice';
    
    testMethod static void test_meth() {
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;  
        
        System.runAs(usrLH){
            
            Triggers_status__c tg_status= new Triggers_status__c();
            tg_status.OpportunityTrigger__c= false;
            tg_status.PromotorCompany__c= false;
            tg_status.Fee_Calculation__c= false;
            insert tg_status;
            
            Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
            
            Business_Sector__c businessSector = new Business_Sector__c();
            businessSector.Name = 'Infrastructure';
            businessSector.Business_Head__c =  usrLH.Id; 
            businessSector.OFAC_Approver__c = usrLH.Id; 
            businessSector.Opportunity_Checker__c = usrLH.Id;
            businessSector.ICRA_Branch__c = branchRecord.Id;
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
            billingAddr.Tax_GST_Classification__c = 'Non-SEZ';
            insert billingAddr;
            
            Opportunity opp = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, SURVEILLANCE, acc.Id); 
            opp.Instrument_type_1__c = 'Non Structured Finance';
            opp.Instrument_type_2__c = 'Rating - Bank Loan Rating';
            opp.Instrument_type_3__c = 'Bank Loan Rating';
            opp.Instrument_type_4__c = 'Bank Loan Rating';
            opp.Customer_Fee_Type__c = 'Non - Cap';
            opp.is_Primary_Not_Present__c = false;
            opp.StageName = 'L1 Meeting';
            opp.Mandate_Type__c = 'Fresh From Existing';
            opp.Bypass_Validation__c = true;
            opp.Billing_Start_Date__c = null;
            opp.Commercial_Head__c = usrLH.id;
            opp.CloseDate = date.today();
            opp.Invoice_Generation_Date__c = date.today();
            opp.Non_Cooperation_Withdrawal_Reason__c = 'Others';
            insert opp;
            
            opp.Reason__c = 'Exit';
            opp.Comment__c = 'Test Exit';
            opp.Defer_Billing_or_Exit_Case__c = 'Exit Case';
            opp.StageName = 'Negotiation ';
            Update opp;
            opp.StageName = 'Discount Approved ';
            opp.Proposed_Surveillance_Fee__c = 12334;
            opp.Proposed_Rating_Fee__c = 1234;
            update opp;
            opp.StageName = 'Closed Won';
            opp.Reason__c = '';
            opp.Defer_Billing_or_Exit_Case__c='To Be Billed';
            opp.Amount = 122333;
            update opp;
            
            Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', acc.Id); 
            insert contactRecord;
            
            List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
                new OpportunityContactRole(
                    ContactId = contactRecord.Id,
                    OpportunityId = opp.Id,
                    IsPrimary = true,
                    Role = INVOICEROLE)};
                        Insert optyConRoles;
            
            Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opp.Id, null,'Proforma Invoice');
            invoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            invoiceRecord.Finance_Email_ID__c=usrLH.id;
            insert invoiceRecord;
            Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opp.Id);
            invoiceLineRecord_A.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A;
            
     
            
            
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(invoiceRecord.id);
            req1.setSubmitterId(usrLH.Id); 
            req1.setProcessDefinitionNameOrId('Proforma_Invoice_Approval_Process');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            
                   /*Invoice__c invoiceRecord1  = ICRA_TestDataFactory.createInvoice('Invoice',opp.Id, null,'Initiate Tax Invoice');
            invoiceRecord1.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            invoiceRecord1.Finance_Email_ID__c=usrLH.id;
            insert invoiceRecord1;
            invoiceRecord1.Invoice_Status__c = 'Tax Invoice';
            update invoiceRecord1;
            Invoice_Line_Item__c invoiceLineRecord_A1 =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord1.Id, opp.Id);
            invoiceLineRecord_A1.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A1;*/
            
            List<String> ApprId_1st = new List<String>{invoiceRecord.Id};
            MultiRecordsApprovalController_full.processRecordsBatchExecute(ApprId_1st, 'Approved', 'test reject', invoiceRecord.id); 
            
            invoiceRecord.Invoice_Status__c = 'Initiate Tax Invoice';
            update invoiceRecord;
            
          /*  Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
            req2.setComments('Submitting request for approval.');
            req2.setObjectId(invoiceRecord.id);
            req2.setSubmitterId(usrLH.Id); 
            req2.setProcessDefinitionNameOrId('Tax_Invoice_Approval_Process');
            req2.setSkipEntryCriteria(true);
            Approval.ProcessResult results = Approval.process(req2);*/
            
            Invoice__c creditNoteInvoiceRecord  = ICRA_TestDataFactory.createInvoice('Credit Note',opp.Id, invoiceRecord.id,'Initiate GST Credit Note');
            creditNoteInvoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            creditNoteInvoiceRecord.Finance_Email_ID__c=usrLH.id;
            creditNoteInvoiceRecord.Bypass_Validation__c=true;
            creditNoteInvoiceRecord.Revised_agreed_amount__c=0;
            insert creditNoteInvoiceRecord;
           /* Invoice_Line_Item__c invoiceLineRecord_A2 =  ICRA_TestDataFactory.createInvoiceLineItem(creditNoteInvoiceRecord.Id, opp.Id);
            invoiceLineRecord_A2.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A2;*/
            
            Transaction_Log__c tr = new Transaction_Log__c();
            tr.Error_Message__c = 'test Invoice Error';
            tr.Invoice__c = invoiceRecord.id;
            Insert tr;
            Transaction_Log__c tr1 = new Transaction_Log__c();
            tr1.Error_Message__c = 'test opp Error';
            tr1.Opportunity__c = opp.id;
            Insert tr1;
            Transaction_Log__c tr2 = new Transaction_Log__c();
            tr2.Error_Message__c = 'test credit Note Invoice Error';
            tr2.Invoice__c = creditNoteInvoiceRecord.id;
            Insert tr2;
            
            
            /*
            1. Create an approval request for the account
            2. Submit on behalf of a specific submitter
            3. Submit the record to specific process and skip the criteria evaluation
            */
            
            
              
            //MultiRecordsApprovalController_full.getSubmittedRecords();
            
            //MultiRecordsApprovalController_full.getBatchStatus();
            
            List<String> ApprId_2st = new List<String>{opp.Id};
            MultiRecordsApprovalController_full.processRecordsBatchExecute(ApprId_2st, 'Approved', 'test reject', opp.id); 
            
            List<String> ApprId_lst = new List<String>{opp.Id};
                
                }
        
        
    }
    
    testMethod static void test_meth3() {
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;  
        
        System.runAs(usrLH){
            
            Triggers_status__c tg_status= new Triggers_status__c();
            tg_status.OpportunityTrigger__c= false;
            tg_status.PromotorCompany__c= false;
            tg_status.Fee_Calculation__c= false;
            insert tg_status;
            
            Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
            
            Business_Sector__c businessSector = new Business_Sector__c();
            businessSector.Name = 'Infrastructure';
            businessSector.Business_Head__c =  usrLH.Id; 
            businessSector.OFAC_Approver__c = usrLH.Id; 
            businessSector.Opportunity_Checker__c = usrLH.Id;
            businessSector.ICRA_Branch__c = branchRecord.Id;
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
            billingAddr.Tax_GST_Classification__c = 'Non-SEZ';
            insert billingAddr;
            
            Opportunity opp = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, SURVEILLANCE, acc.Id); 
            opp.Instrument_type_1__c = 'Non Structured Finance';
            opp.Instrument_type_2__c = 'Rating - Bank Loan Rating';
            opp.Instrument_type_3__c = 'Bank Loan Rating';
            opp.Instrument_type_4__c = 'Bank Loan Rating';
            opp.Customer_Fee_Type__c = 'Non - Cap';
            opp.is_Primary_Not_Present__c = false;
            opp.StageName = 'L1 Meeting';
            opp.Mandate_Type__c = 'Fresh From Existing';
            opp.Bypass_Validation__c = true;
            opp.Billing_Start_Date__c = null;
            opp.Commercial_Head__c = usrLH.id;
            opp.CloseDate = date.today();
            opp.Invoice_Generation_Date__c = date.today();
            opp.Non_Cooperation_Withdrawal_Reason__c = 'Others';
            insert opp;
            
            opp.Reason__c = 'Exit';
            opp.Comment__c = 'Test Exit';
            opp.Defer_Billing_or_Exit_Case__c = 'Exit Case';
            opp.StageName = 'Negotiation ';
            Update opp;
            opp.StageName = 'Discount Approved ';
            opp.Proposed_Surveillance_Fee__c = 12334;
            opp.Proposed_Rating_Fee__c = 1234;
            update opp;
            opp.StageName = 'Closed Won';
            opp.Reason__c = '';
            opp.Defer_Billing_or_Exit_Case__c='To Be Billed';
            opp.Amount = 122333;
            update opp;
            
            Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', acc.Id); 
            insert contactRecord;
            
            List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
                new OpportunityContactRole(
                    ContactId = contactRecord.Id,
                    OpportunityId = opp.Id,
                    IsPrimary = true,
                    Role = INVOICEROLE)};
                        Insert optyConRoles;
            
            Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opp.Id, null,'Proforma Invoice');
            invoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            invoiceRecord.Finance_Email_ID__c=usrLH.id;
            insert invoiceRecord;
            Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opp.Id);
            invoiceLineRecord_A.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A;
            
     
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(invoiceRecord.id);
            req1.setSubmitterId(usrLH.Id); 
            req1.setProcessDefinitionNameOrId('Proforma_Invoice_Approval_Process');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
                        

            Transaction_Log__c tr = new Transaction_Log__c();
            tr.Error_Message__c = 'test Invoice Error';
            tr.Invoice__c = invoiceRecord.id;
            Insert tr;
          
           
            MultiRecordsApprovalController_full.getSubmittedRecords();
            
            MultiRecordsApprovalController_full.getBatchStatus();
            
            List<String> ApprId_2st = new List<String>{invoiceRecord.Id};
                MultiRecordsApprovalController_full.processRecordsBatchExecute(ApprId_2st, 'Approved', 'test reject', opp.id); 
            
            
        }
        
        
    }
    
     testMethod static void test_meth2() {
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;  
        
        System.runAs(usrLH){
            
            Triggers_status__c tg_status= new Triggers_status__c();
            tg_status.OpportunityTrigger__c= false;
            tg_status.PromotorCompany__c= false;
            tg_status.Fee_Calculation__c= false;
            insert tg_status;
            
            Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
            
            Business_Sector__c businessSector = new Business_Sector__c();
            businessSector.Name = 'Infrastructure';
            businessSector.Business_Head__c =  usrLH.Id; 
            businessSector.OFAC_Approver__c = usrLH.Id; 
            businessSector.Opportunity_Checker__c = usrLH.Id;
            businessSector.ICRA_Branch__c = branchRecord.Id;
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
            billingAddr.Tax_GST_Classification__c = 'Non-SEZ';
            insert billingAddr;
            
            Opportunity opp = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, SURVEILLANCE, acc.Id); 
            opp.Instrument_type_1__c = 'Non Structured Finance';
            opp.Instrument_type_2__c = 'Rating - Bank Loan Rating';
            opp.Instrument_type_3__c = 'Bank Loan Rating';
            opp.Instrument_type_4__c = 'Bank Loan Rating';
            opp.Customer_Fee_Type__c = 'Non - Cap';
            opp.is_Primary_Not_Present__c = false;
            opp.StageName = 'L1 Meeting';
            opp.Mandate_Type__c = 'Fresh From Existing';
            opp.Bypass_Validation__c = true;
            opp.Billing_Start_Date__c = null;
            opp.Commercial_Head__c = usrLH.id;
            opp.CloseDate = date.today();
            opp.Invoice_Generation_Date__c = date.today();
            opp.Non_Cooperation_Withdrawal_Reason__c = 'Others';
            insert opp;
            
            opp.Reason__c = 'Exit';
            opp.Comment__c = 'Test Exit';
            opp.Defer_Billing_or_Exit_Case__c = 'Exit Case';
            opp.StageName = 'Negotiation ';
            Update opp;
            opp.StageName = 'Discount Approved ';
            opp.Proposed_Surveillance_Fee__c = 12334;
            opp.Proposed_Rating_Fee__c = 1234;
            update opp;
            opp.StageName = 'Closed Won';
            opp.Reason__c = '';
            opp.Defer_Billing_or_Exit_Case__c='To Be Billed';
            opp.Amount = 122333;
            update opp;
            
            Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', acc.Id); 
            insert contactRecord;
            
            List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
                new OpportunityContactRole(
                    ContactId = contactRecord.Id,
                    OpportunityId = opp.Id,
                    IsPrimary = true,
                    Role = INVOICEROLE)};
                        Insert optyConRoles;
            
            Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opp.Id, null,'Proforma Invoice');
            invoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            invoiceRecord.Finance_Email_ID__c=usrLH.id;
            insert invoiceRecord;
            Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opp.Id);
            invoiceLineRecord_A.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A;
            
     

            
                   /*Invoice__c invoiceRecord1  = ICRA_TestDataFactory.createInvoice('Invoice',opp.Id, null,'Initiate Tax Invoice');
            invoiceRecord1.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            invoiceRecord1.Finance_Email_ID__c=usrLH.id;
            insert invoiceRecord1;
            invoiceRecord1.Invoice_Status__c = 'Tax Invoice';
            update invoiceRecord1;
            Invoice_Line_Item__c invoiceLineRecord_A1 =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord1.Id, opp.Id);
            invoiceLineRecord_A1.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A1;*/
        
            invoiceRecord.Invoice_Status__c = 'Initiate Tax Invoice';
            update invoiceRecord;
            
            Transaction_Log__c tr = new Transaction_Log__c();
            tr.Error_Message__c = 'test Invoice Error';
            tr.Invoice__c = invoiceRecord.id;
            Insert tr;


            Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
            req2.setComments('Submitting request for approval.');
            req2.setObjectId(invoiceRecord.id);
            req2.setSubmitterId(usrLH.Id); 
            req2.setProcessDefinitionNameOrId('Tax_Invoice_Approval_Process');
            req2.setSkipEntryCriteria(true);
            Approval.ProcessResult results = Approval.process(req2);
            
           /* Invoice__c creditNoteInvoiceRecord  = ICRA_TestDataFactory.createInvoice('Credit Note',opp.Id, invoiceRecord.id,'Initiate GST Credit Note');
            creditNoteInvoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            creditNoteInvoiceRecord.Finance_Email_ID__c=usrLH.id;
            creditNoteInvoiceRecord.Bypass_Validation__c=true;
            creditNoteInvoiceRecord.Revised_agreed_amount__c=0;
            insert creditNoteInvoiceRecord;
            Invoice_Line_Item__c invoiceLineRecord_A2 =  ICRA_TestDataFactory.createInvoiceLineItem(creditNoteInvoiceRecord.Id, opp.Id);
            invoiceLineRecord_A2.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A2;*/
            
           
            MultiRecordsApprovalController_full.getSubmittedRecords();
            
            MultiRecordsApprovalController_full.getBatchStatus();
          
                
            List<String> ApprId_1st = new List<String>{invoiceRecord.Id};
            MultiRecordsApprovalController_full.processRecordsBatchExecute(ApprId_1st, 'Approved', 'test reject', invoiceRecord.id); 
            
            
                
                }
        
        
    }
    
    /*
     testMethod static void test_meth1() {
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null); 
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;  
        
        System.runAs(usrLH){
            
            Triggers_status__c tg_status= new Triggers_status__c();
            tg_status.OpportunityTrigger__c= false;
            tg_status.PromotorCompany__c= false;
            tg_status.Fee_Calculation__c= false;
            insert tg_status;
            
            Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
            
            Business_Sector__c businessSector = new Business_Sector__c();
            businessSector.Name = 'Infrastructure';
            businessSector.Business_Head__c =  usrLH.Id; 
            businessSector.OFAC_Approver__c = usrLH.Id; 
            businessSector.Opportunity_Checker__c = usrLH.Id;
            businessSector.ICRA_Branch__c = branchRecord.Id;
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
            billingAddr.Tax_GST_Classification__c = 'Non-SEZ';
            insert billingAddr;
            
            Opportunity opp = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, SURVEILLANCE, acc.Id); 
            opp.Instrument_type_1__c = 'Non Structured Finance';
            opp.Instrument_type_2__c = 'Rating - Bank Loan Rating';
            opp.Instrument_type_3__c = 'Bank Loan Rating';
            opp.Instrument_type_4__c = 'Bank Loan Rating';
            opp.Customer_Fee_Type__c = 'Non - Cap';
            opp.is_Primary_Not_Present__c = false;
            opp.StageName = 'L1 Meeting';
            opp.Mandate_Type__c = 'Fresh From Existing';
            opp.Bypass_Validation__c = true;
            opp.Billing_Start_Date__c = null;
            opp.Commercial_Head__c = usrLH.id;
            opp.CloseDate = date.today();
            opp.Invoice_Generation_Date__c = date.today();
            opp.Non_Cooperation_Withdrawal_Reason__c = 'Others';
            insert opp;
            
            opp.Reason__c = 'Exit';
            opp.Comment__c = 'Test Exit';
            opp.Defer_Billing_or_Exit_Case__c = 'Exit Case';
            opp.StageName = 'Negotiation ';
            Update opp;
            opp.StageName = 'Discount Approved ';
            opp.Proposed_Surveillance_Fee__c = 12334;
            opp.Proposed_Rating_Fee__c = 1234;
            update opp;
            opp.StageName = 'Closed Won';
            opp.Reason__c = '';
            opp.Defer_Billing_or_Exit_Case__c='To Be Billed';
            opp.Amount = 122333;
            update opp;
            
            Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', acc.Id); 
            insert contactRecord;
            
            List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
                new OpportunityContactRole(
                    ContactId = contactRecord.Id,
                    OpportunityId = opp.Id,
                    IsPrimary = true,
                    Role = INVOICEROLE)};
                        Insert optyConRoles;
            
            Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',opp.Id, null,'Proforma Invoice');
            invoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            invoiceRecord.Finance_Email_ID__c=usrLH.id;
            insert invoiceRecord;
            Invoice_Line_Item__c invoiceLineRecord_A =  ICRA_TestDataFactory.createInvoiceLineItem(invoiceRecord.Id, opp.Id);
            invoiceLineRecord_A.Invoice_Taxable_Amount_copy__c = 0;
            update invoiceLineRecord_A;
            
     
            invoiceRecord.Invoice_Status__c = 'Initiate Tax Invoice';
            update invoiceRecord;
            
            Transaction_Log__c tr = new Transaction_Log__c();
            tr.Error_Message__c = 'test Invoice Error';
            tr.Invoice__c = invoiceRecord.id;
            Insert tr;


            
            Invoice__c creditNoteInvoiceRecord  = ICRA_TestDataFactory.createInvoice('Credit Note',opp.Id, invoiceRecord.id,'Initiate GST Credit Note');
            creditNoteInvoiceRecord.Invoice_Created_Date__c = date.newInstance(2025, 12, 05);
            creditNoteInvoiceRecord.Finance_Email_ID__c=usrLH.id;
            creditNoteInvoiceRecord.Bypass_Validation__c=true;
            creditNoteInvoiceRecord.Revised_agreed_amount__c=0;
            insert creditNoteInvoiceRecord;
            MultiRecordsApprovalController_full.getSubmittedRecords();
            MultiRecordsApprovalController_full.getBatchStatus(); 
            List<String> ApprId_1st = new List<String>{creditNoteInvoiceRecord.Id};
            MultiRecordsApprovalController_full.processRecordsBatchExecute(ApprId_1st, 'Approved', 'test reject', creditNoteInvoiceRecord.id); 
          }
    }*/
}