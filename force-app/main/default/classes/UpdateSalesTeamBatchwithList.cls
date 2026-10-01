global class UpdateSalesTeamBatchwithList implements Database.Batchable<sObject>{
      set<id> IdMSMap=new set<Id>();
    string objectname='';
    global UpdateSalesTeamBatchwithList(set<id> IdMSMapobj,string objname) {
        IdMSMap = IdMSMapobj;
        objectname=objname;
    }
    global Database.QueryLocator  start(Database.BatchableContext bc)
    {
        system.debug('IdMSMap '+IdMSMap.size());
          String query = 'SELECT ID, ownerid ' +
                ' FROM  ' +objectname +
                ' WHERE Id in : IdMSMap' ;
               
      return Database.getQueryLocator(query);
        
       
    }
    global  void Execute(Database.BatchableContext bc, List<sObject> listdata)
    { 
        List<sobject> updateall=new List<sobject>();
        system.debug('listdata '+listdata);
        For(sObject MS:listdata)
        {
            Map<string,string> SalesTeamData=new Map<string,string>();
            string ownerid=(String) MS.get('OwnerId');
            SalesTeamData=UpdateSalesTeam.Mtd_UpdateSalesTeam(ownerid);
            
            
            if(SalesTeamData.get('TeamMember')!='')
            {
                MS.put('Team_Member__c',SalesTeamData.get('TeamMember')) ;
            }
            else
            {
                MS.put('Team_Member__c',null) ;           
            }
            
            if(SalesTeamData.get('TeamManager')!='')
            {
                MS.Put('Team_Manager__c',SalesTeamData.get('TeamManager'));
                System.debug('TeamManager from Trigger'+SalesTeamData.get('TeamManager'));
                
            }
            else
            {
                MS.Put('Team_Manager__c',null);
            }
            if(SalesTeamData.get('TeamLeader')!='')
            {
                MS.put('Team_Leader__c',SalesTeamData.get('TeamLeader'));
                System.debug('TeamLeader from Trigger'+SalesTeamData.get('TeamLeader'));
                
            }else
            {
                MS.put('Team_Leader__c',null);
            }
            if(SalesTeamData.get('LocationHead')!='')
            {
                MS.put('Location_Head__c',SalesTeamData.get('LocationHead'));
                System.debug('LocationHead from Trigger'+SalesTeamData.get('LocationHead'));
                
            }else
            {
                MS.put('Location_Head__c',null);
            }
            updateall.add(MS);
        }
        update updateall;
    }
    global  void finish(Database.BatchableContext bv)
    {
        
    }
}