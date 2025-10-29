public class ContactRelationshipHandler {
    public static void updateRelatedContacts(List<Contact> contacts) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Set<String>> accountToRelTypes = new Map<Id, Set<String>>();

        for (Contact c : contacts) {
            if (c.AccountId != null && c.Relationship_Type__c != null) {
                accountIds.add(c.AccountId);
                if (!accountToRelTypes.containsKey(c.AccountId)) {
                    accountToRelTypes.put(c.AccountId, new Set<String>());
                }
                accountToRelTypes.get(c.AccountId).add(c.Relationship_Type__c);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }
        List<Contact> contactsToUpdate = new List<Contact>();

        List<Contact> relatedContacts = [
            SELECT Id, AccountId, Relationship_Type__c, Is_Related__c
            FROM Contact
            WHERE AccountId IN :accountIds
            AND Relationship_Type__c != null
            AND IsDeleted = false
        ];

        Map<Id, Map<String, List<Contact>>> accountRelTypeToContacts = new Map<Id, Map<String, List<Contact>>>();

        for (Contact c : relatedContacts) {
            if (!accountRelTypeToContacts.containsKey(c.AccountId)) {
                accountRelTypeToContacts.put(c.AccountId, new Map<String, List<Contact>>());
            }
            Map<String, List<Contact>> relTypeMap = accountRelTypeToContacts.get(c.AccountId);
            if (!relTypeMap.containsKey(c.Relationship_Type__c)) {
                relTypeMap.put(c.Relationship_Type__c, new List<Contact>());
            }
            relTypeMap.get(c.Relationship_Type__c).add(c);
        }
        for (Id accountId : accountToRelTypes.keySet()) {
            Map<String, List<Contact>> relTypeMap = accountRelTypeToContacts.get(accountId);
            if (relTypeMap == null) continue;

            for (String relType : accountToRelTypes.get(accountId)) {
                List<Contact> matchingContacts = relTypeMap.get(relType);
                if (matchingContacts != null && matchingContacts.size() > 1) {
                    for (Contact c : matchingContacts) {
                        if (c.Is_Related__c != true) {
                            c.Is_Related__c = true;
                            contactsToUpdate.add(c);
                        }
                    }
                } else if (matchingContacts != null && matchingContacts.size() == 1) {
                    Contact singleContact = matchingContacts[0];
                    if (singleContact.Is_Related__c != false) {
                        singleContact.Is_Related__c = false;
                        contactsToUpdate.add(singleContact);
                    }
                }
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}
