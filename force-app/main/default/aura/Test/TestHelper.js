({
  // Fetch the accounts from the Apex controller
  getAccountList: function(component) {
    var action = component.get('c.getAccountsAll');

    // Set up the callback
    var self = this;
    action.setCallback(this, function(actionResult) {
     var state = actionResult.getState();
        if(state === 'ERROR'){
            component.set('v.errorMsg',actionResult.getReturnValue());
        }
     component.set('v.lstAccount', actionResult.getReturnValue());
    });
    $A.enqueueAction(action);
  },
    accountSpecificVal: function(component, event , accId){
        var action = component.get("c.getSpecificAccount");
        action.setParams({
                idAcc : accId
        });
        
        action.setCallback(this, function(resp) { 
            var state = resp.getState(); 
            if(state == "SUCCESS"){  
                if (resp.getReturnValue() != '') {
                     //alert('The following error while updating record' + resp.getReturnValue());
                     component.set("v.acct",resp.getReturnValue());
                }else {
                     alert('successs');
                }
                
                this.onLoad(component, event);
            }    
        });
        $A.enqueueAction(action);
    },
    
    
})