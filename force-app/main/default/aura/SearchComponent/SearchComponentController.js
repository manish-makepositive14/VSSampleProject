({
	handleClick : function(component, event, helper) {
        debugger;
        var appEvt = $A.get("e.c:SearchComponentEvt");
        var searchText = component.get("v.searchText");
        appEvt.setParams({
            "searchText": searchText
        });
        appEvt.fire();
	}
})