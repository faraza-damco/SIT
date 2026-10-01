@isTest
public class CH_MD_approval_EmailId_trigger_Test {
        private static final String INVOICEROLE = 'Name on Invoice';

    @isTest
    public static void CH_approve_approval_EmailIdTest(){
        Test.startTest();
       User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
               User username2 = [SELECT id,name FROM User WHERE Name = 'Jayanta Chatterjee'];

        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
       
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id;
        businessSector.ICRA_Branch__c = branchRecord.Id;
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.GST_Number__c = '24AABCU9603R1ZB';
        accountReccord.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord.PAN_Number__c = 'AAFCR5512P';
        //acc.UCN__c='';
        accountReccord.Constitution_Type_Picklist__c='other';
        accountReccord.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord.ofac_check__c=true;
        accountReccord.Account_Status__c='Active';
        accountReccord.Related_Party__c='No';
        accountReccord.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord.Group_Name__c = 'NA';
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
        Insert accountReccord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512P1ZQ';               
        billingAddr.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr.Is_Primary_Billing_Address__c = true; 
                billingAddr.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr;

        accountReccord.Billing_Address__c= billingAddr.Id;
        accountReccord.ofac_check__c=true;
        accountReccord.Account_Status__c= 'Active';
        update accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branchrecord.Id);
         accountReccord1.GST_Number__c = '24AABCU9603R1ZE';
         accountReccord1.Business_Sector__c = businessSector.Id;
        accountReccord1.Group_Name__c = 'NA';
        accountReccord1.GST_Number__c = '24AABCU9603R1ZA';
        accountReccord1.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord1.PAN_Number__c = 'AAFCR5512Q';
        //acc.UCN__c='';
        //acc.Constitution_Type__c='';
        accountReccord1.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord1.ofac_check__c=true;
        accountReccord1.Account_Status__c='Active';
        accountReccord1.Related_Party__c='No';
        accountReccord1.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord1.ShippingCity ='Delhi';
        accountReccord1.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord1.ShippingPostalCode ='110001';
        accountReccord1.ShippingState ='Delhi';
        accountReccord1.ShippingCountry ='India';
                accountReccord1.Constitution_Type_Picklist__c='other';

        Insert accountReccord1;

        Billing_Address__c billingAddr1 = new Billing_Address__c();
        billingAddr1.Name = 'Damco Test 1';                     
        billingAddr1.Account_Name__c = accountReccord1.Id;           
        billingAddr1.Billing_City__c = 'Mumbai';                 
        billingAddr1.BillingCountry__c = 'India';                  
        billingAddr1.BillingState__c = 'Maharashtra';                  
        billingAddr1.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr1.GSTN__c = '27AAFCR5512Q1ZQ';               
        billingAddr1.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr1.Is_Primary_Billing_Address__c = true;    
                                        billingAddr1.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr1;

