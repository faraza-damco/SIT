({
    doInit : function(component, event, helper) {
                console.log('do')
        component.set("v.submitted",false);
        component.set("v.showComment",true);
        helper.openModal(component, event);
    },
    closeModel: function(component, event, helper) {
        helper.clearApprovals(component, event);
        component.set("v.showModal",false);
        window.location.reload(); 

    },
    submitDetails: function(component, event, helper) {
                console.log('submit')

        component.set("v.showComment",false);
        component.set("v.showSpinner",true);
        helper.submitForApproval(component, event);
    },
    saveOpty: function(component, event, helper) {
                console.log('save')

        if(component.get('v.submitted')){
            component.set("v.showModal",false);
        	$A.get('e.force:refreshView').fire();
        }else{
            event.preventDefault();
            if((component.find('reason').get('v.value') && component.find('comment').get('v.value'))){
        		component.find("opForm").submit();
            	component.set("v.displayError",''); 
            }else{
            	component.set("v.displayError",'Please fill all the required fields.'); 
            }
        }
    },
})