# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)


This has a list of Triggers for the hands-on practice.

Trigger - 1

When an Account is created/updated, write a trigger to ensure a value in the 'Phone' field. It should never be null. If it is null, make sure the trigger throws an error at the Phone field on the Account record. Also, write a test class for the same.

Trigger - 2

When an Account record is created/updated, write a trigger that updates the Shipping Address with the Billing Address values. Write a test class for the same.

Trigger - 3 (Update Child records by Parent)

When an Account Phone field is updated, then update the Phone field of all the related Contacts of the Account with the same value.
Also, write a test class for the same.


Trigger - 4 (Update Parent by Child)

When a Contact's Description is updated, then its parent Account's Description should also be updated with the same value. Write a Test Class for the same.


Trigger - 5 (Roll Up Summary Trigger)

Write a trigger to count the number of related contacts of an account and display the contact count on the Accounts' custom field. Write a test class for the same. (Note: Create a custom field on Account object - Number_of_Contacts__c)
Hint: The Count of Contact's related to an Account will be changed when a new Contact is Created to an Account, or a Contact is deleted from an Account, or a Contact is Undeleted from RecycleBin or a Contact's parent Account is changed from 'abc' to 'xyz.


Trigger - 6 (Prevention of Duplication of records)

Write a Trigger to prevent duplication of account record based on name whenever a record is inserted or updated. Write a Test Class for the same.
Note: Consider the scenario that there are already few duplicate records in the org. Example: There are two Accounts with same name - 'Acme Intl'. Now prevent the any new record creation with the same or existing record updation to this name.