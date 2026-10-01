import { LightningElement, api, track } from 'lwc';
import getPendingApprovalOpportunities from '@salesforce/apex/ICRA_BulkRecallController.getPendingApprovalOpportunities';
import submitForRecall from '@salesforce/apex/ICRA_BulkRecallController.recallApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions'; 

export default class RecallPendingOppsUnderAccount extends LightningElement {
    //@api recordId; // Account Id
    @track opportunities = [];
    @track showCommentModal = false;
    @track comments = '';

    get showOpportunities(){
        return this.opportunities.length > 0;
    }

    get showNoRecords(){
        return this.opportunities.length === 0;
    }

    @api 
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadData(); // load only after recordId arrives
        }
    }
    get recordId() {
        return this._recordId;
    }

    columns = [
        { label: 'Name', fieldName: 'oppUrl', type: 'url', initialWidth: 250, typeAttributes: { label: { fieldName: 'opportunityName' }, target: '_blank' } },
        { label: 'Record Type', fieldName: 'RecordTypeName', wrapText: true },
        { label: 'Instrument Type 4', fieldName: 'Instrument_Type_4', wrapText: true },
        { label: 'Billing Start Date', fieldName: 'BillingStartDate', type: 'date', initialWidth: 120 },
        { label: 'Billing End Date', fieldName: 'BillingEndDate', type: 'date', initialWidth: 120 },
        { label: 'Billing Status', fieldName: 'BillingStatus', wrapText: true },
        { label: 'Pending With', fieldName: 'pendingWith', wrapText: true }
    ];

    async loadData() {
        try {
            const result = await getPendingApprovalOpportunities({ accountId: this._recordId });
            console.log('AccountId:', this._recordId);
            console.log('Opportunities Pending for Approval:', result);
            this.opportunities = result;
        } catch (error) {
            this.showToast('Error loading data', error.body.message, 'error');
        }
    }

    handleRecall(){
        if (!this.opportunities.length){
            this.showToast('No Records', 'There are no approval pending Opportunities.', 'warning');
            return;
        }
        this.showCommentModal = true;
    }

    handleCommentChange(event){
        this.comments = event.target.value;
    }

    closeModal(){
        this.showCommentModal = false;
    }

    async confirmSubmit(){
        if (!this.comments || this.comments.trim() === '') {
            this.showToast('Missing Comment', 'Recall Comments are Mandatory.', 'error');
            return;
        }

        try{
            await submitForRecall({ accountId: this.recordId, comments: this.comments });
            this.showToast('Success', 'Opportunities submitted for recall.', 'success');
            this.showCommentModal = false;
            this.loadData();
            this.dispatchEvent(new CloseActionScreenEvent());
        }catch (error){
            this.showToast('Error', error.body.message, 'error');
        }
    }

    showToast(title, message, variant){
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}