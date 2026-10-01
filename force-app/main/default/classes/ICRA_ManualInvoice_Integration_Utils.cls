/**
 * @description       : 
 * @author            : Damco
 * @group             : 
 * @last modified on  : 
 * @last modified by  : Damco
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0                Damco                               Initial Version
**/
public  class ICRA_ManualInvoice_Integration_Utils {  
    private Static String TranDtls_SupTyp='';
    private Static String DocDtls_No='';
    private Static String TOTAL_INVOICE_AMOUNT='';
    private Static String INVOICE_AMOUNT='';
    private Static String CGST_AMOUNT='';
    private Static String SGST_AMOUNT='';
    private Static String IGST_AMOUNT='';

    private Static String Supplier_GST='';
    private Static String Supplier_STREET='';
    private Static String Supplier_CITY='';
    private Static String Supplier_STATE='';
    private Static String Supplier_ZIP_CODE='';
    private Static String Supplier_STATE_CODE='';
    private Static String Supplier_COUNTRY='';
    private Static String Supplier_LOCATION='';

    private Static String Buyer_GST='';
    private Static String Buyer_STREET='';
    private Static String Buyer_CITY='';
    private Static String Buyer_STATE='';
    private Static String Buyer_ZIP_CODE='';
    private Static String Buyer_STATE_CODE='';
    private Static String Buyer_COUNTRY='';
    private Static String Buyer_LOCATION='';
    private Static String Buyer_NAME='';
    private Static String PRD_DESC='Credit Rating Agency Service';

