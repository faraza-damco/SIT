({
	doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
		console.log('here--')
		var action = component.get("c.pushToiFlow");
        action.setParams({
            opID : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            console.log('getState--',a.getState())
            if (a.getState() === "SUCCESS"){
				console.log('a.getReturnValue()--',a.getReturnValue())                
                if(a.getReturnValue() != null){
                    //alert(a.getReturnValue());
                    if(a.getState() == 'SUCCESS'){
                        var errors = a.getReturnValue();
                        component.set("v.errorMessages", errors); 
                        component.set("v.visible", true);   
                        if(errors=='Data already pushed to iFlow. Do you want to re-push the data?'){
                            component.set("v.popUp", true);
                        }                
                    }else if(a.getState() == 'ERROR'){
                        var errors = a.getReturnValue();
                        component.set("v.errorMessages", errors); 
                        component.set("v.visible", true);                        
                    } 
                    else {
                        var errors = a.getReturnValue();
                        component.set("v.errorMessages", errors);     
                        component.set("v.visible", true);                     
                    }                     
            	}
            } 
            else{
                var errors = a.getReturnValue();
                component.set("v.errorMessages", errors); 
                component.set("v.visible", true);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);        
	},

    handleYes: function(component, event, helper){
        component.set("v.Spinner", true);
		console.log('Data Repushed --')
		var action = component.get("c.pushToiFlowAgain");
        action.setParams({
            opID : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            console.log('getState--',a.getState())
            if (a.getState() === "SUCCESS"){
				console.log('a.getReturnValue()--',a.getReturnValue())                
                if(a.getReturnValue() != null){
                    component.set("v.popUp", false);
                    //alert(a.getReturnValue());
                    if(a.getState() == 'SUCCESS'){
                        var errors = a.getReturnValue();
                        component.set("v.errorMessages", errors); 
                        component.set("v.visible", true);                  
                    }else if(a.getState() == 'ERROR'){
                        var errors = a.getReturnValue();
                        component.set("v.errorMessages", errors); 
                        component.set("v.visible", true);                        
                    } 
                    else {
                        var errors = a.getReturnValue();
                        component.set("v.errorMessages", errors);     
                        component.set("v.visible", true);                     
                    }                     
            	}
            } 
            else{
                var errors = a.getReturnValue();
                component.set("v.errorMessages", errors); 
                component.set("v.visible", true);
                component.set("v.popUp", false);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action); 
    },

    handleNo: function(){
        console.log('Data Repush Cancelled');
        $A.get("e.force:closeQuickAction").fire(); 
        $A.get("e.force:refreshView").fire(); 
    }

})