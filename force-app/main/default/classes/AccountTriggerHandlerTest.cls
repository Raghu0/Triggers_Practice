///@author Raghava Date: 06/30
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
            doesn't get created and throws a runtime DML exception. To avoid this we can insert the partial records that meet the criteria using 
            the operation --- Database.insert(accounts, false);*/
        AccountTriggerHandler.canRunFromTestClass = false;
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
        //Turn on Flag to run the Apex Class for this Test Code
        AccountTriggerHandler.canRunFromTestClass = false;
        Database.insert(accounts, false);

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
        
        //Turn on Flag to run the Apex Class for this Test Code
        AccountTriggerHandler.canRunFromTestClass = false;

        Database.update(insertedAccounts, false);
       
        Test.stopTest();

        List<Account> accountsUpdated = [SELECT Id, Name, Phone FROM Account WHERE Phone = '0123456789'];
            system.assertEquals(50, accountsUpdated.size(), 'Phone field cannot be updated with null');
        }

        @isTest
        private static void updateShippingAddressTestonAccountInsert(){
            List<Account> accounts = new List<Account>();

            //Test Data creation

            for(Integer i = 0; i < 150; i++){
                if(i < 50){
                    accounts.add(new Account(Name = 'Test '+ i,
                                            Phone = '9876543210',
                                            BillingCity = 'Syracuse',
                                            BillingState = 'New York',
                                            BillingCountry = 'USA'));  
                }
                if(i >= 50 && i < 100){
                    accounts.add(new Account( Name = 'Test ' + i,
                                            Phone = '1234567890',
                                            BillingCity = 'Atlantic City',
                                            BillingState = 'New Jersey',
                                            BillingCountry = 'USA'));          
                }
                if(i >= 100){
                    accounts.add(new Account( Name = 'Test ' + i,
                                            Phone = '0123456789'));
                }
            }

            //Test the feature to copy Billing Address to Shipping Address upon insertion

            Test.startTest();
            //Turn on Flag to run the Apex Class for this Test Code
            AccountTriggerHandler.canRunFromTestClass = false;

            Database.insert(accounts, false);
            Test.stopTest();

            //As we created the account records, now assert them

            //Assertion of the Accounts created with New York state
            List<Account> nyAccounts = [SELECT Id, Name, ShippingCity, ShippingState, ShippingCountry
                                        FROM Account
                                        WHERE BillingCity = 'Syracuse'];
            System.debug('Accounts Created with NY :::: ' +nyAccounts.size());
            System.debug('Accounts List NY :::' +nyAccounts);

            System.assertEquals(50, nyAccounts.size(), 'Account records are not created properly.');

            for(Account acc : nyAccounts){
                System.assertEquals('Syracuse', acc.ShippingCity, 'Account Shipping City should be Syracuse');
                System.assertEquals('New York', acc.ShippingState, 'Account Shipping State should be New York');
                System.assertEquals('USA', acc.ShippingCountry, 'Account Shipping Country should be USA');
            }

            //Assertion of the Accounts created with New Jersey state
            List<Account> njAccounts = [SELECT Id, Name, ShippingCity, ShippingState, ShippingCountry
                                        FROM Account
                                        WHERE BillingCity = 'Atlantic City'];

            System.assertEquals(50, njAccounts.size(), 'Account records are not created properly.');

            for(Account acc : njAccounts){
                System.assertEquals('Atlantic City', acc.ShippingCity, 'Account Shipping City should be Atlantic City');
                System.assertEquals('New Jersey', acc.ShippingState, 'Account Shipping State should be New Jersey');
                System.assertEquals('USA', acc.ShippingCountry, 'Account Shipping Country should be USA');
            }

            //Assertion of the Accounts created with Null state
            List<Account> nullAccounts = [SELECT Id, Name, ShippingCity, ShippingState, ShippingCountry
                                        FROM Account
                                        WHERE BillingCity = NULL];

            System.assertEquals(50, nullAccounts.size(), 'Account records are not created properly.');

            for(Account acc : nullAccounts){
                System.assertEquals(null, acc.ShippingCity, 'Account Shipping City should be null');
                System.assertEquals(null, acc.ShippingState, 'Account Shipping State should be null');
                System.assertEquals(null, acc.ShippingCountry, 'Account Shipping Country should be null');
            }
        }

        @isTest
        private static void udpateShippingAddressTestonAccountUpdate(){

            //Test Data Creation
            List<Account> accounts = new List<Account>();
            for(Integer i = 0; i < 100; i++){
                accounts.add(new Account( Name = 'Test ' + i,
                                        Phone = '9876543210',
                                        BillingCity = 'Hyderabad',
                                        BillingState = 'Telangana',
                                        BillingStreet = 'RGV Street',
                                        BillingCountry = 'India'));
            }
            //Turn on Flag to run the Apex Class for this Test Code
            AccountTriggerHandler.canRunFromTestClass = false;

            Database.insert(accounts, false);

            //Now modify the values of Billing Address of the Account records which automatically should be updated to Shipping Address

            List<Account> accountsToBeUpdated = [SELECT Name, Phone, BillingCity FROM Account WHERE Name LIKE 'Test%'];

            for(Account acc : accountsToBeUpdated){
                //Update Account records with i < 50 as Billing City = Warangal
                if(Integer.valueOf(acc.Name.substringAfter('Test ')) < 50){
                    acc.BillingCity = 'Warangal';
                }
                //Update Account records with i < 50 as Billing City = Cyberabad
                if(Integer.valueOf(acc.Name.substringAfterLast('Test ')) >= 50){
                    acc.BillingCity = 'Cyberabad';
                }
            }

            //Test the records by updating the Billing City
            
            Test.startTest();
            //Turn on Flag to run the Apex Class for this Test Code
            AccountTriggerHandler.canRunFromTestClass = false;

            update accountsToBeUpdated;
            Test.stopTest();

            //Assertions if the records are updated properly
            for(Account acc : [SELECT Name, Phone, ShippingCity FROM Account WHERE Name LIKE 'Test%']){

                //Assert if the first 50 records Shipping City is updated with Warangal.
                if(Integer.valueOf(acc.Name.substringAfter('Test ')) < 50){
                    System.assertEquals('Warangal', acc.ShippingCity, 'BillingCity Should be updated with Warangal.');
                }
                //Assert if the first 50 records Shipping City is updated with Cyberbad.
                if(Integer.valueOf(acc.Name.substringAfter('Test ')) >= 50){
                    System.assertEquals('Cyberabad', acc.ShippingCity, 'BillingCity Should be updated with Cyberabad.');
                }
            }

        }

        @isTest
        private static void updateContactPhoneTest(){
            List<Account> accounts = new List<Account>();
            //Test Data Creation
            for(Integer i = 0; i < 100; i++){

                    accounts.add(new Account(Name = 'Test ' + i,
                                            Phone = '9876543210'));
            }

            Database.insert(accounts, false);

            System.debug('Accounts Inserted :::' + accounts);

            List<Contact> contacts = new List<Contact>();

            for(Account acc : accounts){
                if(Integer.valueOf(acc.Name.substringAfter('Test ')) >= 50){
                    for(Integer i = 0; i < 5; i++){
                        contacts.add(new Contact(LastName = acc.Name + 'Test ' +i, 
                                            AccountId = acc.Id));
                    }
                    
                }
            }

            //In total we created 100 Accounts;
            //First 50 Accounts doesn't have any Contacts at all;
            //Last 50 Accounts have, 5 Contacts to each Accounts, total making it as 50 * 5 = 250 Contacts

            insert contacts;

            System.debug('Contacts inserted ::::' +[SELECT Id, AccountId, Phone FROM Contact WHERE AccountId IN :accounts]);

            //Now updating the Phone field of Accounts

            List<Account> accountsToBeUpdated = [SELECT Id, Name, Phone FROM Account WHERE Name LIKE 'Test%'];
            
            for(Account acc : accountsToBeUpdated){
                Integer testAccNumber = Integer.valueOf(acc.Name.substringAfter('Test '));
                //Updating first 50 accounts with Phone = '9849646132'
                if(testAccNumber < 50){
                    acc.Phone = '9849646132';
                }

                //Update next 25 Accounts with Phone = '9999999999'
                if(testAccNumber >= 50 && testAccNumber < 75 ){
                    acc.Phone = '9999999999';
                }

                //Update next 25 Acounts with Phone = null
                if(testAccNumber >= 75){
                    acc.Phone = '8888888888';
                }
            }

            //Now update all the Account records.

            Test.startTest();
            //Turn on Flag to run the Apex Class for this Test Code
            AccountTriggerHandler.canRunFromTestClass = false;

            update accountsToBeUpdated;
            Test.stopTest();

            //As we just updated the Account records, the Test Class will call the trigger and update the Contacts Phone value as coded.
            //Assert if the Contacts are updated as expected.

            //For the first 50 Accounts there are no Contacts associated, so even after updating Accounts, no contact should be affected.

            //Assertion for the last 50 Accounts.

            List<Account> accountsBatch1 = [SELECT Id, Phone FROM Account WHERE Phone = '9999999999'];
            //Querying Contacts Batch 1 --- >= 50 - < 75.
            List<Contact> contactsBatch1 = [SELECT Id, Phone FROM Contact WHERE AccountId IN : accountsBatch1];
            for(Contact cont : contactsBatch1){
                System.assertEquals('9999999999', cont.Phone, 'Contacts Phone is not updated as expected from the Account');
                System.assertNotEquals('9876543210', cont.Phone, 'Contacts Phone is not updated');
            }

            List<Account> accountsBatch2 = [SELECT Id, Phone FROM Account WHERE Phone = '8888888888'];
            //Querying Contacts Batch 2
            List<Contact> contactsBatch2 = [SELECT Id, Phone FROM Contact WHERE AccountId IN : accountsBatch2];
            for(Contact cont : contactsBatch2){
                System.assertEquals( '8888888888', cont.Phone, 'Contacts Phone is not updated as expected from the Account');
                System.assertNotEquals('9876543210', cont.Phone, 'Contacts Phone is not updated');
            }
        }

        @isTest
        private static void preventDuplicateAccountsTest(){

            //Test data creation
            List<Account> accounts = new List<Account>();
            for(Integer i = 0; i < 200; i++){
                accounts.add(new Account(Name = 'Test Account ' + i, Phone = '9876543210'));
            }
            insert accounts;

            List<Account> duplicateAccounts = new List<Account>();
            for(Integer i = 0; i < 200; i++){
                if(i < 50){
                    duplicateAccounts.add(new Account(Name = 'Test Account ' + i, Phone = '9876543210'));
                }
                else{
                    duplicateAccounts.add(new Account(Name = 'Account Test ' + i, Phone = '9876543210'));
                }
            }
            Test.startTest();
            //Turn on Flag to run the Apex Class for this Test Code
            AccountTriggerHandler.canRunFromTestClass = true; 
            Database.insert(duplicateAccounts, false) ;

            List<Account> accountsCreated = [SELECT Id, Name FROM Account WHERE Id IN : duplicateAccounts];
            
            for(Account acc : accountsCreated){
                System.assertEquals(150, accountsCreated.size(), 'Duplicate Accounts should not be created.');
                System.assertNotEquals(200, accountsCreated.size(), 'Duplicate Accounts should not be created.');
            }
            Test.stopTest();
        }

        @isTest
        private static void createContactToAccountTest(){

            //Test Data Creation
            List<Account> accounts = new List<Account>();
            for(Integer i = 0; i < 200; i++){
                if(i < 100){
                    accounts.add(new Account(Name = 'Test Account ' + i,
                                            Create_Contact_Checkbox__c = true,
                                            Phone = '9876543210'));
                }
                else{
                    accounts.add(new Account(Name = 'Test Account ' + i,
                                            Phone = '9876543210'));      
                }
            }

            Test.startTest();
            //Turn on Flag to run the Apex Class for this Test Code
            AccountTriggerHandler.canRunFromTestClass = true; 
            Database.insert(accounts, false);
            Test.stopTest();

            //Assertion
            for(Account acc : [SELECT Id, Name, (SELECT Id, LastName, AccountId FROM Contacts) FROM Account WHERE Id IN : accounts]){
                if(Integer.valueOf(acc.Name.substringAfter('Account ')) < 100 ){
                    System.assertEquals(1, acc.Contacts.size(), 'A Contact should be created as Create_Contact_Checkbox__c is TRUE');
                    System.assertNotEquals(0, acc.Contacts.size(), 'Contact should be created');
                }
                else{
                    System.assertEquals(0, acc.Contacts.size(), 'No Contact should be created.');
                    System.assertNotEquals(1, acc.Contacts.size(), 'No Contact should be created.');
                }
            }
        }
    }