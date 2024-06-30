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
    }