//@author Raghava
@isTest
public with sharing class AccountTriggerHandlerTest {
    @isTest
    private static void performPhoneValidationInsertTest() {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 200; i++){
            if(i<100){
                accounts.add(new Account(Name = 'Test ' + i, Phone = '9876543210'));
            }
            else {
                accounts.add(new Account(Name = 'Test ' + i));
            }
        }

        Test.startTest();
        try {
            /*The reason why I included Database.insert instead of genneral insert operation is as we are inserting List of accounts,
            100 records have phone value and 100 records has no 'Phone' field value and the records without 'Phone' field value 
            doesn't get created and throws a runtime exception. To avoid this we can insert the partial records that meet the criteria using 
            the operation --- Database.insert(accounts, false);*/

            Database.insert(accounts, false);
        } catch (DmlException e) {
            system.assert(e.getMessage().contains('You cannot leave the Phone field empty'));
        }
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Id, Name, Phone FROM Account WHERE Name LIKE 'Test%'];

        system.debug('Total Accounts Inserted :::: ' +insertedAccounts.size());
        system.debug('Accounts that are inserted :::: ' + insertedAccounts);

        system.assertEquals(100, insertedAccounts.size(), 'Only Accounts with Phone field records should be inserted');
        system.assertNotEquals(200, insertedAccounts.size(), 'Only Accounts with Phone field records should be inserted');

        for(Account acc : insertedAccounts){
            system.assert(acc.Phone != null, 'Inserted Accounts should have a Phone value');
        }
        
    }

    @isTest
    private static void performPhoneValidationUpdateTest(){
        List<Account> accounts = new List<Account>();

        for(Integer i = 0; i < 100; i++){
                accounts.add(new Account(Name = 'Test ' + i, Phone = '9876543210'));
            }

        insert accounts;

        List<Account> insertedAccounts = [SELECT Id, Name, Phone FROM Account WHERE Name LIKE 'Test%'];

        for(Account acc : insertedAccounts){
            if(Integer.valueOf(acc.Name.substringAfter('Test ')) < 50){
                acc.Phone = '0123456789';
            }
            else {
                acc.Phone = null;
            }
        }

        Test.startTest();
        try {
            Database.update(insertedAccounts, false);
        } catch (DmlException e) {
            system.assert(e.getMessage().contains('You cannot leave the Phone field empty'));
        }
        Test.stopTest();

        List<Account> accountsUpdated = [SELECT Id, Name, Phone FROM Account WHERE Phone = '0123456789'];
            system.assertEquals(50, accountsUpdated.size(), 'Phone field cannot be updated with null');
        }
    }