trigger MaintenanceRequest on Case (after update) {
    if(Trigger.isUpdate && Trigger.isAfter ) {
        Map<Id,Case> mapOfCases = new Map<Id,Case>();
        List<Case> listToInsert = new List<Case>();
        Equipment_Maintenance_Item__c [] eqMainItem   = [SELECT Maintenance_Request__c,Equipment__r.Maintenance_Cycle__c,Equipment__c,Name,Quantity__c  FROM Equipment_Maintenance_Item__c ];
        List <Equipment_Maintenance_Item__c> eqmSorted = new List<Equipment_Maintenance_Item__c>();

        for(Case mr : Trigger.new) {
            if (mr.Status == 'Closed' && (mr.Type == 'Repair' || mr.Type == 'Routine Maintenance')) {
                for (Equipment_Maintenance_Item__c e : eqMainItem){
                    if(e.Maintenance_Request__c == mr.Id){
                            eqmSorted.add(e);  
                     }
                }
                Case c = MaintenanceRequestHelper.prepareCase(mr,eqmSorted);
                listToInsert.add(c);
                mapOfCases.put(mr.Id, c);
                
            }
        }

        insert listToInsert;

        List <Equipment_Maintenance_Item__c> emiFinal = new List<Equipment_Maintenance_Item__c>();
        for(Case c : Trigger.new) {
            if (c.Status == 'Closed' && (c.Type == 'Repair' || c.Type == 'Routine Maintenance')) {
                
                Case newCase = mapOfCases.get(c.Id);
                List <Equipment_Maintenance_Item__c> emiAddItems =  MaintenanceRequestHelper.prepareItems(c.Id,newCase,eqmSorted);
                eqmSorted.clear();
                for(Equipment_Maintenance_Item__c e : emiAddItems) {
                    emiFinal.add(e);
                }
            }
        }
        
        insert emiFinal;
    
    }
}