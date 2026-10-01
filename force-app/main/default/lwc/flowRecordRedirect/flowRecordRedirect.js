import { LightningElement, api } from 'lwc';

export default class FlowRecordRedirect extends LightningElement {
    @api recordId;

    connectedCallback() {
        if(this.recordId) {
            window.history.replaceState({}, '', '/'+this.recordId);
            window.location.assign('/' + this.recordId);
        }
    }
}