//@author Raghava Date: 06/30
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        /*This trigger fires when the Account record is Inserted or Updated, and the method validates the Phone field, if it is Empty?*/
        AccountTriggerHandler.performPhoneValidation(Trigger.new);   

        /*Trigger to update the Account Shipping Address with Account Billing Address whenever an Account record is created or updated. */
        AccountTriggerHandler.updateShippingAddress(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        /* Trigger to update all related Contact Phone with Account Phone field value whenever an Account record is updated.*/
        AccountTriggerHandler.updateContactPhone(Trigger.new, Trigger.oldMap);
    }
    }