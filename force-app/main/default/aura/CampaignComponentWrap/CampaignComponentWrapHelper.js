({
	saveCampaigndata : function(component, event) {
		alert('hii');
	},
    handleComponentEventData : function(component, event) {
         alert('helloooo');
        var x = event.getParams("campaign");
        var action = component.get('c.createCampaign');
        action.setParams({
                camp : x
        });
        //console.log(JSON.stringify(x));
    }
})