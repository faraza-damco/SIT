// multiApproval.js
import { LightningElement, track } from 'lwc';
import getSubmittedRecords   from '@salesforce/apex/MultiRecordsApprovalController_full.getSubmittedRecords';
import getBatchStatus        from '@salesforce/apex/MultiRecordsApprovalController_full.getBatchStatus';
import processRecordsBatch   from '@salesforce/apex/MultiRecordsApprovalController_full.processRecordsBatchExecute';
import { ShowToastEvent }    from 'lightning/platformShowToastEvent';

export default class MultiApproval extends LightningElement {

    get hasSurveillanceData() {
        return this.surveillanceData && this.surveillanceData.length > 0;
    }

    get hasProformaInvoiceData() {
        return this.invoiceData && this.invoiceData.length > 0;
    }

    get hasTaxInvoiceData() {
        return this.taxInvoiceData && this.taxInvoiceData.length > 0;
    }

    //for opportunities
    @track columnsForSurveillance = [
        {
            label: 'Surveillance Opportunity Name',
            fieldName: 'recordId',
            type: 'url',
            typeAttributes: { label: { fieldName: 'recordName' }, target: '_blank' }
        },
        {
            label: 'Close Date',
            fieldName: 'CloseDate',
            type: 'date-local',
            typeAttributes: { year: '2-digit', month: 'short', day: '2-digit' }
        },
        { label: 'Amount',           fieldName: 'Amount', type: 'currency' },
        { label: 'Approver Name',    fieldName: 'ApprName', type: 'text' },
        { label: 'Submitted by',     fieldName: 'SubmittedBy', type: 'text' },
        {
            label: 'Submitted on',
            fieldName: 'SubmittedDate',
            type: 'date',
            typeAttributes: { year: '2-digit', month: 'short', day: '2-digit' }
        },
        { label: 'Submitted Comments',     fieldName: 'submissionComment', type: 'text' }
    ];

    //for Invoices
    @track columnsForInvoices = [
        {
            label: 'Invoice Name',
            fieldName: 'recordId',
            type: 'url',
            typeAttributes: { label: { fieldName: 'recordName' }, target: '_blank' }
        },
        {
            label: 'Client Name',
            fieldName: 'clientName',
            type: 'text'
        },
        {
            label: 'Instrument Type 4',
            fieldName: 'instrumentType4',
            type: 'text'
        },
        {
            label: 'VoD',
            fieldName: 'vodInCrore',
            type: 'number'
        },
        {
            label: 'Amount to be Billed',
            fieldName: 'amountToBeBilled',
            type: 'number'
        },
        {
            label: 'Billing Start Date',
            fieldName: 'billingStartDate',
            type: 'date'
        },
        {
            label: 'Billing End Date',
            fieldName: 'billingEndDate',
            type: 'date'
        },
        {
            label: 'Invoice Status',
            fieldName: 'invoiceStatus',
            type: 'text'
        },
        
        { label: 'Approver Name',    fieldName: 'ApprName', type: 'text' },
        { label: 'Submitted by',     fieldName: 'SubmittedBy', type: 'text' },
        {
            label: 'Submitted on',
            fieldName: 'SubmittedDate',
            type: 'date',
            typeAttributes: { year: '2-digit', month: 'short', day: '2-digit' }
        },
        { label: 'Submitted Comments',     fieldName: 'submissionComment', type: 'text' },
        
        {
            label: 'Contact Name Verified',
            fieldName: 'contactNameVerified',
            type: 'text'
        }
    ];
    //for Invoices
    @track columnsForTaxInvoices = [
        {
            label: 'Invoice Name',
            fieldName: 'recordId',
            type: 'url',
            typeAttributes: { label: { fieldName: 'recordName' }, target: '_blank' }
        },
        {
            label: 'Client Name',
            fieldName: 'clientName',
            type: 'text'
        },
        {
            label: 'Instrument Type 4',
            fieldName: 'instrumentType4',
            type: 'text'
        },
        {
            label: 'VoD',
            fieldName: 'vodInCrore',
            type: 'number'
        },
        {
            label: 'Amount to be Billed',
            fieldName: 'amountToBeBilled',
            type: 'number'
        },
        {
            label: 'Billing Start Date',
            fieldName: 'billingStartDate',
            type: 'date'
        },
        {
            label: 'Billing End Date',
            fieldName: 'billingEndDate',
            type: 'date'
        },
        {
            label: 'Invoice Status',
            fieldName: 'invoiceStatus',
            type: 'text'
        },
        
        { label: 'Approver Name',    fieldName: 'ApprName', type: 'text' },
        { label: 'Submitted by',     fieldName: 'SubmittedBy', type: 'text' },
        {
            label: 'Submitted on',
            fieldName: 'SubmittedDate',
            type: 'date',
            typeAttributes: { year: '2-digit', month: 'short', day: '2-digit' }
        },
        { label: 'Submitted Comments',     fieldName: 'submissionComment', type: 'text' },

        {
            label: 'Contact Name Verified',
            fieldName: 'contactNameVerified',
            type: 'text'
        }
    ];

