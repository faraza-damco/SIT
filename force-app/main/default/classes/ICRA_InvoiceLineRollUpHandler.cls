/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-22-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   03-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class ICRA_InvoiceLineRollUpHandler { 
    public static boolean firstRun = true; 
    
    public void rollUpInvoiceLines(List<Invoice_Line_Item__c> invoiceLineList){
        
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id,RollUpSum> lineSum = new Map<Id,RollUpSum>();
        
        for(Invoice_Line_Item__c lineRecord : invoiceLineList){
            
            opportunityIdSet.add(lineRecord.Opportunity_Name__c);
        } 
        
        Invoice_Line_Item__c [] tempLineList  =  [
            SELECT Id, Opportunity_Name__c, Total_Amount_for_invoice_Amount__c, Invoice_Status__c, Financial_Year__c, Total_Invoice_Amount_WF__c, Invoice_No__c,
            	Invoice_No__r.isFirst_InvoiceLine_Item__c, Invoice_No__r.Opportunity_Name__c
            FROM Invoice_Line_Item__c 
            WHERE Opportunity_Name__c IN:opportunityIdSet           
            LIMIT 50000]; 
        
        if(tempLineList.Size() >0){ 
            
            lineSum = rollUptoOpportunity(tempLineList);
        }
        
        List<Opportunity> opportunityList = new List <Opportunity>();  
        
        if(lineSum.keySet() != null){
            
            for(Opportunity opportunityRecord : [
                SELECT Id, Name, Annual_Surveillance_Opp_Amount__c, Annual_Initial_Rating_Amount_1__c, Total_Invoice_Amount_1__c
                FROM Opportunity 
                WHERE Id In: lineSum.keySet()
                LIMIT 50000]){   
                    
                    if(lineSum.containsKey(opportunityRecord.Id)){  
                        Opportunity tempRecord = new Opportunity(); 
                        tempRecord.Id = opportunityRecord.Id;
                        tempRecord.Annual_Surveillance_Opp_Amount__c = lineSum.get(opportunityRecord.Id).annualSurveillance;
                        tempRecord.Annual_Initial_Rating_Amount_1__c = lineSum.get(opportunityRecord.Id).annualInitialRating;
                        tempRecord.Total_Invoice_Amount_1__c = lineSum.get(opportunityRecord.Id).invoiceAmount;
                        opportunityList.add(tempRecord);
                    } 
                }
        }  
        
        if(opportunityList.size()>0){
            
            Update opportunityList;
        }  
    }  
    public Map<Id,RollUpSum> rollUptoOpportunity(List<Invoice_Line_Item__c> invoiceLineList){  
        Map<Id,RollUpSum> rollUpSumMap = new Map<Id,RollUpSum>();
        
        for(Invoice_Line_Item__c lineRecord : invoiceLineList){ 
         
            if(lineRecord.Opportunity_Name__c != null){ 
                
                if(rollUpSumMap.containsKey(lineRecord.Opportunity_Name__c)){
                    
                    RollUpSum tempSum = rollUpSumMap.get(lineRecord.Opportunity_Name__c); 
                    
                    if(lineRecord.Invoice_Status__c == Label.Invoice_Rollup_Filter){ 
                        
                        if(tempSum.invoiceAmount > 0){
                            tempSum.invoiceAmount -= lineRecord.Total_Amount_for_invoice_Amount__c;
                            
                            if(lineRecord.Financial_Year__c == 'Current Year' &&  tempSum.annualSurveillance >0  ){ 
                                
                                tempSum.annualSurveillance -= lineRecord.Total_Amount_for_invoice_Amount__c; 
                            }
                            if(lineRecord.Financial_Year__c == 'Current Year' &&  tempSum.annualInitialRating >0  ){ 
                                
                                tempSum.annualSurveillance -= lineRecord.Total_Amount_for_invoice_Amount__c; 
                            }
                        }
                        
                    }else{
                        
                        tempSum.invoiceAmount += lineRecord.Total_Amount_for_invoice_Amount__c;
                        
                        if(lineRecord.Financial_Year__c == 'Current Year'){
                            
                            tempSum.annualSurveillance += lineRecord.Total_Amount_for_invoice_Amount__c;
                            tempSum.annualInitialRating += lineRecord.Total_Amount_for_invoice_Amount__c; 
                        } 
                    } 
                    rollUpSumMap.put(lineRecord.Opportunity_Name__c,tempSum); 
                    
                }else{
                    
                    RollUpSum sum = new RollUpSum(); 
                    if(lineRecord.Invoice_Status__c == Label.Invoice_Rollup_Filter){
                        sum.invoiceAmount = 0.0; 
                        if(lineRecord.Financial_Year__c == 'Current Year'){ 
                            sum.annualSurveillance = 0.0;
                            sum.annualInitialRating = 0.0;
                        } 
                    }else{
                        
                        sum.invoiceAmount = lineRecord.Total_Amount_for_invoice_Amount__c;
                        if(lineRecord.Financial_Year__c == 'Current Year'){
                            
                            sum.annualSurveillance = lineRecord.Total_Amount_for_invoice_Amount__c;
                            sum.annualInitialRating = lineRecord.Total_Amount_for_invoice_Amount__c;
                        } 
                    } 
                    rollUpSumMap.put(lineRecord.Opportunity_Name__c,sum); 
                }  
            } 
        }  
        return rollUpSumMap; 
    }  
    
    public class RollUpSum{
        
        public Double invoiceAmount = 0;
        public Double annualSurveillance = 0;
        public Double annualInitialRating  = 0; 
        
        public RollUpSum(){} 
    } 
}