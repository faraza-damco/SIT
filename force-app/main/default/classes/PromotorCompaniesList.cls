public class PromotorCompaniesList {
    //@InvocableMethod(label='Get Promotor List from CMDT' description='Returns a list of Promotor Companies from CMDT')
    public static void PromotorCompanyTriggerHandler_Insert(List<Account> accList) {
        String names;
        String label;
        String pan;
        String cin;
        String lei;
        Promoter_Company__mdt promotorListDetails= [SELECT Id, MasterLabel, PromotorDetails__c, PromotorLabel__c, PromotorPAN__c, PromotorCIN__c, PromotorLEI__c FROM Promoter_Company__mdt where DeveloperName = 'Promotor_Company_Details' ];
        if(promotorListDetails!=null){
            List<String> promotorNameList= new List<String>();
            List<String> promotorLabelList= new List<String>();
            List<String> promotorPANList= new List<String>();
            List<String> promotorCINList= new List<String>();
            List<String> promotorLEIList= new List<String>();
            Map<Id, String> recordTypeMap = new Map<Id, String>();
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']) {
                recordTypeMap.put(rt.Id, rt.Name);
            }
            
            if(promotorListDetails.PromotorDetails__c!=null){
                names= promotorListDetails.PromotorDetails__c.toLowerCase();
                promotorNameList= names.split(',');
            }
            if(promotorListDetails.PromotorLabel__c!=null){
                label= promotorListDetails.PromotorLabel__c.toLowerCase();
                promotorLabelList= label.split(',');
            }
            if(promotorListDetails.PromotorPAN__c!=null){
                pan= promotorListDetails.PromotorPAN__c.toLowerCase();
                promotorPANList= pan.split(',');
            }
            if(promotorListDetails.PromotorCIN__c!=null){
                cin= promotorListDetails.PromotorCIN__c.toLowerCase();
                promotorCINList= cin.split(',');
            }
            if(promotorListDetails.PromotorLEI__c!=null){
                lei= promotorListDetails.PromotorLEI__c.toLowerCase();
                promotorLEIList= lei.split(',');
            }

            system.debug('Promotor List==>>'+promotorNameList+'******'+promotorLabelList+'*****'+promotorPANList+'*****'+promotorCINList+'*****'+promotorLEIList);
            for(Account acc: accList){
                system.debug('Account Name & PAN==>>'+acc.Name+'***'+'***'+acc.PAN_Number__c);
                for(String labelValue: promotorLabelList){
                    system.debug('Label==>>'+label);
                    system.debug('LabelList==>>'+promotorLabelList);
                    if(acc.Name!=null && acc.Name.toLowerCase().contains(labelValue) && recordTypeMap.get(acc.RecordTypeId) != 'OT Related Accounts'){
                        system.debug('Account Name String==>>'+String.valueOf(acc.Name));
                        acc.addError('ICRA cannot take up mandates from Promoter Companies.');
                    }else if(acc.Name!=null && acc.Name.toLowerCase().contains(labelValue) && recordTypeMap.get(acc.RecordTypeId) == 'OT Related Accounts'){
                        acc.Related_Party__c='Yes';
                    }
                }
                if(acc.Name!=null && promotorNameList.contains(acc.Name.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) != 'OT Related Accounts'){
                    acc.Name.addError('ICRA cannot take up mandates from Promoter Companies.');
                }
                else if(acc.PAN_Number__c!=null && promotorPANList.contains(acc.PAN_Number__c.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) != 'OT Related Accounts'){
                        acc.PAN_Number__c.addError('ICRA cannot take up mandates from Promoter Companies.');

                }
                else if(acc.CIN_Number__c!=null && promotorCINList.contains(acc.CIN_Number__c.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) != 'OT Related Accounts'){
                        acc.CIN_Number__c.addError('ICRA cannot take up mandates from Promoter Companies.');
                }
                else if(acc.LEI_Number__c!=null && promotorLEIList.contains(acc.LEI_Number__c.toLowerCase()) &&recordTypeMap.get(acc.RecordTypeId) != 'OT Related Accounts'){
                        acc.LEI_Number__c.addError('ICRA cannot take up mandates from Promoter Companies.');
                }
                else if(acc.Name!=null && promotorNameList.contains(acc.Name.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) == 'OT Related Accounts'){
                        acc.Related_Party__c='Yes';
                }
                else if(acc.PAN_Number__c!=null && promotorPANList.contains(acc.PAN_Number__c.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) == 'OT Related Accounts'){
                        acc.Related_Party__c='Yes';
                }
                else if(acc.CIN_Number__c!=null && promotorCINList.contains(acc.CIN_Number__c.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) == 'OT Related Accounts'){
                        acc.Related_Party__c='Yes';
                }
                else if(acc.LEI_Number__c!=null && promotorLEIList.contains(acc.LEI_Number__c.toLowerCase()) && recordTypeMap.get(acc.RecordTypeId) == 'OT Related Accounts'){
                        acc.Related_Party__c='Yes';
                }
            }  
        }
    }
    public static void PromotorCompanyTriggerHandler_Update(List<Account> accList, Map<Id,Account> oldMap) {
        String names;
        String label;
        String pan;
        String cin;
        String lei;
        Promoter_Company__mdt promotorListDetails= [SELECT Id, MasterLabel, PromotorDetails__c, PromotorLabel__c, PromotorPAN__c, PromotorCIN__c, PromotorLEI__c FROM Promoter_Company__mdt where DeveloperName = 'Promotor_Company_Details' ];
        if(promotorListDetails!=null){
            List<String> promotorNameList= new List<String>();
            List<String> promotorLabelList= new List<String>();
            List<String> promotorPANList= new List<String>();
            List<String> promotorCINList= new List<String>();
            List<String> promotorLEIList= new List<String>();

            if(promotorListDetails.PromotorDetails__c!=null){
                names= promotorListDetails.PromotorDetails__c.toLowerCase();
                promotorNameList= names.split(',');
            }
            if(promotorListDetails.PromotorLabel__c!=null){
                label= promotorListDetails.PromotorLabel__c.toLowerCase();
                promotorLabelList= label.split(',');
            }
            if(promotorListDetails.PromotorPAN__c!=null){
                pan= promotorListDetails.PromotorPAN__c.toLowerCase();
                promotorPANList= pan.split(',');
            }
            if(promotorListDetails.PromotorCIN__c!=null){
                cin= promotorListDetails.PromotorCIN__c.toLowerCase();
                promotorCINList= cin.split(',');
            }
            if(promotorListDetails.PromotorLEI__c!=null){
                lei= promotorListDetails.PromotorLEI__c.toLowerCase();
                promotorLEIList= lei.split(',');
            }

            system.debug('Promotor List==>>'+promotorNameList+'******'+promotorLabelList+'*****'+promotorPANList+'*****'+promotorCINList+'*****'+promotorLEIList);
            Profile pf= [select id, name from Profile where id=:UserInfo.getProfileId()];
            for(Account acc: accList){
                system.debug('Account Name & PAN==>>'+acc.Name+'***'+'***'+acc.PAN_Number__c);
                if(pf.Name=='System Administrator' && acc.Related_Party__c != oldMap.get(acc.Id).Related_Party__c){
                    continue;
                }
                else if(acc.Name!=null && promotorNameList.contains(acc.Name.toLowerCase())){
                        acc.Related_Party__c='Yes';
                }
                else if(acc.PAN_Number__c!=null && promotorPANList.contains(acc.PAN_Number__c.toLowerCase())){
                        acc.Related_Party__c='Yes';
                }
                else if(acc.CIN_Number__c!=null && promotorCINList.contains(acc.CIN_Number__c.toLowerCase())){
                        acc.Related_Party__c='Yes';
                }
                else if(acc.LEI_Number__c!=null && promotorLEIList.contains(acc.LEI_Number__c.toLowerCase())){
                        acc.Related_Party__c='Yes';
                }else{
                    acc.Related_Party__c='No';
                }

                for(String labelValue: promotorLabelList){
                    system.debug('Label==>>'+label);
                    system.debug('LabelList==>>'+promotorLabelList);
                    if(acc.Name!=null && acc.Name.toLowerCase().contains(labelValue)){
                        system.debug('Account Name String==>>'+String.valueOf(acc.Name));
                            acc.Related_Party__c='Yes';
                    }
                }
            }   
        }
    }
    public static void beforeUpdate(List<Account> accList){
        system.debug('Inside Before Update Trigger===>>>>');
        for(Account acc: accList){
            if(acc.Customer_Fee_Type__c!='Cap'){
                acc.Amount_of_CAP_Fee__c=null;
            }
        }
    }
}