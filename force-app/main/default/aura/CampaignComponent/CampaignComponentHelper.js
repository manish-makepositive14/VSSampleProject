({
	/*getCampList : function(component) {
        debugger; 
		var action = component.get("c.getCampaignList");
        
        action.setCallback(this,function(a){
            var state = a.getState();
            var result = a.getReturnValue();
            console.log(JSON.stringify(result));
            if(state === 'SUCCESS'){
                component.set('v.message',result);  
            }
        });
        $A.enqueueAction(action);
	},*/
    
    sendCampData : function(component) {
        debugger;
        var cmpEvent = component.getEvent("cmpEvent");
        var camp = component.get("v.camp");
        cmpEvent.setParams({
            "campaign":camp
        });
        cmpEvent.fire();
    }
})