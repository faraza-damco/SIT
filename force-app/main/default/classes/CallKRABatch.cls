public  class CallKRABatch {
    private final Employee_KRA__c Employee_KRA;
    public   CallKRABatch(ApexPages.StandardController stdController)
    {
        Employee_KRA= (Employee_KRA__c)stdController.getRecord();
        
    }
    public  void CalculateKra() {
        //BatchCalculateKRA M=new BatchCalculateKRA();
        //database.executeBatch(M);
    }
    
    
}