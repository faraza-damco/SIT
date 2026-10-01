@isTest
public class Total_VoD_Calculation_Batch_Test {
 private static final String TESTNAME1 = 'ConRoleTest';
    private static final String SURVEILLANCE = 'Surveillance'; 
    private static final String ISSUER = 'Issuer';
    private static final String INVOICEROLE = 'Name on Invoice';
    @isTest
    static void testBatchExecution() {

      
        Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User usrLH = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdmin.Id
        );
        insert usrLH;

        System.runAs(usrLH) {

            // Disable triggers
            Triggers_status__c tg = new Triggers_status__c(
                OpportunityTrigger__c = false,
                PromotorCompany__c = false,
                Fee_Calculation__c = false
            );
            insert tg;
            
                    Branch__c branchRecord = ICRA_TestDataFactory.createBranchRecord('Gurgaon');
        
        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id;
        businessSector.ICRA_Branch__c = branchRecord.Id;
        insert businessSector;

            // -----------------------------
            // 2. Create required Account
            // -----------------------------
           Account acc =  ICRA_TestDataFactory.CreateAccount(TESTNAME1, ISSUER, null); 
        acc.PAN_Number__c = 'AAFCR5512V';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='Japan';
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

            // -----------------------------
            // 3. Create Opportunities that satisfy WHERE clause
            // -----------------------------
            // Get Surveillance record type
            Id survRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Surveillance').getRecordTypeId();

            Opportunity opp1 = new Opportunity(
                Name = 'Opty1',
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                AccountId = acc.Id,
                RecordTypeId = survRT,
                Instrument_Category__c = 'BLR',       // REQUIRED FOR BATCH
                Billing_Start_Date__c = Date.today(), // REQUIRED for getLatestOpp()
                VoD_in_crore__c = 50,
                Bypass_Validation__c = true
            );

            insert opp1;

            // Add a second opp under same category to test summation
            Opportunity opp2 = new Opportunity(
                Name = 'Opty2',
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                AccountId = acc.Id,
                RecordTypeId = survRT,
                Instrument_Category__c = 'BLR',
                Billing_Start_Date__c = Date.today().addDays(1),
                Size_to_be_rated_this_year_in_Cr_M__c = 20,
                Bypass_Validation__c = true
            );
            insert opp2;

            // -----------------------------
            // 4. Run Batch
            // -----------------------------
            Test.startTest();
            Database.executeBatch(new Total_VoD_Calculation_Batch(), 5);
            Test.stopTest();

            // -----------------------------
            // 5. Validate Results
            // -----------------------------
            Opportunity updatedOpp1 = [
                SELECT Total_VoD_at_Instrument_Category__c
                FROM Opportunity WHERE Id = :opp1.Id
            ];

            Opportunity updatedOpp2 = [
                SELECT Total_VoD_at_Instrument_Category__c
                FROM Opportunity WHERE Id = :opp2.Id
            ];

            // Total for category BLR should = 50 (opp1) + 20 (opp2) = 70
            System.assertEquals(70, updatedOpp1.Total_VoD_at_Instrument_Category__c,
                'Opp1 should have total VOD = 70');

            System.assertEquals(70, updatedOpp2.Total_VoD_at_Instrument_Category__c,
                'Opp2 should have total VOD = 70');
        }
    }
}