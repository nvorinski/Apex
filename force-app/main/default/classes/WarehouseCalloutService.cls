public with sharing class WarehouseCalloutService implements Queueable{
   
    @future(callout=true)
    public void execute (QueueableContext context) {
        Http http = new Http ();
        HttpRequest request = new HttpRequest ();
        private static final String endpoint = 'https://th-superbadge-apex.herokuapp.com/equipment';
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Product2> equipmentsUpdate = new List<Product2>();
        List<Object> equipment = new List<Object>();
    
        if(response.getStatusCode() == 200){
            equipment = (List<Object>)JSON.deserializeUntyped(response.getBody());
       }else {
           System.debug('Could not fetch data');
       }
        


        for (Product2 e : equipment) {
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
            products.add(product);

        }
        if(equipmentsUpdate.size() > 0) {
            upsert equipmentsUpdate;
        }
        
    }



    
    
    
    


    
    

}
