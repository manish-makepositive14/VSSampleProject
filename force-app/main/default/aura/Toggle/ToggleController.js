({
	changeNow : function(component, event, helper) {
         var cmpTarget = component.find('toggleIt');
		$A.util.toggleClass(cmpTarget, 'Changeme');
	}
})