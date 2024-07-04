trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        //Trigger to update the Account Description when the Contact Description is updated.
        ContactTriggerHandler.updateAccountDescription(Trigger.new, Trigger.oldMap);
    }

}