        accountReccord1.Billing_Address__c= billingAddr1.Id;
        accountReccord1.Account_Status__c= 'Active';
        update accountReccord1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
         Opportunity opportunityRecord_other2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity other22', 'New Business', accountReccord.Id);
        opportunityRecord_other2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_other2.Instrument_type_2__c = 'Others';
        opportunityRecord_other2.Instrument_type_3__c = 'Others';
        opportunityRecord_other2.Instrument_type_4__c = 'Issuer Rating';
        opportunityRecord_other2.Billing_Start_Date__c = System.today();
        opportunityRecord_other2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);

        opportunityRecord_other2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_other2.ASF_Final_Amount__c = 1000;
        opportunityRecord_other2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_other2.Change_in_start_Date__c = false;
        opportunityRecord_other2.Commercial_Head__c = username2.Id;
        opportunityRecord_other2.OwnerId = username.Id;
        opportunityRecord_other2.Pricing_Approved_by_Business_Head__c = true;
        //opportunityRecord_other2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //opportunityRecord_other2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //String ids = opportunityRecord_other.Id;
        
        // opportunityList.add(opportunityRecord_other2);
        
        opportunityRecord_other2.StageName = 'L1 Meeting';
        opportunityRecord_other2.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord_other2.OFAC_Approver__c = username.Id;
        opportunityRecord_other2.BD_Head__c = username.Id;
        opportunityRecord_other2.OFAC_Approved__c = true;
        opportunityRecord_other2.Revised_Billing_End_Date__c = opportunityRecord_other2.Billing_End_Date__c;

        Insert opportunityRecord_other2;
       map<id,Opportunity> parentopp = new map<id,Opportunity>();
       List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_other2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord_other2.Proposed_Rating_Fee__c = 100;
        opportunityRecord_other2.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord_other2.StageName = 'Negotiation';
        opportunityRecord_other2.Pricing_Not_Auto_Approved__c = true;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord_other2;
        
            opportunityRecord_other2.Pricing_Approved_by_Commercial_Head__c = true;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = false;
        opportunityRecord_other2.Pricing_Rejected_by_CEO__c = false;
        opportunityRecord_other2.CH_Approval_Reject_Email_sent__c = false;
        update opportunityRecord_other2;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = true;
        update opportunityRecord_other2;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityRecord_other2);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_BH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CEO(oppList);
        Test.stopTest();
               
    }
    @isTest
     public static void CH_reject_approval_EmailIdTest2(){
        Test.startTest();
       User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
                User username2 = [SELECT id,name FROM User WHERE Name = 'Jayanta Chatterjee'];

        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
       Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id;
        businessSector.ICRA_Branch__c = branchRecord.Id;
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.GST_Number__c = '24AABCU9603R1ZC';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.Group_Name__c = 'NA';
        accountReccord.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord.PAN_Number__c = 'AAFCR5512P';
        //acc.UCN__c='';
        //acc.Constitution_Type__c='';
        accountReccord.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord.ofac_check__c=true;
        accountReccord.Account_Status__c='Active';
        accountReccord.Related_Party__c='No';
        accountReccord.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
                 accountReccord.Constitution_Type_Picklist__c='other';

        Insert accountReccord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512P1ZQ';               
        billingAddr.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr.Is_Primary_Billing_Address__c = true; 
                         billingAddr.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr;

        accountReccord.Billing_Address__c= billingAddr.Id;
        accountReccord.Account_Status__c= 'Active';
        update accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branchrecord.Id);
         accountReccord1.GST_Number__c = '24AABCU9603R1ZG';
         accountReccord1.Business_Sector__c = businessSector.Id;
        accountReccord1.Group_Name__c = 'NA';
        accountReccord1.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord1.PAN_Number__c = 'AAFCR5512Q';
        //acc.UCN__c='';
        //acc.Constitution_Type__c='';
        accountReccord1.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord1.ofac_check__c=true;
        accountReccord1.Account_Status__c='Active';
        accountReccord1.Related_Party__c='No';
        accountReccord1.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord1.ShippingCity ='Delhi';
        accountReccord1.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord1.ShippingPostalCode ='110001';
        accountReccord1.ShippingState ='Delhi';
        accountReccord1.ShippingCountry ='India';
                 accountReccord1.Constitution_Type_Picklist__c='other';

        Insert accountReccord1;

        Billing_Address__c billingAddr1 = new Billing_Address__c();
        billingAddr1.Name = 'Damco Test 1';                     
        billingAddr1.Account_Name__c = accountReccord1.Id;           
        billingAddr1.Billing_City__c = 'Mumbai';                 
        billingAddr1.BillingCountry__c = 'India';                  
        billingAddr1.BillingState__c = 'Maharashtra';                  
        billingAddr1.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr1.GSTN__c = '27AAFCR5512Q1ZQ';               
        billingAddr1.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr1.Is_Primary_Billing_Address__c = true;   
                                         billingAddr1.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr1;

        accountReccord1.Billing_Address__c= billingAddr1.Id;
        accountReccord1.ofac_check__c= true;
        accountReccord1.Account_Status__c= 'Active';
        update accountReccord1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
         Opportunity opportunityRecord_other2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity other22', 'New Business', accountReccord.Id);
        opportunityRecord_other2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_other2.Instrument_type_2__c = 'Others';
        opportunityRecord_other2.Instrument_type_3__c = 'Others';
        opportunityRecord_other2.Instrument_type_4__c = 'Issuer Rating';
        opportunityRecord_other2.Billing_Start_Date__c = System.today();
        opportunityRecord_other2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);
        opportunityRecord_other2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_other2.ASF_Final_Amount__c = 1000;
        opportunityRecord_other2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_other2.Change_in_start_Date__c = false;
        opportunityRecord_other2.Commercial_Head__c = username2.Id;
         opportunityRecord_other2.OwnerId = username.Id;
         opportunityRecord_other2.Pricing_Rejected_by_Business_Head__c = true;
        //opportunityRecord_other2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //opportunityRecord_other2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //String ids = opportunityRecord_other.Id;
        
        // opportunityList.add(opportunityRecord_other2);
        
        opportunityRecord_other2.StageName = 'L1 Meeting';
        opportunityRecord_other2.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord_other2.OFAC_Approver__c = username.Id;
        opportunityRecord_other2.BD_Head__c = username.Id;
        opportunityRecord_other2.OFAC_Approved__c = true;
        Insert opportunityRecord_other2;
       map<id,Opportunity> parentopp = new map<id,Opportunity>();
       List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_other2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord_other2.Proposed_Rating_Fee__c = 100;
        opportunityRecord_other2.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord_other2.StageName = 'Negotiation';
        opportunityRecord_other2.Pricing_Not_Auto_Approved__c = true;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord_other2;
        
            opportunityRecord_other2.Pricing_Approved_by_Commercial_Head__c = false;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = false;
        opportunityRecord_other2.Pricing_Rejected_by_CEO__c = false;
        opportunityRecord_other2.CH_Approval_Reject_Email_sent__c = false;
        update opportunityRecord_other2;
        opportunityRecord_other2.Pricing_Rejected_by_Commercial_Head__c = true;
        update opportunityRecord_other2;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityRecord_other2);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_BH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CEO(oppList);
        Test.stopTest();
               
    }
    @isTest
     public static void MD_approve_approval_EmailIdTest(){
        Test.startTest();
       User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
                User username2 = [SELECT id,name FROM User WHERE Name = 'Jayanta Chatterjee']; //Jayanta Chatterjee

        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id;
        businessSector.ICRA_Branch__c = branchRecord.Id;
        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.GST_Number__c = '24AABCU9603R1ZH';
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.Group_Name__c = 'NA';
        accountReccord.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord.PAN_Number__c = 'AAFCR5512P';
        //acc.UCN__c='';
        //acc.Constitution_Type__c='';
        accountReccord.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord.ofac_check__c=true;
        accountReccord.Account_Status__c='Active';
        accountReccord.Related_Party__c='No';
        accountReccord.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
                 accountReccord.Constitution_Type_Picklist__c='other';

        Insert accountReccord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512P1ZQ';               
        billingAddr.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr.Is_Primary_Billing_Address__c = true;   
                         billingAddr.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr;

        accountReccord.Billing_Address__c= billingAddr.Id;
        accountReccord.ofac_check__c= true;
        accountReccord.Account_Status__c= 'Active';
        update accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branchrecord.Id);
         accountReccord1.GST_Number__c = '24AABCU9603R1ZI';
         accountReccord1.Business_Sector__c = businessSector.Id;
        accountReccord1.Group_Name__c = 'NA';
        accountReccord1.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord1.PAN_Number__c = 'AAFCR5512Q';
        //acc.UCN__c='';
        //acc.Constitution_Type__c='';
        accountReccord1.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord1.ofac_check__c=true;
        accountReccord1.Account_Status__c='Active';
        accountReccord1.Related_Party__c='No';
        accountReccord1.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord1.ShippingCity ='Delhi';
        accountReccord1.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord1.ShippingPostalCode ='110001';
        accountReccord1.ShippingState ='Delhi';
        accountReccord1.ShippingCountry ='India';
                 accountReccord1.Constitution_Type_Picklist__c='other';

        Insert accountReccord1;

        Billing_Address__c billingAddr1 = new Billing_Address__c();
        billingAddr1.Name = 'Damco Test 1';                     
        billingAddr1.Account_Name__c = accountReccord1.Id;           
        billingAddr1.Billing_City__c = 'Mumbai';                 
        billingAddr1.BillingCountry__c = 'India';                  
        billingAddr1.BillingState__c = 'Maharashtra';                  
        billingAddr1.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr1.GSTN__c = '27AAFCR5512Q1ZQ';               
        billingAddr1.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr1.Is_Primary_Billing_Address__c = true; 
                                         billingAddr1.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr1;

        accountReccord1.Billing_Address__c= billingAddr1.Id;
        accountReccord1.ofac_check__c= true;
        accountReccord1.Account_Status__c= 'Active';
        update accountReccord1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
         Opportunity opportunityRecord_other2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity other22', 'New Business', accountReccord.Id);
        opportunityRecord_other2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_other2.Instrument_type_2__c = 'Others';
        opportunityRecord_other2.Instrument_type_3__c = 'Others';
        opportunityRecord_other2.Instrument_type_4__c = 'Issuer Rating';
        opportunityRecord_other2.Billing_Start_Date__c = System.today();
        opportunityRecord_other2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);
        opportunityRecord_other2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_other2.ASF_Final_Amount__c = 1000;
        opportunityRecord_other2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_other2.Change_in_start_Date__c = false;
        opportunityRecord_other2.Commercial_Head__c = username2.Id;
         opportunityRecord_other2.OwnerId = username.Id;
        //opportunityRecord_other2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //opportunityRecord_other2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //String ids = opportunityRecord_other.Id;
        
        // opportunityList.add(opportunityRecord_other2);
        
        opportunityRecord_other2.StageName = 'L1 Meeting';
        opportunityRecord_other2.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord_other2.OFAC_Approver__c = username.Id;
        opportunityRecord_other2.BD_Head__c = username.Id;
        opportunityRecord_other2.OFAC_Approved__c = true;
        opportunityRecord_other2.Pricing_Approved_by_Commercial_Head__c = true;
        Insert opportunityRecord_other2;
       map<id,Opportunity> parentopp = new map<id,Opportunity>();
       List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_other2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord_other2.Proposed_Rating_Fee__c = 100;
        opportunityRecord_other2.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord_other2.StageName = 'Negotiation';
        opportunityRecord_other2.Pricing_Not_Auto_Approved__c = true;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord_other2;
        
            //opportunityRecord_other2.Pricing_Approved_by_Commercial_Head__c = true;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = false;
        opportunityRecord_other2.Pricing_Rejected_by_CEO__c = false;
        opportunityRecord_other2.CH_Approval_Reject_Email_sent__c = true;
        update opportunityRecord_other2;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = true;
        opportunityRecord_other2.Pricing_Rejected_by_CEO__c = false;
        opportunityRecord_other2.MD_Approval_Reject_Email_sent__c = false;
        update opportunityRecord_other2;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityRecord_other2);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_BH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CEO(oppList);
        Test.stopTest();
               
    }
    @isTest
    public static void CEO_approve_approval_EmailIdTest(){
        Test.startTest();
       User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];
               User username2 = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];     //Jayanta Chatterjee

        List<Opportunity> opportunityList = new List<Opportunity>();
        Branch__c branchrecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  username.Id; 
        businessSector.OFAC_Approver__c = username.Id; 
        businessSector.Opportunity_Checker__c = username.Id; 
                businessSector.ICRA_Branch__c = branchRecord.Id;

        insert businessSector;

        Account accountReccord = ICRA_TestDataFactory.CreateAccount('Test Account','Issuer',branchrecord.Id);
        accountReccord.OFAC_Document_Received__c = true;
        accountReccord.Business_Sector__c = businessSector.Id;
        accountReccord.GST_Number__c = '24AABCU9603R1ZJ';
        accountReccord.PAN_Number__c = 'AAFCR5512P';
        accountReccord.Group_Name__c = 'NA';
        accountReccord.LEI_Number__c='012300A0A0A0A0A0A009';
        //acc.UCN__c='';
        //acc.Constitution_Type__c='';
        accountReccord.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord.ofac_check__c=true;
        accountReccord.Account_Status__c='Active';
        accountReccord.Related_Party__c='No';
        accountReccord.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord.ShippingCity ='Delhi';
        accountReccord.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord.ShippingPostalCode ='110001';
        accountReccord.ShippingState ='Delhi';
        accountReccord.ShippingCountry ='India';
                accountReccord.Constitution_Type_Picklist__c='other';

        Insert accountReccord;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accountReccord.Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAFCR5512P1ZQ';               
        billingAddr.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr.Is_Primary_Billing_Address__c = true; 
                        billingAddr.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr;

        accountReccord.Billing_Address__c= billingAddr.Id;
        accountReccord.ofac_check__c= true;
        accountReccord.Account_Status__c= 'Active';
        update accountReccord;
        
        Account accountReccord1 = ICRA_TestDataFactory.CreateAccount('Test Account 2','Issuer',branchrecord.Id);
        //accountReccord.OFAC_Document_Received__c = true;
             accountReccord1.Constitution_Type_Picklist__c='other';

         accountReccord1.GST_Number__c = '24AABCU9603R1ZK';
         accountReccord1.Business_Sector__c = businessSector.Id;
        accountReccord1.Group_Name__c = 'NA';
        accountReccord1.LEI_Number__c='012300A0A0A0A0A0A009';
        accountReccord1.PAN_Number__c = 'AAFCR5512Q';
        //acc.UCN__c='';
        accountReccord.Constitution_Type_Picklist__c='other';
        accountReccord1.CIN_Number__c='U01234Az0123AaZ012345';
        accountReccord1.ofac_check__c=true;
        accountReccord1.Account_Status__c='Active';
        accountReccord1.Related_Party__c='No';
        accountReccord1.Strick_Off_Data_from_MCA__c=System.today();
        accountReccord1.ShippingCity ='Delhi';
        accountReccord1.ShippingStreet ='Office No. 01, 28th Floor';
        accountReccord1.ShippingPostalCode ='110001';
        accountReccord1.ShippingState ='Delhi';
        accountReccord1.ShippingCountry ='India';
        Insert accountReccord1;

        Billing_Address__c billingAddr1 = new Billing_Address__c();
        billingAddr1.Name = 'Damco Test 1';                     
        billingAddr1.Account_Name__c = accountReccord1.Id;           
        billingAddr1.Billing_City__c = 'Mumbai';                 
        billingAddr1.BillingCountry__c = 'India';                  
        billingAddr1.BillingState__c = 'Maharashtra';                  
        billingAddr1.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr1.GSTN__c = '27AAFCR5512Q1ZQ';               
        billingAddr1.Billing_Zip_Postal_Code__c = '514410';        
        billingAddr1.Is_Primary_Billing_Address__c = true;  
                                billingAddr1.Tax_GST_Classification__c = 'Non-SEZ';

        insert billingAddr1;

        accountReccord1.Billing_Address__c= billingAddr1.Id;
        accountReccord1.ofac_check__c= true;
        accountReccord1.Account_Status__c= 'Active';
        update accountReccord1;
        
        Contact contactRecord = ICRA_TestDataFactory.createContact('name', 'Yes', 'Account Contact', accountReccord.Id); 
        Insert contactRecord;
        
        Contact contactRecord1 = ICRA_TestDataFactory.createContact('name a', 'Yes', 'Account Contact', accountReccord1.Id); 
        Insert contactRecord1;
         Opportunity opportunityRecord_other2 = ICRA_TestDataFactory.creatOpportunity('Test Opportunity other22', 'New Business', accountReccord.Id);
        opportunityRecord_other2.Instrument_type_1__c = 'Non Structured Finance';
        opportunityRecord_other2.Instrument_type_2__c = 'Others';
        opportunityRecord_other2.Instrument_type_3__c = 'Others';
        opportunityRecord_other2.Instrument_type_4__c = 'Issuer Rating';
        opportunityRecord_other2.Billing_Start_Date__c = System.today();
        opportunityRecord_other2.Billing_End_Date__c = System.today().addDays(-60).addYears(1);
        opportunityRecord_other2.Rolling_and_Date_Alignmnet__c = true;
        opportunityRecord_other2.ASF_Final_Amount__c = 1000;
        opportunityRecord_other2.Is_Date_Alignment_Done__c = false;
        opportunityRecord_other2.Change_in_start_Date__c = false;
        opportunityRecord_other2.Commercial_Head__c = username.Id;
        opportunityRecord_other2.OwnerId = username2.Id;
        opportunityRecord_other2.Pricing_Approved_by_Business_Head__c = true;
        opportunityRecord_other2.BH_Approval_Rejection_Mail_Sent__c = true;
        //opportunityRecord_other2.Edited_By_Batch_UI__c = 'Edited By Batch';
        //opportunityRecord_other2.Defer_Billing_or_Exit_Case__c = 'To Be Billed';
        //String ids = opportunityRecord_other.Id;
        
        // opportunityList.add(opportunityRecord_other2);
        
        opportunityRecord_other2.StageName = 'L1 Meeting';
        opportunityRecord_other2.Customer_Fee_Type__c = 'Non - Cap';
        opportunityRecord_other2.OFAC_Approver__c = username.Id;
        opportunityRecord_other2.BD_Head__c = username.Id;
        opportunityRecord_other2.OFAC_Approved__c = true;
        Insert opportunityRecord_other2;
       map<id,Opportunity> parentopp = new map<id,Opportunity>();
       List<OpportunityContactRole> optyConRoleso2 = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = contactRecord.Id,
                OpportunityId = opportunityRecord_other2.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoleso2;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opportunityRecord_other2.Proposed_Rating_Fee__c = 100;
        opportunityRecord_other2.Proposed_Surveillance_Fee__c = 100;
        opportunityRecord_other2.StageName = 'Negotiation';
        opportunityRecord_other2.Pricing_Not_Auto_Approved__c = true;
        //opportunityRecord_other2.Commercial_Head__c = UserInfo.getUserId();
        update opportunityRecord_other2;
        //opportunityRecord_other2.Pricing_Approved_by_Business_Head__c = true;
        //opportunityRecord_other2.Pricing_Rejected_by_Business_Head__c = true;
        //opportunityRecord_other2.BH_Approval_Rejection_Mail_Sent__c = true;
        opportunityRecord_other2.Pricing_Approved_by_Commercial_Head__c = true;
        //opportunityRecord_other2.Pricing_Rejected_by_Commercial_Head__c = true;
        opportunityRecord_other2.CH_Approval_Reject_Email_sent__c = true;
        opportunityRecord_other2.Pricing_Rejected_by_CEO__c = true;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = false;
        //opportunityRecord_other2.Pricing_Rejected_by_CEO__c = true;
        //opportunityRecord_other2.CH_Approval_Reject_Email_sent__c = false;
        update opportunityRecord_other2;
        opportunityRecord_other2.Pricing_Approved_by_CEO__c = true;
        opportunityRecord_other2.MD_Approval_Reject_Email_sent__c = false;
        update opportunityRecord_other2;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityRecord_other2);
        //CH_MD_approval_EmailId_Handler.approved_rejected_by_BH(oppList);
        //CH_MD_approval_EmailId_Handler.approved_rejected_by_CH(oppList);
        CH_MD_approval_EmailId_Handler.approved_rejected_by_CEO(oppList);
        Test.stopTest();
               
    }   
   
}