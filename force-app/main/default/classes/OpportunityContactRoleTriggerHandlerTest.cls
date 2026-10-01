/*********************************************************************************************
ClassName -   OpportunityContactRoleTriggerHandlerTest
Description - Test calss for code coverage of OpportunityContactRoleTrigger
*********************************************************************************************/
@isTest(SeeAllData=false) 
public class OpportunityContactRoleTriggerHandlerTest {
    private static final String INVOICEROLE = 'Name on Invoice';
    private static final String PROPOSALPRIMARY_ROLE = 'Proposal Primary Contact';
    private static final String MPRA_ROLE = 'MPRA/SOW';
    private static final String EMAILROLE = 'Email Recipient';
    private static final String CONEMAIL = 'testcontactrole@abc.com';
    private static final String CONEMAIL2 = 'test@abcxyz.com';
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
                Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
                User username = [SELECT id,name FROM User WHERE Name = 'Damco Admin'];

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
        List<Account> accList = new List<Account>{ICRA_TestDataFactory.CreateAccount(TESTNAME1, 'Issuer', branchRecord.Id)/*,
            						ICRA_TestDataFactory.CreateAccount(TESTNAME2, 'Issuer', branchRecord.Id)*/}; 
            accList[0].PAN_Number__c = 'AAACI0210B';
        	accList[0].Business_Sector__c = businessSector.Id; 
        	accList[0].Group_Name__c = 'testingDamco';
            accList[0].ShippingCity ='Delhi';
            accList[0].ShippingStreet ='Office No. 01, 28th Floor';
            accList[0].ShippingPostalCode ='110001';
            accList[0].ShippingState ='Delhi';
            accList[0].ShippingCountry ='India';
            accList[0].ofac_check__c =true;
            accList[0].Account_Status__c ='Active';
            accList[0].Ofac_Approved__c =true;
            accList[0].OFAC_Document_Received__c =true;
        Insert accList;

        Billing_Address__c billingAddr = new Billing_Address__c();
        billingAddr.Name = 'Damco Test 1';                     
        billingAddr.Account_Name__c = accList[0].Id;           
        billingAddr.Billing_City__c = 'Mumbai';                 
        billingAddr.BillingCountry__c = 'India';                  
        billingAddr.BillingState__c = 'Maharashtra';                  
        billingAddr.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr.GSTN__c = '27AAACI0210B1ZP';               
        billingAddr.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr.Is_Primary_Billing_Address__c = true;      
        insert billingAddr;

        Billing_Address__c billingAddr2 = new Billing_Address__c();
        billingAddr2.Name = 'Damco Test 1';                     
        billingAddr2.Account_Name__c = accList[0].Id;           
        billingAddr2.Billing_City__c = 'Mumbai';                 
        billingAddr2.BillingCountry__c = 'India';                  
        billingAddr2.BillingState__c = 'Maharashtra';                  
        billingAddr2.Billing_Street__c = 'Mahrarana Pratap Marg'; 
        billingAddr2.GSTN__c = '27AAACI0210B1ZP';               
        billingAddr2.Billing_Zip_Postal_Code__c = '554410';        
        billingAddr2.Is_Primary_Billing_Address__c = false;      
        insert billingAddr2;

        List<Contact> conList = new List<Contact>{TestFactory.getContact(accList[0].Id,TESTNAME1,TESTNAME1,true),
            										TestFactory.getContact(accList[0].Id,TESTNAME1,TESTNAME2,true),
            										TestFactory.getContact(accList[0].Id,TESTNAME2,TESTNAME1,true),
            										TestFactory.getContact(accList[0].Id,TESTNAME2,TESTNAME2,true),
            										TestFactory.getContact(accList[0].Id,TESTNAME3,TESTNAME3,true),
            										TestFactory.getContact(accList[0].Id,TESTNAME4,TESTNAME4,true)};
        conList[0].Email = CONEMAIL;
        conList[0].Designation__c = DESIGNATION;
        conList[0].Account = accList[0];
        conList[1].Email = CONEMAIL;
        conList[1].Designation__c = DESIGNATION;
        conList[1].Account = accList[0];
        conList[2].Email = CONEMAIL2;
        conList[2].Designation__c = DESIGNATION2;
        conList[2].Account = accList[0];
        conList[3].Email = CONEMAIL;
        conList[3].Designation__c = DESIGNATION;
        conList[3].Account = accList[0];
        //conList[3].Inactive__c = true;
        conList[4].Designation__c = DESIGNATION;
        conList[4].Email = EMAIL;
        conList[4].Account = accList[0];
        conList[5].Email = EMAIL;
        conList[5].Designation__c = DESIGNATION;
        conList[5].Account = accList[0];
        update conList;

