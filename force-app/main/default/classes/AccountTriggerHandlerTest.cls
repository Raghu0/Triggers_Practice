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
            insert accounts;
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
        private static void udpateShippingAddressonAccountUpdate(){

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
            insert accounts;

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
    }