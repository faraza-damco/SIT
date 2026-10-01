trigger CH_MD_approval_EmailId_trigger on Opportunity (after update) {
    system.debug('test called  this trigger');
    if(RecursiveTriggerHandler.isFirstTime){
                RecursiveTriggerHandler.isFirstTime = false;
    if(Trigger.isupdate && Trigger.isAfter){
    for(Opportunity oppRecord : trigger.new){
        if((oppRecord.Pricing_Approved_by_Business_Head__c == true || oppRecord.Pricing_Rejected_by_Business_Head__c == true) && oppRecord.Pricing_Approved_by_CEO__c != true && oppRecord.Pricing_Rejected_by_CEO__c != true && oppRecord.Pricing_Approved_by_Commercial_Head__c!=true && oppRecord.Pricing_Rejected_by_Commercial_Head__c!=true && oppRecord.BH_Approval_Rejection_Mail_Sent__c != true){
            CH_MD_approval_EmailId_Handler.approved_rejected_by_BH(trigger.new);
        }
        else if((oppRecord.Pricing_Approved_by_Commercial_Head__c == true || oppRecord.Pricing_Rejected_by_Commercial_Head__c == true) && oppRecord.Pricing_Approved_by_CEO__c != true && oppRecord.Pricing_Rejected_by_CEO__c != true && oppRecord.CH_Approval_Reject_Email_sent__c != true){
            CH_MD_approval_EmailId_Handler.approved_rejected_by_CH(trigger.new);
        }
        else if((oppRecord.Pricing_Approved_by_CEO__c == true || oppRecord.Pricing_Rejected_by_CEO__c == true) && oppRecord.MD_Approval_Reject_Email_sent__c != true){
            CH_MD_approval_EmailId_Handler.approved_rejected_by_CEO(trigger.new);
        }
    }
    }
    }
}