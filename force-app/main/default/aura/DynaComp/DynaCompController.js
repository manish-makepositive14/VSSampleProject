({
	doInit : function(component, event, helper) {
        
        var msg = component.get("v.message");
        debugger;
		$A.createComponents([
            ["ui:message",{
                "title" : "sample thrown error",
                "severity" : "error",
                
            }],
            ["ui:outputText",{
                "value" : msg
            }]
        ],
                           
           function(components, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    debugger;
                    var message = components[0];
                    var outputText = components[1];
                    
                    message.set("v.body",outputText);
                    
                    var body = component.get("v.body");
                    body.push(message);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
            );
	},
    
})