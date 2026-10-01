/**
* @description       : Controller for PricingApprovalMandates lwc
* @author            : Damco Group
* @Created on  		 : 11-03-2022
**/
public without sharing class PricingApprovalMandatesController {
    private static final String NEWBUSINESS = 'New Business';
    private static final String SEPARATOR = '/';
/**
* @Method Name       : approvMandates
* @description       : To fetch opportunities based on url parameters and approve them
**/
    @AuraEnabled(cacheable=false)
    public static boolean approvMandates(String params) {
        Boolean success = false;
        if(params!=null){
            String bdClassif = params.substringBefore(SEPARATOR);
            Integer month = Integer.ValueOf(params.substringBetween(SEPARATOR));
            Integer year = Integer.ValueOf(params.substringAfterLast(SEPARATOR));
            List<Opportunity> toUpdteOptys = new List<Opportunity>();
            for(Opportunity opty : [SELECT Id,Pricing_Approved_by_Commercial_Head__c FROM Opportunity WHERE 
            RecordType.Name = :NEWBUSINESS AND Pricing_Auto_Approved__c = true AND Pricing_Approved_by_Commercial_Head__c = false AND BD_Team_Classification__c = :bdClassif AND CALENDAR_MONTH(CreatedDate) = :month AND CALENDAR_YEAR(CreatedDate) = :year]){
                toUpdteOptys.add(opty);
                opty.Pricing_Approved_by_Commercial_Head__c = true;
            }
            if(toUpdteOptys.size()>0){
                Database.Update(toUpdteOptys,false);
                success = true;
            }
        }
        return success;
    }
}