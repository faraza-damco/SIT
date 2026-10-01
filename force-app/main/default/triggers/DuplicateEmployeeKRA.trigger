trigger DuplicateEmployeeKRA on Employee_KRA__c (before insert,before update) {
    
    Set<String> Users = new Set<String>();
    Set<String> Quarter = new Set<String>();
    Set<String> FYear = new Set<String>();
    For(Employee_KRA__c acc : trigger.new)
    {
        Users.add(acc.ownerId);
        Quarter.add(acc.Quarter__c);
        FYear.add(acc.Financial_Year__c);
    }
  
    if(trigger.IsInsert)
    {
        if(Users.size() > 0 )
        {
            List<Employee_KRA__c> lstAccount = [select id,OwnerId ,Quarter__c,Financial_Year__c from Employee_KRA__c where ownerId in :Users and Quarter__c in: Quarter and Financial_Year__c in :FYear ];
            
            Map<String ,Employee_KRA__c> mapNameWiseAccount = new Map<String,Employee_KRA__c>();
            For(Employee_KRA__c acc: lstAccount)
            {
                mapNameWiseAccount.put(acc.OwnerId+'-'+acc.Quarter__c+'-'+acc.Financial_Year__c ,acc);
            }
            
            For(Employee_KRA__c acc : trigger.new)
            {
                if(mapNameWiseAccount.containsKey(acc.OwnerId+'-'+acc.Quarter__c+'-'+acc.Financial_Year__c))
                {
                    acc.Name.addError('KRA already Exist ');
                }
            }
            
        }
    }
}