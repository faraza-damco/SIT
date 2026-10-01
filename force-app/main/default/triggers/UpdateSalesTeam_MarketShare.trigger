trigger UpdateSalesTeam_MarketShare on Market_Share__c (before insert,before update) {

   if((system.Label.Update_Sales_Team_of_Market_share=='Active') && (Trigger.isInsert || Trigger.isUpdate)){
        
        For(Market_Share__c MS: Trigger.New)
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
            
            
            
        }
    }
}