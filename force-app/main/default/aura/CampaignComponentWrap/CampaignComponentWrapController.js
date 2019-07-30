({
	saveCampaign : function(component, event, helper) {
		helper.saveCampaigndata(component, event);
	},
    handleComponentEvent : function(component, event, helper) {
        
        alert('a');
        helper.handleComponentEventData(component, event);
    }
})