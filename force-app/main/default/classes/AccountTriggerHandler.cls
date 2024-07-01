//@author Raghava
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
    }