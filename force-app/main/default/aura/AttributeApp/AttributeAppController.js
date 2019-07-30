({
	changeChild : function(component, event, helper) {
		var cmp = component.set("v.value","Billu");
        //console.log("child has chenaged now");
	},
    doSomething : function(component, event, helper) {
        console.log("child has changed");
    }
})