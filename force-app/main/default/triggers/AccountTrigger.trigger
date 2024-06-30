//@author Raghava
trigger AccountTrigger on Account (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        /*This trigger fires when the Account record is Inserted or Updated, and the method validates the Phone field, if it is Empty?*/
        AccountTriggerHandler.performPhoneValidation(Trigger.new);   
    }
    }