    public static String createJSONRequest(String invoiceId){ 

        Manual_Invoice__c [] invoice =  [
            SELECT Account_Name__r.Primary_City__c, Account_Name__r.Primary_Zip_Postal_Code__c, Address__c, Account_ID__c, Amount__c, Account_Name__r.Branch__r.Street__c, 
            Total_Invoice_Taxable_Amount__c,Account_Name__r.Primary_Street__c,Account_Name__r.Primary_State__c,Account_Name__r.Primary_Country__c,Account_Name__r.Branch__r.City__c, Account_Name__r.Branch__r.State__c,Account_Name__r.Branch__r.Zip_Postal_Code__c, Account_Name__r.Branch__r.Country__c, Bill_No__c, 
                Customer_GSTIN__c, Customer_Name__c, Customer_Pan__c, Customer_State__c, Customer_State_Code__c,  IGST_Rate_for_Invoice_Amount__c, IRN_Number__c, Total_Invoice_Amount__c, Invoice_Date__c, Invoice_Created_Date__c, Name, Invoice_Status__c,  Location_of_Supplier__c, Particulars__c, QR_Code__c,  Id,  SAC_HSN__c,  
                SGST_UTGST_Rate_for_Invoice_Amount__c, Service_Code__c,  Supplier_GSTIN__c, Supplier_PAN__c, Supplier_State__c, Supplier_State_Code__c, Total_CGST_Invoice_Amount__c, Total_IGST_Invoice_Amount__c, Total_SGST_Invoice_Amount__c, RecordType.Name, RecordType.DeveloperName, Account_Name__r.Account_Classification__c,
                Source_Branch_1__c, Source_Branch_1__r.Account_Classification__c, Source_Branch_1__r.GSTIN__c, Source_Branch_1__r.Street__c, Source_Branch_1__r.City__c, Source_Branch_1__r.State__c, Source_Branch_1__r.Country__c, Source_Branch_1__r.Zip_Postal_Code__c, Source_Branch_1__r.State_Code__c, Destination_Branch__c, 
                Destination_Branch__r.GSTIN__c, Destination_Branch__r.Street__c, Destination_Branch__r.City__c, Destination_Branch__r.State__c, Destination_Branch__r.Country__c, Destination_Branch__r.Zip_Postal_Code__c, Destination_Branch__r.State_Code__c, Destination_Branch__r.Name, Bill_No_InterBranch__c, CGST_Rate_for_Invoice_Amount_InterBranch__c,
                SGST_UTGST_Rate_on_invoice_InterBranch__c, IGST_Rate_for_Invoice_Amount_InterBranch__c, SGST_Amount_on_Invoice_InterBranch__c, IGST_Amount_on_Invoice_InterBranch__c, CGST_Amount_on_Invoice_InterBranch__c, Total_Invoice_Amount_InterBranch__c
                FROM Manual_Invoice__c 
             WHERE Id =:invoiceId 
             LIMIT 1];

        if(invoice[0].RecordType.DeveloperName!='Inter_Branch_Invoice'){
            List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= [Select id, Name, Account_Classification__c, TranDtls_SupTyp__c from Transaction_Details_Sub_Type__c where Account_Classification__c=:invoice[0].Account_Name__r.Account_Classification__c LIMIT 1];
            if(!transDetailSubTypeList.isEmpty()){
                System.Debug('TransDtls: '+transDetailSubTypeList[0].TranDtls_SupTyp__c);
                TranDtls_SupTyp= transDetailSubTypeList[0].TranDtls_SupTyp__c;
            }  
            DocDtls_No= invoice[0].Bill_No__c;
            TOTAL_INVOICE_AMOUNT= String.valueOf(invoice[0].Total_Invoice_Amount__c);
            INVOICE_AMOUNT= String.valueOf(invoice[0].Total_Invoice_Taxable_Amount__c);
            CGST_AMOUNT= String.valueOf(invoice[0].Total_CGST_Invoice_Amount__c);
            SGST_AMOUNT= String.valueOf(invoice[0].Total_SGST_Invoice_Amount__c);
            IGST_AMOUNT= String.valueOf(invoice[0].Total_IGST_Invoice_Amount__c);
            Supplier_GST= invoice[0].Supplier_GSTIN__c;
            Supplier_STREET= invoice[0].Account_Name__r.Branch__r.Street__c;
            Supplier_CITY= invoice[0].Account_Name__r.Branch__r.City__c;
            Supplier_STATE= invoice[0].Account_Name__r.Branch__r.State__c;
            Supplier_COUNTRY= invoice[0].Account_Name__r.Branch__r.Country__c;
            Supplier_ZIP_CODE= invoice[0].Account_Name__r.Branch__r.Zip_Postal_Code__c;
            Supplier_STATE_CODE= invoice[0].Supplier_State_Code__c;
            Supplier_LOCATION= invoice[0].Account_Name__r.Branch__r.City__c;

            Buyer_GST= invoice[0].Customer_GSTIN__c;
            Buyer_STREET= invoice[0].Account_Name__r.Primary_Street__c;
            Buyer_CITY= invoice[0].Account_Name__r.Primary_City__c;
            Buyer_STATE= invoice[0].Account_Name__r.Primary_State__c;
            Buyer_COUNTRY= invoice[0].Account_Name__r.Primary_Country__c;
            Buyer_ZIP_CODE= invoice[0].Account_Name__r.Primary_Zip_Postal_Code__c;
            Buyer_STATE_CODE= String.valueOf(invoice[0].Customer_State_Code__c);
            Buyer_LOCATION= invoice[0].Account_Name__r.Primary_City__c;	
            Buyer_NAME= invoice[0].Customer_Name__c;	

        }else if(invoice[0].RecordType.DeveloperName=='Inter_Branch_Invoice'){
            System.Debug('Inter Branch Invoice');
            List<Transaction_Details_Sub_Type__c> transDetailSubTypeList= [Select id, Name, Account_Classification__c, TranDtls_SupTyp__c from Transaction_Details_Sub_Type__c where Account_Classification__c=:invoice[0].Source_Branch_1__r.Account_Classification__c LIMIT 1];
            System.Debug(transDetailSubTypeList.size());
            if(!transDetailSubTypeList.isEmpty()){
                System.Debug('TransDtls: '+transDetailSubTypeList[0].TranDtls_SupTyp__c);
                TranDtls_SupTyp= transDetailSubTypeList[0].TranDtls_SupTyp__c;
            }    
            DocDtls_No= invoice[0].Bill_No_InterBranch__c;
            TOTAL_INVOICE_AMOUNT= String.valueOf(invoice[0].Total_Invoice_Amount_InterBranch__c);
            INVOICE_AMOUNT= String.valueOf(invoice[0].Amount__c);
            CGST_AMOUNT= String.valueOf(invoice[0].CGST_Amount_on_Invoice_InterBranch__c);
            SGST_AMOUNT= String.valueOf(invoice[0].SGST_Amount_on_Invoice_InterBranch__c);
            IGST_AMOUNT= String.valueOf(invoice[0].IGST_Amount_on_Invoice_InterBranch__c);
            Supplier_GST= invoice[0].Source_Branch_1__r.GSTIN__c;
            Supplier_STREET= invoice[0].Source_Branch_1__r.Street__c;
            Supplier_CITY= invoice[0].Source_Branch_1__r.City__c;
            Supplier_STATE= invoice[0].Source_Branch_1__r.State__c;
            Supplier_COUNTRY= invoice[0].Source_Branch_1__r.Country__c;
            Supplier_ZIP_CODE= invoice[0].Source_Branch_1__r.Zip_Postal_Code__c;
            Supplier_STATE_CODE= invoice[0].Source_Branch_1__r.State_Code__c;
            Supplier_LOCATION= invoice[0].Source_Branch_1__r.City__c;

            Buyer_GST= invoice[0].Destination_Branch__r.GSTIN__c;
            Buyer_STREET= invoice[0].Destination_Branch__r.Street__c;
            Buyer_CITY= invoice[0].Destination_Branch__r.City__c;
            Buyer_STATE= invoice[0].Destination_Branch__r.State__c;
            Buyer_COUNTRY= invoice[0].Destination_Branch__r.Country__c;
            Buyer_ZIP_CODE= invoice[0].Destination_Branch__r.Zip_Postal_Code__c;
            Buyer_STATE_CODE= invoice[0].Destination_Branch__r.State_Code__c;
            Buyer_LOCATION= invoice[0].Destination_Branch__r.City__c;	
			Buyer_NAME= 'ICRA Limited';
        }   

        Manual_Invoice_Line_Item__c [] lineList = [
            SELECT Account_Classification__c, CGST_Rate_for_Invoice_Amount__c, SGST_UTGST_Rate_for_Invoice_Amount__c, IGST_Rate_for_Invoice_Amount__c,  GST_Rate__c, SGST_UTGST_Amount_on_Invoice__c, 
                CGST_Amount_on_Invoice__c, IGST_Amount_on_Invoice__c, Name, Invoice_Taxable_Amount__c, Id, Total_Amount_Invoiced__c, Total_Invoice_Amount__c, SAC_HSN_OPE__c, SAC_HSN_OT__c, Invoice_No__r.RecordType.Name
              FROM Manual_Invoice_Line_Item__c 
              WHERE Invoice_No__c = : invoice[0].Id 
              LIMIT 50000];

        System.debug('======= Line List ====='+lineList.size());
        
        String  lineItem = ICRA_ManualInvoice_Integration_Utils.lineJSON(lineList);
        System.debug('========== Line JSON ======'+lineItem);
        system.debug('Request Body===== '+ICRA_ManualInvoice_Integration_Utils.invoiceJSON(invoice[0],lineItem));
        return ''+ICRA_ManualInvoice_Integration_Utils.invoiceJSON(invoice[0],lineItem);
    }

