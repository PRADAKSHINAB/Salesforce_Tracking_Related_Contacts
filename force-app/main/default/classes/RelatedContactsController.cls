public with sharing class RelatedContactsController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id contactId) {
        
        Contact mainContact = [
            SELECT Id, AccountId, Relationship_Type__c 
            FROM Contact 
            WHERE Id = :contactId 
            LIMIT 1
        ];

        
        if (mainContact.AccountId == null || mainContact.Relationship_Type__c == null) {
            return new List<Contact>();
        }

        return [
            SELECT Id, Name, Email 
            FROM Contact 
            WHERE AccountId = :mainContact.AccountId 
              AND Relationship_Type__c = :mainContact.Relationship_Type__c
              AND Id != :mainContact.Id
        ];
    }
}
