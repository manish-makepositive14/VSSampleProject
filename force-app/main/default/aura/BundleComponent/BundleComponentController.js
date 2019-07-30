({
    handleBubbledEvent : function(component, event, helper) {
        debugger;
        var message = event.getParam("searchText");
        alert(message);
        // set the handler attributes based on event data
        component.set("v.searchString", message);
        
    }
})