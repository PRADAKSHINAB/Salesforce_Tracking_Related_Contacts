import { LightningElement, api, wire } from 'lwc';
import getRelatedContacts from '@salesforce/apex/RelatedContactsController.getRelatedContacts';

export default class RelatedRelationshipContactsList extends LightningElement {
    @api recordId; 
    relatedContacts = [];
    error;

    @wire(getRelatedContacts, { contactId: '$recordId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.relatedContacts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error?.body?.message || error.statusText || JSON.stringify(error);
            this.relatedContacts = [];
        }
    }

    get hasContacts() {
        return this.relatedContacts && this.relatedContacts.length > 0;
    }
}