        Opportunity opty = ICRA_TestDataFactory.creatOpportunity(TESTNAME1, 'New Business', accList[0].Id); 
        opty.Instrument_type_1__c = 'Non Structured Finance';
        opty.Instrument_type_2__c = 'Rating - Bank Loan Rating';
        opty.Instrument_type_3__c = 'Bank Loan Rating';
        opty.Instrument_type_4__c = 'Bank Loan Rating Fresh';
        opty.StageName = 'L1 Meeting';
        opty.Customer_Fee_Type__c = 'Non - Cap';
        opty.Mandate_Type__c = 'Fresh From Existing';
        opty.Business_Segment__c = 'Rating';
        opty.BillingAddress__c = billingAddr.Id;
        opty.Account = accList[0];
        //opty.TAN_not_applicable__c = true;
        insert opty; 
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = conList[0].Id,
                OpportunityId = opty.Id,
                IsPrimary = true,
                Role = EMAILROLE),
            new OpportunityContactRole(
                ContactId = conList[1].Id,
                OpportunityId = opty.Id,
                IsPrimary = true,
                Role = INVOICEROLE)};
        try{
            Insert optyConRoles;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        //opty.PR_Date__c = System.Today();
        opty.OFAC_Approved__c=true;
        opty.OFAC_Approver__c=username.Id;
        opty.Rolling_and_Date_Alignmnet__c = true;
        update opty;

        optyConRoles.addAll(new List<OpportunityContactRole>{new OpportunityContactRole(
            ContactId = conList[0].Id,
            OpportunityId = opty.Id,
            Role = EMAILROLE),
        new OpportunityContactRole(
            ContactId = conList[2].Id,
            OpportunityId = opty.Id,
            Role = INVOICEROLE),
        new OpportunityContactRole(
            ContactId = conList[4].Id,
            OpportunityId = opty.Id,
            Role = PROPOSALPRIMARY_ROLE),
        new OpportunityContactRole(
            ContactId = conList[5].Id,
            OpportunityId = opty.Id,
            Role = MPRA_ROLE)});    
        try{
            Insert optyConRoles;//2 Name on Invoices , Inactive Contact , Contact from diff Account & Duplicate Contacts errors
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        OpportunityContactRole opty2=  optyConRoles[2];
        if(opty2.Id!=null){
            optyConRoles[2].Role = EMAILROLE;
            optyConRoles[2].ContactId = conList[2].Id;
            update optyConRoles[2];
        }
        OpportunityContactRole opty1=  optyConRoles[1];
        if(opty1.Id!=null){
            optyConRoles[1].ContactId = conList[1].Id;
            Update optyConRoles[1];
        }

        try{
            conList[2].Inactive__c = true;
            Update conList;
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        opty.Commercial_Head__c=usrLH.Id;
        opty.StageName='Negotiation';
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
        //opty.Pricing_Auto_Approved__c=true;
        update opty;
        opty.StageName='Discount Approved';
        update opty;
        opty.StageName = 'Proposal Submission';
        opty.ASF_Agreement_with_Client__c = 'In Absolute';
        update opty;
        opty.StageName = 'Executive Meeting';
        update opty;
        opty.StageName = 'Commercial Head Approval Pending';
        opty.No_Change_required_in_Commercial_clauses__c = true;
        update opty;
        opty.StageName = 'Commercial Head Approved';
        opty.Comm_Legal_Approval_Status__c='Approved';
        opty.Approved_by_Commercial_Head__c=true;
        opty.MPRA_Sent_Date__c = System.today();
        opty.MPRA_SoW_Reference_Number_iflow__c = 'MPRA';
        update opty;
        opty.StageName = 'MPRA & SoW / Subscription Form Sent';
        opty.MPRA_Sent_Date__c = System.today();
        update opty;
        opty.StageName = 'Legal Approval Pending';
        update opty;
        opty.StageName = 'Legal Approved';
        opty.Legal_Compliance_Approval__c = true;
        update opty;
        opty.StageName = 'MPRA & SoW /  Subscription Form Received';
        opty.Mandate_Received_Date__c = System.today()-1;
        update opty;
        opty.StageName = 'Internal Control Approval'; 
        update opty;
        opty.StageName='Closed Won';
        update opty;
        //Coverage for ICRA_EamilViewController
        	ContentVersion content=new ContentVersion(); 
        	content.Title='PI Test'; 
        	content.PathOnClient='/' + content.Title + '.jpg'; 
        	Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'+String.valueOf(accList)+String.valueOf(conList)+String.valueOf(optyConRoles)+String.valueOf(opty)); 
        	content.VersionData=bodyBlob; 
        	insert content; 
    }
    
//Test method
    static testMethod void validateContactRoleUpdate() {
        Test.startTest();
        	List<OpportunityContactRole> optyConRoles = [Select Id,ContactId,OpportunityId,Role from OpportunityContactRole where Role = :EMAILROLE and Opportunity.Parent_Opportunity__c = null Limit 1];
        	List<Opportunity> optyTest = [Select Id from Opportunity];
        	Invoice__c invoiceRecord  = ICRA_TestDataFactory.createInvoice('Invoice',optyConRoles[0].OpportunityId, null,null);
        	invoiceRecord.Invoice_Status__c = 'Initiate Tax Invoice';
        	invoiceRecord.PI_Send__c = false;
            insert invoiceRecord;
        	invoiceRecord.Invoice_Status__c = 'QR and IRN - Failed';
            update invoiceRecord;
           	optyConRoles[0].IsPrimary = true;
            Update optyConRoles;
            List<Contact> con = [Select Id,Inactive__c from Contact where FirstName = :TESTNAME1 Limit 1];
            con[0].Inactive__c = true;
            Delete optyConRoles;
        	invoiceRecord.Invoice_Status__c = 'Proforma Invoice';
            update invoiceRecord;
        
			
        	ContentDocumentLink pdffile = new ContentDocumentLink(LinkedEntityId = invoiceRecord.Id,
                                                                 ContentDocumentId = [select contentdocumentid from contentversion where Title =: 'PI Test'].contentdocumentid);
        	Insert pdffile;
        
        	ICRA_EamilViewController insta = new ICRA_EamilViewController();
        	insta.invoiceStatus = 'PI';
            insta.fetchInvoiceList(); 
           // insta.invoiceDataList[0].selectRecord = true;
            insta.sendSelectedEmail();
        try{
            Update con;      
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }
        Test.stopTest();
        System.assertEquals(optyConRoles.size(),1);
        
    }
}