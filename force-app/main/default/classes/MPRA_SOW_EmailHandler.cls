global class MPRA_SOW_EmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            EmailMessage emailMsg= new EmailMessage();
            emailMsg.Subject= email.subject;
            emailMsg.TextBody= email.plainTextBody;
            emailMsg.HtmlBody= email.HtmlBody;
            emailMsg.status= '3';
            emailMsg.MessageDate= System.Now();
            emailMsg.FromAddress= email.fromAddress;
            List<String> toAddress= email.toAddresses;
            String toAddressStr= String.join(toAddress, ';');
            emailMsg.toAddress= toAddressStr;
            emailMsg.FromName= email.fromName;
            List<String> ccAddress= email.ccAddresses;
            String ccAddressStr= String.join(ccAddress, ';');
            emailMsg.ccAddress= ccAddressStr;

            String Subject= emailMsg.Subject;
            //String OppId= Subject.substring(4,22);
            String OppId;
            if(Subject.contains('Opportunity Id: ')){
                Integer startIndex = Subject.indexOf('Opportunity Id: ') + 16; // Adding 16 to skip the length of the "Opportunity Id: " string
                Integer endIndex = Subject.indexOf(' ', startIndex);
                OppId= Subject.subString(startIndex, endIndex);
                System.debug('Opportunity ID====>>' + OppId);
            }

            if(email.binaryAttachments!=null){
                System.Debug('Attachment Present');
                List<ContentVersion> contentVersionList= new List<ContentVersion>();
                List<ContentDocumentLink> contentDocumentLinkList= new List<ContentDocumentLink>();
                for(Messaging.InboundEmail.BinaryAttachment binaryAttach: email.binaryAttachments){
                    ContentVersion contVer= new ContentVersion();
                    contVer.title= binaryAttach.fileName;
                    contVer.versionData= binaryAttach.body;
                    contVer.pathOnClient= '/'+binaryAttach.fileName;
                    contentVersionList.add(contVer);
                }
                if(contentVersionList.size()>0){
                    System.Debug('Content Version List===>>'+contentVersionList);
                    insert contentVersionList;
                }

                List<Opportunity> OptyList= [Select Id, Name from Opportunity where id=:OppId];
                if(!OptyList.isEmpty()){
                    Opportunity Opty= OptyList.get(0);
                    System.Debug('Opportunity Record===>>'+Opty);
                    emailMsg.RelatedToId= Opty.Id;
                    insert emailMsg;
                    System.Debug('Email Inserted===>>'+emailMsg);

                    contentVersionList= [Select id, ContentDocumentId from ContentVersion where Id IN: contentVersionList];
                    for(ContentVersion conVersion: contentVersionList){
                        ContentDocumentLink conDocumentLink= new ContentDocumentLink();
                        conDocumentLink.ContentDocumentId= conVersion.ContentDocumentId;
                        // conDocumentLink.LinkedEntityId= Opty.Id;
                        conDocumentLink.LinkedEntityId= emailMsg.Id;
                        conDocumentLink.ShareType= 'V';
                        conDocumentLink.Visibility= 'AllUsers';
                        contentDocumentLinkList.add(conDocumentLink);
                    }
                    if(contentDocumentLinkList.size()>0){
                        System.Debug('Content Document Link List===>>'+contentDocumentLinkList);
                        insert contentDocumentLinkList;
                    }
                }
            }else{
                List<Opportunity> OptyList= [Select Id, Name from Opportunity where id=:OppId];
                if(!OptyList.isEmpty()){
                    Opportunity Opty= OptyList.get(0);
                    emailMsg.RelatedToId= Opty.Id;
                    insert emailMsg;
                }
            }
        }catch(exception ex){
            System.Debug('Exception===>>'+ex.getMessage()); 
        }
        result.Success= true;
        return result;
    }
}