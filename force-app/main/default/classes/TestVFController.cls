public with sharing class TestVFController{ 

     public List<string> myTextList{get;set;}
     public string xyz{get;set;}
     public List<Account> accList{get;set;}
     
     public TestVFController(){
        
        if(accList == null)
            accList = new List<Account>();
        accList = [SELECT Name, Phone, Description FROM Account LIMIT 10];
     }
     
     
     public List<String> getAccountList() {
        myTextList= new List<string>();
        for(Account acc:accList){
            string accString = '\r\n       |'+string.valueOf(acc.Name) + '     |'+string.valueOf(acc.Phone)+'        |'+string.valueOf(acc.Description)+'\r\n';
            myTextList.add(accString); 
        }
        return myTextList;
        
     }
    
      public pagereference saveAsAttachment(){
    
            PageReference page = new PageReference('/apex/SaveAsText'); 
            Blob txtPageBlob;
            txtPageBlob = page.getContent();
            Attachment a = new Attachment();
            a.Body = txtPageBlob;
            a.Name = 'TestAttach.txt'; 
            a.ParentId = '00328000002Mrxq';
            a.Description = 'TestDesc'; 
            insert a; 
            
            return null;
    
     } 

 }