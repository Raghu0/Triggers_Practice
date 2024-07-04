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

            system.debug('Accounts Map Size:::;' +accounts.size());
            system.debug('Accounts Map ::: ' +accounts.values());


            //Accounts to be updated
            List<Account> accountsToBeUpdated = new List<Account>();

            //Loop over Contacts and update the accounts description
            for(Contact con : updatedContacts.values()){
                Account acc = accounts.get(con.AccountId);
                acc.Description = con.Description;
                accountsToBeUpdated.add(acc);
            }

            system.debug('Accounts to be updated ::: ' +accountsToBeUpdated);

            update accountsToBeUpdated;
        }
        
    }
}