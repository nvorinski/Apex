@istest
public with sharing class MaintenanceRequestHelperTest {

    private static final string STATUS_NEW = 'New';
    private static final string WORKING = 'Working';
    private static final string CLOSED = 'Closed';
    private static final string REPAIR = 'Repair';
    private static final string REQUEST_ORIGIN = 'Web';
    private static final string REQUEST_TYPE = 'Routine Maintenance';
    private static final string REQUEST_SUBJECT = 'Testing subject';

    private static Vehicle__c createVehicle() {
        Vehicle__c Vehicle = new Vehicle__c (name='Super truck');
        return Vehicle;
    }

    private static Product2 createEq(){
        Product2 equipment = new Product2(name = 'Super Equipment',
                                          Lifespan_Months__c =10,
                                          Maintenance_Cycle__c = 10,
                                          Replacement_Part__c = true);
        return equipment;
    }

    private static Case createMaintenanceRequest (id vehicleID){
        case cs = new Case(
            Type=REPAIR,
            Status=STATUS_NEW,
            Origin=REQUEST_ORIGIN,
            Subject=REQUEST_SUBJECT,
            Vehicle__c = vehicleID
        );
        return cs;
    }

    private static List<Equipment_Maintenance_Item__c> createItemList (id equimpmentId, id requestId,Integer numbItems) {
        Equipment_Maintenance_Item__c wp = new Equipment_Maintenance_Item__c(
            Equipment__c = equimpmentId,
            Maintenance_Request__c = requestId
        );
        if(numbItems==2){
            Product2 prod = createEq();
            prod.Maintenance_Cycle__c = 8;
            insert prod;
    
            Equipment_Maintenance_Item__c wp2 = new Equipment_Maintenance_Item__c(
                Equipment__c = prod.Id,
                Maintenance_Request__c = requestId
            );
    
            List<Equipment_Maintenance_Item__c> lstWP = new List<Equipment_Maintenance_Item__c>();
            lstWP.add(wp);
            lstWP.add(wp2);
            return lstWP;
        }
        List<Equipment_Maintenance_Item__c> lstWP = new List<Equipment_Maintenance_Item__c>();
        lstWP.add(wp);
        return lstWP;
    }

    @istest
    private static void testMaintenanceRequestPositive(){
        Vehicle__c vehicle = createVehicle();
        insert vehicle;
        id vehicleId = vehicle.Id;

        Product2 equipment = createEq();
        insert equipment;
        id equimpmentId = equipment.Id;

        Case caseToUpdate = createMaintenanceRequest(vehicleID);
        insert caseToUpdate;
        id requestId = caseToUpdate.Id;

        List<Equipment_Maintenance_Item__c> listEMI = createItemList(equimpmentId, requestId,2);
        insert listEMI;

        test.startTest();
        caseToUpdate.Status=CLOSED;
        update caseToUpdate;
        test.stopTest();

        Case newReq = [Select id, subject, type, Date_Reported__c, Vehicle__c, Date_Due__c
        from case
        where status =:STATUS_NEW];

        Equipment_Maintenance_Item__c workPart = [SELECT id, Maintenance_Request__c     
                                                        FROM Equipment_Maintenance_Item__c
                                                        WHERE Maintenance_Request__c =:newReq.Id];

        system.assert(workPart != null);
        system.assert(newReq.Subject != null);
        system.assertEquals(newReq.Type, REQUEST_TYPE);
        SYSTEM.assertEquals(workPart.Maintenance_Request__c, newReq.Id);
        SYSTEM.assertEquals(newReq.Vehicle__c, vehicleId);
        SYSTEM.assertEquals(newReq.Date_Reported__c, system.today());
    }

    private static void testMaintenanceRequestPositiveOne(){
        Vehicle__c vehicle = createVehicle();
        insert vehicle;
        id vehicleId = vehicle.Id;

        Product2 equipment = createEq();
        insert equipment;
        id equimpmentId = equipment.Id;

        Case caseToUpdate = createMaintenanceRequest(vehicleID);
        insert caseToUpdate;
        id requestId = caseToUpdate.Id;

        List<Equipment_Maintenance_Item__c> listEMI = createItemList(equimpmentId, requestId,1);
        insert listEMI;

        test.startTest();
        caseToUpdate.Status=CLOSED;
        update caseToUpdate;
        test.stopTest();

        Case newReq = [Select id, subject, type, Date_Reported__c, Vehicle__c, Date_Due__c
        from case
        where status =:STATUS_NEW];

        Equipment_Maintenance_Item__c workPart = [SELECT id, Maintenance_Request__c     
                                                        FROM Equipment_Maintenance_Item__c
                                                        WHERE Maintenance_Request__c =:newReq.Id];

        system.assert(workPart != null);
        system.assert(newReq.Subject != null);
        system.assertEquals(newReq.Type, REQUEST_TYPE);
        SYSTEM.assertEquals(workPart.Maintenance_Request__c, newReq.Id);
        SYSTEM.assertEquals(newReq.Vehicle__c, vehicleId);
        SYSTEM.assertEquals(newReq.Date_Reported__c, system.today());
    }
    @istest
    private static void testMaintenanceRequestNegative() {
        Vehicle__c vehicle = createVehicle();
        insert vehicle;
        id vehicleId = vehicle.Id;

        Product2 equipment = createEq();
        insert equipment;
        id equimpmentId = equipment.Id;

        Case caseToUpdate = createMaintenanceRequest(vehicleID);
        insert caseToUpdate;
        id requestId = caseToUpdate.Id;

        List<Equipment_Maintenance_Item__c> listEMI = createItemList(equimpmentId, requestId,1);
        insert listEMI;

        test.startTest();
        caseToUpdate.Status=WORKING;
        update caseToUpdate;
        test.stopTest();

        List<Case> allRequest = [select id 
        from case];

        Equipment_Maintenance_Item__c workPart = [select id 
                         from Equipment_Maintenance_Item__c 
                         where Maintenance_Request__c = :caseToUpdate.Id];

        system.assert(workPart != null);
        system.assert(allRequest.size() == 1);
    }

    @istest
    private static void testMaintenanceRequestBulk(){
        list<Vehicle__C> vehicleList = new list<Vehicle__C>();
        list<Product2> equipmentList = new list<Product2>();
        list<Equipment_Maintenance_Item__c> workPartList = new list<Equipment_Maintenance_Item__c>();
        list<case> requestList = new list<case>();
        list<id> oldRequestIds = new list<id>();
        
        for(integer i = 0; i < 300; i++){
           vehicleList.add(createVehicle());
            equipmentList.add(createEq());
        }
        insert vehicleList;
        insert equipmentList;
        
        for(integer i = 0; i < 300; i++){
            requestList.add(createMaintenanceRequest(vehicleList.get(i).id));
        }
        insert requestList;
        
        for(integer i = 0; i < 300; i++){
            for (Equipment_Maintenance_Item__c emi : createItemList(equipmentList.get(i).Id, requestList.get(i).id,1)){
                workPartList.add(emi);
            }
        }
        insert workPartList;
        
        test.startTest();
        for(case req : requestList){
            req.Status = CLOSED;
            oldRequestIds.add(req.Id);
        }
        update requestList;
        test.stopTest();
        
        list<case> allRequests = [select id
                                 from case
                                 where status =: STATUS_NEW];
        
        list<Equipment_Maintenance_Item__c> workParts = [select id
                                                        from Equipment_Maintenance_Item__c
                                                        where Maintenance_Request__c in: oldRequestIds];
        
        system.assert(allRequests.size() == 300);
    }

}
