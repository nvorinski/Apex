@isTest
global class WarehouseCalloutServiceTest {
    @isTest
    static void testWarehouseCallout(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new WarehouseCalloutServiceMock());
        System.enqueueJob(new WarehouseCalloutService());
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Product2]);
    }
}
