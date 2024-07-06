//@author Raghava Date: 06/30
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {

    //BEFORE_INSERT
    if(Trigger.isBefore && Trigger.isInsert)
    {
        /*This trigger fires when the Account record is Inserted or Updated, and the method validates the Phone field, if it is Empty?*/
        AccountTriggerHandler.performPhoneValidation(Trigger.new);   

        /*Trigger to update the Account Shipping Address with Account Billing Address whenever an Account record is created or updated. */
        AccountTriggerHandler.updateShippingAddress(Trigger.new);

        //Trigger to check for Account duplicates and prevent the record creation
        AccountTriggerHandler.preventDuplicateAccounts(Trigger.new);
    }

    //BEFORE_UPDATE
    if(Trigger.isBefore && Trigger.isUpdate){
        //Trigger to check for Account duplicates and prevent the record updation
        AccountTriggerHandler.preventDuplicateAccounts(Trigger.new);

    }

    //AFTER_INSERT
    if(Trigger.isAfter && Trigger.isInsert){
        //Trigger to create related Contact to Account when the Create_Contact_Checkbox__c is TRUE.
        AccountTriggerHandler.createContactToAccount(Trigger.new);
    }

    //AFTER_UPDATE
    if(Trigger.isAfter && Trigger.isUpdate){
        /*This trigger fires when the Account record is Inserted or Updated, and the method validates the Phone field, if it is Empty?*/
        AccountTriggerHandler.performPhoneValidation(Trigger.new); 

        /* Trigger to update all related Contact Phone with Account Phone field value whenever an Account record is updated.*/
        AccountTriggerHandler.updateContactPhone(Trigger.new, Trigger.oldMap);
    }


    }