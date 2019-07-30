public with sharing class AccountsController {
  

  @AuraEnabled
  public static AuraProcessingMessage getAccountsAll() {
      AuraProcessingMessage proMessage = new AuraProcessingMessage();
      try{
        List<AccountWrapper> accWrap = new List<AccountWrapper>();
        List<Account> accList = [SELECT Id, name, industry, Type, NumberOfEmployees, TickerSymbol, Phone
        FROM Account Limit 10];
        AccountWrapper acWrap;
        
        for(Account acc:accList){
            acWrap = new AccountWrapper(acc,false);
           // acWrap.rowNum ++;
            accWrap.add(acWrap);
        }
        proMessage.isSuccess = true;
        promessage.successMsg = 'You are awesome!';
        return promessage;
      }
      catch(Exception e){
         proMessage.isSuccess = false; 
          promessage.errorMsg = e.getMessage();
		return promessage;          
      }
  }
  @AuraEnabled
  public static Account getSpecificAccount(String idAcc){
       List<Account> accList = [SELECT Id, Name, industry, Type, Phone
    FROM Account where id=:idAcc];
    return accList[0];
  }
    
  @AuraEnabled
  public static void updateAccount(Account accObj){
       update accObj;
  }
 
  
  public class AccountWrapper{
      @AuraEnabled
      public Account acc;  
      @AuraEnabled
      Public integer rowNum;
      @AuraEnabled
      public Boolean selected;
      public AccountWrapper(Account acc,boolean selected){
          this.acc = acc;
          this.selected = selected;
      }
  }
    
    public class TextWrapper{
        @AuraEnabled
        Public integer rowNum;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String typ;
        @AuraEnabled
        public String industry;
    }  
}