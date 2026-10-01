@isTest
public with sharing class MPRA_SOW_EmailHandler_Test {
    @isTest
    public static void EmailHandler(){

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //ICRA_TestDataFactory
        User usrLH = TestFactory.createTestUser1(pf.Id, 'Test FirstName', 'Test LastName',null);
        usrLH.MobilePhone='1234567890';
        usrLH.Branch__c='Gurugram';
        usrLH.Designation__c='VP';
        usrLH.City='Gurugram';
        update usrLH;
        
        Branch__c branchRecord = new Branch__c();
        branchRecord.Name = 'Gurugram';
        branchRecord.City__c ='Gurugram';
        branchRecord.Street__c ='Gurugram';
        branchRecord.GSTIN__c ='06AAACI0218B1ZG';
        branchRecord.PAN__c ='AAACI0218B';
        branchRecord.State__c ='Haryana';
        branchRecord.State_Code__c ='06';
        branchRecord.Authorized_Signatory__c=usrLH.Id;
        insert branchRecord;

        Business_Sector__c businessSector = new Business_Sector__c();
        businessSector.Name = 'Infrastructure';
        businessSector.Business_Head__c =  usrLH.Id; 
        businessSector.OFAC_Approver__c = usrLH.Id; 
        businessSector.Opportunity_Checker__c = usrLH.Id; 
        insert businessSector;
        
        Account Acc=TestFactory.getAccount('XYZ', false);
        acc.PAN_Number__c = 'AAFCR5512V';
       	//acc.GST_Number__c = '24AAACI0218B1ZG';
        acc.Group_Name__c = 'testDamco';
        acc.Business_Sector__c= businessSector.Id;
        Acc.ShippingCity ='Delhi';
        Acc.ShippingStreet ='Office No. 01, 28th Floor';
        Acc.ShippingPostalCode ='110001';
        Acc.ShippingState ='Delhi';
        Acc.ShippingCountry ='India';
        Acc.Account_Status__c ='Active';
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
        insert billingAddr;

        Acc.Billing_Address__c= billingAddr.Id;
        update Acc;
        
        Contact Contact =TestFactory.getContact(Acc.Id,'abxd','xyz1',true);
        Contact.Billing_Contact__c='Yes';
        Contact.Email='xyz@mail.com';
        Contact.Salutation='Mr.';
        Contact.Designation__c='test' ; 
        Contact.MailingStreet='xyz1'; Contact.MailingCity='Delhi';
        Contact.MailingState='Delhi' ; Contact.MailingPostalCode='110001';
        Contact.MailingCountry='India' ; Contact.Phone='+9188345678' ;
        update Contact;

        List<Opportunity> Opp=TestFactory.generateOppsForAccount(Acc.Id,1,1);
        Opp[0].Contact__c=Contact.Id;
        Opp[0].VoD_in_crore__c=150;
        Opp[0].Send_MPRA__C=true;
        Opp[0].ownerId=usrLH.Id;
        Opp[0].IRF_Final_Amount__c=134;
        Opp[0].ASF_Final_Amount__c=156;
        Opp[0].Amount_To_Be_Billed__c=156;
        Opp[0].Contact_for_Proposal__c=Contact.Id;
        Opp[0].Contact_for_MPRA_SOW__c=Contact.Id;
        Opp[0].Date_of_Proposal__c=system.today();
        Opp[0].Business_Segment__c = 'Rating';
        Opp[0].Instrument_type_1__c = 'Non Structured Finance';
        Opp[0].Instrument_type_2__c = 'Rating - Bank Loan Rating';
        Opp[0].Instrument_type_3__c = 'Bank Loan Rating';
        Opp[0].Instrument_type_4__c = 'Bank Loan Rating Fresh';
        Opp[0].Customer_Fee_Type__c='Non - Cap';
        Opp[0].MPRA_Sent_Date__c=System.today();
        insert Opp;

        List<OpportunityContactRole> optyConRoleList= new List<OpportunityContactRole>();
        OpportunityContactRole optyConRole1 = new OpportunityContactRole();
        optyConRole1.OpportunityId= Opp[0].Id;
        optyConRole1.ContactId= Contact.Id;
        optyConRole1.Role= 'MPRA/SOW';
        optyConRoleList.add(optyConRole1);
        insert optyConRoleList;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.Subject= 'Re: Opportunity Id: '+Opp[0].Id+ ' Million (Issuer Rating) Rating Programme';
        email.fromAddress = 'test@example.com';
        email.plainTextBody = 'Test Body';
        email.HtmlBody='htmltext';
        //List<String> toAddress= new List<String>{'to@test.com','to@test1.com'};
        email.toAddresses= new List<String>{'to@test.com','to@test1.com'};
        String toAddressStr= String.join(email.toAddresses, ';');
        //email.toAddresses=toAddress;
        email.fromName= 'From Name';
        List<String> ccAddress= new List<String>{'to@test.com','to@test1.com'};
        email.ccAddresses= new List<String>{'to@test.com','to@test1.com'};
        String ccAddressStr= String.join(email.ccAddresses, ';');

        EmailMessage emailMsg= new EmailMessage();
        emailMsg.Subject= email.subject;
        emailMsg.TextBody= email.plainTextBody;
        emailMsg.HtmlBody= email.htmlBody;
        emailMsg.status= '3';
        emailMsg.MessageDate= System.Now();
        emailMsg.FromAddress= email.fromAddress;
        emailMsg.FromName= email.fromName;

        emailMsg.toAddress= toAddressStr;
        //String ccAddressStr= String.join(ccAddress, ';');
        emailMsg.ccAddress= ccAddressStr;

        env.fromAddress= 'abc@test.com';

        Messaging.InboundEmail.BinaryAttachment binaryAttach = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttach.body = blob.valueOf('my test binary attachment text');
        binaryAttach.fileName = 'testDoc.txt';
        binaryAttach.mimeTypeSubType = 'text/plain';
        
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] {binaryAttach};
        MPRA_SOW_EmailHandler emailHandlerClass = new MPRA_SOW_EmailHandler();
        emailHandlerClass.handleInboundEmail(email, env);
        
        
    }
}