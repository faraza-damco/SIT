import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import oppData from '@salesforce/apex/ecgOpportunityValidationController.oppData'
const FIELDS = [ 'Opportunity.StageName'];
const ACCFIELDS = ['Account.classification__c'];
import { refreshApex } from '@salesforce/apex';
export default class EcgOpportunityValidaion extends LightningElement {

    isShowModal = false;
    @api recordId
    opps = {};

    // handleSearch() {
    //     oppData({ recordId: this.recordId })
    //         .then(result => {
    //             this.opps = result;
    //             this.error = undefined;
    //             console.log('this.opps', this.opps)
    //             console.log('this.opps.StageName==L1 Meeting', this.opps.StageName == 'L1 Meeting');
    //             console.log('ecg', this.opps.Account.classification__c != 'ECG');
    //             console.log('inst2', this.opps.Instrument_type_2__c == 'Rating - Bank Loan Rating');
    //             console.log('vod', (this.opps.VoD_in_crore__c >= 0 && this.opps.VoD_in_crore__c <= 100))

    //             if (this.opps.StageName == 'L1 Meeting' && this.opps.Account.Classification__c != 'ECG' && ((this.opps.Instrument_type_4__c == 'Issuer Rating') ||
    //                 (this.opps.Instrument_type_2__c == 'Rating - Bank Loan Rating' &&
    //                     (this.opps.VoD_in_crore__c >= 0 && this.opps.VoD_in_crore__c <= 100)))) {
    //                 console.log(' this.isShowModal', this.isShowModal)
    //                 this.isShowModal = true;
    //             }
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             this.accounts = undefined;
    //         })
    // }
    @wire(getRecord, { recordId: '$recordId', fields: ACCFIELDS })
    stageWatcher({ data }) {
        if (data) {
            refreshApex(this.wiredOppResult);
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    stageWatcher({ data }) {
        if (data) {
            refreshApex(this.wiredOppResult);
        }
    }

    @wire(oppData, { recordId: '$recordId' })
    wiredRecord(result) {
        this.wiredOppResult = result;
        const { data, error } = result;
        if (data) {
            this.opps = data;
            this.error = undefined;
            if (this.opps.StageName == 'L1 Meeting' && this.opps.Account.Classification__c != 'ECG' && ((this.opps.Instrument_type_4__c == 'Issuer Rating') ||
                (this.opps.Instrument_type_2__c == 'Rating - Bank Loan Rating' &&
                    (this.opps.VoD_in_crore__c >= 0 && this.opps.VoD_in_crore__c <= 100)))) {
                console.log(' this.isShowModal', this.isShowModal)
                this.isShowModal = true;

            }
            refreshApex(this.wiredOppResult)
        }
        if (error) {
            this.error = error;
        }
    }

    // @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    // wiredRecord({ error, data }) {
    // console.log('ECg')
    //     console.log('ECgrec',this.recordId)

    //     if (data) {
    //         console.log('ECG',data);
    //         this.data = data;
    //          console.log('fields',this.data.fields.Instrument_type_2__c.value);
    //          console.log('stage',this.data.fields.StageName.value);
    //          console.log('vod',this.data.fields.VoD_in_crore__c.value<=0 && this.data.fields.VoD_in_crore__c.value>=100);
    //          console.log('vod g ',this.data.fields.VoD_in_crore__c.value >= 0 );
    //          console.log('vod s', this.data.fields.VoD_in_crore__c.value <= 100);


    //         if((this.data.fields.Instrument_type_2__c.value=='Rating - Bank Loan Rating' ||
    //         this.data.fields.Instrument_type_4__c.value=='Issuer Rating')
    //         && (this.data.fields.VoD_in_crore__c<=0 || this.data.fields.VoD_in_crore__c >=100) &&
    //         this.data.fields.StageName=='L1 Meeting'){
    //             console.log('trueeeeeeeee')
    //             this.isShowModal=true
    //         }
    //         if(this.data.fields.StageName.value=='L1 Meeting'&& this.data.fields.BD_Team_Classification__c.value!='ECG'&& ((this.data.fields.Instrument_type_4__c.value=='Issuer Rating')||
    //         (this.data.fields.Instrument_type_2__c.value=='Rating - Bank Loan Rating' && 
    //         (this.data.fields.VoD_in_crore__c.value >= 0 && this.data.fields.VoD_in_crore__c.value <= 100)))){
    //             // this.isShowModal=true

    //         }
    //     } else if (error) {
    //         console.log('ECG error',error);
    //         this.error = error;
    //     }
    // }

    hideModalBox() {
        this.isShowModal = false;
    }
}