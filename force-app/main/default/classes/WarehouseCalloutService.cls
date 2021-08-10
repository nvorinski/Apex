public with sharing class WarehouseCalloutService implements Queueable{
    private static final String ENDPOINT = 'https://th-superbadge-apex.herokuapp.com/equipment';

    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        Http http = new Http ();
        HttpRequest request = new HttpRequest ();
        
        request.setEndpoint(ENDPOINT);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Product2> equipmentsUpdate = new List<Product2>();
        List<Object> equipment = new List<Object>();
    
        if(response.getStatusCode() == 200){
            equipment = (List<Object>)JSON.deserializeUntyped(response.getBody());
       }else {
           System.debug('Could not fetch data');
       }

        for (Object e : equipment) {
            Map<String,Object> productMap = (Map<String,Object>) e;
            Product2 product = new Product2();

            product.Replacement_Part__c = (Boolean)productMap.get('replacement');
            product.Cost__c = (Integer)productMap.get('cost');
            product.Current_Inventory__c = (Integer)productMap.get('quantity');
            product.Lifespan_Months__c = (Integer)productMap.get('lifespan');
            product.Maintenance_Cycle__c = (Integer)productMap.get('maintenanceperiod');
            product.Warehouse_SKU__c = (String) productMap.get('sku');
            product.Name = (String) productMap.get('name');
            product.ProductCode = (String) productMap.get('_id');
            equipmentsUpdate.add(product);

        }
        if(equipmentsUpdate.size() > 0) {
            upsert equipmentsUpdate;
    }
        
    }  
    public static void  execute(QueueableContext context) {
        runWarehouseEquipmentSync();
    }

}
