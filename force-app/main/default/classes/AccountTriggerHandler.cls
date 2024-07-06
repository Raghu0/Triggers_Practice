//@author Raghava Date: 06/30
public with sharing class AccountTriggerHandler {

    public static Boolean canRunFromTestClass{get;set;}

    /* This method validates if the Account.Phone field is Empty or not */
    public static void performPhoneValidation(List<Account> newAccounts){
        if(!newAccounts.isEmpty()){
            if(Test.isRunningTest() && canRunFromTestClass == true){
                for(Account acc : newAccounts){
                    if(acc.Phone == null){
                        acc.Phone.addError('You cannot leave the Phone field empty');
                    }
                }
            }
        
        }
        }
 
    /*Method to update Account Shipping Address with Account Billing Address
    whenever an Account record is created or updated.*/
    public static void updateShippingAddress(List<Account> newAccounts){
        if(Test.isRunningTest() && canRunFromTestClass == true){
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
        if(Test.isRunningTest() && canRunFromTestClass == true){
            for(Account acc : newAccounts){
                if(acc.Phone != oldAccounts.get(acc.Id).Phone){
                    accounts.put(acc.Id, acc);
                }
            }
        }

    //If it is changed, then query the related Contacts of the Accounts
        //Now with the above for loop, we collected all the Account records whose Phone value is changed.
        //Now the related Contacts Phone value should be updated accordingly.
 
        List<Contact> contactsToBeUpdated = new List<Contact>() ;

        if(!accounts.isEmpty()){
            for(Contact cont : [SELECT Id, Phone, AccountId FROM Contact WHERE AccountId IN : accounts.keySet()]){
                //Update those Contacts with Accounts Phone value.
                        cont.Phone = accounts.get(cont.AccountId).Phone;
                        contactsToBeUpdated.add(cont);
                    }
        }

        /* Here in Line 38 we used Map collection instead of List, the reason behind that is to avoid more lines of
        code and additional SOQL query if we resort to list. In Line 53, we have to use Phone field value from Account record,
        to update the Contact Phone value. If we use List instead of Map, we will ending up with extra SOQL query and nested for loop. You can give it a try for learning.*/
 
    //Update all the Contact records, at once.
    if(!contactsToBeUpdated.isEmpty()){
        update contactsToBeUpdated;
        }
    }

    //Method to prevent duplication of Account records whenever a record is created or updated.
    public static void preventDuplicateAccounts(List<Account> newAccounts){

        //Set of Account Names that are to be inserted /Updated
        Set<String> accountNames = new Set<String>();

        //Iterate over the new records about to be inserted /updated and add all the acc names to the set
        if(Test.isRunningTest() && canRunFromTestClass == true){
            for(Account acc : newAccounts){
                accountNames.add(acc.Name);
            }
        }


        /*Collect all the existing account records in the org. Here there can be two scenarios 
            1. The org is already cleaned and there are no duplicate accounts existing in the org. All Account Names are unique ones
            2. Unlike above scenario, there can be already existing duplicates existing in the org and we are implementing this apex code to prevent further duplication.
        Considering the worst case in the above two scenarios, I'm using a Map to collect all the Account records from the org.*/

        Map<String, List<Account>> existingAccounts = new Map<String, List<Account>>();

        //Iterate over all the Account records.
        if(!accountNames.isEmpty()){
            for(Account acc : [SELECT Id, Name FROM Account WHERE Name IN : accountNames]){
                if(!existingAccounts.containsKey(acc.Name)){
                    existingAccounts.put(acc.Name, new List<Account>());
                }
                else{
                    existingAccounts.get(acc.Name).add(acc);
                }
            }
        }


        /*I used multi-value map where the keys are account names and the values are lists of accounts allowed
         the trigger to handle cases where multiple existing accounts have the same name.*/

         //Now loop over the new Account records and validate the names

         if(!accountNames.isEmpty()){
            for(Account acct : newAccounts){
                if(existingAccounts.containsKey(acct.Name)){
                    acct.addError('There is already an Account with this name.');
                }
             }
         }
    }

    //Method to create a related Contact to Account when a custom checkbox field - Create_Contact_Checkbox__c is ticked.
    public static void createContactToAccount(List<Account> newAccounts){

        List<Contact> contactsToBeCreated = new List<Contact>();

        //Check if the Test Class method should run this code or not?
        if(Test.isRunningTest() && canRunFromTestClass == true){
            for(Account acc : newAccounts){
                if(acc.Create_Contact_Checkbox__c == true && acc.Phone != null){
                    Contact con = new Contact();
                    con.FirstName = 'Test ';
                    con.LastName = acc.Name;
                    con.AccountId = acc.Id;
                    con.Phone = acc.Phone;
                    contactsToBeCreated.add(con);
                }
            }

        }

        if(!contactsToBeCreated.isEmpty()){
            insert contactsToBeCreated;
        }
    }

}