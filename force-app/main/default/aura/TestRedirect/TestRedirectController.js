({
    lightningNavigate : function(component, event, helper) {
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "TestRedirected"
            }, 
            "state": {}
        };
        
        navService.navigate(pageReference);
    }
})