public class InvoiceReminderEmailHandler {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public Id opportunityId;
    }

    @InvocableMethod(label='Send Invoice Reminder Emails')
    public static void sendReminders(List<InputWrapper> inputList) {
        System.debug('### [START] Invoice Reminder Email Triggered');
        Set<Id> oppIds = new Set<Id>();
        for(InputWrapper i : inputList) {
            oppIds.add(i.opportunityId);
        }
        System.debug('### [Input Opportunity IDs]: ' + oppIds);

        // Fetch opportunities
        List<Opportunity> opps = [
            SELECT Id, Name, Billing_Start_Date__c, Owner.Id, Owner.Email, Owner.Name,
                   BD_Head__r.Email, BD_Head__r.Name, Team_Leader__r.Email, Team_Leader__r.Name,
                   Reminder_Email_Sent__c
            FROM Opportunity 
            WHERE Id IN :oppIds
        ];
        System.debug('### [Queried Opportunities]: Count = ' + opps.size());

        Map<Id, List<Opportunity>> ownerOppMap = new Map<Id, List<Opportunity>>();
        Map<Id, String> ownerEmailMap = new Map<Id, String>();
        Map<Id, String> bdHeadEmailMap = new Map<Id, String>();
        Map<Id, String> teamLeadEmailMap = new Map<Id, String>();
        Map<Id, String> ownerNameMap = new Map<Id, String>();

        for (Opportunity opp : opps) {
            System.debug('### [Processing Opportunity]: ' + opp.Id + ', Owner: ' + opp.OwnerId);
            if (!ownerOppMap.containsKey(opp.OwnerId)) {
                ownerOppMap.put(opp.OwnerId, new List<Opportunity>());
            }
            ownerOppMap.get(opp.OwnerId).add(opp);
            ownerEmailMap.put(opp.OwnerId, opp.Owner.Email);
            ownerNameMap.put(opp.OwnerId, opp.Owner.Name);
            if (opp.BD_Head__r != null) {
                bdHeadEmailMap.put(opp.OwnerId, opp.BD_Head__r.Email);
            }
            if (opp.Team_Leader__r != null) {
                teamLeadEmailMap.put(opp.OwnerId, opp.Team_Leader__r.Email);
            }
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Get Org-Wide Email Address
        Id orgWideEmailAddressId = null;
        List<OrgWideEmailAddress> orgWideEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sales@icraindia.info' LIMIT 1];
        if (!orgWideEmails.isEmpty()) {
            orgWideEmailAddressId = orgWideEmails[0].Id;
        }
        System.debug('### [Org-Wide Email ID]: ' + orgWideEmailAddressId);

        for (Id ownerId : ownerOppMap.keySet()) {
            List<Opportunity> ownerOpps = ownerOppMap.get(ownerId);
            String toEmail = ownerEmailMap.get(ownerId);
            //String ccEmail1 = bdHeadEmailMap.get(ownerId);
            String ccEmail2 = teamLeadEmailMap.get(ownerId);
            List<String> ccList = new List<String>();
            //if (!String.isBlank(ccEmail1)) ccList.add(ccEmail1);
            if (!String.isBlank(ccEmail2)) ccList.add(ccEmail2);

            System.debug('### [Preparing Email For Owner]: ' + ownerId + ', To: ' + toEmail + ', CC: ' + ccList);
            if (String.isBlank(toEmail)) {
                System.debug('### [SKIPPED]: Owner has no email');
                continue;
            }

            String body = 'Hi ' + ownerNameMap.get(ownerId) + ',<br/><br/>' +
                          'Kindly be informed that the below are the pending surveillance opportunities that have not been invoiced yet. ' +
                          'It is recommended to take necessary measures to resolve this matter promptly.<br/><br/>' +
                          '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">' +
                          '<tr><th>Opportunity Name</th><th>Billing Start Date</th></tr>';

            for (Opportunity opp : ownerOpps) {
                String link = URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id;
                body += '<tr><td><a href="' + link + '">' + opp.Name + '</a></td>' +
                        '<td>' + String.valueOf(opp.Billing_Start_Date__c) + '</td></tr>';
                opp.Reminder_Email_Sent__c = true;
                oppsToUpdate.add(opp);
            }

            body += '</table><br/><br/>Thank you,<br/>ICRA Limited';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{toEmail});
            if (!ccList.isEmpty()) {
                email.setCcAddresses(ccList);
            }
            if (orgWideEmailAddressId != null) {
                email.setOrgWideEmailAddressId(orgWideEmailAddressId);
            }
            email.setSubject('Notification to generate Tax invoice for Surveillance Opportunities due for Billing');
            email.setHtmlBody(body);

            System.debug('### [Email Constructed]: To=' + toEmail + ', Body Length=' + body.length());
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            System.debug('### [Sending Emails]: Count = ' + emails.size());
            Messaging.sendEmail(emails, false);
        } else {
            System.debug('### [No Emails To Send]');
        }

        if (!oppsToUpdate.isEmpty()) {
            System.debug('### [Updating Opportunities]: Count = ' + oppsToUpdate.size());
            update oppsToUpdate;
        } else {
            System.debug('### [No Opportunities To Update]');
        }

        System.debug('### [END] Invoice Reminder Email Process');
    }
}