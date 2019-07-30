public class CampaignController {
    
    @AuraEnabled
    Public static AuraProcessingMessage getCampaignList(){
        CampaignWrapper campWrap;
        List<CampaignWrapper> campWrapLst = new List<CampaignWrapper>();
        AuraProcessingMessage auraMessage = new AuraProcessingMessage();
        try{
            List<Campaign> campLst = [Select id, Name, Packed__c, Price__c, Quantity__c FROM Campaign];
            for(Campaign cmp:campLst){
                campWrap = new CampaignWrapper();
                campWrap.cmp = cmp;
                campWrap.selected = false;
                campWrapLst.add(campWrap);
            }
            auraMessage.isSuccess = true;
            auraMessage.successMsg = 'Loaded';
            auraMessage.campWrap = campWrapLst;
            System.debug('@@@aura'+auraMessage);
            return auraMessage;
        }
        catch(Exception e){
            auraMessage.isSuccess = false;
            auraMessage.errorMsg = e.getMessage();
            return auraMessage;
        }
    }
    
    public void createCampaign(String camp){
        Campaign camps  = (Campaign)JSON.deserialize(camp, Campaign.class);
        system.debug('@@@camps'+camps);
        insert camps;
    }
    
    @AuraEnabled
    Public AuraProcessingMessage getSaveCampaign(){
        return null;
    }
    
    public class CampaignWrapper{
      @AuraEnabled
      public Campaign cmp;  
      @AuraEnabled
      public Boolean selected;
  }
    
}