public class ICRA_DatealighnmentHelper {
    public static List<Opportunity> UpdateDate(Map<id,Opportunity> Parents,Map<id,List<Opportunity>> Chields, Date SmallestDate )
    {
        List<Opportunity> UpdateAlighnedOpp=new  List<Opportunity> ();
        List<Opportunity> chldrcrds=new List<Opportunity>();
        for(Id opid : Parents.keyset()){
            if(Chields.get(opid)==null)
            {
                System.debug('Parent--'+opid+'----do not have any chield record Please check ');
                break;
            }
            else
            {
                List<Opportunity> childopps = Chields.get(opid);
                System.debug('Child Record '+childopps.size());
                for(Opportunity oppChild : childopps){
                    System.debug('Child Record Name '+oppChild.Name);
                }
                
            }
            System.debug('Parent Record Name'+Parents.get(opid).Name);
            System.debug('Parent Record '+Parents.get(opid));
            System.debug('SmallestDate--initial '+SmallestDate);
            //For BLR 
            if(Parents.get(opid).RecordType.Name =='Surveillance' && Parents.get(opid).Opportunity_Batch_Process__c == 'BLR-Date-Align'  ){ //&& Parents.get(opid).Skip_Date_Alignment__c == false
                Date tempdate = Date.newInstance(Parents.get(opid).Billing_End_Date__c.year(), SmallestDate.month(),SmallestDate.day()); 
                System.debug('entered in first loop  BLR-Date-Align ');
                System.debug('tempdate--initial '+tempdate);
                if(Parents.get(opid).Change_in_start_Date__c == false ){
                    //01/09/2021 - 28-02-2022
                    system.debug('');
                    if( Parents.get(opid).Billing_End_Date__c < tempdate){ // 28-02-2022 < 31- 03-2022 tempdate = end 
                        system.debug(Parents.get(opid).name +' Yes temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            Parents.get(opid).Billing_End_Date__c = tempdate ; //31- 03-2021
                        }else{
                            system.debug('tempdate.addYears(-1) '+tempdate.addYears(-1));
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                            system.debug(' Parents.get(opid).Billing_End_Date__c  '+ Parents.get(opid).Billing_End_Date__c );
                        } 
                        
                    }
                    else{
                        system.debug(Parents.get(opid).name + ' No, temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            // Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            system.debug('Day < 365');
                            if(tempdate < Parents.get(opid).Billing_Start_Date__c){
                                system.debug('entered in if loop at 47 line');
                                Parents.get(opid).Billing_End_Date__c =tempdate.addYears(1); 
                            }else{Parents.get(opid).Billing_End_Date__c =tempdate; 
                                system.debug('entered in else loop at 50 line');
                                 }
                            
                        }
                        else{
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                             system.debug('entered in else loop at 56 line');
                        }
                        system.debug(' Parents.get(opid).Billing_End_Date__c  else part'+ Parents.get(opid).Billing_End_Date__c );
                    }
                }
                
                Parents.get(opid).CloseDate =  Parents.get(opid).Billing_Start_Date__c;
                Parents.get(opid).Amount_To_Be_Billed__c = feeAmountCalculation( Parents.get(opid).Billing_Start_Date__c, Parents.get(opid).Billing_End_Date__c, Parents.get(opid).ASF_Final_Amount__c);
                System.debug('@@@@@@@@'+Parents.get(opid));
                Parents.get(opid).Is_Date_Alignment_Done__c = true;
                Parents.get(opid).Edited_By_Batch_UI__c = 'Edited By Batch';
                System.debug('===== Edited_By_Batch_UI__c ===='+Parents.get(opid).Edited_By_Batch_UI__c);
                tempdate=Parents.get(opid).Billing_End_Date__c;
                
                
                // For Chield Records
                // 
                if(Chields.get(opid)!=null)
                {
                    System.debug('Chields.get(opid) '+Chields.get(opid));
                    System.debug('tempdate for chield '+tempdate);
                    chldrcrds=UpdateonChieldRecoreds(Chields.get(opid),tempdate);
                }
                
                if(Parents.get(opid).Skip_Date_Alignment__c != true){
                    UpdateAlighnedOpp.add(Parents.get(opid)); 
                }
                
                if(chldrcrds.Size()>0)
                {
                    UpdateAlighnedOpp.addAll(chldrcrds);
                }
                 System.debug('BLR Logic Ended here');
            }//For CP same as BLR
            else if(Parents.get(opid).RecordType.Name =='Surveillance' && Parents.get(opid).Opportunity_Batch_Process__c == 'BLR-CP-Align'  ){ //&& Parents.get(opid).Skip_Date_Alignment__c == false
                Date tempdate = Date.newInstance(Parents.get(opid).Billing_End_Date__c.year(), SmallestDate.month(),SmallestDate.day()); 
                System.debug('entered in first loop BLR-CP-Align');
                System.debug('tempdate--initial '+tempdate);
                if(Parents.get(opid).Change_in_start_Date__c == false ){
                    //01/09/2021 - 28-02-2022
                    system.debug('');
                    if( Parents.get(opid).Billing_End_Date__c < tempdate){ // 28-02-2022 < 31- 03-2022 tempdate = end 
                        system.debug(Parents.get(opid).name +' Yes temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            Parents.get(opid).Billing_End_Date__c = tempdate ; //31- 03-2021
                        }else{
                            system.debug('tempdate.addYears(-1) '+tempdate.addYears(-1));
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                            system.debug(' Parents.get(opid).Billing_End_Date__c  '+ Parents.get(opid).Billing_End_Date__c );
                        } 
                        
                    }
                    else{
                        system.debug(Parents.get(opid).name + ' No, temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            // Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            if(tempdate < Parents.get(opid).Billing_Start_Date__c){
                                Parents.get(opid).Billing_End_Date__c =tempdate.addYears(1); 
                            }else{Parents.get(opid).Billing_End_Date__c =tempdate; }
                            
                        }
                        else{
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                        }
                        system.debug(' Parents.get(opid).Billing_End_Date__c  else part'+ Parents.get(opid).Billing_End_Date__c );
                    }
                }
                
                Parents.get(opid).CloseDate =  Parents.get(opid).Billing_Start_Date__c;
                Parents.get(opid).Amount_To_Be_Billed__c = feeAmountCalculation( Parents.get(opid).Billing_Start_Date__c, Parents.get(opid).Billing_End_Date__c, Parents.get(opid).ASF_Final_Amount__c);
                System.debug('@@@@@@@@'+Parents.get(opid));
                Parents.get(opid).Is_Date_Alignment_Done__c = true;
                Parents.get(opid).Edited_By_Batch_UI__c = 'Edited By Batch';
                System.debug('===== Edited_By_Batch_UI__c ===='+Parents.get(opid).Edited_By_Batch_UI__c);
                tempdate=Parents.get(opid).Billing_End_Date__c;
                
                
                // For Chield Records
                // 
                if(Chields.get(opid)!=null)
                {
                    System.debug('Chields.get(opid) '+Chields.get(opid));
                    System.debug('tempdate for chield '+tempdate);
                    chldrcrds=UpdateonChieldRecoreds(Chields.get(opid),tempdate);
                }
                
                if(Parents.get(opid).Skip_Date_Alignment__c != true){
                    UpdateAlighnedOpp.add(Parents.get(opid)); 
                }
                
                if(chldrcrds.Size()>0)
                {
                    UpdateAlighnedOpp.addAll(chldrcrds);
                }
                  System.debug('BLR-CP-Align Ended');
                
            }
            // For BLR-STB-Align
            /*else if(Parents.get(opid).RecordType.Name =='Surveillance' && Parents.get(opid).Opportunity_Batch_Process__c == 'BLR-STB-Align'  ){ //&& Parents.get(opid).Skip_Date_Alignment__c == false
                Date tempdate = Date.newInstance(Parents.get(opid).Billing_End_Date__c.year(), SmallestDate.month(),SmallestDate.day()); 
                System.debug('entered in first loop BLR-STB-Align');
                System.debug('tempdate--initial '+tempdate);
                if(Parents.get(opid).Change_in_start_Date__c == false ){
                    //01/09/2021 - 28-02-2022
                    system.debug('');
                    if( Parents.get(opid).Billing_End_Date__c < tempdate){ // 28-02-2022 < 31- 03-2022 tempdate = end 
                        system.debug(Parents.get(opid).name +' Yes temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            Parents.get(opid).Billing_End_Date__c = tempdate ; //31- 03-2021
                        }else{
                            system.debug('tempdate.addYears(-1) '+tempdate.addYears(-1));
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                            system.debug(' Parents.get(opid).Billing_End_Date__c  '+ Parents.get(opid).Billing_End_Date__c );
                        } 
                        
                    }
                    else{
                        system.debug(Parents.get(opid).name + ' No, temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            // Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            if(tempdate < Parents.get(opid).Billing_Start_Date__c){
                                Parents.get(opid).Billing_End_Date__c =tempdate.addYears(1); 
                            }else{Parents.get(opid).Billing_End_Date__c =tempdate; }
                            
                        }
                        else{
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                        }
                        system.debug(' Parents.get(opid).Billing_End_Date__c  else part'+ Parents.get(opid).Billing_End_Date__c );
                    }
                }
                
                Parents.get(opid).CloseDate =  Parents.get(opid).Billing_Start_Date__c;
                Parents.get(opid).Amount_To_Be_Billed__c = feeAmountCalculation( Parents.get(opid).Billing_Start_Date__c, Parents.get(opid).Billing_End_Date__c, Parents.get(opid).ASF_Final_Amount__c);
                System.debug('@@@@@@@@'+Parents.get(opid));
                Parents.get(opid).Is_Date_Alignment_Done__c = true;
                Parents.get(opid).Edited_By_Batch_UI__c = 'Edited By Batch';
                System.debug('===== Edited_By_Batch_UI__c ===='+Parents.get(opid).Edited_By_Batch_UI__c);
                tempdate=Parents.get(opid).Billing_End_Date__c;
                
                
                // For Chield Records
                // 
                if(Chields.get(opid)!=null)
                {
                    System.debug('Chields.get(opid) '+Chields.get(opid));
                    System.debug('tempdate for chield '+tempdate);
                    chldrcrds=UpdateonChieldRecoreds(Chields.get(opid),tempdate);
                }
                
                if(Parents.get(opid).Skip_Date_Alignment__c != true){
                    UpdateAlighnedOpp.add(Parents.get(opid)); 
                }
                
                if(chldrcrds.Size()>0)
                {
                    UpdateAlighnedOpp.addAll(chldrcrds);
                }
                 System.debug('BLR-STB-Align Ended ');
                
            } */
            // BLR-Other-Align
            else if(Parents.get(opid).RecordType.Name =='Surveillance' && Parents.get(opid).Opportunity_Batch_Process__c == 'BLR-Other-Align'  ){ //&& Parents.get(opid).Skip_Date_Alignment__c == false
                Date tempdate = Date.newInstance(Parents.get(opid).Billing_End_Date__c.year(), SmallestDate.month(),SmallestDate.day()); 
                System.debug('entered in first loop BLR-Other-Align');
                System.debug('tempdate--initial '+tempdate);
                if(Parents.get(opid).Change_in_start_Date__c == false ){
                    //01/09/2021 - 28-02-2022
                    system.debug('');
                    if( Parents.get(opid).Billing_End_Date__c < tempdate){ // 28-02-2022 < 31- 03-2022 tempdate = end 
                        system.debug(Parents.get(opid).name +' Yes temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            Parents.get(opid).Billing_End_Date__c = tempdate ; //31- 03-2021
                        }else{
                            system.debug('tempdate.addYears(-1) '+tempdate.addYears(-1));
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                            system.debug(' Parents.get(opid).Billing_End_Date__c  '+ Parents.get(opid).Billing_End_Date__c );
                        } 
                        
                    }
                    else{
                        system.debug('Parent End Date '+Parents.get(opid).Billing_End_Date__c);
                        system.debug('Temp date '+tempdate);
                        system.debug(Parents.get(opid).name + ' No, temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        system.debug('No days between== '+days);
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            // Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            if(tempdate < Parents.get(opid).Billing_Start_Date__c){
                                Parents.get(opid).Billing_End_Date__c =tempdate.addYears(1); 
                            }else{Parents.get(opid).Billing_End_Date__c =tempdate; }
                            
                        }
                        else{
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                        }
                        system.debug(' Parents.get(opid).Billing_End_Date__c  else part'+ Parents.get(opid).Billing_End_Date__c );
                    }
                }
                
                Parents.get(opid).CloseDate =  Parents.get(opid).Billing_Start_Date__c;
                Parents.get(opid).Amount_To_Be_Billed__c = feeAmountCalculation( Parents.get(opid).Billing_Start_Date__c, Parents.get(opid).Billing_End_Date__c, Parents.get(opid).ASF_Final_Amount__c);
                System.debug('@@@@@@@@'+Parents.get(opid));
                Parents.get(opid).Is_Date_Alignment_Done__c = true;
                Parents.get(opid).Edited_By_Batch_UI__c = 'Edited By Batch';
                System.debug('===== Edited_By_Batch_UI__c ===='+Parents.get(opid).Edited_By_Batch_UI__c);
                tempdate=Parents.get(opid).Billing_End_Date__c;
                
                
                // For Chield Records
                // 
                if(Chields.get(opid)!=null)
                {
                    System.debug('Chields.get(opid) '+Chields.get(opid));
                    System.debug('tempdate for chield '+tempdate);
                    chldrcrds=UpdateonChieldRecoreds(Chields.get(opid),tempdate);
                }
                
                if(Parents.get(opid).Skip_Date_Alignment__c != true){
                    UpdateAlighnedOpp.add(Parents.get(opid)); 
                }
                
                if(chldrcrds.Size()>0)
                {
                    UpdateAlighnedOpp.addAll(chldrcrds);
                }
                System.debug('BLR-Other-Align Ended' );
              
            }
            else if(Parents.get(opid).RecordType.Name =='Surveillance' && (Parents.get(opid).Opportunity_Batch_Process__c == 'Other' || Parents.get(opid).Opportunity_Batch_Process__c == 'MF-YF' || Parents.get(opid).Opportunity_Batch_Process__c == 'MM-Date-FY')  ){ //&& Parents.get(opid).Skip_Date_Alignment__c == false
                Date tempdate = Date.newInstance(Parents.get(opid).Billing_End_Date__c.year(), 03,31); 
                 System.debug('Intedred into FY Data');
                System.debug('tempdate--initial '+tempdate);
                if(Parents.get(opid).Change_in_start_Date__c == false && Parents.get(opid).Parent_RecordType__c=='New Business'){
                    //01/09/2021 - 28-02-2022
                    system.debug('');
                    if( Parents.get(opid).Billing_End_Date__c < tempdate){ // 10-02-2023 < 31- 03-2023 tempdate = end 
                        system.debug(Parents.get(opid).name +' Yes temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            Parents.get(opid).Billing_End_Date__c = tempdate ; //31- 03-2021
                        }else{
                            system.debug('tempdate.addYears(-1) '+tempdate.addYears(-1));
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                            system.debug(' Parents.get(opid).Billing_End_Date__c  '+ Parents.get(opid).Billing_End_Date__c );
                        } 
                        
                    }
                    else{
                        system.debug(Parents.get(opid).name + ' No, temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            //Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            Parents.get(opid).Billing_End_Date__c =tempdate; 
                        }else{
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                        }
                        system.debug(' Parents.get(opid).Billing_End_Date__c  else part'+ Parents.get(opid).Billing_End_Date__c );
                    }
                }
                // Else part for survillance parent End date change.
                else
                {
                    if( Parents.get(opid).Billing_End_Date__c < tempdate){ // 10-02-2023 < 31- 03-2023 tempdate = end 
                        system.debug(Parents.get(opid).name +' Yes temp date is grater than billing end date for parent surv');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days <= 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            Parents.get(opid).Billing_End_Date__c = tempdate ; //31- 03-2021
                        }else{
                            system.debug('tempdate.addYears(-1) '+tempdate.addYears(-1));
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                            system.debug(' Parents.get(opid).Billing_End_Date__c  '+ Parents.get(opid).Billing_End_Date__c );
                        } 
                        
                    }
                    
                    else{
                        system.debug(Parents.get(opid).name + ' No, temp date is grater than billing end date for parent');
                        Integer days = Parents.get(opid).Billing_Start_Date__c.daysBetween(tempdate); 
                        if(days <= 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            //Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            if(days>=0)
                            {
                                Parents.get(opid).Billing_End_Date__c =tempdate; 
                            }
                            else
                            {
                                Parents.get(opid).Billing_End_Date__c = tempdate.addYears(1); 
                            }
                            
                        }else{
                            Parents.get(opid).Billing_End_Date__c = tempdate.addYears(-1);
                        }
                        system.debug(' Parents.get(opid).Billing_End_Date__c  else part'+ Parents.get(opid).Billing_End_Date__c );
                    }
                }
                
