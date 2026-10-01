import { LightningElement, api, track } from 'lwc';
import getOpportunitiesForApproval from '@salesforce/apex/ICRA_OpportunityApprovalController.getOpportunitiesForApproval';
import submitForApproval from '@salesforce/apex/ICRA_OpportunityApprovalController.submitForApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions'; 

export default class OpportunityApprovals extends LightningElement {
    //@api recordId; // Account Id
    @track opportunities = [];
    @track inactiveApprovers = [];
    @track noRecords = false;
    @track noInactiveUsers = true;
    @track showCommentModal = false;
    @track comments = '';
    //@track showModal = false;

    get showOpportunities(){
        return this.opportunities.length > 0 && this.inactiveApprovers.length === 0;
    }

    get showInactiveUsers(){
        return this.inactiveApprovers.length > 0;
    }

    get showNoRecords(){
        return this.opportunities.length === 0 && this.inactiveApprovers.length === 0;
    }

    get inactiveUsersMessage(){
    const names = [...new Set(this.inactiveApprovers.map(a => a.ApproverName).filter(name => name))];

    return names.length
        ? `The following approver(s) are either missing or inactive: ${names.join(', ')}.\n Kindly update the approval hierarchy and retry the submission.`
        : '';
    }

    @api 
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadData(); // load only after recordId arrives
            //this.showModal = true;
        }
    }
    get recordId() {
        return this._recordId;
    }

    columns = [
        { label: 'Name', fieldName: 'oppUrl', type: 'url', initialWidth: 250, typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        { label: 'Record Type', fieldName: 'RecordTypeName', wrapText: true },
        { label: 'Instrument Type 4', fieldName: 'Instrument_Type_4', wrapText: true },
        { label: 'Billing Start Date', fieldName: 'BillingStartDate', type: 'date', initialWidth: 120  },
        { label: 'Billing End Date', fieldName: 'BillingEndDate', type: 'date', initialWidth: 120  },
        { label: 'Billing Status', fieldName: 'BillingStatus', wrapText: true }
    ];

    async loadData() {
        try {
            const result = await getOpportunitiesForApproval({ accountId: this._recordId });
            console.log('AccountId:', this._recordId);
            console.log('Opportunities for Approval:', result.opportunities);
            console.log('Inactive Users for Approval:', result.inactiveApprovers);
            this.opportunities = result.opportunities;
            this.inactiveApprovers = result.inactiveApprovers;
            this.noRecords = result.opportunities.length === 0;
            this.noInactiveUsers = result.inactiveApprovers.length === 0;
        } catch (error) {
            this.showToast('Error loading data', error.body.message, 'error');
        }
    }

    handleSend() {
        if (!this.opportunities.length) {
            this.showToast('No Records', 'There are no pending Opportunities for approval.', 'warning');
            return;
        }
        this.showCommentModal = true;
    }

    handleCommentChange(event) {
        this.comments = event.target.value;
    }

    closeModal() {
        this.showCommentModal = false;
    }

    async confirmSubmit() {
        if (!this.comments || this.comments.trim() === '') {
            this.showToast('Missing Comment', 'Please enter a comment before submitting.', 'error');
            return;
        }

        try {
            await submitForApproval({ accountId: this.recordId, comments: this.comments });
            this.showToast('Success', 'Opportunities submitted for approval.', 'success');
            this.showCommentModal = false;
            this.loadData();
            //this.showModal= false;
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}