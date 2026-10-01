import { LightningElement, api, track } from 'lwc';
import reviewPDF from '@salesforce/apex/ICRA_SendToClient.reviewPDF';
import sendPdfToClient from '@salesforce/apex/ICRA_SendToClient.sendPDF';
import displayInfo from '@salesforce/apex/ICRA_SendToClient.displayInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IcraSendToClient extends LightningElement {
    @api recordId;
    @track showModal = false;
    isReviewing = false;
    isSending = false;
    @track message = '';
    hasLoadedInfo = false;

    get formattedText() {
    return `<div style="font-size: 12px; font-weight: bold; text-align:left; color: #3B3B3B;border: 1px solid #e0e0e0;display: justify;flex-direction: column;
    justify-content: center; align-items: center;padding: 8px 12px; background-color: #f9f9f9;border-radius: 4px;box-shadow: 0 1px 3px rgba(0,0,0,0.1);max-height: 500px;overflow-y: auto;">
                ${this.message}
            </div>`;
}

    renderedCallback(){
        if(!this.hasLoadedInfo && this.recordId){
            this.hasLoadedInfo = true;
            this.displayInformation();
        }
    }

    @api invoke(){
        console.log('ICRA_SendToClient invoked with recordId:', this.recordId);
        this.showModal = true;
    }

    handleReview(){
        this.isReviewing = true;
        reviewPDF({recordId: this.recordId})
            .then(url => {
                const pdfUrl = `${url}`;
                window.open(pdfUrl, '_blank');
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Could not load PDF.', 'error');
            });
    }

    handleSend(){
        this.isSending = true;
        sendPdfToClient({recordId: this.recordId})
            .then(() => {
                this.showToast('Success', 'PDF sent to client.', 'success');
                this.close();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                this.isSending = false;
            });
    }

    displayInformation(){
        displayInfo({recordId: this.recordId})
            .then((result) => {
                console.log('Display Info Result:', result);
                this.message = result.replace(/\n/g, '<br/>');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    close(){
        this.dispatchEvent(new CustomEvent('close'));
        this.showModal = false;
    }

    closeModal() {
        this.showModal = false;
    }

    showToast(title, message, variant){
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}