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

}