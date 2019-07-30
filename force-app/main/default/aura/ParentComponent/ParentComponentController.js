({
	changeParent : function(component, event, helper) {
		var cmp = component.set("v.sampleAtt","Billu Badshah");
        console.log('changing the parent vaue');
	},
    doSomething : function(component, event, helper) {
        console.log("parent has chenaged");
    }
})