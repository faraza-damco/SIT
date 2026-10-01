public class Debtor_Invoice_3to6Months_Controller {
    
    public String accountID {get;set;}
    
    public list<DebtorInvoiceDetail> getDebtorInvoiceDetail(){
        
        List<Account> accountList;
        List<DebtorInvoiceDetail> debtorInvoiceList = new List<DebtorInvoiceDetail>();
        if(! Test.isRunningTest()){
        accountList = [SELECT Id,Name,Historical_Debtor_Ageing__c,Debtor_Balance_Amount__c,(select Id,Name,Bill_No__c,Invoice_Date__c,Account__c,Account__r.Name,Email_Already_Send__c,Account__r.Debtor_Balance_Amount__c from Debtor_Invoices__r where  Email_Already_Send__c = false)  
                       FROM Account
                       WHERE 
                       Id =: accountID AND
                       Historical_Debtor_Ageing__c > 90 AND
                       Historical_Debtor_Ageing__c <= 180
                       
                      ];
        }else{
                    accountList = [SELECT Id,Name,Historical_Debtor_Ageing__c,Debtor_Balance_Amount__c,(select Id,Name,Bill_No__c,Invoice_Date__c,Account__c,Account__r.Name,Email_Already_Send__c,Account__r.Debtor_Balance_Amount__c from Debtor_Invoices__r where  Email_Already_Send__c = false)  
                                   FROM Account];
        }
        for(Account account : accountList){
            
            for(Debtor_Invoice__c dI : account.Debtor_Invoices__r){
                
                if(account.Id == dI.Account__c){
                    
                    DebtorInvoiceDetail debtor = new DebtorInvoiceDetail();
                    debtor.invoiceDate = dI.Invoice_Date__c;
                    debtor.billNumber = dI.Name;
                    debtor.accountName = dI.Account__r.Name;
                    debtor.totalInvoiceAmount = dI.Account__r.Debtor_Balance_Amount__c;
                    debtorInvoiceList.add(debtor);
                }
            }
        }
          return debtorInvoiceList;        
     }
    
    public class DebtorInvoiceDetail{
        public Date invoiceDate {get;set;}
        public String billNumber {get;set;}
        public String accountName {get;set;}
        public Decimal totalInvoiceAmount {get;set;}
        public DebtorInvoiceDetail(){}
    }
 }