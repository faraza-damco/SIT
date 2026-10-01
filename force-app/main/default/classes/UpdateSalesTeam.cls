public class UpdateSalesTeam {
    public  static Map<string,string> Mtd_UpdateSalesTeam(string ids)
    {
        Map<string,string> SalesTeamData=new Map<string,string>();
        SalesTeamData.put('TeamMember','');
        SalesTeamData.put('TeamManager','');
        SalesTeamData.put('TeamLeader','');
        SalesTeamData.put('LocationHead','');
        
        user[] TeamMember;
        user[] TeamManager;
        user[] TeamLeader;
        user[] LocationHead;
     //   user[] CommercialHead;
        
        
        string UserRole='';
        TeamMember =[select id,name,userroleid,userrole.name, managerid,manager.name from user where id=:ids limit 1];
        system.debug('TeamMember '+TeamMember);
        if(TeamMember[0].userrole.name!=null)
        {
            UserRole=TeamMember[0].userrole.name;
       
        }
       
            
        if(UserRole.contains('Member'))
        {
          
             SalesTeamData.put('TeamMember',TeamMember[0].Id);
            if(TeamMember.Size()>0)
            {
                if(TeamMember[0].managerid !=null){
                    TeamManager=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Manager%' limit 1];
                    if(TeamManager.Size()>0)
                    {
                        SalesTeamData.put('TeamManager',TeamManager[0].Id);
                    }
                    
                    System.debug('User TeamManager '+TeamManager);
                }
            }  
            if(TeamManager.Size()>0 )
            {
                system.debug('TeamLeader section');
                if(TeamManager[0].managerid !=null){
                    TeamLeader=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamManager[0].managerid and userrole.name like '%Leader%' limit 1];
                    if(TeamLeader.Size()>0)
                    {
                        SalesTeamData.put('TeamLeader',TeamLeader[0].Id);
                    }
                    system.debug('TeamLeader '+TeamLeader);
                }
            }else
            {
                system.debug('TeamManager '+TeamManager);
                if(TeamMember[0].managerid !=null){
                    TeamLeader=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Leader%' limit 1];
                    if(TeamLeader.Size()>0)
                    {
                        SalesTeamData.put('TeamLeader',TeamLeader[0].Id);
                    }
                    system.debug('direct TeamLeader  '+TeamLeader);
                } 
            }
            if(TeamLeader.Size()>0 )
            {
                if(TeamLeader[0].managerid !=null){
                    LocationHead=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamLeader[0].managerid and userrole.name like '%Location%'   limit 1];
                    if(LocationHead.Size()>0)
                    {
                        SalesTeamData.put('LocationHead',LocationHead[0].Id);
                    }
                    system.debug('LocationHead '+LocationHead);   
                }
            }
            else
            {
                LocationHead=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Location%'   limit 1];
                if(LocationHead.Size()>0)
                {
                    SalesTeamData.put('LocationHead',LocationHead[0].Id);
                }
                system.debug('dirct LocationHead '+LocationHead);   
                
            }
            
        }
        else if (UserRole.contains('Manager'))
        {
            SalesTeamData.put('TeamMember','');
            SalesTeamData.put('TeamManager',TeamMember[0].Id);
            if(TeamMember.Size()>0 )
            {
                
                
                if(TeamMember[0].managerid !=null){
                    TeamLeader=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Leader%' limit 1];
                    if(TeamLeader.Size()>0)
                    {
                        SalesTeamData.put('TeamLeader',TeamLeader[0].Id);
                    }
                    system.debug('TeamLeader '+TeamLeader);
                }
            }
            if(TeamLeader.Size()>0 )
            {
                if(TeamLeader[0].managerid !=null){
                    LocationHead=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamLeader[0].managerid and userrole.name like '%Location%'   limit 1];
                    if(LocationHead.Size()>0)
                    {
                        SalesTeamData.put('LocationHead',LocationHead[0].Id);
                    }
                    
                    system.debug('LocationHead '+LocationHead);   
                }
            }
            else
            {
                LocationHead=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Location%'   limit 1];
                if(LocationHead.Size()>0)
                {
                    SalesTeamData.put('LocationHead',LocationHead[0].Id);
                }
                system.debug('dirct LocationHead '+LocationHead);   
                
            }
            
        }
        else if (UserRole.contains('Leader'))
        {
            SalesTeamData.put('TeamManager','');
            SalesTeamData.put('TeamLeader',TeamMember[0].Id);
            SalesTeamData.put('TeamMember','');
            LocationHead=[select id,name,userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Location%'   limit 1];
            if(LocationHead.Size()>0)
            {
                SalesTeamData.put('LocationHead',LocationHead[0].Id);
            }
            system.debug('dirct LocationHead '+LocationHead);   
            
        }
        else if (UserRole.contains('Location'))
        {
             SalesTeamData.put('LocationHead',TeamMember[0].Id);
           /* SalesTeamData.put('TeamManager','');
            SalesTeamData.put('TeamMember','');
            SalesTeamData.put('TeamLeader','');
            SalesTeamData.put('LocationHead',TeamMember[0].Id);
            CommercialHead=[select id,name, userroleid,userrole.name, managerid,manager.name,manager.managerid,manager.manager.name from user where id=:TeamMember[0].managerid and userrole.name like '%Commercial%'   limit 1];
            if(CommercialHead.Size()>0)
            {
                SalesTeamData.put('CommercialHead',CommercialHead[0].Id);
            }
            system.debug('CommercialHead '+CommercialHead); 
            */
        }
        System.debug('SalesTeamData '+SalesTeamData);
        return SalesTeamData;
    }
}