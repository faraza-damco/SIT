import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class GetRelatedListInfoDemo extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Mandate_ID__c', 'Account.Primary_Account__c'] })
    account;
}