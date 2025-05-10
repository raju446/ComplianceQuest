@isTest
public class PartToProductSchedulerTest {

    @isTest
    Public static void testScheduleJob() {
        Test.startTest();
        PartToProductScheduler.scheduleJob();
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronJobDetail.Name, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'Daily Part to Product Sync' LIMIT 1];
        System.assertEquals('Daily Part to Product Sync', ct.CronJobDetail.Name);
        System.assertEquals('0 0 6 * * ?', ct.CronExpression);
    }

    @isTest
    Public static void testSchedulerExecutionWithAdminPermissions() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            LastName = 'testadmns',
            Username = 'testcquser1@gmail.com',
            Email = 'testcquser@gmail.com',
            Alias = 'aduser',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;

        PermissionSet cqProductAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'CQ_Product_Admin' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = adminUser.Id,
            PermissionSetId = cqProductAdmin.Id
        );
        insert psa;

        Test.startTest();
        PartToProductScheduler scheduler = new PartToProductScheduler();
        String cronExpression = '0 0 0 1 1 ?';
        System.schedule('Test PartToProductScheduler', cronExpression, scheduler);
        Test.stopTest();
    }

    @isTest
    Public static void testSchedulerWithoutAdminPermissions() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User standardUser = new User(
            LastName = 'testcquser5',
            Username = 'testcquser2@gmail.com',
            Email = 'testcqusers@gmail.com',
            Alias = 'srduser',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;

        Test.startTest();
        PartToProductScheduler scheduler = new PartToProductScheduler();
        String cronExpression = '0 0 0 1 1 ?';
        System.schedule('Test PartToProductScheduler', cronExpression, scheduler);
        Test.stopTest();

        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(0, products.size(), 'No products should have been synced');
    }
    
    @isTest
    Public static void testSyncPartsToProducts() {
    
        SQX_Part__c part1 = new SQX_Part__c(
            Name = 'Part 1',
            Part_Number__c = 'P001',
            Active__c = true
        );
        SQX_Part__c part2 = new SQX_Part__c(
            Name = 'Part 2',
            Part_Number__c = 'P002',
            Active__c = true
        );
        insert new List<SQX_Part__c>{ part1, part2 };

        Product2 existingProduct = new Product2(
            Name = 'Part 1',
            ProductCode = 'P001',
            IsActive = true
        );
        insert existingProduct;

        Test.startTest();
        PartToProductBatchService service = new PartToProductBatchService();
        service.syncPartsToProducts();
        Test.stopTest();

        SQX_Part__c updatedPart = [SELECT Product__c FROM SQX_Part__c WHERE Id = :part1.Id];
        System.assertNotEquals(null, updatedPart.Product__c, 'Part 1 should be linked to an existing product');
        
        SQX_Part__c updatedPart2 = [SELECT Product__c FROM SQX_Part__c WHERE Id = :part2.Id];
        System.assertNotEquals(null, updatedPart2.Product__c, 'Part 2 should be linked to an existing product');
    }

    @isTest
    Public static void testPermissionUtils() {

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            LastName = 'testUser',
            Username = 'testadminuser2@gmail.com',
            Email = 'adminuser2@gmail.com',
            Alias = 'auser2',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;

        PermissionSet cqProductAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'CQ_Product_Admin' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = adminUser.Id,
            PermissionSetId = cqProductAdmin.Id
        );
        insert psa;

        Test.startTest();
        Boolean hasPermission = UserPermissionHelper.isSystemAdminWithPermission('CQ_Product_Admin');
        Test.stopTest();
        
        System.assert(hasPermission, 'User should have the required permission');
    }
}