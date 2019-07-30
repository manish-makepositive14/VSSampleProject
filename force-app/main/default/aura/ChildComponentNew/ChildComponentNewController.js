({
	showPopup: function(component, event, helper){
      var lst = component.get("v.individualRec").Id;
      //debugger;
      console.log(lst);
     /* document.getElementById("newAccountSectionId").style.display = "block";
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
      }*/
     
  }
})