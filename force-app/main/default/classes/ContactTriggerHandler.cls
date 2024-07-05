//@Raghu0

public with sharing class ContactTriggerHandler {
    /* Method to update the Account Description with same value as Contact Description whenever a Contact is updated.*/

    public static void updateAccountDescription(List<Contact> newContacts, Map<Id, Contact> oldContacts){

        //Create a Set to Collect the AccountIds
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Contact> updatedContacts = new Map<Id, Contact>();

        for(Contact cont : newContacts){
            //Collect only those Accounts where the Description of the Contact is changed and there is a Parent Account related to the Contact
            if(cont.AccountId != null && cont.Description != oldContacts.get(cont.Id).Description){
                accountIds.add(cont.AccountId);
                updatedContacts.put(cont.Id, cont);
            }
        }

        //Now query the account records 
        if(!accountIds.isEmpty()){
            Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Description FROM Account WHERE Id IN : accountIds]);


            //Accounts to be updated
            List<Account> accountsToBeUpdated = new List<Account>();

            //Loop over Contacts and update the accounts description
            for(Contact con : updatedContacts.values()){
                Account acc = accounts.get(con.AccountId);
                acc.Description = con.Description;
                accountsToBeUpdated.add(acc);
            }

            update accountsToBeUpdated;
        }
        
    }

    //Method to count the total related Contacts associated to an account that are Created / Undeleted /Deleted
    public static void countTotalContacts(List<Contact> contacts){
    
        //Query Accounts related to the Contacts
        Set<Id> accountIds = new Set<Id>();

        for(Contact con : contacts){
            if(con.AccountId != null){
                accountIds.add(con.AccountId);
            }
        }
        //Call another helper method 
        countTotalContactsHelper(accountIds);
    }

    /*Method to count the total related contacts associated to an account that are updated. When a contact is updated, it has below scenarios
            1. AccountId of the contact is updated, from 'abc' account to 'xyz' account. Then count should be added to 'xyz' account and count should be reduced from 'abc' account
            2. AccountId of the Contact is updated with new value, and there is no account before. So the count of this account should be added.  */

    public static void countTotalContactsUpdated(List<Contact> newContacts, Map<Id, Contact> oldContacts){
        Set<Id> accountIds = new Set<Id>();

        for(Contact con : newContacts){
            if(oldContacts.containsKey(con.Id) && con.AccountId != oldContacts.get(con.Id).AccountId){
                if(oldContacts.get(con.Id).AccountId != null){
                    accountIds.add(oldContacts.get(con.Id).AccountId);
                }
                if(con.AccountId != null){
                    accountIds.add(con.AccountId);
                }
            }
        }
        //Call another helper method
        countTotalContactsHelper(accountIds);

    }


    public static void countTotalContactsHelper(Set<Id> accountIds){

                //Now query over the accountIds and map the total related contacts to the AccountId
                Map<Id, Integer> acctIdToContactCount = new Map<Id,Integer>();

                for(Account acc : [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN : accountIds]){
                    acctIdToContactCount.put(acc.Id, acc.Contacts.size());
                }
                //Query Account Map to use it in the loop.
                Map<Id, Account> accountsToBeUpdated = new Map<Id, Account>([SELECT Id, Number_of_Contacts__c FROM Account WHERE Id IN : accountIds]);
                //As we iterated through all the accounts, now update the 'Number of Contacts' field with the count.
                for(Id accId : acctIdToContactCount.keySet()){
                    Account acc = accountsToBeUpdated.get(accId);
                    acc.Number_of_Contacts__c = acctIdToContactCount.get(accId);
                }
        
                //Update the Account records 
                update accountsToBeUpdated.values();

    }
}