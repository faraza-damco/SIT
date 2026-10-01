global class ICRA_DebtorEmail_6to12months implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String InvoiceQuery = '';
        String debtorEmail = 'Yes';
        String debtorType = '1year';
        if(! test.isRunningTest()){
            InvoiceQuery = 'SELECT Id, Name,Bill_No__c,Debtor_Type__c,Email_Send_at__c,Opportunity_Name__r.Debtors_Ageing__c,Contact_Name__r.AccountId,Contact_Name__c,Contact_Name__r.Check_Debtor_Email_1_year__c,Contact_Name__r.Contact_Debtor_Type__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c  WHERE Contact_Name__r.Email != null AND Contact_Name__r.Debtor_Email__c = :debtorEmail AND Opportunity_Name__r.Debtors_Ageing__c > 180 AND Opportunity_Name__r.Debtors_Ageing__c <= 365 AND  Contact_Name__r.Account.Historical_Debtor_Ageing__c > 180 AND Contact_Name__r.Account.Historical_Debtor_Ageing__c <= 365  AND Contact_Name__r.Contact_Debtor_Type__c =: debtorType';
        }
        else{
            InvoiceQuery = 'SELECT Id, Name,Bill_No__c,Debtor_Type__c,Email_Send_at__c,Opportunity_Name__r.Debtors_Ageing__c,Contact_Name__r.AccountId,Contact_Name__c,Contact_Name__r.Check_Debtor_Email_1_year__c,Contact_Name__r.Contact_Debtor_Type__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c';
        }
        return Database.getQueryLocator(InvoiceQuery);
     }
    global void execute(Database.BatchableContext BC,List<Invoice__c> InvoiceList){
          Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Invoice__c> updateDebtorpicklist = new List<Invoice__c>();
         for(Invoice__c invoiceRecord : InvoiceList){
            if(invoiceRecord.Contact_Name__r.Check_Debtor_Email_1_year__c == false){
                 Messaging.SingleEmailMessage email_record = new Messaging.SingleEmailMessage();
                email_record.setTargetObjectId(invoiceRecord.Contact_Name__c);  
                 EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Debtor_Email_6to12_months' LIMIT 1];
                email_record.setTemplateID(emailTemplate.Id);
                email_record.setWhatId(invoiceRecord.Opportunity_Name__r.Id);
                email_record.setToAddresses(new List<String> {invoiceRecord.Contact_Name__r.Email});
                 emailSet.add(email_record);
                accountIdSet.add(invoiceRecord.Contact_Name__r.AccountId);
                invoiceRecord.Debtor_Type__c = '1year';
                invoiceRecord.Email_Send_at__c = '1year';
                updateDebtorpicklist.add(invoiceRecord);
            }
        }
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.addAll(emailSet);
        Messaging.sendEmail(emailList);
        List<Account> accountList = new List<Account>();
        for(Account acc : [SELECT Id,Name,Email_Send_at__c FROM Account WHERE Id =: accountIdSet]){
            acc.Email_Send_at__c = '1year';
            accountList.add(acc);
        }
         if(accountList.size() > 0){
            update accountList;
        }
        if(updateDebtorpicklist.size() > 0){
            update updateDebtorpicklist;
        }
        List<Debtor_Invoice__c> updateCheckEmailFlag = new  List<Debtor_Invoice__c>();
         for(Debtor_Invoice__c updateDebtor : [SELECT Id,Name,Bill_No__c,Invoice_Date__c,Email_Already_Send__c,Account__r.Name,Total_Invoice_Amount__c,Account__r.Total_Oustanding_Debtor_Invoice_Amount__c,Account__r.Historical_Debtor_Ageing__c,Account__r.Id,Account__r.Debtor_Balance_Amount__c 
                          FROM Debtor_Invoice__c 
                          WHERE (Account__r.Id =: accountIdSet AND
                                 Account__r.Contact_Name__r.Email != null AND
                                 Email_Already_Send__c = false AND 
                                 Account__r.Historical_Debtor_Ageing__c > 180 AND
                                 Account__r.Historical_Debtor_Ageing__c <= 365) 
                          OR(
                              Account__r.Id =: accountIdSet AND
                              Account__r.Contact_Name__r.Email != null AND
                              Email_Already_Send__c = false AND
                              Account__r.Total_Oustanding_Debtor_Invoice_Amount__c < 100000 AND
                              Account__r.Historical_Debtor_Ageing__c > 365)
                          ]){ 
              updateDebtor.Email_Already_Send__c = true ;
                updateCheckEmailFlag.add(updateDebtor);
               
        }
        if(updateCheckEmailFlag.size() > 0){
            
            update updateCheckEmailFlag;
        } 
     }
    global void finish(Database.BatchableContext BC){
        system.debug('Executed'+BC);
    }
 }