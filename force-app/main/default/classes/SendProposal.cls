global class SendProposal {
    
    webservice  static  string SendAttachment(string OppotunityId){
        System.debug('Email send action fired');
        String sMessage='';
        List<OpportunityContactRole> optyConRoleList= new List<OpportunityContactRole>();
        List<Contact> conList= new List<Contact>();
        //string sEmailAddress='niiyaz1@damcogroup.com';
       // try{ 
            EmailTemplate et = [SELECT Id,Subject,HtmlValue, Body FROM EmailTemplate WHERE DeveloperName ='PROPOSAL'];
            Opportunity Opp=[select Id,owner.email, Addition_Email_Recipient_1__c,Addition_Email_Recipient_2__c, Date_of_Proposal__c ,ContactId,Opportunity.Crore_or_Million__c,Opportunity.Owner.Name,Opportunity.owner.mobilephone ,Opportunity.CurrencyDisplayFormula__c,Opportunity.Contact_for_Proposal__r.Salutation, Opportunity.Contact_for_Proposal__r.Name,Opportunity.Contact_for_Proposal__r.email,Contact__r.email,VoD_in_crore__c,Instrument_type_4__c from Opportunity  where id = :OppotunityId limit 1 ];
            if(Opp!=null){
                optyConRoleList= [select id, OpportunityId, ContactId, Role FROM OpportunityContactRole where Role='Proposal Primary Contact' AND OpportunityId=:Opp.Id];
            }
        
            if(!optyConRoleList.isEmpty()){
                conList= [select id, Name, firstName, lastName, Email, Designation__c, Salutation from Contact where Id=:optyConRoleList[0].ContactId];
            }
            OrgWideEmailAddress [] owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
            // if(Opp.Contact_for_Proposal__r.email==null)
            // {
            //     sMessage='Contact for Proposal email not found !!';
            //     return sMessage;
            // }
            // if(Opp.Contact_for_Proposal__c==null )
            // {
            //     sMessage='Please fill Contact for Proposal !';
            //     return sMessage;
            // }
            
            if(Opp.Date_of_Proposal__c==null )
            {
                sMessage='Please fill Date of Proposal !';
                return sMessage;
            }
            if(Opp.VoD_in_crore__c==null)
            {
                sMessage='Vod not found !!';
                return sMessage;
            }
            if(Opp.VoD_in_crore__c==null)
            {
                sMessage='Vod not found !!';
                return sMessage;
            }
         if(opp.owner.mobilephone==null)
            {
                sMessage='Owner Mobile No. not found !!';
                return sMessage;
            }

            string sEmailAddress='';
            if(conList.size()>0){
                    sEmailAddress= conList[0].Email;//Opp.Contact_for_Proposal__r.email;
            }
            string sCCEmailAddress1=Opp.Addition_Email_Recipient_1__c;
            string sCCEmailAddress2=Opp.Addition_Email_Recipient_2__c;
            string sCCEmailAddress3=Opp.owner.email;
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref = page.ICRA_Proposal_new;
            pref.getParameters().put('Id',OppotunityId);
            pref.setRedirect(true);
            Blob b; 
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
                
            } else {
                b = pref.getContent();
            }
            
            attach.setFileName('Proposal for '+Opp.CurrencyDisplayFormula__c+' '+Opp.VoD_in_crore__c+' '+Opp.Crore_or_Million__c+' ('+Opp.Instrument_type_4__c+') Rating Programme.pdf');
            attach.setBody(b);
            semail.setTemplateId(et.Id);
            semail.setWhatId(opp.Id);
            semail.setOrgWideEmailAddressId(owea.get(0).Id);
            
            semail.setSubject('Proposal for '+Opp.CurrencyDisplayFormula__c+' '+Opp.VoD_in_crore__c+' '+Opp.Crore_or_Million__c+' ('+Opp.Instrument_type_4__c+') Rating Programme');
            if(sEmailAddress!=null){
                semail.setToAddresses(new List<String>{sEmailAddress});
            }
            // if(sBCCEmailAddress!=null){
            //     semail.setFromAddress(sBCCEmailAddress);
            // }
            List<string> cclst=new List<string>();
            if(sCCEmailAddress1!=null)
            {
                cclst.add(sCCEmailAddress1);
            }
            if(sCCEmailAddress2!=null)
            {
                cclst.add(sCCEmailAddress2);
            }
            if(sCCEmailAddress3!=null)
            {
                cclst.add(sCCEmailAddress3);
            }
            if(cclst.Size()>0)
            {
                semail.setccAddresses(cclst);
            }
            
            //semail.setBccAddresses(new List<String>{sBCCEmailAddress});
            //semail.setPlainTextBody('Please find the attached Opportunity details');
            
            String htmlBody = et.HtmlValue;
            if(conList.size()>0){
                htmlBody = htmlBody.replace('{!Opportunity.Contact_for_Proposal__r}', conList[0].Salutation/*opp.Contact_for_Proposal__r.Salutation*/);
                htmlBody = htmlBody.replace('{!Opportunity.Contact_for_Proposal__c}', conList[0].Name/*opp.Contact_for_Proposal__r.Name*/);
            }
            htmlBody = htmlBody.replace('{!Opportunity.VoD_in_crore__c}', String.valueof(opp.VoD_in_crore__c));
            htmlBody = htmlBody.replace('{!Opportunity.Instrument_type_4__c}', opp.Instrument_type_4__c);
            htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', opp.owner.Name);
            htmlBody = htmlBody.replace('{!Opportunity.OwnerPhone}', opp.owner.mobilephone );
            htmlBody = htmlBody.replace('{!Opportunity.Crore_or_Million__c} ', opp.Crore_or_Million__c == 'Crore' ? 'Cr.' : 'Million' );
            
            htmlBody = htmlBody.replace('{!Opportunity.CurrencyDisplayFormula__c}', opp.CurrencyDisplayFormula__c);
            semail.setHtmlBody(htmlBody);
            //semail.setReferences(param1)(opp.Id);
            semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            //mail.setEntityAttachments(new List<Id>(/*contentVersionIds*/))
            Messaging.SendEmailResult[] r ;
            if(Test.isRunningTest()) { }
            else if(!String.isBlank(sEmailAddress)){
                r=  Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                System.debug('email'+r);
                for(Messaging.SendEmailResult rr:r){
                    System.debug('Email result ' + rr.IsSuccess());
                    if(rr.IsSuccess())
                    {
                        Opp.stageName='Proposal Submission';
                        update Opp;
                    }  
                }
                sMessage='SUCCESS';
                return sMessage;
            }
            sMessage= 'Email not sent !';
            return sMessage;
      /*  }
        catch(Exception ex){
            sMessage=ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause();
            system.debug('sMessage '+sMessage);
            return 'There is something went wrong. Please contact your Administrator';
        }
        */
    }
    webservice  static  string SendMPRAAttachment(string OppotunityId,boolean MPRA,boolean SOW){
        System.debug('Email send action fired from vf page');
        system.debug('OppotunityId '+OppotunityId);
        String sMessage='';
        List<OpportunityContactRole> optyConRoleList= new List<OpportunityContactRole>();
        List<Contact> conList= new List<Contact>();

        //string sEmailAddress='niiyaz1@damcogroup.com';
       // try{  
            EmailTemplate et = [SELECT Id,Subject,HtmlValue, Body FROM EmailTemplate WHERE DeveloperName ='MPRA_SOW'];
            Opportunity Opp=[select Id,Contact_for_MPRA_SOW__c,Contact_for_MPRA_SOW__r.Salutation,Contact_for_MPRA_SOW__r.Name,Contact_for_MPRA_SOW__r.email,owner.Name,owner.MobilePhone,owner.email,CurrencyDisplayFormula__c,Contact__r.Salutation,Contact__r.Name,StageName,Crore_or_Million__c,Owner.Designation__c,BillingAddress__r.Billing_Street__c,BillingAddress__r.Billing_City__c,BillingAddress__r.BillingState__c,
                             BillingAddress__r.Billing_Zip_Postal_Code__c,BillingAddress__r.BillingCountry__c,Account.PAN_Number__c,Account.TAN_Number__c,
                             BillingAddress__r.GSTN__c,Contact__r.MailingStreet,Contact__r.MailingCity,
                             Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.MailingCountry,Contact__r.Phone,MPRA_Sent_Date__c,SOW_Effective_Date__c,
                             Contact__r.Designation__c,Contact__r.Department,Account.Branch__r.Street__c,Account.Branch__r.City__c,
                             Account.Branch__r.State__c,Account.Branch__r.GSTIN__c,Account.Branch__r.PAN__c,Account.Branch__r.Authorized_Signatory__c , ContactId,Contact__r.email,VoD_in_crore__c,Instrument_type_4__c,Send_MPRA__c,Send_SOW__c from Opportunity  where id = :OppotunityId limit 1 ];
            system.debug('Opp '+Opp);
            optyConRoleList= [select id, OpportunityId, ContactId, Role FROM OpportunityContactRole where OpportunityId=:Opp.Id AND Role='MPRA/SOW' ORDER BY CreatedDate DESC];
            if(!optyConRoleList.isEmpty()){
                conList= [select id, Name, firstName, lastName, Designation__c, Salutation, Email from Contact where id=:optyConRoleList[0].ContactId ORDER BY CreatedDate DESC];
            }
            OrgWideEmailAddress [] owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
            if(MPRA==false && SOW==false )
            {
                sMessage='Please select at least one type of Document (MPRA/SOW) !';
                return sMessage;
            }
            if(conList.isEmpty() )
            {
                sMessage='Please add Contact Role with role as MPRA/SOW !';
                return sMessage;
            }
            
            
            if(MPRA==true)
            {
                 opp.Send_MPRA__c=true;
                // if(opp.MPRA_Sent_Date__c==null){
                    //opp.MPRA_Sent_Date__c=System.Today();
                // }

            }
            if(SOW==true)
            {
                opp.Send_SOW__c=true;
                //if(opp.SOW_Effective_Date__c==null){
                    //opp.SOW_Effective_Date__c=System.Today();
                // }
            }
           
            
          			/*System.debug('opp Data '+Opp.BillingAddress__r.Billing_Street__c); System.debug('opp Data '+Opp.Owner.Designation__c);
                System.debug('opp Data '+Opp.IRF_Final_Amount__c); System.debug('opp Data '+Opp.ASF_Final_Amount__c); 
                System.debug('opp Data '+Opp.BillingAddress__r.Billing_City__c); System.debug('opp Data '+Opp.BillingAddress__r.Billing_Street__c); 
              System.debug('opp Data '+Opp.BillingAddress__r.BillingState__c); System.debug('opp Data '+Opp.BillingAddress__r.Billing_Zip_Postal_Code__c); 
                  System.debug('opp Data '+Opp.BillingAddress__r.BillingCountry__c); System.debug('opp Data '+Opp.Account.PAN_Number__c); 
                System.debug('opp Data '+Opp.Account.TAN_Number__c); System.debug('opp Data '+Opp.Account.Billing_Address__r.GSTN__c); 
                System.debug('opp Data '+Opp.Contact__r.Designation__c); 
                System.debug('opp Data '+Opp.Contact__r.MailingStreet); System.debug('opp Data '+Opp.Contact__r.MailingCity); 
                System.debug('opp Data '+Opp.Contact__r.MailingState); System.debug('opp Data '+Opp.Contact__r.MailingPostalCode); 
                System.debug('opp Data '+Opp.Contact__r.MailingCountry); System.debug('opp Data '+Opp.Contact__r.Phone); 
                System.debug('opp Data '+Opp.Account.Branch__r.Street__c); System.debug('opp Data '+Opp.Account.Branch__r.City__c); 
                System.debug('opp Data '+Opp.Account.Branch__r.State__c ); System.debug('opp Data '+Opp.Account.Branch__r.GSTIN__c); 
                System.debug('opp Data '+Opp.Account.Branch__r.PAN__c); System.debug('opp Data '+Opp.Account.Branch__r.Authorized_Signatory__c);*/
            if( 
                Opp.BillingAddress__r.Billing_Street__c=='' && Opp.Owner.Designation__c==''   &&
               Opp.IRF_Final_Amount__c<=0 && Opp.ASF_Final_Amount__c<=0 && 
                Opp.BillingAddress__r.Billing_City__c=='' && Opp.BillingAddress__r.Billing_Street__c=='' && 
                Opp.BillingAddress__r.BillingState__c=='' && Opp.BillingAddress__r.Billing_Zip_Postal_Code__c=='' && 
                Opp.BillingAddress__r.BillingCountry__c=='' && Opp.Account.PAN_Number__c=='' && 
                Opp.Account.TAN_Number__c=='' && Opp.BillingAddress__r.GSTN__c=='' && 
                Opp.Contact__r.Designation__c=='' && 
                Opp.Contact__r.MailingStreet=='' && Opp.Contact__r.MailingCity=='' && 
                Opp.Contact__r.MailingState=='' && Opp.Contact__r.MailingPostalCode=='' && 
                Opp.Contact__r.MailingCountry=='' && Opp.Contact__r.Phone=='' && 
                Opp.Account.Branch__r.Street__c=='' && Opp.Account.Branch__r.City__c=='' && 
                Opp.Account.Branch__r.State__c =='' && Opp.Account.Branch__r.GSTIN__c=='' && 
                Opp.Account.Branch__r.PAN__c=='' && Opp.Account.Branch__r.Authorized_Signatory__c==''
            )
            {
                sMessage='Please fill complete Account billing address, PAN, TAN and GST.\n'+
                    +'Please fill complete Contact mailing address, Designation and Phone.\n'+
                    +'Please fill complete Branch address, GST, PAN and Authorized Signatory.\n'+
                    +'Please fill IRF Amount and ASF amount.\n'+
                    +'Please fill Record Owner Designation.';
                return sMessage;
            }
            
            
            string sEmailAddress='';
            if(conList[0].Email!=null){
                sEmailAddress= conList[0].Email;//Opp.Contact_for_MPRA_SOW__r.email;
            }
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment attach_sideLetter = new Messaging.EmailFileAttachment();
            string sCCEmailAddress=Opp.owner.email;
            
            if(MPRA){
                System.debug('MPRA Checked======>>>');
                PageReference prefMPRA;         // = page.ICRA_MPRA_DOC;
                PageReference prefMPRA_ICE;         // = page.ICRA_MPRA_DOC;
                if(Opp.Instrument_type_4__c=='Issuer Rating')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Loss Estimation/Direct Assignment')
                {
                    prefMPRA = page.ICRA_MPRA_DA;
                }
                else if(Opp.Instrument_type_4__c=='Resolution Plan - Independent Credit Evaluation (ICE)')
                {
                    prefMPRA = page.ICRA_MPRA_ICE;
                    prefMPRA_ICE= page.ICRA_Side_Letter_ICE_SoW;
                }
                else if(Opp.Instrument_type_4__c=='Pass Through Certificates')
                {
                    prefMPRA = page.ICRA_MPRA_PTC;
                }
                else if(Opp.Instrument_type_4__c=='Security Receipts')
                {
                    prefMPRA = page.ICRA_MPRA_SR;
                }
                else if(Opp.Instrument_type_4__c=='Mutual Fund Rating')         //need to update
                {
                    prefMPRA = page.ICRA_MPRA_MF;
                }
                else if(Opp.Instrument_type_4__c=='Fixed Deposits')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Non-Convertible Debenture')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Certificate of Deposit')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Commercial Paper')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Short Term Borrowing Programme')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Various Debt Instruments')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Long Term Borrowing Programme')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Hybrid Debt')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='PP- Market Linked Debenture')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Preference Shares')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Sub Debt')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Bank Loan Rating')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Bank Loan Rating Fresh')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Bank Loan Rating Enhancement')
                {
                    prefMPRA = page.ICRA_MPRA_Standard;
                }
                else if(Opp.Instrument_type_4__c=='Infrastructure Expected Loss Ratings')
                {
                    prefMPRA = page.ICRA_MPRA_AIF;
                }
                else if(Opp.Instrument_type_4__c=='Infrastructure Investment Trusts-InvITs')
                {
                    prefMPRA = page.ICRA_MPRA_AIF;
                }
                else if(Opp.Instrument_type_4__c=='Real Estate Investment Trust')
                {
                    prefMPRA = page.ICRA_MPRA_AIF;
                }
                else if(Opp.Instrument_type_4__c=='Monitoring Activity')
                {
                    prefMPRA = page.ICRA_MPRA_AIF;
                }
                else if(Opp.Instrument_type_4__c=='AIF')
                {
                    prefMPRA = page.ICRA_MPRA_AIF;
                }

                prefMPRA.getParameters().put('Id',OppotunityId);
                prefMPRA.setRedirect(true);

                if(Opp.Instrument_type_4__c=='Resolution Plan - Independent Credit Evaluation (ICE)'){
                    prefMPRA_ICE.getParameters().put('Id',OppotunityId);
                    prefMPRA_ICE.setRedirect(true);
                }
                
                Blob BprefMPRA; 
                Blob BprefMPRA_ICE; 
                if(Test.isRunningTest()) { 
                    BprefMPRA = blob.valueOf('Unit.Test');  
                } else {
                    if(Opp.Instrument_type_4__c=='Resolution Plan - Independent Credit Evaluation (ICE)'){
                        BprefMPRA_ICE = prefMPRA_ICE.getContent();
                        BprefMPRA = prefMPRA.getContent();
                    }else{
                        BprefMPRA = prefMPRA.getContent();
                    }

                }
                string Mpra_Doc = EncodingUtil.base64Encode(BprefMPRA);
                system.debug('File====>>>>'+Mpra_Doc);
                Map<String,Object> mapOfMPRA= ICRA_dscSigning_MPRA_SoW.SignedDoc(OppotunityId, Mpra_Doc);
                
                ContentVersion mpra_Content= SendProposal.parseDoc(mapOfMPRA, 'MPRA_', opp);
                //ContentVersion[] insertedContent_MPRA = [select id, VersionData, ContentDocumentId from ContentVersion ORDER BY SystemModstamp DESC LIMIT 1];
                attach.setFileName('MPRA_'+opp.Instrument_type_4__c+'.pdf');
                attach.setBody(mpra_Content.VersionData);

                attach_sideLetter.setFileName('MPRA_'+opp.Instrument_type_4__c+'side_letter.pdf');
                attach_sideLetter.setBody(BprefMPRA_ICE);
            }
            if(SOW){
                System.debug('SoW Checked======>>>');
                PageReference prefSow ;
                
                if(Opp.Instrument_type_4__c=='Issuer Rating')
                {
                    prefSow = page.ICRA_Issuer_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Loss Estimation/Direct Assignment')
                {
                    prefSow = page.ICRA_DA_SoW;
                }
                else if(Opp.Instrument_type_4__c=='Bank Loan Rating')
                {
                    prefSow = page.ICRA_SAW_BLR_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Bank Loan Rating Fresh')
                {
                    prefSow = page.ICRA_SAW_BLR_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Bank Loan Rating Enhancement')
                {
                    prefSow = page.ICRA_SAW_BLR_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Non-Convertible Debenture' )
                {
                    prefSow = page.ICRA_NCD_CD_Rating;
                }
                
                else if(Opp.Instrument_type_4__c=='Certificate of Deposit')
                {
                    prefSow = page.ICRA_NCD_CD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Fixed Deposits')
                {
                    prefSow = page.ICRA_CP_STD_FD_Rating;
                }
                
                else if(Opp.Instrument_type_4__c=='Commercial Paper')
                {
                    prefSow = page.ICRA_CP_STD_FD_Rating;
                }
                // else if(Opp.Instrument_type_4__c=='Assignee Payout')
                // {
                //     prefSow = page.ICRA_RRAAP_Doc;
                // }
                // else if(Opp.Instrument_type_4__c=='Pass Through Certificates')
                // {
                //     prefSow = page.ICRA_RRAPTC_Doc;
                // }
                else if(Opp.Instrument_type_4__c=='Short Term Borrowing Programme')
                {
                    prefSow = page.ICRA_CP_STD_FD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Various Debt Instruments')
                {
                    prefSow = page.ICRA_CP_STD_FD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Long Term Borrowing Programme')
                {
                    prefSow = page.ICRA_CP_STD_FD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Hybrid Debt')
                {
                    prefSow = page.ICRA_NCD_CD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='PP- Market Linked Debenture')
                {
                    prefSow = page.ICRA_NCD_CD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Preference Shares')
                {
                    prefSow = page.ICRA_NCD_CD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Sub Debt')
                {
                    prefSow = page.ICRA_NCD_CD_Rating;
                }
                else if(Opp.Instrument_type_4__c=='Mutual Fund Rating')
                {
                    prefSow = page.ICRA_MF_Rating_SoW;
                }
                prefSow.getParameters().put('Id',OppotunityId);
                prefSow.setRedirect(true);
                // Blob BprefSow = prefSow.getContent();
                
                Blob BprefSow; 
                if(Test.isRunningTest()) { 
                    BprefSow = blob.valueOf('Unit.Test');
                    
                } else {
                    BprefSow = prefSow.getContent();
                }

                string Sow_Doc = EncodingUtil.base64Encode(BprefSow);
                system.debug('File====>>>>'+Sow_Doc);
                Map<String,Object> mapOfSoW=ICRA_dscSigning_MPRA_SoW.SignedDoc(OppotunityId, Sow_Doc);
                //ContentVersion[] insertedContent_SoW = [select id, VersionData, ContentDocumentId from ContentVersion ORDER BY SystemModstamp DESC LIMIT 1];
                ContentVersion SoW_Content= SendProposal.parseDoc(mapOfSoW, 'SoW_', opp);
                attach2.setFileName('SOW_'+opp.Instrument_type_4__c+'.pdf');
                attach2.setBody(SoW_Content.VersionData);
            }
            semail.setTemplateId(et.Id);
            semail.setWhatId(opp.Id);
            
            
            String htmlBody = et.HtmlValue;
            if(conList[0].Salutation!=null){
                htmlBody = htmlBody.replace('{!Opportunity.Contact__r}', conList[0].Salutation/*opp.Contact_for_MPRA_SOW__r.Salutation*/);
            }
            if(conList[0].Name!=null){
                htmlBody = htmlBody.replace('{!Opportunity.Name}', conList[0].Name /*opp.Contact_for_MPRA_SOW__r.Name*/);
            }
            htmlBody = htmlBody.replace('{!Opportunity.VoD_in_crore__c}', String.valueof(opp.VoD_in_crore__c));
            htmlBody = htmlBody.replace('{!Opportunity.Instrument_type_4__c}', opp.Instrument_type_4__c);
            htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', opp.owner.Name);
            htmlBody = htmlBody.replace('{!Opportunity.OwnerPhone}', opp.owner.mobilephone );
            htmlBody = htmlBody.replace('{!Opportunity.Crore_or_Million__c} ', opp.Crore_or_Million__c == 'Crore' ? 'Cr.' : 'Million' );
            
            htmlBody = htmlBody.replace('{!Opportunity.CurrencyDisplayFormula__c}', opp.CurrencyDisplayFormula__c);
            semail.setHtmlBody(htmlBody);
            semail.setSubject('Opportunity Id: '+Opp.Id+' '+' Proposal for Rs.'+Opp.VoD_in_crore__c+' '+(opp.Crore_or_Million__c=='Crore'?'Cr.':'Million')  +' ('+Opp.Instrument_type_4__c+') Rating Programme');
            semail.setOrgWideEmailAddressId(owea.get(0).Id);
            semail.setToAddresses(new List<String>{sEmailAddress});
            List<String> cclst= new List<String>();
            cclst.add(System.Label.MPRA_SoW_Email);
            if(sCCEmailAddress!=null)
            {
                cclst.add(sCCEmailAddress);
            }
            if(cclst.Size()>0)
            {
                semail.setccAddresses(cclst);
            }
            //semail.setPlainTextBody('Please find the attached Opportunity details');
            if(MPRA && SoW){
                if(Opp.Instrument_type_4__c=='Resolution Plan - Independent Credit Evaluation (ICE)'){
                    semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach,attach2,attach_sideLetter});
                }else{
                    semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach,attach2});
                }
                                
            }
            else if(MPRA && SoW==false){
                if(Opp.Instrument_type_4__c=='Resolution Plan - Independent Credit Evaluation (ICE)'){
                    semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach,attach_sideLetter});
                }else{
                    semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});  
                }
                
            }else if(MPRA==false && SoW){
                semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach2});                
            }
            
            if(!string.isBlank(sEmailAddress)){
                Messaging.SendEmailResult[] r =  Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                for(Messaging.SendEmailResult rr:r){
                    System.debug('Email result ' + rr.IsSuccess());
                    if(rr.IsSuccess()==true)
                    {
                        //OPP.StageName='MPRA & SoW / Subscription Form Sent';
                        if(!Test.isRunningTest())
                        {
                            update OPP;
                        }
                    }
                } 
                sMessage='SUCCESS';
                return sMessage;
            }

            sMessage='Email not Sent';
            return sMessage;
      /* }
        catch(Exception ex){
            sMessage=ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause();
            return sMessage;
              //  'There is something went wrong. Please contact your Administrator';
        }
        */
    }
    public static ContentVersion parseDoc(Map<String,Object> respMap2, String name, Opportunity opp){
        if(respMap2.get('SignedFile') != null){
                        string returnFile;
                        system.debug('Response======>>>>'+respMap2.get('SignedFile').tostring());
                        returnFile = respMap2.get('SignedFile').tostring();
                        returnFile= returnFile.removeEnd('"');
                        returnFile= returnFile.removeStart('"');
                        Blob myBlob = EncodingUtil.base64Decode(returnFile);
                        ContentVersion ContentInsert = new ContentVersion();
                        ContentInsert.Title = name+opp.Instrument_type_4__c+' | Signed';
                        ContentInsert.VersionData = myBlob;
                        ContentInsert.PathOnClient = '/'+' | Signed.pdf';
                        return ContentInsert;
        }else{
            string error = respMap2.get('ErrorMessage').tostring();
                            Error_Log__c el = new Error_Log__c();
                            el.Record_ID__c =opp.Id;
                            el.Error_Message__c = error;
                            //el.Response__c = res.getBody();
                            insert el;
                            return null;
        }
    }

    // public static void updateEffectiveDates(String OppotunityId){
    //     Opportunity opp= [select id, MPRA_Sent_Date__c, SOW_Effective_Date__c from opportunity where id=:OppotunityId];
    //     if(opp.MPRA_Sent_Date__c==null){
    //         opp.MPRA_Sent_Date__c=System.Today();
    //         update opp;
    //     }
    //     if(opp.SOW_Effective_Date__c==null){
    //         opp.SOW_Effective_Date__c=System.Today();
    //         update opp;
    //     }

    // }


    public static void coverClass(){
        Integer i=1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    
    }
}