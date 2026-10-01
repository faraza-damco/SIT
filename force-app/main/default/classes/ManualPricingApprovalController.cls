/**
 * Name               : ManualPricingApprovalController
 * @description       : Controller for manualPricingApproval component
 * @author            : Damco Group
 * @Created on        : 15-03-2022
**/
public class ManualPricingApprovalController {
    //public static final String SALESEMAIL = system.label.Sales_ICRA_email;

/**
* @Method Name       : getOpportunity
* @description       : To fetch Opportunity record from recordId
**/
@AuraEnabled
public static Opportunity getOpportunity(String recordId){
    try{
        if(recordId==null || (!Test.isRunningTest() && System.Approval.isLocked(recordId))){
            return null;
        }else{
            List<Opportunity> optyList = new List<Opportunity>();
            optyList = [SELECT Id,Name,Pricing_Not_Auto_Approved__c,Pricing_Approved_by_Business_Head__c, Pricing_Approved_by_Commercial_Head__c, Pricing_Approved_by_CEO__c, Commercial_Head__c,Target_Fee_IRF__c,Annual_Surveillance_Fee_as_per_Framework__c,CurrencyDisplayFormula__c,Customer_Fee_Type__c,Ownership_Type__c,VoD_in_crore__c,Proposed_Rating_Fee__c,Proposed_Surveillance_Fee__c,Pricing_Rejected_by_Business_Head__c FROM Opportunity WHERE Id = :recordId AND StageName = 'Negotiation'];
            return optyList.size()>0?optyList[0]:null;
        }
    }catch(Exception e ){
        throw new AuraHandledException('Error getting Opportunity '+e.getMessage() + ' record id: '+recordId);
    }
}
/**
* @Method Name       : resetApproval
* @description       : To restart approval process on Proposed Fee changes on not approved mandates
**/
@AuraEnabled
public static Opportunity resetApproval(String recordId){
    try{
        if(recordId!=null || !System.Approval.isLocked(recordId)){
            List<Opportunity> toUpdate = new List<Opportunity>();
            //Loop will run only once
            for(Opportunity opty : [SELECT Id,Name,Pricing_Not_Auto_Approved__c,Commercial_Head__c,Target_Fee_IRF__c,Annual_Surveillance_Fee_as_per_Framework__c,CurrencyDisplayFormula__c,Customer_Fee_Type__c,Ownership_Type__c,VoD_in_crore__c,Proposed_Rating_Fee__c,Proposed_Surveillance_Fee__c,Pricing_Approved_by_CEO__c,Pricing_Approved_by_Commercial_Head__c FROM Opportunity WHERE Id = :recordId AND StageName = 'Negotiation' AND Pricing_Not_Auto_Approved__c = true]){
                 //if((field=='VOD' && opty.VoD_in_crore__c>2000)||(field=='FEE' && (opty.Proposed_Rating_Fee__c<opty.Target_Fee_IRF__c||opty.Proposed_Surveillance_Fee__c<opty.Target_Fee_ASF__c))){    
                    opty.Pricing_Approved_by_CEO__c = false;
                    opty.Pricing_Approved_by_Commercial_Head__c = false;
                    opty.Pricing_Approved_by_Business_Head__c = false;
                    opty.BH_Approval_Rejection_Mail_Sent__c = false;
                    opty.CH_Approval_Reject_Email_sent__c = false;
                    opty.MD_Approval_Reject_Email_sent__c = false;
                    toUpdate.add(opty);  
                //}
            }
            if(toUpdate.size()>0){
                Update toUpdate;
                return toUpdate[0];
            }
        }
        return null;
    }catch(Exception e ){
        throw new AuraHandledException('Error while reset approval '+e.getMessage() + ' record id: '+recordId);
    }
}
/**
* @Method Name       : invokeApprovalProcess
* @description       : Submit the record for approval
**/
@AuraEnabled
public static void invokeApprovalProcess(String recordId){
    try{
        //User opty = [Select ID from User where Email =: SALESEMAIL limit 1];
        List<Opportunity> opty = [Select Id, ownerID,BD_Head__c, Account.Business_Sector__r.Business_head__c, Pricing_Approved_by_CEO__c, Pricing_Approved_by_Commercial_Head__c, Pricing_Approved_by_Business_Head__c,
        BH_Approval_Rejection_Mail_Sent__c, CH_Approval_Reject_Email_sent__c, MD_Approval_Reject_Email_sent__c, Pricing_Rejected_by_Business_Head__c, Pricing_Rejected_by_Commercial_Head__c,
        Pricing_Rejected_by_CEO__c from opportunity where Id =: recordId limit 1];
    // changes - Query the Bd head and business secor and update the record;
        
        opty[0].BD_Head__c=opty[0].Account.Business_Sector__r.Business_head__c;
        opty[0].Pricing_Approved_by_CEO__c = false;
        opty[0].Pricing_Approved_by_Commercial_Head__c = false;
        opty[0].Pricing_Approved_by_Business_Head__c = false;
        opty[0].BH_Approval_Rejection_Mail_Sent__c = false;
        opty[0].CH_Approval_Reject_Email_sent__c = false;
        opty[0].MD_Approval_Reject_Email_sent__c = false;
        opty[0].Pricing_Rejected_by_Business_Head__c = false;
        opty[0].Pricing_Rejected_by_Commercial_Head__c = false;
        opty[0].Pricing_Rejected_by_CEO__c = false;
        update opty[0];

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(recordId);
        req.setProcessDefinitionNameOrId('Pricing_Approval_Enhancement');
        req.setSubmitterId(opty[0].ownerID);
        Approval.ProcessResult approvalResult = Approval.process(req);
        //System.debug('offer submitted for approval successfully: '+approvalResult.isSuccess());
    }catch(Exception e ){
        throw new AuraHandledException('Error submitting for approval '+e.getMessage() +'====>'+e.getLineNumber() +' record id: '+recordId);
    }
}
/**
* @Method Name       : updateApprovalFields
* @description       : Clear Approval checks as manual approval was cancelled
**/
@AuraEnabled
public static void updateApprovalFields(String recordId){
    try{
        if(recordId!=null || !System.Approval.isLocked(recordId)){
            List<Opportunity> optyList = new List<Opportunity>();
            for(Opportunity opty : [SELECT Id,Name,Pricing_Auto_Approved__c,Deviation_IRF_Percent__c,Deviation_ASF_Percent__c,Annual_Surveillance_Fee_as_per_Framework__c,Pricing_Not_Auto_Approved__c,Pricing_Approved_by_Commercial_Head__c,Pricing_Approved_by_CEO__c,Proposed_Rating_Fee__c,Proposed_Surveillance_Fee__c FROM Opportunity WHERE Id = :recordId AND StageName = 'Negotiation']){
                opty.Proposed_Rating_Fee__c = null;
                opty.Proposed_Surveillance_Fee__c = null;
                opty.Pricing_Approved_by_Commercial_Head__c = false;
                opty.Pricing_Approved_by_CEO__c = false;
                opty.Pricing_Approved_by_Business_Head__c = false;
                opty.Pricing_Auto_Approved__c = false;
                opty.Pricing_Not_Auto_Approved__c = false;
                opty.Deviation_IRF_Percent__c = null;
                opty.Deviation_ASF_Percent__c = null;
                opty.Annual_Surveillance_Fee_as_per_Framework__c = null;
                opty.Target_Fee_IRF__c = null;
                opty.Minimum_Deviation_PA__c=null;
                opty.Maximum_Deviation_PA__c=null;
                opty.BD_Head_Approval_PA__c=false;
                opty.CBO_Approval_PA__c=false;
                opty.MD_CEO_Approval_PA__c=false;
                optyList.add(opty);
            }
            if(optyList.size()>0){
                Update optyList;
            }
        }
    }catch(Exception e ){
        throw new AuraHandledException('Error while reset approval fields'+e.getMessage() + ' record id: '+recordId);
    }
}
}