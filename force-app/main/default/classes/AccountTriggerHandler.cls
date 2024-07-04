//@author Raghava Date: 06/30
public with sharing class AccountTriggerHandler {
    /* This method validates if the Account.Phone field is Empty or not */
    public static void performPhoneValidation(List<Account> newAccounts){
        if(!newAccounts.isEmpty()){
            for(Account acc : newAccounts){
                if(acc.Phone == null){
                    acc.Phone.addError('You cannot leave the Phone field empty');
                }
            }
        }
        }
 
 
    /*Method to update Account Shipping Address with Account Billing Address
    whenever an Account record is created or updated.*/
    public static void updateShippingAddress(List<Account> newAccounts){
        if(!newAccounts.isEmpty()){
            for(Account acc : newAccounts){
                acc.ShippingStreet = acc.BillingStreet;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingState = acc.BillingState;
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingPostalCode = acc.BillingPostalCode;
            }
        }
    }
 
 
    /* Method to update the all the related Contact's Phone field with Parent's Account Phone field whenever an Account Record is Updated */
 
 
    public static void updateContactPhone(List<Account> newAccounts, Map<Id, Account> oldAccounts){
 
 
    //Check if the Account Phone field value is actually changed by comparing the old and new values of Account.
        //Accounts whose Phone value is updated.
        Map<Id, Account> accounts = new Map<Id, Account>();
 
        for(Account acc : newAccounts){
            if(acc.Phone != oldAccounts.get(acc.Id).Phone){
                accounts.put(acc.Id, acc);
            }
        }
    //If it is changed, then query the related Contacts of the Accounts
        //Now with the above for loop, we collected all the Account records whose Phone value is changed.
        //Now the related Contacts Phone value should be updated accordingly.
 
        List<Contact> contactsToBeUpdated = new List<Contact>() ;
 
        for(Contact cont : [SELECT Id, Phone, AccountId FROM Contact WHERE AccountId IN : accounts.keySet()]){
    //Update those Contacts with Accounts Phone value.
            cont.Phone = accounts.get(cont.AccountId).Phone;
            contactsToBeUpdated.add(cont);
        }
        /* Here in Line 38 we used Map collection instead of List, the reason behind that is to avoid more lines of
        code and additional SOQL query if we resort to list. In Line 53, we have to use Phone field value from Account record,
        to update the Contact Phone value. If we use List instead of Map, we will ending up with extra SOQL query and nested for loop. You can give it a try for learning.*/
 
    //Update all the Contact records, at once.
    if(!contactsToBeUpdated.isEmpty()){
        update contactsToBeUpdated;
       
    }
    }

}
 