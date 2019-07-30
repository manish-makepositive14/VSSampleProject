trigger EventTrigger on Event__c (after update,after insert, after delete) {
    
    EventHandler eveNadlerObject = new EventHandler();
    
    if(Trigger.isInsert && Trigger.isUpdate){
       eveNadlerObject.onAfterInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isUpdate){
       eveNadlerObject.onAfterUpdate(Trigger.new,Trigger.oldMap);
    }
    else if(Trigger.isInsert && Trigger.isUpdate){
       eveNadlerObject.onAfterDelete(Trigger.new);
    }
}