    @track surveillanceData                  = [];
    @track selectedRows          = [];
    @track invoiceData           = [];
    @track taxInvoiceData           = [];
    @track transactionLogData           = [];
    @track selectedInvoiceRow    = [];
    @track isLoading             = false;
    @track jobStatus             = false;
    @track opplist= [];
    @track invlist= [];
    @track taxInvList= [];
    @track transactionLogDataList= [];

    
    @track isRejectReasonModal   = false;
    @track rejectionReason       = '';

    connectedCallback() {
        this.loadData();
        this.checkJobStatus();
    }

    loadData() {
        this.isLoading = true;
        console.log('here in loadData');
        getSubmittedRecords()
            .then(result => {
                console.log('result sumittedrecords-->',JSON.stringify(result));
                this.opplist = (result.oppWrp || []);
                this.invlist = (result.invWrp || []);
                this.taxInvList = (result.taxInvWrp || []);
                this.transactionLogDataList = (result.failedRecordsWrp || []);
                console.log('here-->');
            if (
                this.invlist.length === 0 &&
                this.taxInvList.length === 0 &&
                this.opplist.length === 0 &&
                this.transactionLogDataList.length === 0
                ) {
                this.surveillanceData = [];
                this.invoiceData = [];
                this.taxInvoiceData = [];
                this.transactionLogData = [];
                } else {
                this.surveillanceData = this.opplist.map(r => ({ ...r, recordId: `/${r.recordId}` }));
                this.invoiceData = this.invlist.map(r => ({ ...r, recordId: `/${r.recordId}` }));
                this.taxInvoiceData = this.taxInvList.map(r => ({ ...r, recordId: `/${r.recordId}` }));
                this.transactionLogData =this.transactionLogDataList.map(r => ({ ...r, recordId: `/${r.recordId}` }));
            }
        })
            .catch(error => {
                console.log('error-->',error);
                this.showToast('Error', error.body?.message||error.message, 'error', 'sticky');
            })
            .finally(() => this.isLoading = false);
    }

    checkJobStatus() {
        getBatchStatus()
            .then(status => this.jobStatus = (status === 'Fail'))
            .catch(() => {}); // ignore
    }

    handleRowSelection(e) {
        this.selectedRows = e.detail.selectedRows;
        console.log('this.selectedRows--->188',this.selectedRows);
    }

    handleApprove() {
        this.process('Approve');
    }

    handleReject() {
        if (!this.selectedRows.length) return;
        this.isRejectReasonModal = true;
    }

    handleReasonChange(e) {
        this.rejectionReason = e.target.value;
    }

    get isSubmitDisabled() {
        return !this.rejectionReason.trim();
    }

    handleCancelReject() {
        this.isRejectReasonModal = false;
        this.rejectionReason = '';
    }

    handleConfirmReject() {
        this.isRejectReasonModal = false;
        this.process('Reject', this.rejectionReason);
        this.rejectionReason = '';
    }

    process(processType, reason) {
        if (!this.selectedRows.length) return;
        console.log('this.selectedRows--->220',JSON.stringify(this.selectedRows));
        const ids = this.selectedRows.map(r => r.WorkItemId || r.workItemId);
        const recordId = this.selectedRows.map(r => r.recordId || r.recordId);
        console.log('recordId--->>>>248',recordId)
        this.isLoading = true;
        processRecordsBatch({
            lstWorkItemIds: ids,
            processType,
            rejectionReason: reason,
            recordId: recordId.toString()
        })
        .then(msg => {
            const success = msg.toLowerCase().includes('success');
            this.showToast(success?'Success':'Error', msg, success?'success':'error');
            this.loadData();
            this.checkJobStatus();
        })
        .catch(error => {
            console.log('here in error')
            this.showToast('Error', error.body?.message||error.message, 'error', 'sticky');
        })
        .finally(() => {
            this.isLoading = false;
            setTimeout(() => {
                window.location.reload();
            }, 200);

        });
    }

    get isActionDisabled() {
        return !this.selectedRows.length;
    }

    handleRefresh() {
        window.location.reload();
    }

    showToast(title, message, variant, mode='dismissible') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
    }
}