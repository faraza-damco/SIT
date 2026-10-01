/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-27-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public  class ICRA_IntegrationUtilities {  

    private Static String TranDtls_SupTyp='';
    public static String createJSONRequest(String invoiceId){ 

        Invoice__c [] invoice =  [
            SELECT Opportunity_Name__r.BillingAddress__r.Billing_City__c, Opportunity_Name__r.BillingAddress__r.Billing_Zip_Postal_Code__c, Address__c, Account_ID__c, Amount__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Street__c, 
                Total_Invoice_Taxable_Amount__c,Opportunity_Name__r.BillingAddress__r.Billing_Street__c,Opportunity_Name__r.BillingAddress__r.BillingState__c,Opportunity_Name__r.BillingAddress__r.BillingCountry__c	,Opportunity_Name__r.Opp_ICRA_Branch__r.City__c, Opportunity_Name__r.Opp_ICRA_Branch__r.State__c,Opportunity_Name__r.Opp_ICRA_Branch__r.Zip_Postal_Code__c, Opportunity_Name__r.Opp_ICRA_Branch__r.Country__c, Bill_No__c, CGST_Amount_on_Credit_Note__c, CGST_Rate_for_Invoice_Amount__c, Credit_Note__c, Credit_Note_Discount__c, Credit_Note_No__c, Credit_Note_Type__c, 
                Customer_GSTIN__c, Customer_Name__c, Customer_Pan__c, Customer_State__c, Customer_State_Code__c,  IGST_Amount_on_Credit_Note__c, IGST_Rate_for_Invoice_Amount__c, IRN_Number__c, Invoice_Amount__c, Invoice_Date__c, Invoice_Created_Date__c, Name, Invoice_Status__c,  Location_of_Supplier__c, Particulars__c,    QR_Code__c, Reason_for_Credit_Note__c, Id,  SAC_HSN__c, SGST_UTGST_Amount_on_Credit_Note__c, Invoice_No__r.Bill_No__c, Invoice_No__r.Invoice_Date__c, Invoice_No__r.IRN_Number__c,
                SGST_UTGST_Rate_for_Invoice_Amount__c, Service_Code__c,  Supplier_GSTIN__c, Supplier_PAN__c, Supplier_State__c, Supplier_State_Code__c, Total_CGST_Invoice_Amount__c, Total_Credit_Amount__c,  Total_GST_Amount__c, Total_IGST_Invoice_Amount__c, Total_Invoice_Amount__c, Total_SGST_Invoice_Amount__c, RecordType.Name, Credit_Note_Created_Date__c ,CGST_Rate_on_Credit_Note__c,  IGST_Rate_for_Credit_Note__c, SGST_Rate_for_Credit_Note__c,Address_Single_Line__c, Opportunity_Name__r.Account_Classification__c, Opportunity_Name__r.GST_Not_Applicable__c
             FROM Invoice__c 
             WHERE Id =:invoiceId 
             LIMIT 1];

        List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= [Select id, Name, Account_Classification__c, TranDtls_SupTyp__c from Transaction_Details_Sub_Type__c where Account_Classification__c=:invoice[0].Opportunity_Name__r.Account_Classification__c /*AND GST_not_Applicable__c=:invoice[0].Opportunity_Name__r.GST_Not_Applicable__c*/ LIMIT 1];
            system.debug('TranDtls_SupTyp===>>'+transDetailSubTypeList[0].TranDtls_SupTyp__c);
            if(!transDetailSubTypeList.isEmpty()){
                TranDtls_SupTyp= transDetailSubTypeList[0].TranDtls_SupTyp__c;
            }

        Invoice_Line_Item__c [] lineList = [
            SELECT Account_Classification__c, CGST_Rate_for_Invoice_Amount__c, SGST_UTGST_Rate_for_Invoice_Amount__c, IGST_Rate_for_Invoice_Amount__c,  GST_Rate__c, SGST_UTGST_Amount_on_Invoice__c, 
                CGST_Amount_on_Invoice__c, IGST_Amount_on_Invoice__c, Name, Invoice_Record_Type__c, Invoice_Taxable_Amount__c, Id,SAC_HSN__c, Total_Amount_Invoiced__c, Total_Amount_for_invoice_Amount__c 
              FROM Invoice_Line_Item__c 
              WHERE Invoice_No__c = : invoice[0].Id 
              LIMIT 50000];

        System.debug('======= Line List ====='+lineList.size());
        
        String  lineItem = ICRA_IntegrationUtilities.lineJSON(lineList);
        System.debug('========== Line JSON ======'+lineItem);
        system.debug('Request Body===== '+ICRA_IntegrationUtilities.invoiceJSON(invoice[0],lineItem));
        return ''+ICRA_IntegrationUtilities.invoiceJSON(invoice[0],lineItem);
    }

   public static String lineJSON(List<Invoice_Line_Item__c> invoiceLineList){
        System.debug('=========== Invoice Line ========');
        String jsonString = '"ItemList": [';
        String tempJson ='';
       
        Integer sno = 0;
        if(! invoiceLineList.isEmpty()){
            for(Invoice_Line_Item__c lineRecord :invoiceLineList ){
                System.debug('========='+lineRecord.IGST_Amount_on_Invoice__c);
                sno ++;
                tempJson += '{"SlNo" : "'+sno+'",'; 
                tempJson += '"PrdDesc" : "'+System.Label.Credit_Note_Description+'",';
                tempJson += '"HsnCd" : "'+lineRecord.SAC_HSN__c+'",';
                tempJson += '"IsServc" : "Y",'; 
                tempJson += '"UnitPrice" : '+lineRecord.Invoice_Taxable_Amount__c+',';
                tempJson += '"TotAmt" : '+lineRecord.Invoice_Taxable_Amount__c+','; 
                tempJson += '"AssAmt" : '+lineRecord.Invoice_Taxable_Amount__c+',';
                tempJson += '"GstRt" : '+lineRecord.GST_Rate__c+',';// ?
                tempJson += '"CgstRt" : '+lineRecord.CGST_Rate_for_Invoice_Amount__c+',';
                tempJson += '"SgstRt" : '+lineRecord.SGST_UTGST_Rate_for_Invoice_Amount__c+',';
                tempJson += '"IgstRt" : '+lineRecord.IGST_Rate_for_Invoice_Amount__c+',';  
                tempJson += '"SgstAmt" : '+lineRecord.SGST_UTGST_Amount_on_Invoice__c+',';
                tempJson += '"IgstAmt" : '+lineRecord.IGST_Amount_on_Invoice__c+',';
                tempJson += '"CgstAmt" : '+lineRecord.CGST_Amount_on_Invoice__c+','; 
                tempJson += '"TotItemVal" : '+lineRecord.Total_Amount_for_invoice_Amount__c+',';
                tempJson += '"OrgCntry" : "IN"},';   
            } 

        } 

        String finalJson = jsonString+tempJson.removeEnd(',')+'],';
        return finalJson;
    } 

    public static String invoiceJSON(Invoice__c invoiceRecord, String lineItem){
        System.debug('=========== Invoice Line ========');
        String mainJson = '[{';
        mainJson += '"User_GSTIN": "'+invoiceRecord.Supplier_GSTIN__c+'",';
        mainJson += '"Version": "1.01",';
        mainJson += ' "is_irn": "Y",';
        mainJson += '"is_ewb": "N",';

        String TranDtls = '"TranDtls": {';
        TranDtls += '"TaxSch": "GST",';
        TranDtls += '"SubType": "SUPPLY",';
        TranDtls += '"SupTyp": "'+TranDtls_SupTyp+'"},'; // Clerification with ICRA Team         "B2B"         '+TranDtls_SupTyp+'

        String DocDtls = '"DocDtls": {';
        if(invoiceRecord.RecordType.Name =='Credit Note'){
            DocDtls += '"Typ": "CRN",';
            DocDtls += '"No": "'+invoiceRecord.Credit_Note_No__c+'",';
            DocDtls += '"Dt": "'+invoiceRecord.Credit_Note_Created_Date__c.format( )+'"},';
        }else{
            DocDtls += '"Typ": "INV",';
            DocDtls += '"No": "'+invoiceRecord.Bill_No__c+'",';
            DocDtls += '"Dt": "'+invoiceRecord.Invoice_Created_Date__c.format( )+'"},';
        }
 


        String SellerDtls = '"SellerDtls": {';
        SellerDtls += '"Gstin": "'+invoiceRecord.Supplier_GSTIN__c+'",';
        SellerDtls += '"LglNm": "ICRA Limited",';
        SellerDtls += '"Addr1":"'+invoiceRecord.Opportunity_Name__r.Opp_ICRA_Branch__r.Street__c+', '+invoiceRecord.Opportunity_Name__r.Opp_ICRA_Branch__r.City__c +'",';
        
        SellerDtls += '"Addr2": "'+invoiceRecord.Opportunity_Name__r.Opp_ICRA_Branch__r.State__c +', '+
        invoiceRecord.Opportunity_Name__r.Opp_ICRA_Branch__r.Country__c +'",';


        SellerDtls += '"Loc": "'+invoiceRecord.Location_of_Supplier__c+'",';
        SellerDtls += '"Pin": '+invoiceRecord.Opportunity_Name__r.Opp_ICRA_Branch__r.Zip_Postal_Code__c+','; 
        SellerDtls += '"Stcd": "'+invoiceRecord.Supplier_State_Code__c+'"},';

        String BuyerDtls = '"BuyerDtls": {';
        BuyerDtls += '"Gstin": "'+invoiceRecord.Customer_GSTIN__c+'",';
        BuyerDtls += '"LglNm": "'+invoiceRecord.Customer_Name__c+'",';
        //BuyerDtls += '"Addr1": "'+invoiceRecord.Address__c+'",'; // Break 
        //BuyerDtls += '"Addr1": "'+invoiceRecord.Address_Single_Line__c+'",';
        //BuyerDtls += '"Addr1": "'+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_Street__c+', '+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_City__c +'",';
        BuyerDtls += '"Addr1": "'+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_Street__c+'",';
        BuyerDtls += '"Addr2": "'+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_City__c+', '+invoiceRecord.Opportunity_Name__r.BillingAddress__r.BillingState__c+', '+invoiceRecord.Opportunity_Name__r.BillingAddress__r.BillingCountry__c	 +','+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_Zip_Postal_Code__c +'",';
        BuyerDtls += '"Loc": "'+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_City__c+'",';
        BuyerDtls += '"Pin": '+invoiceRecord.Opportunity_Name__r.BillingAddress__r.Billing_Zip_Postal_Code__c+',';
        BuyerDtls += '"Stcd": "'+invoiceRecord.Customer_State_Code__c+'",';
        BuyerDtls += '"Pos": "'+invoiceRecord.Customer_State_Code__c+'"},'; 

        //BuyerDtls.replaceAll('\n', '');
        //system.debug('BuyerDtls request body'+BuyerDtls);

        String ValDtls = '"ValDtls": {';

        if(invoiceRecord.RecordType.Name =='Credit Note'){

            ValDtls += '"AssVal": '+invoiceRecord.Credit_Note__c+',';
            ValDtls += '"CgstVal": '+invoiceRecord.CGST_Amount_on_Credit_Note__c+',';
            ValDtls += '"SgstVal": '+invoiceRecord.SGST_UTGST_Amount_on_Credit_Note__c+',';
            ValDtls += '"IgstVal": '+invoiceRecord.IGST_Amount_on_Credit_Note__c+',';
            ValDtls += '"TotInvVal": '+invoiceRecord.Total_Credit_Amount__c+'}';

        }else{
            ValDtls += '"AssVal": '+invoiceRecord.Total_Invoice_Taxable_Amount__c+',';
            ValDtls += '"CgstVal": '+invoiceRecord.Total_CGST_Invoice_Amount__c+',';
            ValDtls += '"SgstVal": '+invoiceRecord.Total_SGST_Invoice_Amount__c+',';
            ValDtls += '"IgstVal": '+invoiceRecord.Total_IGST_Invoice_Amount__c+',';
            ValDtls += '"TotInvVal": '+invoiceRecord.Total_Invoice_Amount__c+'}';
        }

        String RefDtls = '"RefDtls": {';
        if(invoiceRecord.RecordType.Name =='Credit Note'){
            RefDtls += '"PrecDocDtls" : [{';
            RefDtls += '"InvNo" : "'+invoiceRecord.Invoice_No__r.Bill_No__c+'",';
            RefDtls += '"InvDt" : "'+invoiceRecord.Invoice_Date__c.format( )+'",';
            RefDtls += '"OthRefNo" : "'+invoiceRecord.Invoice_No__r.Bill_No__c+'"}]},';             //+invoiceRecord.Invoice_No__r.IRN_Number__c+
        }

        String jsonString = '"ItemList": [';
        String finalJSON ='';
        if(invoiceRecord.RecordType.Name =='Credit Note'){
            String tempJson ='';
            tempJson += '{"SlNo" : "1",'; 
            tempJson += '"PrdDesc" : "'+System.Label.Credit_Note_Description+'",';
            tempJson += '"HsnCd" : "'+invoiceRecord.SAC_HSN__c+'",';
            tempJson += '"IsServc" : "Y",'; 
            tempJson += '"UnitPrice" : '+invoiceRecord.Credit_Note__c+',';
            tempJson += '"TotAmt" : '+invoiceRecord.Credit_Note__c+','; 
            tempJson += '"AssAmt" : '+invoiceRecord.Credit_Note__c+',';
            tempJson += '"GstRt" : '+(invoiceRecord.CGST_Rate_on_Credit_Note__c + invoiceRecord.IGST_Rate_for_Credit_Note__c + invoiceRecord.SGST_Rate_for_Credit_Note__c )+',';// ?
            tempJson += '"CgstRt" : '+invoiceRecord.CGST_Rate_on_Credit_Note__c+',';
            tempJson += '"SgstRt" : '+invoiceRecord.SGST_Rate_for_Credit_Note__c+',';
            tempJson += '"IgstRt" : '+invoiceRecord.IGST_Rate_for_Credit_Note__c+','; 
            tempJson += '"SgstAmt" : '+invoiceRecord.SGST_UTGST_Amount_on_Credit_Note__c+','; 
            tempJson += '"IgstAmt" : '+invoiceRecord.IGST_Amount_on_Credit_Note__c+',';
            tempJson += '"CgstAmt" : '+invoiceRecord.CGST_Amount_on_Credit_Note__c+','; 
            tempJson += '"TotItemVal" : '+invoiceRecord.Total_Credit_Amount__c+',';
            tempJson += '"OrgCntry" : "IN"},';

            finalJSON = jsonString+tempJson.removeEnd(',')+'],'; 
        }
 
        if(invoiceRecord.RecordType.Name =='Credit Note'){
            mainJson += TranDtls + DocDtls + RefDtls+ SellerDtls + BuyerDtls + finalJSON + ValDtls+'}]'; 
        }else{
            mainJson += TranDtls + DocDtls + SellerDtls + BuyerDtls + lineItem + ValDtls+'}]';
        }

       return mainJson;  
    }
 
    public static string CancelJson(string irnNo,string reason)
    {
        String jsonString = '[';
         jsonString += '{"Irn" : "'+irnNo+'",'; 
         jsonString += '"CnlRsn" : "1",';
         jsonString += '"CnlRem" : "'+reason+'"}]';
        
        return jsonString;
    }
}