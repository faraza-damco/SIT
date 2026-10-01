public class CH_MD_approval_EmailId_Handler {
    public static String emailSubject = '';
    public static String emailbody = '';
    public static void approved_rejected_by_BH(List<Opportunity> newOpportunity){
        List<Opportunity> updateoppList = new List<Opportunity>();
        String BH_userId = '';
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> approve_emailId = new List<String>();
        List<Opportunity> updateMDoppList = new List<Opportunity>();
        String userRoleId = '';
        String ManagerId = '';
        Set<String> managerIdSet = new Set<String>();
        Map<String,String> user_Manager_Map = new Map<String,String>();
        List<User> userList = [SELECT Id,ManagerID,Email,Name FROM USER WHERE ManagerID != null AND isactive = true];
        String fetchBHId = '';
        for(Opportunity oppRecord2 : newOpportunity){
            if(oppRecord2.Pricing_Approved_by_Business_Head__c == true || oppRecord2.Pricing_Rejected_by_Business_Head__c == true){
                fetchBHId = oppRecord2.BD_Head__c;
                system.debug('fetchBHId '+fetchBHId);
                ManagerId = oppRecord2.OwnerId;
                oppList.add(oppRecord2);
                //BH_userIdSet.add(oppRecord2.BD_Head__c);
            }
        }
        if(!(userList.isEmpty())){
                for(User userRecord : userList){
                    user_Manager_Map.put(userRecord.Id,userRecord.ManagerId);
                }
            }
            String mgId='';
            String mgCombination ='';
        for(String manager : user_Manager_Map.keySet()){
            mgId = user_Manager_Map.get(ManagerId);
            mgCombination+=mgId;
            if(mgId != null && mgId != '' && mgId != fetchBHId ){
                managerIdSet.add(mgId);
                system.debug('Adding in the managerIdSet '+managerIdSet); //if mngrId= fetchId then break
                ManagerId = mgId;
            }
        }
        if(!mgCombination.contains(fetchBHId)){
            managerIdSet.clear();
        }else{
            for(User userRec : [SELECT Id,Name,Email,ManagerId FROM USER WHERE Id IN: managerIdSet]){
                system.debug('Emails are '+userRec.Email);
                system.debug('Names are '+userRec.Name);
                approve_emailId.add(userRec.Email);
            }
        }

        system.debug('managerIdSet  '+managerIdSet);

        for(Opportunity oppRecord : [SELECT Id,Name,OwnerId,Owner.Name,Pricing_Approved_by_Business_Head__c,Pricing_Rejected_by_Business_Head__c,BH_Approval_Rejection_Mail_Sent__c 
                                     FROM Opportunity WHERE Id IN: oppList]){
           
            if(oppRecord.Pricing_Approved_by_Business_Head__c == true){
                emailbody = 'Hi '+oppRecord.Owner.Name+ ',<br/>';
                emailbody += '<br/>';
                emailbody += 'Your pricing approval request has been approved by BH.<br/>';
                emailbody += '<br/>';
                emailbody += 'Click here for details: <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id+'">Opportunity Link</a><br/>';
                emailbody += '<br/>';
                emailbody += 'Thank you,<br/>';
                emailbody += '<br/>';
                emailbody += 'Salesforce';
                
            }
            if(oppRecord.Pricing_Rejected_by_Business_Head__c == true){
                emailbody = 'Hi '+oppRecord.Owner.Name+ ',<br/>';
                 emailbody += '<br/>';
                emailbody += 'Your pricing approval request has been rejected by BH.<br/>';
                emailbody += '<br/>';
                emailbody += 'Click here for details: <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id+'">Opportunity Link</a><br/>';
                emailbody += '<br/>';
                emailbody += 'Thank you,<br/>';
                emailbody += '<br/>';
                emailbody += 'Salesforce';
            }
            
            if(!(approve_emailId.isEmpty()) && approve_emailId.size() > 0){
                emailSubject = 'Pricing Approval – BH - '+oppRecord.Name;
                emailMessage(approve_emailId,oppRecord.Id,oppRecord.OwnerId,emailSubject,emailbody);
                oppRecord.BH_Approval_Rejection_Mail_Sent__c = true;
                updateoppList.add(oppRecord);
                updateOppEmailcheckpoint(updateoppList);
            }else{
                emailSubject = 'Pricing Approval – BH - '+oppRecord.Name;
                emailMessage(null,oppRecord.Id,oppRecord.OwnerId,emailSubject,emailbody);
                oppRecord.BH_Approval_Rejection_Mail_Sent__c = true;
                updateoppList.add(oppRecord);
                updateOppEmailcheckpoint(updateoppList);
            }
        }
        
    }
    public static void approved_rejected_by_CH(List<Opportunity> newOpportunity){
        /*Set<Id> CH_userIdSet = new Set<Id>();
        List<String> approve_emailId = new List<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> updateoppList = new List<Opportunity>();
        for(Opportunity oppRecord2 : newOpportunity){
            if(oppRecord2.Pricing_Approved_by_Commercial_Head__c == true || oppRecord2.Pricing_Rejected_by_Commercial_Head__c == true){
                CH_userIdSet.add(oppRecord2.Commercial_Head__c);
                oppList.add(oppRecord2);
            }
        }
        if(!(CH_userIdSet.isEmpty())){
                for(User userRecord : [SELECT id,Name,ManagerId,Manager.Email FROM User WHERE Id IN : CH_userIdSet]){
                    approve_emailId.add(userRecord.Manager.Email);
                }
              
            }*/
        List<Opportunity> updateoppList = new List<Opportunity>();
        String CH_userId = '';
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> approve_emailId = new List<String>();
        List<Opportunity> updateMDoppList = new List<Opportunity>();
        String userRoleId = '';
        String ManagerId = '';
        Set<String> managerIdSet = new Set<String>();
        Map<String,String> user_Manager_Map = new Map<String,String>();
        List<User> userList = [SELECT Id,ManagerID,Email,Name FROM USER WHERE ManagerID != null AND isactive = true];
        String fetchCHId = '';
       
        
         for(Opportunity oppRecord2 : newOpportunity){
            if(oppRecord2.Pricing_Approved_by_Commercial_Head__c == true || oppRecord2.Pricing_Rejected_by_Commercial_Head__c == true){
               // system.debug('Entered in for loop ');
               // system.debug('Pricing_Approved_by_CEO__c '+oppRecord2.Pricing_Approved_by_CEO__c);
               // system.debug('Commerical head '+oppRecord2.Commercial_Head__c);
                
               // MD_userId  = oppRecord2.Commercial_Head__r.ManagerId;
                fetchCHId = oppRecord2.Commercial_Head__c;
                system.debug('fetchCHId '+fetchCHId);
                ManagerId = oppRecord2.OwnerId;
                oppList.add(oppRecord2);
            }
         }
          if(!(userList.isEmpty())){
                    for(User userRecord : userList){
                        user_Manager_Map.put(userRecord.Id,userRecord.ManagerId);
                    }   
                }
                
                String mgIdCH='';
                String mgCombinationCH ='';
                   for(String manager : user_Manager_Map.keySet()){
                    mgIdCH = user_Manager_Map.get(ManagerId);
                    mgCombinationCH+=mgIdCH;
                    if(mgIdCH != null && mgIdCH != '' && mgIdCH != fetchCHId ){
                        managerIdSet.add(mgIdCH);
                        system.debug('Adding in the managerIdSet '+managerIdSet);
                        ManagerId = mgIdCH;
                    }  
                }
                system.debug('mgCombinationCH ==>> '+mgCombinationCH);
                
                if(!mgCombinationCH.contains(fetchCHId)){
                    managerIdSet.clear();
                }else{
                    for(User userRec : [SELECT Id,Name,Email,ManagerId FROM USER WHERE Id IN: managerIdSet]){
                            system.debug('Emails are '+userRec.Email);
                            system.debug('Names are '+userRec.Name);
                        approve_emailId.add(userRec.Email);
                        }
                }
                system.debug('managerIdSet  '+managerIdSet);
        
        
        
        for(Opportunity oppRecord : [SELECT Id,Name,OwnerId,Owner.Name,Pricing_Approved_by_Commercial_Head__c,Pricing_Rejected_by_Commercial_Head__c,CH_Approval_Reject_Email_sent__c 
                                     FROM Opportunity WHERE Id IN: oppList]){
           
            if(oppRecord.Pricing_Approved_by_Commercial_Head__c == true){
                emailbody = 'Hi '+oppRecord.Owner.Name+ ',<br/>';
                emailbody += '<br/>';
                emailbody += 'Your pricing approval request has been approved by CH.<br/>';
                emailbody += '<br/>';
                //emailbody += 'Click here for details: <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id+'">Opportunity Link</a><br/>';
                emailbody += 'Click here for details:'+'<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'.'+'</a>';
                emailbody += '<br/>';
                emailbody += 'Thank you,<br/>';
                emailbody += '<br/>';
                emailbody += 'Salesforce';
                
            }
            if(oppRecord.Pricing_Rejected_by_Commercial_Head__c == true){
                emailbody = 'Hi '+oppRecord.Owner.Name+ ',<br/>';
                 emailbody += '<br/>';
                emailbody += 'Your pricing approval request has been rejected by CH.<br/>';
                emailbody += '<br/>';
                //emailbody += 'Click here for details: <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id+'">Opportunity Link</a><br/>';
                emailbody += 'Click here for details:'+'<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'.'+'</a>';
                emailbody += '<br/>';
                emailbody += 'Thank you,<br/>';
                emailbody += '<br/>';
                emailbody += 'Salesforce';
            }
            
            if(!(approve_emailId.isEmpty()) && approve_emailId.size() > 0){
                emailSubject = 'Pricing Approval – CH - '+oppRecord.Name;
                emailMessage(approve_emailId,oppRecord.Id,oppRecord.OwnerId,emailSubject,emailbody);
                oppRecord.CH_Approval_Reject_Email_sent__c = true;
                updateoppList.add(oppRecord);
                updateOppEmailcheckpoint(updateoppList);
            }else{
                emailSubject = 'Pricing Approval – CH - '+oppRecord.Name;
                emailMessage(null,oppRecord.Id,oppRecord.OwnerId,emailSubject,emailbody);
                oppRecord.CH_Approval_Reject_Email_sent__c = true;
                updateoppList.add(oppRecord);
                updateOppEmailcheckpoint(updateoppList);
            }
        }
        
    }
    public static void approved_rejected_by_CEO(List<Opportunity> newOpportunity){
        //Set<Id> MD_userIdSet = new Set<Id>();
        String MD_userId = '';
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> approve_emailId = new List<String>();
        List<Opportunity> updateMDoppList = new List<Opportunity>();
        String userRoleId = '';
        String ManagerId = '';
        Set<String> managerIdSet = new Set<String>();
        Map<String,String> user_Manager_Map = new Map<String,String>();
        List<User> userList = [SELECT Id,ManagerID,Email,Name FROM USER WHERE ManagerID != null AND isactive = true];
        String fetchCHId = '';
        String MD_ID = '';
        List<User> fetchMD = new List<User>();
        for(Opportunity oppRecord3 : newOpportunity){
            if(oppRecord3.Commercial_Head__c != null){
                fetchCHId = oppRecord3.Commercial_Head__c;
            }
            
        }
        if(fetchCHId != null && fetchCHId != ''){
            fetchMD = [SELECT Id,ManagerID,Email,Name FROM USER WHERE Id =: fetchCHId limit 1];
        }
        if(fetchMD.size() > 0 && fetchMD[0].ManagerID != null){
            MD_ID = fetchMD[0].ManagerID;
        }
        
        
         for(Opportunity oppRecord2 : newOpportunity){
            if(oppRecord2.Pricing_Approved_by_CEO__c == true || oppRecord2.Pricing_Rejected_by_CEO__c == true){
               // system.debug('Entered in for loop ');
               // system.debug('Pricing_Approved_by_CEO__c '+oppRecord2.Pricing_Approved_by_CEO__c);
               // system.debug('Commerical head '+oppRecord2.Commercial_Head__c);
                
               // MD_userId  = oppRecord2.Commercial_Head__r.ManagerId;
                MD_userId = MD_ID;
                system.debug('MD userId'+MD_userId);
                ManagerId = oppRecord2.OwnerId;
                oppList.add(oppRecord2);
            }
         }
          if(!(userList.isEmpty())){
                    for(User userRecord : userList){
                        user_Manager_Map.put(userRecord.Id,userRecord.ManagerId);
                    }   
                }
                    //String mgIdMD='';
                    //String mgCombinationMD='';
                   for(String manager : user_Manager_Map.keySet()){
                    String mgIdMD = user_Manager_Map.get(ManagerId);
                    //mgCombinationMD+=mgIdMD;
                    if(mgIdMD != null && mgIdMD != '' && mgIdMD != MD_userId ){
                        managerIdSet.add(mgIdMD);
                        system.debug('Adding in the managerIdSet '+managerIdSet);
                        ManagerId = mgIdMD;
                    }   
                }
                //if(!mgCombinationMD.contains(MD_userId)){
                //    managerIdSet.clear();
                //}else{
                    for(User userRec : [SELECT Id,Name,Email,ManagerId FROM USER WHERE Id IN: managerIdSet]){
                            system.debug('Emails are '+userRec.Email);
                            system.debug('Names are '+userRec.Name);
                        approve_emailId.add(userRec.Email);
                        }
                //}
                system.debug('managerIdSet  '+managerIdSet);
        
        for(Opportunity oppRecord : [SELECT Id,Name,OwnerId,Owner.Name,Pricing_Rejected_by_CEO__c,Pricing_Approved_by_CEO__c,MD_Approval_Reject_Email_sent__c 
                                     FROM Opportunity WHERE Id IN: oppList]){
            system.debug('Onwer Name '+oppRecord.Owner.Name);
            system.debug('Opp URL '+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id);
            if(oppRecord.Pricing_Approved_by_CEO__c == true){
                emailbody = 'Hi '+oppRecord.Owner.Name+ ',<br/>';
                emailbody += '<br/>';
                emailbody += 'Your pricing approval request has been approved by MD.<br/>';
                emailbody += '<br/>';
                //emailbody += 'Click here for details: <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id+'">Opportunity Link</a><br/>';
                emailbody += 'Click here for details:'+'<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'.'+'</a>';

                emailbody += '<br/>';
                emailbody += 'Thank you,<br/>';
                emailbody += '<br/>';
                emailbody += 'Salesforce';
            }
            if(oppRecord.Pricing_Rejected_by_CEO__c == true){
                emailbody = 'Hi '+oppRecord.Owner.Name+ ',<br/>';
                emailbody += '<br/>';
                emailbody += 'Your pricing approval request has been rejected by MD.<br/>';
                emailbody += '<br/>';
                //emailbody += 'Click here for details: <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppRecord.Id+'">Opportunity Link</a><br/>';
                emailbody += 'Click here for details:'+'<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRecord.id+'.'+'</a>';
                emailbody += '<br/>';
                emailbody += 'Thank you,<br/>';
                emailbody += '<br/>';
                emailbody += 'Salesforce';
            }
            
          
                    
            if(!(approve_emailId.isEmpty()) && approve_emailId.size() > 0){
                emailSubject = 'Pricing Approval – MD- '+oppRecord.Name;
                emailMessage(approve_emailId,oppRecord.Id,oppRecord.OwnerId,emailSubject,emailbody);
                 oppRecord.MD_Approval_Reject_Email_sent__c	 = true;
                updateMDoppList.add(oppRecord);
                updateOppEmailcheckpoint(updateMDoppList);
            }
        }
        
    }
    public static void emailMessage(List<String> CHEmailId, String oppId, String oppOwnerId, String subject, String body){
        OrgWideEmailAddress [] owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'sales@icraindia.info'];
        Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();
        //emailRecord.setTargetObjectId(oppId);
        emailRecord.setOrgWideEmailAddressId(owea[0].Id);
        emailRecord.setCcAddresses(CHEmailId);
        emailRecord.setToAddresses(new List<String> {oppOwnerId});
        emailRecord.setSaveAsActivity(false); 
        emailRecord.setSubject(subject);
        emailRecord.setHtmlBody(body);
        emailSet.add(emailRecord);      
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.addAll(emailSet);
        if(!(emailList.isEmpty())){
            Messaging.sendEmail(emailList);
        }
        
    }
    public static void updateOppEmailcheckpoint(List<Opportunity> updateoppList){
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        for(Opportunity opp: updateoppList){
            oppListUpdate.add(opp);
        }
        if(!(oppListUpdate.isEmpty()) && oppListUpdate.size() > 0){
            update oppListUpdate;
        }
    }
}