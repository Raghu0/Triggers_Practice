@isTest
public with sharing class ContactTriggerHandlerTest {

    @isTest
    private static void updateAccountDescriptionTest(){

        //Create Test Data
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 100; i++){
            accounts.add(new Account(Name = 'Test ' + i, Phone = '9876543210', Description = 'Test Account'));
        }

        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for(Account acc : accounts){
                contacts.add(new Contact(LastName = 'Contact ' + acc.Name, Description = 'Test Contact', AccountId = acc.Id));
            }

        insert contacts;

        List<Contact> contactsToBeUpdated = [SELECT Id, LastName, Description, AccountId FROM Contact WHERE LastName LIKE '%Test%'];
        for(Contact con : contactsToBeUpdated){
            if(Integer.valueOf(con.LastName.SubstringAfter('Test ')) >= 50){
                con.Description = 'Test Description';
            }
        }

        Test.startTest();
        update contactsToBeUpdated;
        Test.stopTest();

        //Assertion
        List<Account> accountsToBeAsserted = [SELECT Id, Name, Description FROM Account WHERE Name LIKE 'Test %'];

        SYstem.debug('Accounts To Be Asserted :::: ' +accountsToBeAsserted);

        for(Account acc : accountsToBeAsserted){

            Integer accountIndex = Integer.valueOf(acc.Name.substringAfter('Test '));

            if(accountIndex < 50){
                System.assertEquals('Test Account', acc.Description, 'Account Description should not be updated.');
                System.assertNotEquals('Test Description', acc.Description, 'Account Description should not be updated.');
            }
            else {
                System.assertEquals('Test Description', acc.Description, 'Account Description should be updated to \'Test Description\'');
                System.assertNotEquals('Test Account', acc.Description, 'Account Description should be updated to \'Test Description\'');
            }
        }
    }

    @isTest
    private static void countTotalContactsTest(){

        //Test Data Creation -- Accounts 
        List< Account> accounts = new List<Account>();
        for(Integer i = 0; i < 200; i++){
            if(i < 50){
                accounts.add(new Account(Name = 'Set 1 Test ' + i, 
                                        Phone = '9876543210'));
            }
            if(i >= 50 && i < 100){
                accounts.add(new Account(Name = 'Set 2 Test ' + i, 
                                        Phone = '9876543210'));
            }
            if(i >= 100){
                accounts.add(new Account(Name = 'Set 3 Test ' + i, 
                                        Phone = '9876543210'));
            }
        }


        insert accounts;

        //Contacts created

        //Contacts to be newly inserted
        List<Contact> newContacts = new List<Contact>();
        for(Account acc : accounts){
            Integer accIndex = Integer.valueOf(acc.Name.substringAfter('Test '));
            for(Integer i = 0; i < 5; i++){
                if(accIndex < 50){
                    newContacts.add(new Contact(LastName = 'Insert Test Contact ' + i + ' ' + accIndex,
                                                AccountId = acc.Id));
                }
                if(accIndex >= 50 && accIndex < 100){
                    newContacts.add(new Contact(LastName = 'Update Test Contact ' +accIndex + '.' +i,
                                                AccountId = acc.Id));
                }
                if(accIndex >= 100){
                    newContacts.add(new Contact(LastName = 'Delete Test Contact ' +accIndex + ' ' + i,
                                                AccountId = acc.Id));
                }

            }
        }

        //Testing when the new Contacts are inserted
        Test.startTest();
        insert newContacts;
        
        //Assertion if the Contacts are inserted and counted properly
        Map<Id, Account> accountsIdMap = new Map<Id, Account>([SELECT Id, Name, Number_of_Contacts__c FROM Account WHERE Id IN : accounts]);
        for(Account acct : accountsIdMap.values()){
            System.assertEquals(5, acct.Number_of_Contacts__c, 'Contacts Count is not correct.');
            System.assertNotEquals(0, acct.Number_of_Contacts__c, 'Contacts count is not correct.');
        }

        //Contacts to be deleted
        List<Contact> contactsToBeDeleted = [SELECT Id, LastName, AccountId FROM Contact WHERE LastName LIKE 'Delete %'];
        Set<Id> acctIds = new Set<Id>();
        for(Contact con : contactsToBeDeleted){
            acctIds.add(con.AccountId);
        }

        //Testing the Count after the Contacts are deleted.
        delete contactsToBeDeleted;

        //Assertion of Accounts after the Accounts are deleted.
        List<Account> accountsWithDeletedContacts = [SELECT Id, Name, Number_of_Contacts__c FROM Account WHERE Id IN : acctIds];
        for(Account acc : accountsWithDeletedContacts){
            system.assertEquals(0, acc.Number_of_Contacts__c, 'Number of Contacts count is not updated after deletion of the Contacts.');
            System.assertNotEquals(5, acc.Number_of_Contacts__c, 'Number of Contacts count is not updated after deletion of the Contacts');
        }
        
        //Contacts to be updated
        List<Contact> contactsToBeUpdated = [SELECT Id, LastName FROM Contact WHERE LastName LIKE 'Update%'];
        List<Account> updatingAccounts = [SELECT Id, Name, Number_of_Contacts__c FROM Account WHERE Name LIKE 'Set 1%'];
        System.debug('Accounts Size for updated Accts::: ' +updatingAccounts.size() + 'Accounts:::; ' +updatingAccounts); 
        Integer contactIndex = 0;
        for(Account acc : updatingAccounts){
            Integer count = 0;
            while(count < 5 && contactIndex < contactsToBeUpdated.size()){
                contactsToBeUpdated[contactIndex].AccountId = acc.Id;
                contactIndex++;
                count++;
            }
        }

        //Testing the count after AccountId updation of the Contacts
        update contactsToBeUpdated;


        //Assertion if the Contact count is updated properly
        for(Account acc : [SELECT Id, Name, Number_of_Contacts__c FROM Account WHERE Name LIKE 'Update%']){
            System.assertEquals(10, acc.Number_of_Contacts__c, 'Contacts count is not updated properly.');
            System.assertNotEquals(5, acc.Number_of_Contacts__c, 'Contacts count is not updated properly');
        }

        for(Account acc : [SELECT Id,Name, Number_of_Contacts__c FROM Account WHERE Name LIKE 'Set 2%']){
            System.assertEquals(0, acc.Number_of_Contacts__c, 'Contacts count is not updated properly.');
            System.assertNotEquals(5, acc.Number_of_Contacts__c, 'Contacts count is not updated properly');
        }

        //Contacts to be Undeleted
        System.debug('Contacts to be Undeleted:::; ' +contactsToBeDeleted);

        undelete contactsToBeDeleted;

        System.debug('Contacts to be Undeleted:::; ' +contactsToBeDeleted);

        List<Account> accountsAfterUndeletedContacts = [SELECT Id,Name, Number_of_Contacts__c FROM Account WHERE Id IN :acctIds];

        System.debug('Accounts after Undeleted Contacts :::: ' +accountsAfterUndeletedContacts);
        
        //Assertion 
        for(Account acc : accountsAfterUndeletedContacts){
            system.assertEquals(5, acc.Number_of_Contacts__c, 'Number of Contacts count is not updated after undeletion of the Contacts.');
            System.assertNotEquals(0, acc.Number_of_Contacts__c, 'Number of Contacts count is not updated after undeletion of the Contacts');
        }
        Test.stopTest();
        
    }

}