@isTest
global class WarehouseSyncScheduleTest {

    @isTest
    static void testScheduledJob() {
        String scheduleTime = '00 00 01 * * ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobID=System.schedule('Warehouse Time To Schedule to Test', scheduleTime, new WarehouseSyncSchedule());
        Test.stopTest();

      CronTrigger [] a = [SELECT Id FROM CronTrigger WHERE NextFireTime > today];
        System.assertEquals(jobID, a[0].Id,'Schedule');
    }
}
