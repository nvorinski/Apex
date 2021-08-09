public class MaintenanceRequestHelper {

    public static Case prepareCase (Case emiCase, List<Equipment_Maintenance_Item__c> eqMainItem) {
        Case caseAdd = new Case();
        Decimal minCycle = 0;
        List<Equipment_Maintenance_Item__c> emiAdd = new List<Equipment_Maintenance_Item__c>();
        
        
        //find shortest maintence cycle if there is multiple equipment involved else put of the current equipment
        if(eqMainItem.size()>0){  
                if(eqMainItem.size()>1){
                    for(Integer i=0; i<eqMainItem.size(); i++) {
                        if(i==0){
                            minCycle= eqMainItem[i].Equipment__r.Maintenance_Cycle__c;
                        }else{
                            if(minCycle>eqMainItem[i].Equipment__r.Maintenance_Cycle__c) {
                                minCycle= eqMainItem[i].Equipment__r.Maintenance_Cycle__c;
                            }
                        }

                    }
                }else{
                    minCycle = eqMainItem[0].Equipment__r.Maintenance_Cycle__c;
                }
        }
   
        Integer mainCycle = minCycle.intValue();
        caseAdd.Vehicle__c = emiCase.Vehicle__c;
        caseAdd.Type = 'Routine Maintenance';
        caseAdd.Subject = emiCase.Subject + ' (Auto Renewed)';
        caseAdd.Date_Reported__c = Date.today();
        caseAdd.Date_Due__c = Date.today() + mainCycle;
        caseAdd.Status = 'New';
        caseAdd.AccountId = emiCase.AccountId;
        caseAdd.AssetId = emiCase.AssetId;
        caseAdd.Origin = emiCase.Origin;
        caseAdd.Reason = emiCase.Reason;
        return caseAdd;
   
     
    }

    public static List<Equipment_Maintenance_Item__c> prepareItems(Id oldID, Case newCase, List<Equipment_Maintenance_Item__c> eqMainItem) {
        List<Equipment_Maintenance_Item__c> emiAdd = new List<Equipment_Maintenance_Item__c>();
        
        for(Equipment_Maintenance_Item__c e : eqMainItem){
            Equipment_Maintenance_Item__c em = new Equipment_Maintenance_Item__c(
                Maintenance_Request__c = newCase.Id,
                Equipment__c = e.Equipment__c
            );
            emiAdd.add(em);

        }
        return emiAdd;
 
    }

}