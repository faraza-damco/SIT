/**
 * Name               : PricingApprovalMandatesBatch
 * @description       : Batch class to fetch all the pending approval opportunity and send an email to SECG and ICG commision head
 * @author            : Damco Group
 * @Created on        : 11-03-2022
**/
global class PricingApprovalMandatesBatch implements Database.Batchable<SObject>, Database.Stateful {
        global static final String NEWBUSINESS = 'New Business';
        global static final String ICGHEAD = 'ICG - Commercial Head';
        global static final String ICGSTR = 'ICG';
        global static final String SECGSTR = 'SECG';
   		global static final List<String> STAGES = new List<String>{'L1 Meeting','Negotiation','Closed Lost'};
        global static final List<String> COMMHEADS = new List<String>{'ICG - Commercial Head','SECG - Commercial Head'};
        global String query='SELECT Id,Account.Name,Name,BD_Team_Classification__c,Sector__c,Sub_Sector__c,Ownership_Type__c,Customer_Fee_Type__c,Branch__c,Mandate_Type__c,Business_Segment__c,Owner.Name,Instrument_type_1__c,Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Target_Fee_IRF__c,Annual_Surveillance_Fee_as_per_Framework__c,Proposed_Rating_Fee__c,Proposed_Surveillance_Fee__c,Deviation_IRF_Percent__c,Deviation_ASF_Percent__c,Proposed_Yield_IRF__c,Proposed_Yield_ASF__c FROM Opportunity WHERE Pricing_Not_Auto_Approved__c = false AND Pricing_Auto_Approved__c = true AND RecordType.Name = :NEWBUSINESS AND StageName NOT IN:STAGES AND Pricing_Approved_by_Commercial_Head__c = false AND CreatedDate = THIS_MONTH';
        global final String domain = URL.getSalesforceBaseUrl().toExternalForm() + '/';

        //FOR CSV
        global final String START = '"';
        global final String COLBR = '","';
        global final String FINISH = '"\n';
    
        global final String TABLEHEAD = 'Id , Account Name , Opportunity Name , BD Team Classification , Sector , Sub-Sector , Ownership Type , Customer Fee Type , Branch , Mandate Type , Business Segment , Opportunity Owner , Instrument type 1 , Instrument type 2 , Instrument type 3 , Instrument type 4 , Volume of Debt/Balance Sheet (In Crore) , Initial Rating Fee as per Framework , Annual Surveillance Fee as per Framework, Proposed Rating Fee, Proposed Surveillance Fee, Deviation IRF Percentage, Deviation ASF Percentage, Proposed Yield-IRF(BPS), Proposed Yield-ASF(BPS) \n';
        global String finalstr1,finalstr2;
        
    	Set<Id> optyIds = new Set<Id>();
    
    	public PricingApprovalMandatesBatch() {
            query = 'SELECT Id,Account.Name,Name,BD_Team_Classification__c,Sector__c,Sub_Sector__c,Ownership_Type__c,Customer_Fee_Type__c,Branch__c,Mandate_Type__c,Business_Segment__c,Owner.Name,Instrument_type_1__c,Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Target_Fee_IRF__c,Annual_Surveillance_Fee_as_per_Framework__c,Proposed_Rating_Fee__c,Proposed_Surveillance_Fee__c,Deviation_IRF_Percent__c,Deviation_ASF_Percent__c,Proposed_Yield_IRF__c,Proposed_Yield_ASF__c FROM Opportunity WHERE Pricing_Not_Auto_Approved__c = false AND Pricing_Auto_Approved__c = true AND RecordType.Name = :NEWBUSINESS AND StageName NOT IN:STAGES AND Pricing_Approved_by_Commercial_Head__c = false AND Createddate = THIS_MONTH';
    	}	
    
    	public PricingApprovalMandatesBatch(Set<Id> bscope) {
            this.optyIds.addAll(bscope);
            query = 'SELECT Id,Account.Name,Name,BD_Team_Classification__c,Sector__c,Sub_Sector__c,Ownership_Type__c,Customer_Fee_Type__c,Branch__c,Mandate_Type__c,Business_Segment__c,Owner.Name,Instrument_type_1__c,Instrument_type_2__c,Instrument_type_3__c,Instrument_type_4__c,VoD_in_crore__c,Target_Fee_IRF__c,Annual_Surveillance_Fee_as_per_Framework__c,Proposed_Rating_Fee__c,Proposed_Surveillance_Fee__c,Deviation_IRF_Percent__c,Deviation_ASF_Percent__c,Proposed_Yield_IRF__c,Proposed_Yield_ASF__c FROM Opportunity WHERE Id IN :optyIds';
    	}
    
        global Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator(query);
        }
       
        global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
            for(Opportunity opp : scope){
                //FOR CSV
                string navLink = '=HYPERLINK(""'+domain+opp.Id+ '"" , ""'+opp.Id+'"")';
                
                string recordString = START+navLink+COLBR+opp.Account.Name+COLBR+opp.Name+COLBR+opp.BD_Team_Classification__c+COLBR+opp.Sector__c+COLBR+opp.Sub_Sector__c+COLBR+opp.Ownership_Type__c+COLBR+opp.Customer_Fee_Type__c+COLBR+opp.Branch__c+COLBR+opp.Mandate_Type__c+COLBR+opp.Business_Segment__c+COLBR+opp.Owner.Name+COLBR+opp.Instrument_type_1__c+COLBR+opp.Instrument_type_2__c+COLBR+opp.Instrument_type_3__c+COLBR+opp.Instrument_type_4__c+COLBR+opp.VoD_in_crore__c+COLBR+opp.Target_Fee_IRF__c+COLBR+opp.Annual_Surveillance_Fee_as_per_Framework__c+COLBR+opp.Proposed_Rating_Fee__c+COLBR+opp.Proposed_Surveillance_Fee__c+COLBR+opp.Deviation_IRF_Percent__c+COLBR+opp.Deviation_ASF_Percent__c+COLBR+opp.Proposed_Yield_IRF__c+COLBR+opp.Proposed_Yield_ASF__c+FINISH;
                if(opp.BD_Team_Classification__c == SECGSTR){
                    finalstr1 = String.isBlank(finalstr1)?TABLEHEAD+recordString:finalstr1 +recordString;
                }else if(opp.BD_Team_Classification__c == ICGSTR){
                    finalstr2 = String.isBlank(finalstr2)?TABLEHEAD+recordString:finalstr2 +recordString;
                }
            }
        }
       
        global void finish(Database.BatchableContext BC) {
            if(String.isNotBlank(finalstr1)||String.isNotBlank(finalstr2)){
            /*String icgHeadAdd,secgHeadAdd;
            for(User comHead : [SELECT Email,UserRole.Name FROM User WHERE UserRole.Name In: COMMHEADS]){
                if((ICGHEAD).equalsIgnoreCase(comHead.UserRole.Name)){
                    icgHeadAdd = comHead.Email;
                }else{
                    secgHeadAdd = comHead.Email;
                }
            }*/
            OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info' Limit 1];
            Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
            String body = ',<br><br>Please find the attached report for approval of mandates for the month of '+System.Now().format('MMMMM')+' '+System.Today().Year()+', which got auto approved by the system.\nKindly approve using below link.<br>';
            String approveLinkPt1 = '<br><a href="'+domain+'lightning/n/Pricing_Approval?c__params=';
            String approveLinkPt2 = '/'+System.Today().month()+'/'+System.Today().year()+'">Link to Approve</a>';
            String signature = '<br><br>Thank You, <br>ICRA Team';
            String subject = 'Mandates for Pricing Approval';
            String fileName = 'Mandates for Pricing Approval.csv';
                if(String.isNotBlank(finalstr1)) {//SECG
                    Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
                        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                        efa1.setFileName(SECGSTR+' '+fileName);
                        efa1.setBody(Blob.valueOf(finalstr1));
                    email1.setSubject( SECGSTR+' '+subject );
                    email1.setOrgWideEmailAddressId(owea.Id);
                    Commercial_Head_Details__c secg = Commercial_Head_Details__c.getValues(SECGSTR);
                    email1.setToAddresses(new List<String>{secg.Email__c});
                    //email1.setToAddresses(new List<String>{'bindushree1@damcogroup.com'});
                    email1.setHtmlBody('Hi '+secg.Name__c+body+approveLinkPt1+SECGSTR+approveLinkPt2+signature);
                    email1.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa1});
                    emails.add(email1);
                }
                if(String.isNotBlank(finalstr2)){//ICG
                    Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();
                        Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
                        efa2.setFileName(ICGSTR+' '+fileName);
                        efa2.setBody(Blob.valueOf(finalstr2));
                    email2.setSubject( ICGSTR+' '+subject );
                    email2.setOrgWideEmailAddressId(owea.Id);
                    Commercial_Head_Details__c icg = Commercial_Head_Details__c.getValues(ICGSTR);
                    email2.setToAddresses(new List<String>{icg.Email__c});
                    //email2.setToAddresses(new List<String>{'bindushree1@damcogroup.com'});
                    email2.setHtmlBody('Hi '+icg.Name__c+body+approveLinkPt1+ICGSTR+approveLinkPt2+signature);
                    email2.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa2});
                    emails.add(email2);
                }
                System.debug('@@@'+emails.size());
                if(emails.size()>0){
                    Messaging.sendEmail(emails);
                }
            }
        }
    }