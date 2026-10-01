trigger UpdaeAgencyOnAccount on Live_Rating__c (after insert,after update) {
    List<Live_Rating__c> LRlist=new List<Live_Rating__c>();
    List<Live_Rating__c> LRExistingLiveRatinglist=new List<Live_Rating__c>();
    List<Account> LiveAccountlist=new List<Account>();
    List<Account> WithdrawnAccountlist=new List<Account>();
    Set<Id> lrIdsList=new Set<Id>();
    Set<Id> AccIdsList=new Set<Id>();
    Map<string,list<string>> mapLiveRating=new Map<string,list<string>>();
    Map<string,Account> mapAccount=new Map<string,Account>();
     Map<string,Account> WithdrawnmapAccount=new Map<string,Account>();
    for(Live_Rating__c LR:Trigger.New)
    {
        AccIdsList.add(LR.Account__c);
        lrIdsList.add(LR.Id);
    }
    LRlist=[select id,Agency__c,Client_Status__c,Account__c from Live_Rating__c where id in:lrIdsList ];
    LRExistingLiveRatinglist=[select id,Agency__c,Client_Status__c,Account__c from Live_Rating__c  where Account__c in:AccIdsList 
                              and (Client_Status__c='Live' or Client_Status__c='INC') and id not in: lrIdsList];
    for(Live_Rating__c aclr:LRExistingLiveRatinglist)
    {
        if(mapLiveRating.containsKey(aclr.Account__c))
        {
            list<string> Agency=mapLiveRating.get(aclr.Account__c);
            Agency.add(aclr.Agency__c);
            mapLiveRating.put(aclr.Account__c,Agency);
        }
        else
        {
            mapLiveRating.put(aclr.Account__c,New List<string>{aclr.Agency__c});
        }
        
    }
    System.debug('mapLiveRating '+mapLiveRating);
    for(Live_Rating__c lrdata:LRlist )
    {
        if(lrdata.Client_Status__c=='Live' || lrdata.Client_Status__c=='INC')
        {
            if(mapAccount.containsKey(lrdata.Account__c))
            {
                Account acc=mapAccount.get(lrdata.Account__c);
                //acc.Id=lrdata.Account__c;
                string Agency=lrdata.Agency__c+'_Agency__C';    
                acc.put(Agency,true);
                //LiveAccountlist.add(acc);
            }
            else
            {
                Account acc=new Account();
                acc.Id=lrdata.Account__c;
                string Agency=lrdata.Agency__c+'_Agency__C';    
                acc.put(Agency,true);
                LiveAccountlist.add(acc);
                mapAccount.put(lrdata.Account__c,acc);
            }
            
            
        }
        else if(lrdata.Client_Status__c=='Withdrawn')
        {
            System.debug('mapLiveRating.get(lrdata.Account__c) '+mapLiveRating);            
            
            if(mapLiveRating.get(lrdata.Account__c)!=null)
            {
                
                System.debug('mapLiveRating.get(lrdata.Account__c) '+mapLiveRating.get(lrdata.Account__c));            
                if(!mapLiveRating.get(lrdata.Account__c).contains(lrdata.Agency__c))
                {
                    if(mapAccount.containsKey(lrdata.Account__c))
                    {
                        Account acc=new Account();
                        //acc.Id=lrdata.Account__c;
                        string Agency=lrdata.Agency__c+'_Agency__C';
                        acc.put(Agency,false);
                        //WithdrawnAccountlist.add(acc);
                    }
                    else
                    {
                        Account acc=new Account();
                        acc.Id=lrdata.Account__c;
                        string Agency=lrdata.Agency__c+'_Agency__C';
                        acc.put(Agency,false);
                        WithdrawnAccountlist.add(acc);
                        mapAccount.put(lrdata.Account__c,acc);
                        
                    }
                }
            }
            else
            {
                if(mapAccount.containskey(lrdata.Account__c))
                {
                    Account acc=mapAccount.get(lrdata.Account__c);
                    
                    string Agency=lrdata.Agency__c+'_Agency__C';
                    acc.put(Agency,false);
                    // WithdrawnAccountlist.add(acc);
                }
                else
                {
                    Account acc=new Account();
                    acc.Id=lrdata.Account__c;
                    string Agency=lrdata.Agency__c+'_Agency__C';
                    acc.put(Agency,false);
                    WithdrawnAccountlist.add(acc);
                    mapAccount.put(lrdata.Account__c,acc);
                }
            }
            
            
        }
        
    }
    if(!LiveAccountlist.isEmpty())
    {
        try{
            update LiveAccountlist;
        }
        catch(Exception Ex)
        {
            System.debug('Error :- '+Ex.getLineNumber()+' on Line Number '+Ex.getLineNumber() );
        }
    }
    if(!WithdrawnAccountlist.isEmpty())
    {
        try{
            update WithdrawnAccountlist;
        }
        catch(Exception Ex)
        {
            System.debug('Error :- '+Ex.getLineNumber()+' on Line Number '+Ex.getLineNumber() );
        }
    }
    
    
}