global class EmailReminder_Debtors_Batch_More_1year implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String debtorEmail = 'Yes';
        String debtorType = 'After 1year';
        String  InvoiceQuery ='';
        if(! test.isRunningTest()){
            InvoiceQuery = 'SELECT Id, Name,Bill_No__c,Account_ID__c,Debtor_Type__c,Contact_Name__r.Account.Outstanding_Amount__c,Email_Send_at__c,Total_Invoice_Amount__c,Opportunity_Name__r.Name,Opportunity_Name__r.ASF_Final_Amount__c,Opportunity_Name__r.Debtors_Ageing__c,Contact_Name__c,Contact_Name__r.Check_Debtor_Email_1_year__c,Contact_Name__r.Contact_Debtor_Type__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c  WHERE Contact_Name__r.Email != null AND Contact_Name__r.Debtor_Email__c = :debtorEmail AND Opportunity_Name__r.Debtors_Ageing__c > 365 AND Total_Invoice_Amount__c  >= 100000 AND Contact_Name__r.Account.Historical_Debtor_Ageing__c > 365 AND Contact_Name__r.Account.Outstanding_Amount__c > 100000 AND Contact_Name__r.Contact_Debtor_Type__c =: debtorType';
        }else{
            InvoiceQuery = 'SELECT Id, Name,Bill_No__c,Account_ID__c,Debtor_Type__c,Contact_Name__r.Account.Outstanding_Amount__c,Email_Send_at__c,Total_Invoice_Amount__c,Opportunity_Name__r.Name,Opportunity_Name__r.ASF_Final_Amount__c,Opportunity_Name__r.Debtors_Ageing__c,Contact_Name__c,Contact_Name__r.Check_Debtor_Email_1_year__c,Contact_Name__r.Contact_Debtor_Type__c,Contact_Name__r.Name, Contact_Name__r.Email FROM Invoice__c';
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
                
                EmailTemplate [] emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Debtors_Email_1_year' LIMIT 1];
                if(emailTemplate.size() > 0){
                    email_record.setTemplateID(emailTemplate[0].Id);  
                }  
                email_record.setWhatId(invoiceRecord.Opportunity_Name__r.Id);   
                email_record.setToAddresses(new List<String> {invoiceRecord.Contact_Name__r.Email});
                emailSet.add(email_record);
                accountIdSet.add(invoiceRecord.Contact_Name__r.AccountId);
                invoiceRecord.Debtor_Type__c = 'After 1year';
                invoiceRecord.Email_Send_at__c = 'After 1year';
                invoiceRecord.Contact_Name__r.Check_Debtor_Email_1_year__c = true;
                updateDebtorpicklist.add(invoiceRecord);
            }
            
         }
        
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.addAll(emailSet);
        
        Messaging.sendEmail(emailList);
        List<Account> accountList = new List<Account>();
        for(Account acc : [SELECT Id,Name,Email_Send_at__c FROM Account WHERE Id =: accountIdSet]){
            acc.Email_Send_at__c = 'After 1year';
            accountList.add(acc);
        }
        
        if(accountList.size() > 0){
            update accountList;
        }
        if(updateDebtorpicklist.size() > 0){
            update updateDebtorpicklist;
        }
        List<Debtor_Invoice__c> updateCheckEmailFlag = new  List<Debtor_Invoice__c>();
        
        for(Debtor_Invoice__c updateDebtor : [SELECT Id,Name,Bill_No__c,Email_Already_Send__c,Invoice_Date__c,Account__r.Name,Total_Invoice_Amount__c,Account__r.Total_Oustanding_Debtor_Invoice_Amount__c,Account__r.Historical_Debtor_Ageing__c,Account__r.Id,Account__r.Contact_Name__r.Email,Account__r.Contact_Name__r.Contact_Debtor_Type__c 
                                              FROM Debtor_Invoice__c 
                                              WHERE Account__r.Id =: accountIdSet AND
                                              Email_Already_Send__c = false AND
                                              Account__r.Contact_Name__r.Email != null AND
                                              Account__r.Contact_Name__r.Contact_Debtor_Type__c = 'After 1year' AND
                                              Account__r.Historical_Debtor_Ageing__c > 365 AND
                                              Account__r.Total_Oustanding_Debtor_Invoice_Amount__c > 100000 
                                             ]){ 
                                                  updateDebtor.Email_Already_Send__c = true ;
                                                 updateCheckEmailFlag.add(updateDebtor);
                                              }
        if(updateCheckEmailFlag.size() > 0){
            
            update updateCheckEmailFlag;
        }
     }
    
    
    global void finish(Database.BatchableContext BC){
    }
    
}