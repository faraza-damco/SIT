public class ws_con_PushToiFlow {

    @Auraenabled 
    public static List<String> pushToiFlow(String opID){ 

        List<String> errors = new List<String>();
        Opportunity opty = [SELECT ID,Mandate_ID__c,Rated_Entity__c, Rated_Entity__r.Branch__c,Rated_Entity__r.Group_Name__c, Rated_Entity__r.Account_Classification__c,GST_Not_Applicable__c, GST_Number__c, PAN_Number_Rated_Formula__c, MPRA_SoW_Reference_Number_iflow__c, MPRA_Sent_Date__c, Mandate_Type__c, VoD_in_crore__c,CurrencyIsoCode, is_Special__c FROM Opportunity WHERE Id =:opID LIMIT 1];
        try{
            if (opty.Rated_Entity__c == null) {
                errors.add('Rated Entity is missing');
            }
            if (opty.Rated_Entity__r.Branch__c == null) {
                errors.add('Branch is missing');
            }
            if (opty.Rated_Entity__r.Group_Name__c == null) {
                errors.add('Group Name is missing');
            }
            if (opty.Rated_Entity__r.Account_Classification__c == null) {
                errors.add('Account Classification is missing');
            }
            if (opty.GST_Not_Applicable__c == false && opty.GST_Number__c==null) {
                errors.add('GST Number is missing');
            }
            if (opty.Rated_Entity__r.Account_Classification__c != 'Export' && opty.PAN_Number_Rated_Formula__c == null) {
                errors.add('PAN Number is missing');
            }
            if (opty.MPRA_SoW_Reference_Number_iflow__c == null) {
                errors.add('MPRA/SoW Reference No. is missing');
            }
            if (opty.MPRA_Sent_Date__c == null) {
                errors.add('MPRA Effective Date is missing');
            }
            if (opty.Mandate_Type__c == null) {
                errors.add('Mandate Type is missing');
            }
            if (opty.VoD_in_crore__c == null) {
                errors.add('VOD is missing');
            }
            if (opty.CurrencyIsoCode == null) {
                errors.add('Currency is missing');
            }
            if(!errors.isEmpty()){
                system.debug('Validation Errors====>'+errors);
                return errors;
            }else{
                if(opty.is_Special__c!=true){
                    opty.is_Special__c= true;
                    update opty;
                    errors.add('The case has been marked as special');
                    return errors; 
                }else{
                    errors.add('The case is already marked as special');
                    return errors; 
                }
            }
        }catch(exception ex){
            errors.add('Some error has occured. Please Contact System Administrator with details '+ex.getMessage()+'-'+'at line number '+ex.getLineNumber());
            return errors;
        }
    }
}