//@author Raghava
trigger AccountTrigger on Account (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        /*This trigger fires when the Account record is Inserted or Updated, and the method validates the Phone field, if it is Empty?*/
        AccountTriggerHandler.performPhoneValidation(Trigger.new);   

        /*Trigger to update the Account Shipping Address with Account Billing Address whenever an Account record is created or updated. */
        AccountTriggerHandler.updateShippingAddress(Trigger.new);
    }
    }