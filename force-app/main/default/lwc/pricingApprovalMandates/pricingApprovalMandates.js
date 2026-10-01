import { LightningElement,track,wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import approvMandates from "@salesforce/apex/PricingApprovalMandatesController.approvMandates";

export default class PricingApprovalMandates extends LightningElement {
    displayValue = 'Please click on Approve to proceed.';
    showButton = false;
    showSpinner = false;
    params;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlValue = currentPageReference.state.c__params;
            if (urlValue) {
                this.params = urlValue;
                this.showButton = true; 
            } else {
              this.displayValue = 'Please click on the approve link from email to proceed';
            }
        }
    }
    handleClick(event) {
        if (this.params) {
            this.showButton = false; 
            this.showSpinner = true;
            approvMandates({ params: this.params })
              .then(result => {
                  if(result){
                    this.displayValue = 'Successfully approved opportunities. You can close the window now!';
                  }else{
                    this.displayValue = 'Pricing is already approved. You can close the window now!';
                  }
                this.showSpinner = false;
              })
              .catch(error => {
                this.showSpinner = false;
                this.displayValue = 'Error during processing. Please reach out to your administrator.';
              });
          }
    }
}