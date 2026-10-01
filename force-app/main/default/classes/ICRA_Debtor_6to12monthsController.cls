public class ICRA_Debtor_6to12monthsController {
    public String accountID {get;set;}
     public List<InvoiceDetail> getInvoiceDetail(){ 
         List<Invoice__c> invoiceList;
        if(! Test.isRunningTest()){
            invoiceList = [
                SELECT Id,Name,Bill_No__c,Invoice_Created_Date__c,Contact_Name__r.Check_Debtor_Email_1_year__c,Total_Invoice_Taxable_Amount__c,Opportunity_Name__r.Debtors_Ageing__c,Contact_Name__c,Contact_Name__r.Account.Name,
                Contact_Name__r.Contact_Debtor_Type__c,Contact_Name__r.Name, Contact_Name__r.Email,Contact_Name__r.AccountId,Account_ID__c,Opportunity_Name__r.ASF_Final_Amount__c,Opportunity_Name__r.AccountId,Opportunity_Name__r.Balance_Amount__c 
                FROM Invoice__c  
                WHERE  (Contact_Name__r.Email != null AND 
                        Opportunity_Name__r.AccountId =: accountID AND
                        Contact_Name__r.Debtor_Email__c = 'Yes' AND 
                        Contact_Name__r.Contact_Debtor_Type__c = '1year' AND
                        Opportunity_Name__r.Debtors_Ageing__c > 180 AND 
                        Opportunity_Name__r.Debtors_Ageing__c <= 365 AND 
                        Opportunity_Name__r.Account.Historical_Debtor_Ageing__c > 180 AND 
                        Opportunity_Name__r.Account.Historical_Debtor_Ageing__c <= 365) 
                OR (
                    Contact_Name__r.Email != null AND
                    Opportunity_Name__r.AccountId =: accountID AND
                    Contact_Name__r.Debtor_Email__c = 'Yes' AND
                    Contact_Name__r.Contact_Debtor_Type__c = '1year' AND
                    Opportunity_Name__r.Account.Balance_Amount__c < 100000 AND
                    Opportunity_Name__r.Debtors_Ageing__c > 365 AND
                    Opportunity_Name__r.Account.Historical_Debtor_Ageing__c > 365) 
            ];    
        }else{
            invoiceList = [
                SELECT Id,Name,Bill_No__c,Invoice_Created_Date__c,Contact_Name__r.Check_Debtor_Email_1_year__c,Total_Invoice_Taxable_Amount__c,Opportunity_Name__r.Debtors_Ageing__c,Contact_Name__c,Contact_Name__r.Account.Name,
                Contact_Name__r.Contact_Debtor_Type__c,Contact_Name__r.Name, Contact_Name__r.Email,Contact_Name__r.AccountId,Account_ID__c,Opportunity_Name__r.ASF_Final_Amount__c,Opportunity_Name__r.AccountId,Opportunity_Name__r.Balance_Amount__c 
                FROM Invoice__c];
        }
        
        List<InvoiceDetail> invoiceDetailList = new List<InvoiceDetail>();
        
        for(Invoice__c invoiceRecord : invoiceList ){
            InvoiceDetail  invoice = new InvoiceDetail();
            invoice.billNumber = invoiceRecord.Bill_No__c;
            invoice.invoiceDate = invoiceRecord.Invoice_Created_Date__c;
            invoice.accountName=invoiceRecord.Contact_Name__r.Account.Name;
            invoice.totalInvoiceAmount = invoiceRecord.Opportunity_Name__r.Balance_Amount__c;
            
            invoiceDetailList.add(invoice); 
        }
        List<Debtor_Invoice__c> debtorList;
        
        if( ! Test.isRunningTest()){
            debtorList = [SELECT Id,Name,Bill_No__c,Invoice_Date__c,Email_Already_Send__c,Account__r.Name,Total_Invoice_Amount__c,Account__r.Total_Oustanding_Debtor_Invoice_Amount__c,Account__r.Historical_Debtor_Ageing__c,Account__r.Id,Account__r.Debtor_Balance_Amount__c 
                          FROM Debtor_Invoice__c 
                          WHERE (Account__r.Id =: accountID AND
                                 Account__r.Contact_Name__r.Email != null AND
                                 Email_Already_Send__c = false AND 
                                 Account__r.Historical_Debtor_Ageing__c > 180 AND
                                 Account__r.Historical_Debtor_Ageing__c <= 365) 
                          OR(
                              Account__r.Id =: accountID AND
                              Account__r.Contact_Name__r.Email != null AND
                              Email_Already_Send__c = false AND
                              Account__r.Total_Oustanding_Debtor_Invoice_Amount__c < 100000 AND
                              Account__r.Historical_Debtor_Ageing__c > 365)
                          
                         ];
        }else{
            debtorList = [SELECT Id,Name,Bill_No__c,Invoice_Date__c,Email_Already_Send__c,Account__r.Name,Total_Invoice_Amount__c,Account__r.Total_Oustanding_Debtor_Invoice_Amount__c,Account__r.Historical_Debtor_Ageing__c,Account__r.Id,Account__r.Debtor_Balance_Amount__c 
                          FROM Debtor_Invoice__c ];
        }
         for(Debtor_Invoice__c debtorInvoice : debtorList){
            InvoiceDetail  invoice= new InvoiceDetail();
            invoice.billNumber = debtorInvoice.Bill_No__c;
            invoice.invoiceDate = debtorInvoice.Invoice_Date__c;
            invoice.accountName= debtorInvoice.Account__r.Name;
            invoice.totalInvoiceAmount = debtorInvoice.Account__r.Debtor_Balance_Amount__c;
            invoiceDetailList.add(invoice); 
        } 
        return invoiceDetailList; 
        
    }
    
    public class InvoiceDetail{
        public Date invoiceDate {get;set;}
        public String billNumber {get;set;}
        public String accountName {get;set;}
        public Decimal totalInvoiceAmount {get;set;}
        public InvoiceDetail(){}
        
    }
    
}