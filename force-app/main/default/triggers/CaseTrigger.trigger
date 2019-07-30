trigger CaseTrigger on Case (after update,before insert) {

    CaseTriggerHandler casTriggerObject = new CaseTriggerHandler();

 	if(Trigger.isInsert && Trigger.isBefore){
        casTriggerObject.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        casTriggerObject.onAfterUpdate(Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
}