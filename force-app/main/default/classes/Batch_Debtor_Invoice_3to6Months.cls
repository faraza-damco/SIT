global class Batch_Debtor_Invoice_3to6Months implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String debtorInvoiceQuery = '';
        if(! Test.isRunningTest()){
            debtorInvoiceQuery = 'SELECT Id,Name,Bill_No__c,Invoice_Date__c,Account__r.Name,Total_Invoice_Amount__c,Account__r.Total_Oustanding_Debtor_Invoice_Amount__c,Account__r.Historical_Debtor_Ageing__c,Email_Already_Send__c,Account__r.Id,Account__r.Debtor_Balance_Amount__c FROM Debtor_Invoice__c WHERE Account__r.Historical_Debtor_Ageing__c > 90 AND Account__r.Historical_Debtor_Ageing__c <= 180 AND Email_Already_Send__c = false';
        }else{
            debtorInvoiceQuery = 'SELECT Id,Name,Bill_No__c,Invoice_Date__c,Account__r.Name,Total_Invoice_Amount__c,Account__r.Total_Oustanding_Debtor_Invoice_Amount__c,Account__r.Historical_Debtor_Ageing__c,Email_Already_Send__c,Account__r.Id,Account__r.Debtor_Balance_Amount__c FROM Debtor_Invoice__c';
        }
        return Database.getQueryLocator(debtorInvoiceQuery);
    }
     global void execute(Database.BatchableContext BC,List<Debtor_Invoice__c> debtorInvoiceList){
        
        Map<Id,List<Contact>> contactMap = new Map<Id,List<Contact>>();
        
        Set<Id> accountSet = new Set<Id>();
        
        List<Debtor_Invoice__c> updateCheckEmailFlag = new  List<Debtor_Invoice__c>();
        
        Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>();
        
        for(Debtor_Invoice__c debtor : debtorInvoiceList){
            accountSet.add(debtor.Account__c);
        }
        
        for(Contact contactRecord : [SELECT Id,Name,Email,Contact_Debtor_Type__c,Debtor_Email__c,AccountId 
                                     FROM Contact
                                     WHERE Contact_Debtor_Type__c = '180Days' AND
                                     Email  != null AND
                                     Debtor_Email__c = 'Yes' AND
                                     AccountId IN :accountSet                          
                                    ]) { 
                                        Messaging.SingleEmailMessage email_record = new Messaging.SingleEmailMessage();
                                        email_record.setTargetObjectId(contactRecord.Id);
                                        
                                        EmailTemplate [] emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Debtor_Invoices_Email_3to6_months' LIMIT 1];
                                        if(emailTemplate.size() > 0){
                                            email_record.setTemplateID(emailTemplate[0].Id);  
                                        }
                                        email_record.setWhatId(contactRecord.accountId);  
                                        email_record.setToAddresses(new List<String> {contactRecord.Email});
                                        emailSet.add(email_record);                        
                                     }
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.addAll(emailSet);
        
        Messaging.sendEmail(emailList);
    }
     global void finish(Database.BatchableContext BC){
    }
    
}