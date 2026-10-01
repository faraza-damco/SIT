public class BulkApprovalSubmitter_15Days {
	
    @InvocableMethod(label='Submit Opportunities for Approval')
    public static void submitOpportunities(List<Id> oppIds) {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();

        for(Opportunity opp : opps){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(opp.Id);
            req.setComments('Submitting for the Approval - Hold to To Be Billed');
            req.setProcessDefinitionNameOrId('day15_before_Opportunity_Billing_Statu');
            requests.add(req);
        }
        
        // Submit approvals in bulk
        for(Approval.ProcessSubmitRequest req : requests){
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                // handle failure if required
                System.debug('Failed to submit for approval: ' + result.getErrors());
            }
            else{
                System.debug('Failed to submit for approval: ' + result);
            }
        }
    }
}