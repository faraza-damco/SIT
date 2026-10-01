/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-19-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   02-19-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class ICRA_TestDataFactory { 
    
    public static Account CreateAccount(String Name, String Recordtype,String BranchId){
        
        Account accountRecord = new Account();
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        accountRecord.Name = Name;
        accountRecord.Account_Classification__c = 'Non-SEZ';
        accountRecord.GST_Number__c = '24AABCU9603R1ZC';
        accountRecord.PAN_Number__c = 'AABCU9603R';
        accountRecord.TAN_Number__c = 'PDES03028F';
        accountRecord.BillingCity ='Office No. 01, 28th Floor';
        accountRecord.BillingStreet ='Gandhinagar';
        accountRecord.BillingPostalCode ='382355';
        accountRecord.BillingState ='Gujarat';
        accountRecord.BillingCountry ='India';
        accountRecord.Group_Name__c = 'NA';
       
        if(BranchId != null){
            accountRecord.branch__c = BranchId;
        }        
         
        return accountRecord;
    }
    
    public static Contact createContact(String name, String billingContact, String recordType, String accountId){
        
        Contact contactRecord = new Contact();
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        contactRecord.LastName = name;
        contactRecord.Billing_Contact__c = billingContact; 
        contactRecord.AccountId = accountId;
        contactRecord.Level__c = 'MD'; 
        contactRecord.Email = 'abc@gmail.com'; 
        contactRecord.MobilePhone = '9999999999';
        contactRecord.Phone = '9880077798';
        return contactRecord;
    }
    public static Branch__c createBranchRecord(String Name){
        Branch__c branchRecord = new Branch__c();
        branchRecord.Name = Name;
        branchRecord.City__c ='Gurugram';
        branchRecord.GSTIN__c ='06AAACI0218B1ZG';
        branchRecord.PAN__c ='AAACI0218B';
        branchRecord.State__c ='Haryana';
        branchRecord.State_Code__c ='06';
        insert branchRecord;
        return branchRecord;
    }
    public static Opportunity creatOpportunity(String name, String recordType, String accountID  ) {//String userId
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        opportunityRecord.Name = name;
        opportunityRecord.AccountId = accountID;
        opportunityRecord.Business_Segment__c = 'Rating';
        opportunityRecord.Mandate_Type__c = 'Fresh From Fresh';
        opportunityRecord.Type_Tender__c = 'Tender';
        opportunityRecord.StageName ='Closed Won';
        opportunityRecord.Conversion_Probability__c = 'High';
        opportunityRecord.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRecord.VoD_in_crore__c = 100;
        opportunityRecord.CurrencyIsoCode = 'INR';
        opportunityRecord.Mandate_Received_Date__c =System.today();
        opportunityRecord.IRF_Final_Amount__c = 1000000;
        opportunityRecord.ASF_Final_Amount__c = 1000000;
        if(opportunityRecord.Name == 'Surveillance'){
            opportunityRecord.Defer_Billing_or_Exit_Case__c = 'To Be Billed'; 
            opportunityRecord.Client_Status__c = 'Live';
        }
        
        ////opportunityRecord.Expected_Deferred_Date__c = System.today();
        //opportunityRecord.Comment__c = 'Deferred';
        opportunityRecord.Non_Cooperation_Withdrawal_Reason__c='Bank/Third party influence';
        opportunityRecord.Revenue_Loss_in_Rs__c=4100;
        opportunityRecord.CloseDate = System.today().addDays(90);
        opportunityRecord.GST_Not_Applicable__c = false;
        opportunityRecord.Billing_Start_Date__c = System.today();
        opportunityRecord.BD_Approve__c = false;
        opportunityRecord.Billing_END_Date__c = system.today().addYears(1);
         opportunityRecord.Proforma_Invoice_ok__c = true;
        opportunityRecord.Amount_To_Be_Billed__c = 10; 
        
        return opportunityRecord;
        
    }
    
    public static Invoice__c createInvoice(String recordType, String opportunityID, String invoiceNo,String invoiceStatus){
        
        Invoice__c invoiceRecord = new Invoice__c();
        invoiceRecord.RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        invoiceRecord.Opportunity_Name__c = opportunityID;
        invoiceRecord.Invoice_No__c = invoiceNo;
        invoiceRecord.Revised_agreed_amount__c = 1000000 ;
        invoiceRecord.Invoice_Status__c = invoiceStatus;
              
       // insert invoiceRecord;
        return invoiceRecord;
        
    }
    public static Invoice_Line_Item__c  createInvoiceLineItem(String invoiceId, String opportunityId  ){
        
        Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
        invoiceLineItemRecord.Opportunity_Name__c = opportunityId;
        invoiceLineItemRecord.Invoice_No__c =invoiceId;
         
        insert invoiceLineItemRecord;
        return invoiceLineItemRecord;
        
    }
    
    public static Payment_Receipt__c createPaymentReceipt(String opportunityId, String InvoiceId){
        
        Payment_Receipt__c paymentReceiptRecord = new Payment_Receipt__c(); 
        paymentReceiptRecord.Opportunity__c = opportunityId; 
        paymentReceiptRecord.Invoice_No__c = InvoiceId; 
        paymentReceiptRecord.Gross_Amount__c = 5; 
        return paymentReceiptRecord;
    } 
    
    public static void loadCustomeSetting(){
        Bank_Account_Setting__c  bankAccount  =  new Bank_Account_Setting__c();
        bankAccount.Account_Name__c ='Test';
        bankAccount.Bank_Address__c = 'Test Address';
        bankAccount.Name = 'Test';
        Insert bankAccount;
        
        Invoice_Footer_Setting__c invoiceFooter = new Invoice_Footer_Setting__c();
        invoiceFooter.CIN__c ='CIN';
        invoiceFooter.Name='Test';        
        Insert invoiceFooter;
        
        Invoice_Static_Text__c staticText = new Invoice_Static_Text__c();
        staticText.Description_A__c = 'Test';
        staticText.Name = 'Test';
        Insert staticText;   
        
        Manual_Invoice_Static_Text__c manualStaticText = new Manual_Invoice_Static_Text__c();
        manualStaticText.Description__c = 'Test';
        manualStaticText.Service_Code__c = 'Test';
        manualStaticText.Name = 'Inter-Branch Invoice';
        insert manualStaticText;        
        
    }
    public static Manual_Invoice__c createManualInvoice (String recordType,String AccountId,String ContactId,String irn,String qrcode){
        Manual_Invoice__c manualInvoice = new  Manual_Invoice__c();
        manualInvoice.RecordTypeId = Schema.SObjectType.Manual_Invoice__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        manualInvoice.Account_Name__c = AccountId;
        manualInvoice.Contact_Name__c = ContactId;
       // manualInvoice.Invoice_Date__c = invoiceDate;
        manualInvoice.IRN_Number__c = irn ;
        manualInvoice.QR_Code__c = qrcode;
        insert manualInvoice;
        return manualInvoice;
    }
    public static Manual_Invoice__c createISDrecord(String recordType,String BranchId){
        Manual_Invoice__c manualISD = new Manual_Invoice__c();
        manualISD.RecordTypeId = Schema.SObjectType.Manual_Invoice__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        manualISD.Branch__c = BranchId;
        manualISD.CGST__c = 100;
        manualISD.SGST__c = 100;
        manualISD.IGST__c = 0; 
        insert manualISD;
        return manualISD;
    }
    public static Manual_Invoice__c createInterBranch(String recordType,String SBranchId,String DBranchId){
        Manual_Invoice__c manualInterBranchRecord = new Manual_Invoice__c();
        manualInterBranchRecord.RecordTypeId = Schema.SObjectType.Manual_Invoice__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        manualInterBranchRecord.Source_Branch_1__c = SBranchId;
        manualInterBranchRecord.Destination_Branch__c = DBranchId;
        manualInterBranchRecord.Amount__c = 100000;
        manualInterBranchRecord.Base_Amount_Received_Inter_Branch__c = 1000;
        insert manualInterBranchRecord;
        return manualInterBranchRecord;
    }
    public static Manual_Invoice_Line_Item__c createManualInvoiceLineItem (String manualInvoiceId){
        
        Manual_Invoice_Line_Item__c manualLineItemRecord = new Manual_Invoice_Line_Item__c();
        manualLineItemRecord.Invoice_No__c = manualInvoiceId;
        manualLineItemRecord.Base_Amount_Received__c = 10000;
        manualLineItemRecord.Invoice_Taxable_Amount__c = 100000;
        insert manualLineItemRecord;
        return manualLineItemRecord;
    }
    public static Debtor_Invoice__c createDebtorInvoiceRecord (String AccountID,Integer TotalAmount){
        Debtor_Invoice__c debtorInvoiceRecord  = new Debtor_Invoice__c();
        debtorInvoiceRecord.Account__c = AccountID;
        debtorInvoiceRecord.BIll_No__c = 'Testing';
        debtorInvoiceRecord.Total_Invoice_Amount__c = 10000;
        debtorInvoiceRecord.Total_Outstanding_Amount_including_GST__c = TotalAmount;
        
       // insert debtorInvoiceRecord;
        return debtorInvoiceRecord;
    }
    
    public static Debtor_Payment__c createDebtorPayment (String AccountId, String DebtorInvoiceID){
        Debtor_Payment__c debtorPaymentRecord = new Debtor_Payment__c();
        debtorPaymentRecord.Account_Name__c = AccountId;
        debtorPaymentRecord.Debtor_Invoice__c = DebtorInvoiceID;
        debtorPaymentRecord.Gross_Amount_Manual__c = 1000;
        insert debtorPaymentRecord;
        return debtorPaymentRecord;
    }
   /* public static Profile createProfile(String Name){
        Profile profile = new Profile();
        profile
        //insert profile;
        return profile;
        
    }*/
    public static User createUser(String Name,String Email,String LastName,String Username,String manager,String profile){
        User user = new User();
        //user.Name = Name;
        user.Email = Email;
        user.LastName = LastName;
        user.FirstName = Name;
        user.Username = Username;
        user.ManagerId = manager;
        user.ProfileId = profile;
        insert user;
        return user;
    }
}