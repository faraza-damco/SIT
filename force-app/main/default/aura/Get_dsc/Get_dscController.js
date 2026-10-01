({
    doInit : function(component, event, helper) {
        var action = component.get("c.SignedDoc");    
        var IvId = component.get("v.recordId");
        console.log(IvId);
        
        action.setParams({
            "InvId":IvId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state==>' +state);
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                if(data=="success"){
                    toastEvent.setParams({
                        title : 'Success',
                        message:'Document signed successfully!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }else{
                    toastEvent.setParams({
                        title : 'Error',
                        message:data,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                }
                toastEvent.fire();
                
            }
            else if(state === "ERROR") {
                console.log('error');
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: errors[0].message,
                    duration:' 10000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})