   public static String lineJSON(List<Manual_Invoice_Line_Item__c> invoiceLineList){
        System.debug('=========== Invoice Line ========');
        String jsonString = '"ItemList": [';
        String tempJson ='';
       
        Integer sno = 0;
        if(! invoiceLineList.isEmpty()){
            for(Manual_Invoice_Line_Item__c lineRecord :invoiceLineList ){
                System.debug('========='+lineRecord.IGST_Amount_on_Invoice__c);
                sno ++;
                tempJson += '{"SlNo" : "'+sno+'",'; 
                tempJson += '"PrdDesc" : "'+System.Label.Credit_Note_Description+'",';
                if(lineRecord.Invoice_No__r.recordType.Name=='OPE'){
                    tempJson += '"HsnCd" : "'+lineRecord.SAC_HSN_OPE__c+'",'; 
                }else if(lineRecord.Invoice_No__r.recordType.Name=='Other Services'){
                    tempJson += '"HsnCd" : "'+lineRecord.SAC_HSN_OT__c+'",';
                }  
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
                tempJson += '"TotItemVal" : '+lineRecord.Total_Invoice_Amount__c+',';      
                tempJson += '"OrgCntry" : "IN"},';   
            } 

        } 

        String finalJson = jsonString+tempJson.removeEnd(',')+'],';
        return finalJson;
    } 

