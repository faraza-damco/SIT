import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getOpportunitiesForAccount from '@salesforce/apex/ICRA_MultiApproval_OptyController.getOpportunitiesForAccount';
import processApprovals from '@salesforce/apex/ICRA_MultiApproval_OptyController.processApprovals';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IcraMultiApprovalOptyController extends LightningElement {
    _accountId;

    @api
    get accountId() {
        return this._accountId;
    }

    set accountId(value) {
        this._accountId = value;
        if (value) {
            this.loadData();
        }
    }

    @track hideCheckboxColumn = true;
    @track opportunities = [];
    @track loading = false;

    selectedWorkItemIds = [];
    showCommentArea = false;
    currentAction = '';
    comments = '';

    columns = [
        { label: 'Account Name', fieldName: 'accountName', type: 'text' },
        { label: 'Name', fieldName: 'oppUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        { label: 'Record Type', fieldName: 'RecordTypeName' },
        { label: 'Instrument Type 4', fieldName: 'Instrument_Type_4' },
        { label: 'Billing Start Date', fieldName: 'BillingStartDate', type: 'date' },
        { label: 'Billing End Date', fieldName: 'BillingEndDate', type: 'date' },
        { label: 'Billing Status', fieldName: 'BillingStatus' }
    ];

    // Wire method to get URL parameters
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            const newAccountId = currentPageReference.state.accountId!=null ? currentPageReference.state.accountId : currentPageReference.state.c__accountId;
            if (newAccountId && newAccountId !== this._accountId) {
                this._accountId = newAccountId;
                this.loadData();
            }
        }
    }

    get noOpportunities() {
        return (!this.opportunities || this.opportunities.length === 0) && !this.loading;
    }

    async loadData() {
        this.loading = true;
        try {
            const data = await getOpportunitiesForAccount({ accountId: this.accountId });
            this.opportunities = data || [];
            this.selectedWorkItemIds = this.opportunities.map(item => item.workItemId);
        } catch (err) {
            this.showToast('Error', this._extractError(err), 'error');
            this.opportunities = [];
            this.selectedWorkItemIds = [];
        } finally {
            this.loading = false;
        }
    }
    /*
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows || [];
        this.selectedWorkItemIds = selectedRows.map(r => r.workItemId);
    }*/

    handleApproveClick() {
        this._startAction('Approve');
    }
    handleRejectClick() {
        this._startAction('Reject');
    }

    _startAction(action) {
        this.currentAction = action;
        if (!this.selectedWorkItemIds || this.selectedWorkItemIds.length === 0) {
            this.showToast('Error', `Please select at least one Opportunity to ${action.toLowerCase()}.`, 'error');
            return;
        }
        this.showCommentArea = true;
        this.comments = '';
    }

    handleCancelAction() {
        this.showCommentArea = false;
        this.currentAction = '';
        this.comments = '';
    }

    async handleConfirmAction() {
        if(!this.selectedWorkItemIds || this.selectedWorkItemIds.length === 0) {
            this.showToast('Error', 'No records selected.', 'error');
            return;
        }
        if(this.currentAction === 'Reject' && (!this.comments || this.comments.trim() === '')){
            this.showToast('Error', 'Please enter a comment to reject.', 'error');
            return;
        }
        try {
            await processApprovals({ workItemIds: this.selectedWorkItemIds, action: this.currentAction, comments: this.comments });
            this.showToast('Success', `${this.currentAction}d successfully.`, 'success');
            this.showCommentArea = false;
            this.currentAction = '';
            this.comments = '';
            this.opportunities=[];

        } catch (err) {
            this.showToast('Error', this._extractError(err), 'error');
        }
    }

    // Helper to extract error message
    _extractError(err) {
        try {
            if (err && err.body && err.body.message) return err.body.message;
            if (err && err.body && err.body.output && err.body.output.errors && err.body.output.errors.length)
                return err.body.output.errors.map(e => e.message).join('; ');
            if (typeof err === 'string') return err;
            return JSON.stringify(err);
        } catch (e) {
            return 'Unknown error';
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleCommentChange(event) {
        this.comments = event.target.value;
    }
}