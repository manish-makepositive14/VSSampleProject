public class AuraProcessingMessage {
	@AuraEnabled Public boolean isSuccess;
    @AuraEnabled Public String errorMsg;
    @AuraEnabled Public String successMsg;
    @AuraEnabled Public List<CampaignController.CampaignWrapper> campWrap;
    
    public AuraProcessingMessage(){
        isSuccess = false;
        errorMsg = '';
        successMSg = '';
    }
}