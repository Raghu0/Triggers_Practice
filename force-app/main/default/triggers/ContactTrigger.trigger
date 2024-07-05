trigger ContactTrigger on Contact (before insert, before update, after insert, after update, before delete, after undelete, after delete) {

    if(Trigger.isAfter && Trigger.isUpdate){
        //Trigger to update the Account Description when the Contact Description is updated.
        ContactTriggerHandler.updateAccountDescription(Trigger.new, Trigger.oldMap);
        //Trigger to update the 'Number_of_Contacts__c' count on the Account 
        ContactTriggerHandler.countTotalContactsUpdated(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        //Trigger to update the 'Number_of_Contacts__c' count on the Account 
        ContactTriggerHandler.countTotalContacts(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        //Trigger to update the 'Number_of_Contacts__c' count on the Account
        ContactTriggerHandler.countTotalContacts(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isUndelete){
        //Trigger to update the 'Number_of_Contacts__c' count on the Account
        ContactTriggerHandler.countTotalContacts(Trigger.new);
    }
    


}