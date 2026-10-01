/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-29-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   05-23-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class ICRA_CreateMultipleInvoice {
    
    public static void filterAndCreateInvoice(List<Opportunity> opportunityList,String batchType){ 
        Map<Id, Date> accountSetMap = new Map<Id,Date>();
        Map<Id, Date> opportunitystartDateMap = new Map<Id,Date>();
        
        Map<Date,List<Opportunity>> opportunityWithDateMap = new Map<Date,List<Opportunity>>();
        Map<Id,List<Opportunity>> opportunityWithIDMap = new Map<Id,List<Opportunity>>();
        Map<Id, Map<Date, List<Opportunity>>> OpportunityWithAccountMap = new Map<Id, Map<Date, List<Opportunity>>>();
        
        Map<Id,Integer> branchMap = new Map<Id,Integer>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        
        
        Map<String,List<Opportunity>> opportunitygroupigMap = new Map<String,List<Opportunity>>();
        
        for(Opportunity opportunityRecord : opportunityList){ 
            if(opportunityRecord.AccountId != null){  
                accountSetMap.put(opportunityRecord.AccountId,opportunityRecord.Billing_End_date__c); 
                opportunitystartDateMap.put(opportunityRecord.AccountId,opportunityRecord.Billing_Start_date__c);
            }
        } 
        
        Date filterDate = Date.today();
        if(batchType == 'Surveillance-90'){
            filterDate = Date.today().addDays(90);
        }else{
            filterDate = Date.today();
        }
        
        Opportunity [] tempOpportunityList = new List<Opportunity>();
        if(batchType == 'Surveillance-90'){ 
            
            tempOpportunityList = [SELECT Id, AccountId, Proforma_Invoice_Required__c, Name, StageName, Total_Invoice_Amount_1__c, Amount_To_Be_Billed__c, ASF_Final_Amount__c, Billing_Start_Date__c, Instrument_type_3__c,
                                   Billing_End_date__c, Customer_Fee_Type__c, Defer_Billing_or_Exit_Case__c, IRF_Final_Amount__c, RecordType.Name ,Instrument_type_2__c, Account.Branch__r.Updated_Surveillance_fees_Sequence__c
                                   FROM Opportunity 
                                   WHERE Defer_Billing_or_Exit_Case__c = 'To Be Billed' 
                                   AND StageName = 'Closed Won'
                                   AND AccountId = : accountSetMap.keySet() 
                                   AND RecordType.Name = 'Surveillance'
                                   AND Billing_Start_date__c  >=: opportunitystartDateMap.values()
                                   AND Billing_End_date__c =: accountSetMap.values() 
                                   AND (Total_Invoice_Amount_1__c <= 1 OR Total_Invoice_Amount_1__c = null )
                                   AND Amount_To_Be_Billed__c >= 1
                                   ORDER BY Amount_To_Be_Billed__c DESC ];
            
            
            if(tempOpportunityList.size() > 0){ 
                for(Opportunity opportunityRecord : tempOpportunityList){
                    String mapKey ='';
                    
                    if(opportunityRecord.Instrument_type_3__c == 'Commercial Paper/Certificate of Deposit/Short-term Debt'){
                        mapKey  = opportunityRecord.AccountId + '-'+ opportunityRecord.Instrument_type_3__c+'-'+ opportunityRecord.Billing_End_Date__c.format();
                    }else{
                        mapKey  = opportunityRecord.AccountId + '-'+ opportunityRecord.Instrument_type_2__c+'-'+ opportunityRecord.Billing_End_Date__c.format();
                    } 
                    
                    if(opportunitygroupigMap.containsKey(mapKey)){
                        opportunitygroupigMap.get(mapKey).add(opportunityRecord);
                        
                    }else{
                        opportunitygroupigMap.put(mapKey,new List<Opportunity>{opportunityRecord});
                        
                    } 
                }
            } 
            
            
        }else{
            
            tempOpportunityList = [SELECT Id, AccountId, Proforma_Invoice_Required__c, Name, StageName, Total_Invoice_Amount_1__c, Amount_To_Be_Billed__c, ASF_Final_Amount__c, Billing_Start_Date__c, 
                                   Billing_End_date__c, Customer_Fee_Type__c, Defer_Billing_or_Exit_Case__c, IRF_Final_Amount__c, RecordType.Name ,Instrument_type_2__c,Invoice_Generation_Date__c,
                                   Account.Branch__r.Updated_Billing_Sequence__c,Instrument_type_3__c
                                   FROM Opportunity 
                                   WHERE StageName = 'Closed Won'
                                   AND AccountId IN : accountSetMap.keySet()
                                   AND RecordType.Name = 'New Business'
                                   AND Invoice_Generation_Date__c >= : Date.today().addDays(- (Integer.valueOf(System.Label.PI_Batch_Start_Date)))
                                   AND Invoice_Generation_Date__c <= : Date.today()
                                   AND Amount_To_Be_Billed__c >= 1
                                   AND (Total_Invoice_Amount_1__c <= 1 OR Total_Invoice_Amount_1__c = null )
                                   ORDER BY Amount_To_Be_Billed__c DESC ];
            
            if(tempOpportunityList.size() > 0){ 
                for(Opportunity opportunityRecord :tempOpportunityList){ 
                    
                    String mapKey ='';
                    
                    if(opportunityRecord.Instrument_type_3__c == 'Commercial Paper/Certificate of Deposit/Short-term Debt'){
                        mapKey  = opportunityRecord.AccountId + '-'+ opportunityRecord.Instrument_type_3__c+'-'+ opportunityRecord.Invoice_Generation_Date__c.format();
                    }else{
                        mapKey  = opportunityRecord.AccountId + '-'+ opportunityRecord.Instrument_type_2__c+'-'+ opportunityRecord.Invoice_Generation_Date__c.format();
                    } 
                    
                    if(opportunitygroupigMap.containsKey(mapKey)){
                        opportunitygroupigMap.get(mapKey).add(opportunityRecord);
                    }else{
                        opportunitygroupigMap.put(mapKey, new List<Opportunity>{opportunityRecord});
                    } 
                }
                
            } 
        }
        
        
        if(opportunitygroupigMap != null){
            invoiceList = createMultipleLine(opportunitygroupigMap,batchType); 
        } 
    }
    
    
    public Static List<Invoice__c> createMultipleLine( Map<String, List<Opportunity>> opportunitygroupigMap, String batchType){ 
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        
        Map<String,List<Invoice_Line_Item__c>>  invoiceLineItemMap = new Map<String,List<Invoice_Line_Item__c>>();
        
        Date filterDate = Date.today();
        if(batchType == 'Surveillance-90'){
            filterDate = Date.today().addDays(90);
        }else{
            filterDate = Date.today();
        }
        
        for(String accountGroup : opportunitygroupigMap.keySet()){   
            
            Boolean newBusinessLine = true;
            Boolean surveillanceLine = true;
            String externalID =''; 
            Set<String> instrumentTypeSet = new Set<String>(); 
            for( Opportunity opportunityRecord : opportunitygroupigMap.get(accountGroup)){ 
                
                String instrumentType = '';
                if(opportunityRecord.Billing_Start_Date__c != null && opportunityRecord.RecordType.Name == 'New Business'){
                    
                    if(newBusinessLine){
                        
                        Invoice__c invoice = new Invoice__c ();
                        invoice.Invoice_Status__c = opportunityRecord.Proforma_Invoice_Required__c == 'No' ? 'Tax Invoice':'Proforma Invoice';
                        externalID = opportunityRecord.Id+''+opportunityRecord.AccountId+''+opportunityRecord.Instrument_type_2__c;
                        instrumentTypeSet.add(opportunityRecord.Instrument_type_2__c);
                        invoice.Invoice_Created_Date__c = System.today(); 
                        invoice.isFirst_InvoiceLine_Item__c = true;
                        invoice.Opportunity_Name__c = opportunityRecord.Id;
                        invoice.Invoice_External_ID__c = externalID;
                        invoiceList.add(invoice);
                        invoiceLineItemMap = fillInvoiceLineMap(invoiceLineItemMap,opportunityRecord ,externalID); 
                        newBusinessLine = false;
                        
                    }else{
                        if(instrumentTypeSet.contains(opportunityRecord.Instrument_type_2__c)){
                            invoiceLineItemMap = fillInvoiceLineMap(invoiceLineItemMap,opportunityRecord ,externalID);
                        }else{
                            Invoice__c invoice = new Invoice__c ();
                            invoice.Invoice_Status__c = opportunityRecord.Proforma_Invoice_Required__c == 'No' ? 'Tax Invoice':'Proforma Invoice';
                            externalID = opportunityRecord.Id+''+opportunityRecord.AccountId+''+opportunityRecord.Instrument_type_2__c;
                            instrumentTypeSet.add(opportunityRecord.Instrument_type_2__c);
                            invoice.Invoice_Created_Date__c = System.today(); 
                            invoice.isFirst_InvoiceLine_Item__c = true;
                            invoice.Opportunity_Name__c = opportunityRecord.Id;
                            invoice.Invoice_External_ID__c = externalID;
                            invoiceList.add(invoice);
                            invoiceLineItemMap = fillInvoiceLineMap(invoiceLineItemMap,opportunityRecord ,externalID);
                        } 
                        
                    }
                    
                } else  if(opportunityRecord.Billing_Start_Date__c != null && opportunityRecord.RecordType.Name == 'Surveillance'){
                    if(surveillanceLine){
                        Invoice__c invoice = new Invoice__c ();
                        invoice.Invoice_Status__c = 'Proforma Invoice';
                        invoice.Invoice_Created_Date__c = System.today(); 
                        invoice.isFirst_InvoiceLine_Item__c = true;
                        invoice.Opportunity_Name__c = opportunityRecord.Id; 
                        externalID = opportunityRecord.Id+'InvPI'+opportunityRecord.AccountId;
                        invoice.Invoice_External_ID__c = externalID;
                        invoiceList.add(invoice);
                        invoiceLineItemMap = fillInvoiceLineMap(invoiceLineItemMap,opportunityRecord ,externalID); 
                        surveillanceLine = false;
                        
                    }else{
                        
                        invoiceLineItemMap = fillInvoiceLineMap(invoiceLineItemMap,opportunityRecord ,externalID); 
                    }
                }
            }  
        } 
        
        if( invoiceList.size()>0 ){
            Insert invoiceList;
        } 
        
        List<Invoice_Line_Item__c> tempItem = new List<Invoice_Line_Item__c> ();
        if(invoiceLineItemMap != null ){ 
            for(Invoice__c inv : invoiceList){
                if(inv.Invoice_External_ID__c != null){
                    for(Invoice_Line_Item__c invl :invoiceLineItemMap.get(inv.Invoice_External_ID__c)){
                        Invoice_Line_Item__c invlTemp = new Invoice_Line_Item__c();
                        invlTemp.Opportunity_Name__c= invl.Opportunity_Name__c;
                        invlTemp.Invoice_No__c = inv.Id;
                        tempItem.add(invlTemp);
                    }
                }
            } 
            
            
            if(tempItem.size()>0){ 
                Insert tempItem ; 
            } 
        }
        
        return invoiceList;
        
    }
    
    public Static Map<String,List<Invoice_Line_Item__c>> fillInvoiceLineMap (Map<String,List<Invoice_Line_Item__c>> invoiceLineItemMap, Opportunity opportunityRecord, String externalID ){ 
        
        if(invoiceLineItemMap.containsKey(externalID)){
            List<Invoice_Line_Item__c> temp = invoiceLineItemMap.get(externalID);
            Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c(); 
            invoiceLineItem.Opportunity_Name__c = opportunityRecord.Id;  
            temp.add(invoiceLineItem);
            invoiceLineItemMap.put(externalID,temp);
        }else{
            Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
            invoiceLineItem.Opportunity_Name__c = opportunityRecord.Id;  
            invoiceLineItemMap.put(externalID,new List<Invoice_Line_Item__c>{invoiceLineItem});
        }
        
        return invoiceLineItemMap;
    }
}