                Parents.get(opid).CloseDate =  Parents.get(opid).Billing_Start_Date__c;
                Parents.get(opid).Amount_To_Be_Billed__c = feeAmountCalculation( Parents.get(opid).Billing_Start_Date__c, Parents.get(opid).Billing_End_Date__c, Parents.get(opid).ASF_Final_Amount__c);
                System.debug('@@@@@@@@'+Parents.get(opid));
                Parents.get(opid).Is_Date_Alignment_Done__c = true;
                //Parents.get(opid).Start_Change__c  = false;
                Parents.get(opid).Edited_By_Batch_UI__c = 'Edited By Batch';
                System.debug('===== Edited_By_Batch_UI__c ===='+Parents.get(opid).Edited_By_Batch_UI__c);
                if(Parents.get(opid).Change_in_start_Date__c == false && Parents.get(opid).Parent_RecordType__c=='New Business'){
                    tempdate=Parents.get(opid).Billing_End_Date__c;
                }
                else
                {
                    tempdate=Parents.get(opid).Billing_End_Date__c;
                }
                system.debug(' 163 Parents.get(opid).Parent_RecordType__c '+Parents.get(opid).Parent_RecordType__c);
                
                // For Chield Records
                // 
                if(Chields.get(opid)!=null)
                {
                    System.debug('Chields.get(opid) '+Chields.get(opid));
                    System.debug('tempdate for chield '+tempdate);
                    chldrcrds=UpdateonChieldRecoreds(Chields.get(opid),tempdate);
                }
                
                
                UpdateAlighnedOpp.add(Parents.get(opid));
                if(chldrcrds.Size()>0)
                {
                    UpdateAlighnedOpp.addAll(chldrcrds);
                }
                
            }
            
        }
        
        return UpdateAlighnedOpp;
    }
    public static List<Opportunity> UpdateonChieldRecoreds(List<Opportunity>  chieldRecords, Date ParentEndDate)
    {
        List<Opportunity> childRecordswithoutSkipAlign = new List<Opportunity>();
        Integer I=0;
        for(Opportunity chldopps:chieldRecords)
        {
             System.debug('Chield Record Name'+chldopps.name);
            System.debug('Parent End Date '+ParentEndDate);
            if((chldopps.Opportunity_Batch_Process__c == 'Other' || chldopps.Opportunity_Batch_Process__c == 'MF-YF' || chldopps.Opportunity_Batch_Process__c == 'MM-Date-FY') && chldopps.Parent_RecordType__c=='Surveillance' && I==0) 
            {
                I=1;
                System.debug('Parent End Date first Chield '+chldopps.Name);
                System.debug('hldopps.Parent_Opportunity__r.Billing_End_date__c '+chldopps.Parent_Opportunity__r.Billing_End_date__c);
                if(chldopps.Parent_Opportunity__r.Billing_End_date__c<ParentEndDate)
                {
                    if(chldopps.Start_Change__c == false){
                        chldopps.Billing_Start_Date__c = ParentEndDate.addDays(1);
                   		 chldopps.Billing_End_Date__c = ParentEndDate.addyears(1);
                    }
                    else
                    {
                       
                         Integer days =chldopps.Billing_Start_Date__c.daysBetween(ParentEndDate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            //Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            if(days>=0  )
                            {
                                chldopps.Billing_End_Date__c =ParentEndDate; 
                            }
                            else
                            {
                                chldopps.Billing_End_Date__c = ParentEndDate.addYears(1); 
                            }
                            
                        }else{
                            chldopps.Billing_End_Date__c = ParentEndDate.addYears(-1);
                        } 
                    }
                    //chldopps.Billing_Start_Date__c = chldopps.Parent_Opportunity__r.Billing_End_Date__c.addDays(1);
                    ///chldopps.Billing_End_Date__c = ParentEndDate;
                    // 4/1/2022--31/3/2023
                    // 4/1/2023--31/3/2024
                   
                    System.debug('Parent End Date first Chield--Billing_Start_Date__c '+ chldopps.Billing_Start_Date__c);
                    System.debug('Parent End Date first Chield--Billing_End_Date__c '+ chldopps.Billing_End_Date__c);
                }
                else
                {
                    if(chldopps.Start_Change__c == false){
                     //   chldopps.Billing_Start_Date__c = chldopps.Parent_Opportunity__r.Billing_End_date__c.addDays(1);
                     chldopps.Billing_Start_Date__c = ParentEndDate.addDays(1);
                    chldopps.Billing_End_Date__c = ParentEndDate.addyears(1);
                    }
                    else
                    {
                         Integer days =chldopps.Billing_Start_Date__c.daysBetween(ParentEndDate); 
                        if(days < 365 ){ // 01/09/2023 - 31- 03-2022 (-1)
                            //Parents.get(opid).Billing_End_Date__c =Parents.get(opid).Billing_Start_Date__c.addYears(1).addDays(-1);  //31- 03-2021
                            if(days>=0  )
                            {
                                chldopps.Billing_End_Date__c =ParentEndDate; 
                            }
                            else
                            {
                                chldopps.Billing_End_Date__c = ParentEndDate.addYears(1); 
                            }
                            
                        }else{
                            chldopps.Billing_End_Date__c = ParentEndDate.addYears(-1);
                        }
                    }
                    // chldopps.Billing_Start_Date__c = chldopps.Parent_Opportunity__r.Billing_End_date__c.addDays(1);
                    
                    
                    System.debug('Parent End Date first Chield--Billing_Start_Date__c else'+ chldopps.Billing_Start_Date__c);
                    System.debug('Parent End Date first Chield--Billing_End_Date__c else'+ chldopps.Billing_End_Date__c);
                    
                }
                
            }
            else
            {
                
                if(chldopps.Start_Change__c == false){
                    if(chldopps.Parent_Opportunity__r.skip_date_Alignment__c == true && I==0 && chldopps.Parent_Opportunity__r.RecordType.Name == 'Surveillance'){
                        chldopps.Billing_End_Date__c = ParentEndDate.addDays(1).addYears(1).addDays(-1);
                         system.debug('child opp start date '+chldopps.Billing_Start_Date__c);
                         system.debug('child opp end date '+chldopps.Billing_End_Date__c);
                        I = 1;
                    }
                    else{
                         chldopps.Billing_Start_Date__c = ParentEndDate.addDays(1);
                    chldopps.Billing_End_Date__c = chldopps.Billing_Start_Date__c.addYears(1).addDays(-1);
                    system.debug('change is false start date '+chldopps.Billing_Start_Date__c);
                    system.debug('change is false end date '+chldopps.Billing_End_Date__c);
                    }
                   
                }
                // chldopps.Billing_Start_Date__c = ParentEndDate.addDays(1);
                else{
                    Date  tempstartdate = ParentEndDate.addDays(1);
                  
                    chldopps.Billing_End_Date__c = tempstartdate.addYears(1).addDays(-1);
                    system.debug('in else part end date '+chldopps.Billing_End_Date__c);
                    system.debug('child opp start date'+chldopps.Billing_Start_Date__c);
                }
                //chldopps.Billing_End_Date__c = chldopps.Billing_Start_Date__c.addYears(1).addDays(-1);
                
            }
            
            ParentEndDate=chldopps.Billing_End_Date__c;
            system.debug('ParentEndDate at 496 line'+ParentEndDate);
            chldopps.CloseDate = chldopps.Billing_Start_Date__c;
            chldopps.Amount_To_Be_Billed__c = feeAmountCalculation(chldopps.Billing_Start_Date__c, chldopps.Billing_End_Date__c, chldopps.ASF_Final_Amount__c);
            system.debug('*** Calculation for Amount to be billed**** '+feeAmountCalculation(chldopps.Billing_Start_Date__c, chldopps.Billing_End_Date__c, chldopps.ASF_Final_Amount__c));
            System.debug('@@@@@@@@'+chldopps);
            System.debug('@@@@@@@@ Chld Name'+chldopps.name);
            chldopps.Is_Date_Alignment_Done__c = true;
            //chldopps.Start_Change__c = false;
            chldopps.Edited_By_Batch_UI__c = 'Edited By Batch';
            System.debug('====  Is_Date_Alignment_Done__c  for all chields'+chldopps.Is_Date_Alignment_Done__c);
            
            if(chldopps.Skip_Date_Alignment__c != true){
                childRecordswithoutSkipAlign.add(chldopps);
            }
        }
        return childRecordswithoutSkipAlign;
        // return chieldRecords;
    }
    public static Decimal feeAmountCalculation(Date startDate, Date endDate, Decimal amount){  
        system.debug('=====Entered in the Fee calculation====');
        system.debug('***** startDate ******* '+startDate);
        system.debug('***** endDate ******* '+endDate);
        system.debug('***** amount ******* '+amount);
        integer numberOfDays = startDate.daysBetween(endDate)+1;
        Integer yearDays =0;
        Decimal perDay = 0;
        Decimal totalAmount = 0;
        
        if(Date.isLeapYear(startDate.year())){
            yearDays = 366; 
            perday = amount.divide(366,2);
        }else{
            yearDays = 365;
            perday = amount.divide(365,2);
        }
        
        
        if(numberOfDays >= 365){
            totalAmount = amount;
        }else{
            totalAmount = (perDay * numberOfDays).round(System.RoundingMode.CEILING);
        }
        system.debug('***** totalAmount ****'+totalAmount);
        return totalAmount;  
    } 
    /*public static Opportunity OtherDateAlignment(Opportunity OtherOpp,Date ParentEndDate)
    {
        //Parent--29-03-2022
        Date tempdate = Date.newInstance(ParentEndDate.year(), 03,31); //31-03-2022
        //Billing_End_Date__c--29/03/2023
        if( OtherOpp.Billing_End_Date__c < tempdate){
            OtherOpp.Billing_End_Date__c = tempdate;
            OtherOpp.Billing_Start_Date__c = OtherOpp.Billing_End_Date__c.addDays(1); 
        }else{
            OtherOpp.Billing_End_Date__c = tempdate;//31/03/2022
            OtherOpp.Billing_Start_Date__c = ParentEndDate.addDays(1);//30/03/2022
        }
        
        
        return OtherOpp;
    } */
}