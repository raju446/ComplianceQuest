public with sharing class PartToProductScheduler implements Schedulable {

    public void execute(SchedulableContext context) {
        if (UserPermissionHelper.isSystemAdminWithPermission('CQ_Product_Admin')) {
            PartToProductBatchService service = new PartToProductBatchService();
            service.syncPartsToProducts();
        }
    }
    
    public static void scheduleJob() {
        String cron = '0 0 6 * * ?'; // 6 AM GMT daily
        System.schedule('Daily Part to Product Sync', cron, new PartToProductScheduler());
    }
}