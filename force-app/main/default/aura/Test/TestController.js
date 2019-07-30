({
  doInit: function(component, event, helper) {        
    helper.getAccountList(component);
  },
   showPopup: function(component, event, helper){
      var lst = component.get("v.lstAccount");
      //debugger;
      console.log(lst.length);
      document.getElementById("newAccountSectionId").style.display = "block";
      for(var x=0;x<lst.length;x++){
          if(lst[x].selected == true){
              console.log(lst[x].acc.Name);
             // alert(lst[x].acc.Id);
               //debugger;
              component.set('v.accId', lst[x].acc.Id);
              //debugger;
              var accId = lst[x].acc.Id ;
              helper.accountSpecificVal(component, event,lst[x].acc.Id);
          }  
      }
     
  },
  updateValues : function (component,event){
        debugger ;
        var name = component.get("v.acct.Name");
        var acc = component.get("v.acct");
        var action = component.get("c.updateAccount");
      action.setParams({
                accObj : acc
        });
      action.setCallback(this, function(resp) { 
            var state = resp.getState(); 
            if(state == "SUCCESS"){  
                if (resp.getReturnValue() != '') {
                     alert('successs');
                     //alert('The following error while updating record' + resp.getReturnValue());
                     //component.set("v.acct",resp.getReturnValue());
                     document.getElementById("newAccountSectionId").style.display = "none";
                    
                     //window.reload();
                }else {
                     alert('successs');
                }
            }    
        });
        $A.enqueueAction(action);
   },
    addRows: function(component,event,helper){
        
    },
  deleteAccount: function(component, event, helper) {
    event.preventDefault();
    var accountName = event.target.getElementsByClassName('account-name')[0].value;
    confirm('Delete the ' + accountName + ' account? (don’t worry, this won’t actually work!)');
  }
})