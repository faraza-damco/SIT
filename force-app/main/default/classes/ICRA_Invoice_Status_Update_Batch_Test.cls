@IsTest
private class ICRA_Invoice_Status_Update_Batch_Test {

    @IsTest
    static void testInvoiceCounterIncrement() {
        String SURVEILLANCE = 'Surveillance'; 
        String TESTNAME1 = 'TestAccount';
        String ISSUER = 'Issuer';   
        String TESTNAME2 = 'TestNameRole';
        String TESTNAME3 = 'TestRole';
        String TESTNAME4 = 'NameRole';
        String DESIGNATION = 'Asst Mngr';
        String DESIGNATION2 = 'A M';
        String EMAIL = 'test@testing.com';
        String CONEMAIL = 'testcontactrole@abc.com';
        String CONEMAIL2 = 'test@abcxyz.com';
        String INVOICEROLE = 'Name on Invoice';
        String PROPOSALPRIMARY_ROLE = 'Proposal Primary Contact';
        String MPRA_ROLE = 'MPRA/SOW';
        String MPRA_Sent = 'MPRA & SoW / Subscription Form Sent';
        String EMAILROLE = 'Email Recipient';

        Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        branchRecord.Updated_Surveillance_fees_Sequence__c = 100;
        update branchRecord;

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

        Opportunity SurvOpty = ICRA_TestDataFactory.creatOpportunity('Surveillance_Opty', SURVEILLANCE, acc.Id);
        //SurvOpty.Parent_Opportunity__c = Opty.Id;
        SurvOpty.Rollover_Check__c = true;
        SurvOpty.Opp_ICRA_Branch__c = branchRecord.Id;
        SurvOpty.Non_Cooperation_Withdrawal_Reason__c = 'Others';
        SurvOpty.Billing_Start_Date__c = System.today().addDays(5);
        SurvOpty.Billing_End_Date__c = System.today().addDays(50);
        insert SurvOpty;
    
        List<OpportunityContactRole> optyConRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                ContactId = conList[0].Id,
                OpportunityId = SurvOpty.Id,
                IsPrimary = true,
                Role = EMAILROLE),
                new OpportunityContactRole(
                    ContactId = conList[4].Id,
                    OpportunityId = SurvOpty.Id,
                    Role = PROPOSALPRIMARY_ROLE),
                new OpportunityContactRole(
                    ContactId = conList[1].Id,
                    OpportunityId = SurvOpty.Id,
                    IsPrimary = true,
                    Rollover_Check__c = true,
                    Role = INVOICEROLE)
         };

        try{
            Insert optyConRoles;//Expecting No Email on Contact Error
        }catch(Exception ex){
            System.debug('%%%Exception- '+ex.getMessage());
        }

        // Create multiple invoices WITHOUT billing number
        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Integer i = 0; i < 3; i++) {
            invoices.add(new Invoice__c(
                Opportunity_Name__c = SurvOpty.Id,
                Billing_Number__c = null,
                Invoice_Status__c='Proforma Invoice'
            ));
        }
        insert invoices;

        Test.startTest();
        invokeBatch_Invoice_Status_Update.invokeBatch();
        Test.stopTest();

        // Reload Centre
        Branch__c updatedCentre = [
            SELECT Updated_Surveillance_fees_Sequence__c
            FROM Branch__c
            WHERE Id = :branchRecord.Id
        ];

        // Reload Invoices
        List<Invoice__c> updatedInvoices = [
            SELECT Billing_Number__c
            FROM Invoice__c
            WHERE Opportunity_Name__c = :SurvOpty.Id
            ORDER BY Billing_Number__c ASC
        ];

        System.assertEquals(
            103,
            updatedCentre.Updated_Surveillance_fees_Sequence__c,
            'Branch counter should increment by number of invoices'
        );

        System.assertEquals(3, updatedInvoices.size());

        // Verify sequential numbering
        System.assertEquals(101, updatedInvoices[0].Billing_Number__c);
        System.assertEquals(102, updatedInvoices[1].Billing_Number__c);
        System.assertEquals(103, updatedInvoices[2].Billing_Number__c);
    }

    @IsTest
    static void testNoInvoicesDoesNothing() {

        Branch__c centre = new Branch__c(
            Name = 'Empty Centre',
            Updated_Surveillance_fees_Sequence__c = 5
        );
        insert centre;

        Test.startTest();
        invokeBatch_Invoice_Status_Update.invokeBatch();
        Test.stopTest();

        Branch__c refreshed = [
            SELECT Updated_Surveillance_fees_Sequence__c
            FROM Branch__c
            WHERE Id = :centre.Id
        ];

        System.assertEquals(
            5,
            refreshed.Updated_Surveillance_fees_Sequence__c,
            'Counter must not change when no invoices exist'
        );
    }
}