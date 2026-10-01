import { LightningElement, api, wire } from 'lwc';
import getOppFields from '@salesforce/apex/SendtoVolodyCompController.getOppFields';
import getAgreementType from '@salesforce/apex/SendtoVolodyCompController.getAgreementType'
import createCrmContract from '@salesforce/apex/SendtoVolodyCompController.createCrmContract';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { refreshApex } from '@salesforce/apex';

export default class SendToVolodyComp extends LightningElement {

    isShowError = false
    NotInputedFields = ''
    isShowSpinner=false
    isDisButton=true
    selectedAgreement

    @api
    set recordId(value){
        this._recordId = value;

        if (value){
            this.loadFields();
        }
    }

    get recordId(){
        return this._recordId;
    }

    async loadFields(){
        try{
            const result = await getOppFields({ recordId: this.recordId });

            if(result !== 'All Fields Inputed'){
                this.isShowError = true;
                this.NotInputedFields = result;
            }else{
                this.isShowError = false;
                this.NotInputedFields = '';
            }
        }catch(error){
            console.error(error);
        }
    }
/*
    @wire(getOppFields, { recordId: '$recordId'})
    opps({ data, error }) {
        if (data) {
            console.log('data', data)
            this.wiredData = data; // Store the wired data for later use
            if (data != 'All Fields Inputed') {
                this.isShowError = true;
                this.NotInputedFields = data;
            }else {
                this.isShowError = false;
                this.NotInputedFields = '';
            }
        }
        else if (error) {
            console.log('error', error)
        }
    }*/
    
    myMap
        @wire(getAgreementType)
        getType({data,error}){
            if(data){
                console.log('data getAgreementType - ',data);
                this.myMap=data.map(ele=> ({
                    value:ele,
                    label:ele
                }));
            }
            else if(error){
                console.log('error getAgreementType - ',error);
            }
        }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    initiateContract() {
        this.isShowSpinner=true;
        console.log('InitiateContract')
        createCrmContract({'optyId':this.recordId, 'agreement':this.selectedAgreement})
            .then(data => { 
                 this.isShowSpinner=false;
                        console.log('dat--?',data);

                if (data == 'Success') {
                
                    this.showtoast('Success', 'Contract Creation Initiated', 'success');
                    setTimeout(()=>{
                    this.closeModal();
                    },1000)
                }
                else {
                    const errors=data
                    console.log('errors',errors);
                    this.showtoast('Error', errors, 'error');
                }
            })
            .catch(error => {
                 this.isShowSpinner=false;

            })
    }

    //Tast Notification
    showtoast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }))
    }

    handleAgreement(event){
        this.selectedAgreement=event.detail.value;
        this.isDisButton=false;
    }
}