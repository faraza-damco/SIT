@isTest
public class TestFactory {
  public static Account getAccount(String name, Boolean doInsert){
    Account a = new Account(name = name,Group_Name__c = 'N/A',OFAC_Document_Received__c = true);
    if(doInsert){
      insert a;
    }
    return a;
  }
  public static Contact getContact(Id accountId, String fname, String lname, Boolean doInsert){
    Contact c = new Contact(firstName = fname, lastName = lname, accountId = accountId);
    if(doInsert){
      insert c;
    }
    return c;
  }
  public static void generateAccountWithContacts(Integer numContacts){
    Account a = getAccount('default account ltd', true);
    List<Contact> contacts = new List<Contact>();
    for(Integer i = 0; i < numContacts; i++){
      String contactName = 'contact' + i;
      contacts.add(getContact(a.id, contactName, contactName, false));
    }
    insert contacts;
  }
  public static Opportunity[] generateOppsForAccount(id accountId, Decimal amount, Integer numOpps){
    List<Opportunity> opps = new List<Opportunity>();
    for(Integer i = 0; i < numOpps; i++){
      Opportunity o = new Opportunity();
      o.name = 'Account ' + i;
      o.accountId = accountid;
      o.amount = amount;
      o.closeDate = Date.today().addDays(5);
      o.stageName = 'L1 Meeting';
      opps.add(o);
    }
    return opps;
  }
    public static Branch__c generateBranch(string Name){
        	Branch__c B = new Branch__c(Name = Name);
    	insert B;
    
    return B;
    }
     public static Lead generateLead(string Company,string LastName,string Branch ){
   		Lead l = new Lead(Company = Company,Branch__c=Branch,Classification__c='ICG',LOB__c='Public Finance',Business_Segment__c='Rating',
                      Instrument_1__c='Structured Finance',Instrument_2__c='Rating - Money Market (SF)',
                          Instrument_3__c='Security Receipts',Instrument_4__c='Security Receipts', LastName = LastName);
    	insert l;
    
    return l;
  }
     public static Market_Share__c generateMarketshare(id accountId){
   		Market_Share__c MS = new Market_Share__c(Account__c  = accountId,LT_Rating__c='A+');
    	insert MS;
    
    return MS;
  }
  public static User generateUser(String profileName){
    UserRole userRole = new UserRole(DeveloperName = 'TestingTeam', Name = 'Testing Team');
    insert userRole;
    User u = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
      LastName = 'last',
      Email = 'Cpt.Awesome@awesomesauce.com',
      Username = 'Cpt.Awesome@awesomesauce.com',
      CompanyName = 'Testing Co',
      Title = 'Captian',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
        
      UserRoleId = userRole.Id
    );
    insert u;
    return u;
  }
    public static User createTestUser(Id roleId, Id profID, String fName, String lName,string ManagerIds)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId,
                                UserRoleId = roleId,
                              ManagerId=ManagerIds
                            	 );
        insert tuser;
        return tuser;
    }
    
     public static Sector_Location_Master__c createsectorlocation(string recordtype,Boolean doInsert)
    {  
         Id SectorreRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('Sector Master').getRecordTypeId();
         Id LocationeRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('Location Master').getRecordTypeId();
         Id SFreRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('SF Master').getRecordTypeId();
           
       Sector_Location_Master__c slm=New Sector_Location_Master__c();
        if(recordtype==SectorreRecordTypeId){
            slm.Instrument__c='Rating - Bank Loan Rating';
            slm.Sector__c='Engineering';
            slm.Valid_Value__c='Engineering - Capital Goods';
            slm.RecordTypeId=SectorreRecordTypeId;
        }
         if(recordtype==LocationeRecordTypeId){
            slm.Instrument__c='Rating - Bank Loan Rating';
            slm.Location__c='Mumbai';
            slm.Valid_Value__c='Mumbai';
            slm.RecordTypeId=LocationeRecordTypeId;
        }
         if(recordtype==SFreRecordTypeId){
            slm.SL_NO__c=1.0;
            slm.Min_Yield__c=0.0;
            slm.Max_Yield__c=2.5;
            slm.Target_of_increase__c='15';
            slm.RecordTypeId=SFreRecordTypeId;
        }
        if(doInsert)
        {
            insert slm;
        }
        return slm;            
            
        }
      public static Pricing_Structure__c createPricestructure(string BD_classifaction,Boolean doInsert)
       {  
         Id SectorreRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('Sector Master').getRecordTypeId();
         Id LocationeRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('Location Master').getRecordTypeId();
         Id SFreRecordTypeId = Schema.SObjectType.Sector_Location_Master__c.getRecordTypeInfosByName().get('SF Master').getRecordTypeId();
           
       Pricing_Structure__c prm=New Pricing_Structure__c();
        if(BD_classifaction=='ICG'){
            prm.Instrument__c='Rating - Bank Loan Rating';
            prm.Location__c='Mumbai';
            prm.Sector__c='Engineering';
            prm.BD_Team_Classification__c=BD_classifaction;
            prm.VOD_Min__c=0.0;
            prm.VOD_Max__c=251;
            prm.Target_Yield__c=0.20;
            prm.Min_Fee_Rs_Lacs__c=500000.00;
        }
        if(BD_classifaction=='SECG'){
            prm.Instrument__c='Rating - Bank Loan Rating';
            prm.Location__c='Mumbai';
            prm.Sector__c='Engineering';
            prm.BD_Team_Classification__c=BD_classifaction;
            prm.VOD_Min__c=0.0;
            prm.VOD_Max__c=251;
            prm.Target_Yield__c=2.0;
            prm.Min_Fee_Rs_Lacs__c=35000.00;
        }
        
        if(doInsert)
        {
            insert prm;
        }
        return prm;            
            
        }
      public static Account CreateAccount(String Name, String Recordtype,Boolean doInsert){
        
        Account accountRecord = new Account();
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        accountRecord.Name = Name;
        accountRecord.Account_Classification__c = 'Non-SEZ';
        accountRecord.GST_Number__c = 'GST115451a';
        accountRecord.PAN_Number__c = 'RTYUV5554A';
        accountRecord.TAN_Number__c = 'TAN5454141';
           
          if(doInsert){
             insert accountRecord;
          }
        
        return accountRecord;
    }
        public static Opportunity CreateOpportunityNonstructured_FFF(String Name, String Recordtype,String accountID,Boolean doInsert){
        
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.RecordTypeId =Recordtype;
        opportunityRecord.Name = name;
        opportunityRecord.AccountId = accountID;
        opportunityRecord.Customer_Fee_Type__c='Non - Cap';
        opportunityRecord.Business_Segment__c = 'Rating';
        opportunityRecord.Mandate_Type__c = 'Fresh From Fresh';
        opportunityRecord.Type_Tender__c = 'Non - Tender';
        opportunityRecord.StageName ='L1 Meeting';
        opportunityRecord.Conversion_Probability__c = 'High';
        opportunityRecord.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRecord.Instrument_type_1__c ='Non Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Bank Loan Rating';
        opportunityRecord.Instrument_type_3__c ='Bank Loan Rating';
        opportunityRecord.Instrument_type_4__c ='Bank Loan Rating Fresh';
        opportunityRecord.VoD_in_crore__c =20;
        opportunityRecord.CurrencyIsoCode = 'INR';
        opportunityRecord.Mandate_Received_Date__c =System.today();
        opportunityRecord.GST_Not_Applicable__c = false;
        //opportunityRecord.CloseDate= date.newInstance(2022, 03, 31);
        opportunityRecord.CloseDate = system.today();        
                 
          if(doInsert){
             insert opportunityRecord;
          }
        
        return opportunityRecord;
    }
    
     public static Opportunity CreateOpportunitystructured_FFF(String Name, String Recordtype,String accountID,Boolean doInsert){
        
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.RecordTypeId =Recordtype;
        opportunityRecord.Name = name;
        opportunityRecord.AccountId = accountID;
        opportunityRecord.Customer_Fee_Type__c='Non - Cap';
        opportunityRecord.Business_Segment__c = 'Rating';
        opportunityRecord.Mandate_Type__c = 'Fresh From Fresh';
        opportunityRecord.Type_Tender__c = 'Non - Tender';
        opportunityRecord.StageName ='L1 Meeting';
        opportunityRecord.Conversion_Probability__c = 'High';
        opportunityRecord.Likely_Initial_Rating_Fee__c =1000000;
        opportunityRecord.Instrument_type_1__c ='Structured Finance';
        opportunityRecord.Instrument_type_2__c ='Rating - Money Market (SF)';
        opportunityRecord.Instrument_type_3__c ='Security Receipts';
        opportunityRecord.Instrument_type_4__c ='Pass Through Certificates';
        opportunityRecord.VoD_in_crore__c =20;
        opportunityRecord.CurrencyIsoCode = 'INR';
        opportunityRecord.Mandate_Received_Date__c =System.today();
        opportunityRecord.GST_Not_Applicable__c = false;
        //opportunityRecord.CloseDate= date.newInstance(2022, 03, 31);
        opportunityRecord.CloseDate= system.today();
                 
          if(doInsert){
             insert opportunityRecord;
          }
        
        return opportunityRecord;
    }
   
      public static User createTestUser1(Id profID, String fName, String lName,string ManagerIds)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              Designation__c='xyz',
                              ProfileId = profId,
                              
                              ManagerId=ManagerIds
                             );
        insert tuser;
        return tuser;
    }
    
}