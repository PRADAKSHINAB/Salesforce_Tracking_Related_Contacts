trigger ContactRelationshipTrigger on Contact (after insert, after update) {
    Set<Id> accountIds = new Set<Id>();
    for(Contact c : Trigger.new) {
        if(c.AccountId != null && c.Relationship_Type__c != null) {
            accountIds.add(c.AccountId);
        }
    }
    if(accountIds.isEmpty()) return;
    List<Contact> contactsToUpdate = new List<Contact>();
    List<Contact> contacts = [SELECT Id, AccountId, Relationship_Type__c, Is_Related__c FROM Contact WHERE AccountId IN :accountIds AND IsDeleted = false];

    Map<Id, Map<String, List<Contact>>> groupedContacts = new Map<Id, Map<String, List<Contact>>>();

    for(Contact c : contacts){
        if(!groupedContacts.containsKey(c.AccountId)){
            groupedContacts.put(c.AccountId, new Map<String, List<Contact>>());
        }
        Map<String, List<Contact>> relMap = groupedContacts.get(c.AccountId);

        if(!relMap.containsKey(c.Relationship_Type__c)){
            relMap.put(c.Relationship_Type__c, new List<Contact>());
        }
        relMap.get(c.Relationship_Type__c).add(c);
    }

    for(Id accId : groupedContacts.keySet()){
        Map<String, List<Contact>> relMap = groupedContacts.get(accId);
        for(String relType : relMap.keySet()){
            List<Contact> relContacts = relMap.get(relType);
            Boolean isRelated = relContacts.size() > 1;

            for(Contact c : relContacts){
                if(c.Is_Related__c != isRelated){
                    c.Is_Related__c = isRelated;
                    contactsToUpdate.add(c);
                }
            }
        }
    }

    if(!contactsToUpdate.isEmpty()){
        update contactsToUpdate;
    }
}
