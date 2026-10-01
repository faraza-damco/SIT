({
    openModal : function(component, event) {
        var recordId = component.get('v.recordId');
        var notApproved = 'Pricing_Not_Auto_Approved__c":{"oldValue":false,"value":true';
        var changedPIRF = 'Proposed_Rating_Fee__c":{"oldValue":';
        var changedPASF = 'Proposed_Surveillance_Fee__c":{"oldValue":';
        var changedVOD = 'VoD_in_crore__c":{"oldValue":';
        var changeType = event.getParams().changeType;
        
        var changedFields = JSON.stringify(event.getParams().changedFields);
        console.log('changedFields',changedFields);
        if(component.get('v.recordId')!=null &&  
           changeType=='CHANGED' && !changedFields.includes(notApproved) && (changedFields.includes(changedPIRF)||changedFields.includes(changedPASF)||changedFields.includes(changedVOD))){
            console.log('if1');
            var action1 = component.get("c.resetApproval");
            action1.setParams({
                recordId : recordId,
                //field : changedFields.includes(changedVOD)?"VOD":"FEE"
            });
            action1.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS" && response.getReturnValue()!=null){
                    var opportunity = response.getReturnValue(); 
                    console.log('if1.1');
                    
                    this.modalEntry(component, event, opportunity);
                } else if(state === "ERROR"){
                    
                    console.log('Error-->: ' + JSON.stringify(response.getError()));
                } else {
                    console.log('No action needed/Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                }
            });
            $A.enqueueAction(action1);
        }
        
        else if(component.get('v.recordId')!=null &&((changeType=='CHANGED' && changedFields.includes(notApproved))||changeType=='LOADED')){
            console.log('ele')
            var action2 = component.get("c.getOpportunity");
            action2.setParams({
                recordId : recordId
            });
            
            action2.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('if2.1');
                    var opportunity = response.getReturnValue();
                    if ((opportunity.Pricing_Approved_by_Business_Head__c==false && opportunity.Pricing_Approved_by_Commercial_Head__c==false && opportunity.Pricing_Approved_by_CEO__c==false && changeType=='LOADED') || changeType=='CHANGED'){
                        this.modalEntry(component, event, opportunity,changeType);
                    }
                } else if(state === "ERROR"){
                    console.log('Error-->: ' + JSON.stringify(response.getError()));
                } else {
                    console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                }
            });
            $A.enqueueAction(action2);
        }
    },
    modalEntry : function(component, event, opportunity) {
        console.log('modalEntry');
        
        if(opportunity!=null && opportunity.Pricing_Not_Auto_Approved__c && opportunity.Commercial_Head__c==null){
            console.log('modalEntry if1');
            
            component.set("v.showModal",true);
            component.set("v.submitted",true);
            component.set("v.displayMessgae",'Cannot submit for approval due to missing Commercial Head on Opportunity.'); 
        }
        else if((opportunity!=null && opportunity.Pricing_Not_Auto_Approved__c)||(opportunity!=null && opportunity.Pricing_Not_Auto_Approved__c && opportunity.Pricing_Rejected_by_Business_Head__c)){
            console.log('modalEntry elseif');
            
            var errorFields = '';
            if(opportunity.Customer_Fee_Type__c!='Cap'&&opportunity.Ownership_Type__c!='Government'){
                errorFields = "IRF as per framework is : "+opportunity.CurrencyDisplayFormula__c+" "+opportunity.Target_Fee_IRF__c+" <br/> ASF as per framework is : "+opportunity.CurrencyDisplayFormula__c+" "+opportunity.Annual_Surveillance_Fee_as_per_Framework__c+"<br/>";
            }if(opportunity.VoD_in_crore__c>5000){
                errorFields += "Volume of Debt/Balance Sheet (In Crore) : "+opportunity.CurrencyDisplayFormula__c+" "+(opportunity.VoD_in_crore__c).toFixed(4)+"<br/>";
            }if(opportunity.Customer_Fee_Type__c=='Cap'){
                errorFields += "Customer Fee Type is : "+opportunity.Customer_Fee_Type__c+"<br/>";
            }if(opportunity.Ownership_Type__c=='Government'){
                errorFields += "Ownership Type is : "+opportunity.Ownership_Type__c+"<br/>";
            }
            var msg = "<b>This Opportunity requires approval since,<br/> "+errorFields+"Click OK to invoke Approval process Or Click Cancel to go back.</b>";
            component.set("v.displayMessgae",msg);
            component.set("v.showModal",true);
        }
            else{
                console.log('modalEntry else');
                
            }
    },
    
    submitForApproval : function(component, event) {
        const recordId = component.get('v.recordId');
        var action = component.get("c.invokeApprovalProcess");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.displayMessgae",'Successfully submitted for approval.'); 
            } else if(state === "ERROR"){
                component.set("v.displayMessgae",'Record is locked and Mandate is already submitted for Approval. Changes are not recommended'); 
                console.log('Error-->: ' + JSON.stringify(response.getError()));
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
            component.set("v.submitted",true);
            component.set("v.showSpinner",false);
            component.set("v.showComment",false);
        });
        $A.enqueueAction(action);
    },
    clearApprovals : function(component, event) {
        const recordId = component.get('v.recordId');
        var action = component.get("c.updateApprovalFields");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                $A.get('e.force:refreshView').fire();
                component.set("v.showModal",false);
            } else if(state === "ERROR"){
                component.set("v.displayMessgae",'Error while updating Proposed fees. Please make sure to complete the approval process'); 
                console.log('Error: ' + JSON.stringify(response.getError()));
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
            component.set("v.submitted",true);
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        
    }
})