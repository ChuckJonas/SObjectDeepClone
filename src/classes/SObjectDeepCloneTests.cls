@isTest
private class SObjectDeepCloneTest {

	@isTest static void accountWithContacts() {
		Account acc = createAccount();
        insert acc;

        Map<String, Contact> contactsByName = new Map<String,Contact>();
        for(Integer i = 0; i < 5; i++){
            Contact c = createContact(acc.Id, 'Contact', String.valueOf(i));
            contactsByName.put(c.FirstName + c.LastName, c);
        }

        insert contactsByName.values();

        //pass opportunities just to test query gen on multiple children
        SObjectDeepClone clone = new SObjectDeepClone(acc.Id, new Set<String>{'contacts', 'opportunities'});
        Id clonedId = clone.save();
        System.assertNotEquals(null, clonedId);
        System.assertNotEquals(acc.Id, clonedId);

        Account queriedClonedAccount = [SELECT Name, (SELECT FirstName, LastName FROM Contacts) FROM Account WHERE Id = :clonedId];
        System.assertEquals(acc.Name, queriedClonedAccount.Name);
        for(contact c : queriedClonedAccount.Contacts){
            Contact orgContact = contactsByName.get(c.FirstName + c.LastName);
            System.assertNotEquals(null, orgContact);
        }
    }

    @isTest static void testInvalidRelationship() {
        Account acc = createAccount();
        insert acc;

        try{
            SObjectDeepClone clone = new SObjectDeepClone(acc.Id, new Set<String>{'asdf'});
        }catch(SObjectDeepClone.DeepCloneException e){
            return;
        }
        system.assert(false, 'DeepCloneException should have been thrown');
    }

    //== OBJECT CREATORS... Might need to adjust to pass ORG validations
    private static Account createAccount(){
        return new Account(
            name = 'abc'
        );
    }

    private static Contact createContact(Id accId, String firstName, String lastName){
        return new Contact(
            AccountId = accId,
            FirstName = firstName,
            LastName = lastName
        );
    }

}