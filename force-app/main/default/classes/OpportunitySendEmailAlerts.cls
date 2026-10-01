public class OpportunitySendEmailAlerts {

    public class Input {
        @InvocableVariable(required=true)
        public Id OpportunityId;
    }

    @InvocableMethod(label='Send Proforma Invoice Emails for Opportunities (Bulk-Safe)')
    public static void sendEmails(List<Input> inputs) {
        if(inputs == null || inputs.isEmpty()) {
            return;
        }

        // Collect Opportunity Ids
        Set<Id> oppIds = new Set<Id>();
        for(Input i : inputs) {
            if(i.OpportunityId != null) {
                oppIds.add(i.OpportunityId);
            }
        }
        if (oppIds.isEmpty()) return;

        // Query Opportunities + Owner data
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Name, Billing_Start_Date__c, Owner.Name, Owner.Email, Team_Leader__r.Email, BD_Head__r.Email
             FROM Opportunity 
             WHERE Id IN :oppIds]
        );

        // Get Org-Wide Email Address ID (defensive)
        Id orgWideEmailAddressId = null;
        List<OrgWideEmailAddress> orgWideEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sales@icraindia.info' LIMIT 1];
        if (!orgWideEmails.isEmpty()) {
            orgWideEmailAddressId = orgWideEmails[0].Id;
        }
		
        
        
        
        // Build emails
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Id> oppIdOrder = new List<Id>(); // maintain ordering for tracking

        for(Id oppId : oppIds) {
            Opportunity opp = oppMap.get(oppId);

            if (opp == null || String.isBlank(opp.Owner.Email)) {
                continue;
            }
			
            List<String> toAddresses = new List<String>();
            List<String> ccList = new List<String>();
            
            // Always include Owner
            toAddresses.add(opp.Owner.Email);
            
            String emailBody = buildEmailBody(opp);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses);
            email.setSubject('Notification to generate Proforma invoice for Surveillance Opportunities.');
            email.setHtmlBody(emailBody);
            email.setSaveAsActivity(false);

            if(!String.isBlank(opp.Team_Leader__r.Email)){
                ccList.add(opp.Team_Leader__r.Email);
            }
            if(!ccList.isEmpty()){
                email.setCcAddresses(ccList);
            }
            
            if (orgWideEmailAddressId != null) {
                email.setOrgWideEmailAddressId(orgWideEmailAddressId);
            }

            emailsToSend.add(email);
            oppIdOrder.add(oppId);
        }

        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
        
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
            for (Integer i = 0; i < results.size(); i++) {
                Id oppId = oppIdOrder[i];
        
                if (results[i].isSuccess()) {
                    System.debug('Email sent successfully for Opportunity Id: ' + oppId);
        
                    Opportunity updatedOpp = new Opportunity(
                        Id = oppId,
                        Is_Notification_Email_Sent__c = true
                    );
                    oppsToUpdate.add(updatedOpp);
                } else {
                    System.debug('Email failed for Opportunity Id: ' + oppId);
                    for (Messaging.SendEmailError err : results[i].getErrors()) {
                        System.debug('Error: ' + err.getMessage());
                    }
                }
            }
        
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
        }

    }

    // Build HTML Email Body
    private static String buildEmailBody(Opportunity opp) {
        String billingDate = (opp.Billing_Start_Date__c != null) 
            ? opp.Billing_Start_Date__c.format() 
            : '';

        String oppLink = URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id;

        String body = ''
            + '<!DOCTYPE html>'
            + '<html>'
            + '<head><meta charset="UTF-8"><title>Proforma Invoice Notification</title></head>'
            + '<body style="font-family: \'Salesforce Sans\', Arial, sans-serif; color: #333333; font-size: 14px; line-height: 1.5;">'
            + '<p>Hi ' + escapeHtml(opp.Owner.Name) + ',</p>'
            + '<p>The following Surveillance Opportunity is due for Proforma Invoice:</p>'
            + '<table style="border-collapse: collapse; width: 100%; margin: 16px 0;">'
            + '<tr>'
            + '<th style="text-align: left; padding: 8px; border: 1px solid #dddddd;">Opportunity Name</th>'
            + '<th style="text-align: left; padding: 8px; border: 1px solid #dddddd;">Billing Start Date</th>'
            + '</tr>'
            + '<tr>'
            + '<td style="padding: 8px; border: 1px solid #dddddd;">'
            + '<a href="' + oppLink + '" target="_blank">' + escapeHtml(opp.Name) + '</a>'
            + '</td>'
            + '<td style="padding: 8px; border: 1px solid #dddddd;">'
            + billingDate
            + '</td>'
            + '</tr>'
            + '</table>'
            + '<p>If a Proforma Invoice is not required, please uncheck the <strong>"Proforma Invoice required"</strong> checkbox on the Opportunity record.</p>'
            + '<p>Thank you,<br>ICRA Limited</p>'
            + '</body></html>';

        return body;
    }

    // Escape special characters for HTML safety
    private static String escapeHtml(String input) {
        if (input == null) return '';
        return input
            .replace('&','&amp;')
            .replace('<','&lt;')
            .replace('>','&gt;')
            .replace('"','&quot;')
            .replace('\'','&#x27;');
    }
}