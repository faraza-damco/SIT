trigger UpdateSalesTeam on Opportunity (after insert,after update) {
    List<Opportunity> mslist=new  List<Opportunity>();
    set<Id> mslst=new set<Id> ();
    //system.debug('Trigger.New Size '+Trigger.New.Size());
    
    if((system.Label.Update_Sales_Team_of_Opportunity=='Active') && (Trigger.isInsert || Trigger.isUpdate)){
        if(Trigger.New.Size()==1    )
        {
            if(RecursiveTriggerHandler.isFirstTime){
                RecursiveTriggerHandler.isFirstTime = false;
                set<Id> mslst=new set<Id> ();
                For(Opportunity MS: Trigger.New)
                {
                    //  System.debug('Trigger.oldmap.get(MS.id).owner '+Trigger.oldmap.get(MS.id).ownerId);
                    // System.debug('Trigger.newmap.get(MS.id).owner '+Trigger.newmap.get(MS.id).ownerId);
                    if(Trigger.isUpdate){
                        if(Trigger.oldmap!=null && Trigger.oldmap.get(MS.id).ownerId != Trigger.newmap.get(MS.id).ownerId )
                        {
                            mslst.add(MS.Id);
                        }
                    }else
                    {
                        mslst.add(MS.Id);
                    }
                    
                }
                system.debug('mslst '+mslst);
                For(Opportunity MS:[select id,ownerid from Opportunity where id in:mslst ])
                {
                    Map<string,string> SalesTeamData=new Map<string,string>();
                    SalesTeamData=UpdateSalesTeam.Mtd_UpdateSalesTeam(MS.ownerId);
                    
                    
                    if(SalesTeamData.get('TeamMember')!='')
                    {
                        MS.Team_Member__c=SalesTeamData.get('TeamMember') ;
                    }
                    else
                    {
                        MS.Team_Member__c=null;                
                    }
                    
                    if(SalesTeamData.get('TeamManager')!='')
                    {
                        System.debug('TeamManager from Trigger'+SalesTeamData.get('TeamManager'));
                        MS.Team_Manager__c=SalesTeamData.get('TeamManager');
                    }
                    else
                    {
                        MS.Team_Manager__c=null;
                    }
                    if(SalesTeamData.get('TeamLeader')!='')
                    {
                        System.debug('TeamLeader from Trigger'+SalesTeamData.get('TeamLeader'));
                        MS.Team_Leader__c=SalesTeamData.get('TeamLeader');
                    }else
                    {
                        MS.Team_Leader__c=null;
                    }
                    if(SalesTeamData.get('LocationHead')!='')
                    {
                        System.debug('LocationHead from Trigger'+SalesTeamData.get('LocationHead'));
                        MS.Location_Head__c=SalesTeamData.get('LocationHead');
                    }else
                    {
                        MS.Location_Head__c=null;
                    }
                    
                    mslist.add(MS);
                    
                }
                if(mslist.size()>0)
                {
                    update mslist;
                }
                
            }
        }
        else
        { 
            if(Trigger.isInsert)
            {
                if(RecursiveTriggerHandler.isFirstTime){
                    RecursiveTriggerHandler.isFirstTime = false;
                    set<id> IdMSMap=new set<Id>();
                    system.debug('Trigger.New from trigger '+Trigger.New.size());
                    For(Opportunity MS: Trigger.New)
                    {
                        
                        IdMSMap.add(MS.Id);
                        
                        
                    }
                    if(IdMSMap.size()>0)
                    {
                        UpdateSalesTeamBatchwithList obj=new UpdateSalesTeamBatchwithList(IdMSMap,'Opportunity');
                        Database.executeBatch(obj,50);
                    }
                }
            }
        }
    }
    
    
}