    public static String invoiceJSON(Manual_Invoice__c invoiceRecord, String lineItem){
        System.debug('=========== Invoice Line ========');
        
        String mainJson = '[{';
        mainJson += '"User_GSTIN": "'+Supplier_GST+'",';
        mainJson += '"Version": "1.01",';
        mainJson += ' "is_irn": "Y",';
        mainJson += '"is_ewb": "N",';

        String TranDtls = '"TranDtls": {';
        TranDtls += '"TaxSch": "GST",';
        TranDtls += '"SubType": "SUPPLY",';
        TranDtls += '"SupTyp": "'+TranDtls_SupTyp+'"},'; // Clerification with ICRA Team  "B2B"

        String DocDtls = '"DocDtls": {';
        /*if(invoiceRecord.RecordType.Name =='Credit Note'){
            DocDtls += '"Typ": "CRN",';
            DocDtls += '"No": "'+invoiceRecord.Credit_Note_No__c+'",';
            DocDtls += '"Dt": "'+invoiceRecord.Credit_Note_Created_Date__c.format( )+'"},';
        }else{*/
            DocDtls += '"Typ": "INV",';
            DocDtls += '"No": "'+DocDtls_No+'",';
            System.Debug('Date===>>>'+invoiceRecord.Invoice_Date__c);       
            DocDtls += '"Dt": "'+invoiceRecord.Invoice_Date__c.format( )+'"},';         //Invoice_Created_Date__c
        //}
 


        String SellerDtls = '"SellerDtls": {';
        SellerDtls += '"Gstin": "'+Supplier_GST+'",';
        SellerDtls += '"LglNm": "ICRA Limited",';
        SellerDtls += '"Addr1":"'+Supplier_STREET+', '+Supplier_CITY +'",';
        
        SellerDtls += '"Addr2": "'+Supplier_STATE +', '+
        Supplier_COUNTRY +'",';


        SellerDtls += '"Loc": "'+Supplier_LOCATION+'",';
        SellerDtls += '"Pin": '+Supplier_ZIP_CODE+','; 
        SellerDtls += '"Stcd": "'+Supplier_STATE_CODE+'"},';

        String BuyerDtls = '"BuyerDtls": {';
        BuyerDtls += '"Gstin": "'+Buyer_GST+'",';
        BuyerDtls += '"LglNm": "'+Buyer_NAME+'",';
        //BuyerDtls += '"Addr1": "'+invoiceRecord.Address__c+'",'; // Break 
        //BuyerDtls += '"Addr1": "'+invoiceRecord.Address_Single_Line__c+'",';
        //BuyerDtls += '"Addr1": "'+invoiceRecord.Opportunity_Name__r.Account.Primary_Street__c+', '+invoiceRecord.Opportunity_Name__r.Account.Primary_City__c +'",';
        BuyerDtls += '"Addr1": "'+Buyer_STREET+'",';
        BuyerDtls += '"Addr2": "'+Buyer_CITY+', '+Buyer_STATE+', '+Buyer_COUNTRY +','+Buyer_ZIP_CODE +'",';
        BuyerDtls += '"Loc": "'+Buyer_CITY+'",';
        BuyerDtls += '"Pin": '+Buyer_ZIP_CODE+',';
        BuyerDtls += '"Stcd": "'+Buyer_STATE_CODE+'",';
        BuyerDtls += '"Pos": "'+Buyer_STATE_CODE+'"},'; 

        //BuyerDtls.replaceAll('\n', '');
        //system.debug('BuyerDtls request body'+BuyerDtls);

        String ValDtls = '"ValDtls": {';

        /*if(invoiceRecord.RecordType.Name =='Credit Note'){

            ValDtls += '"AssVal": '+invoiceRecord.Credit_Note__c+',';
            ValDtls += '"CgstVal": '+invoiceRecord.CGST_Amount_on_Credit_Note__c+',';
            ValDtls += '"SgstVal": '+invoiceRecord.SGST_UTGST_Amount_on_Credit_Note__c+',';
            ValDtls += '"IgstVal": '+invoiceRecord.IGST_Amount_on_Credit_Note__c+',';
            ValDtls += '"TotInvVal": '+invoiceRecord.Total_Credit_Amount__c+'}';

        }else{*/
            ValDtls += '"AssVal": '+INVOICE_AMOUNT+',';
            ValDtls += '"CgstVal": '+CGST_AMOUNT+',';
            ValDtls += '"SgstVal": '+SGST_AMOUNT+',';
            ValDtls += '"IgstVal": '+IGST_AMOUNT+',';
            ValDtls += '"TotInvVal": '+TOTAL_INVOICE_AMOUNT+'}';
        //}

        String jsonString = '"ItemList": [';
        String finalJSON ='';
        if(invoiceRecord.RecordType.DeveloperName =='Inter_Branch_Invoice'){
            String tempJson ='';
            tempJson += '{"SlNo" : "1",'; 
            tempJson += '"PrdDesc" : "'+PRD_DESC+'",';
            tempJson += '"HsnCd" : "'+invoiceRecord.SAC_HSN__c+'",';
            tempJson += '"IsServc" : "Y",'; 
            tempJson += '"UnitPrice" : '+invoiceRecord.Amount__c+',';
            tempJson += '"TotAmt" : '+invoiceRecord.Amount__c+','; 
            tempJson += '"AssAmt" : '+invoiceRecord.Amount__c+',';
            tempJson += '"GstRt" : '+(invoiceRecord.CGST_Rate_for_Invoice_Amount_InterBranch__c + invoiceRecord.IGST_Rate_for_Invoice_Amount_InterBranch__c + invoiceRecord.SGST_UTGST_Rate_on_invoice_InterBranch__c )+',';// ?
            tempJson += '"CgstRt" : '+invoiceRecord.CGST_Rate_for_Invoice_Amount_InterBranch__c+',';
            tempJson += '"SgstRt" : '+invoiceRecord.SGST_UTGST_Rate_on_invoice_InterBranch__c+',';
            tempJson += '"IgstRt" : '+invoiceRecord.IGST_Rate_for_Invoice_Amount_InterBranch__c+','; 
            tempJson += '"SgstAmt" : '+invoiceRecord.SGST_Amount_on_Invoice_InterBranch__c+','; 
            tempJson += '"IgstAmt" : '+invoiceRecord.IGST_Amount_on_Invoice_InterBranch__c+',';
            tempJson += '"CgstAmt" : '+invoiceRecord.CGST_Amount_on_Invoice_InterBranch__c+','; 
            tempJson += '"TotItemVal" : '+invoiceRecord.Total_Invoice_Amount_InterBranch__c+',';
            tempJson += '"OrgCntry" : "IN"},';

            finalJSON = jsonString+tempJson.removeEnd(',')+'],'; 
        }
 
        if(invoiceRecord.RecordType.DeveloperName =='Inter_Branch_Invoice'){
            mainJson += TranDtls + DocDtls + SellerDtls + BuyerDtls + finalJSON + ValDtls+'}]'; 
        }else{
            mainJson += TranDtls + DocDtls + SellerDtls + BuyerDtls + lineItem + ValDtls+'}]';
        }
            System.Debug('mainJson=====>>'+mainJson);
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