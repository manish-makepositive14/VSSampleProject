({
    doInit : function(component, event, helper) {
        var action = component.get('c.getAccountsAll');
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            var result = actionResult.getReturnValue();
            if(state === 'SUCCESS'){
                if(result.isSuccess){
                    component.set('v.errorMsg',result.successMSg);
                }
                else{
                    component.set('v.errorMsg',result.errorMsg);
                }
            }
                
        });
        $A.enqueueAction(action);
    }
})