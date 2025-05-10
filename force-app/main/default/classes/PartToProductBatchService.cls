public with sharing class PartToProductBatchService {
    
    public Map<String, Product2> existingProductMap = new Map<String, Product2>();
    public List<Product2> productsToInsert = new List<Product2>();
    public List<SQX_Part__c> partsToUpdate = new List<SQX_Part__c>();
    public Map<String, Id> insertedProductKeyMap = new Map<String, Id>();

    public void syncPartsToProducts() {
        loadExistingProducts();

        List<SQX_Part__c> parts = fetchEligibleParts();

        for (SQX_Part__c part : parts) {
            String key = PartToProductBatchServiceHelper.generateKey(part);
            
            if (existingProductMap.containsKey(key)) {
                part.Product__c = existingProductMap.get(key).Id;
                partsToUpdate.add(part);
            } else {
                Product2 product = PartToProductBatchServiceHelper.createProduct(part);
                productsToInsert.add(product);
                insertedProductKeyMap.put(key, null);
                partsToUpdate.add(part);
            }
        }

        if (!productsToInsert.isEmpty()) {
            insert productsToInsert;

            for (Product2 p : productsToInsert) {
                String key = PartToProductBatchServiceHelper.generateKey(p);
                insertedProductKeyMap.put(key, p.Id);
            }

            updatePartsWithNewProducts();
        }

        if (!partsToUpdate.isEmpty()) {
            update partsToUpdate;
        }
    }

    public void loadExistingProducts() {
        for (Product2 product : [
            SELECT Id, Name, ProductCode 
            FROM Product2 
            WHERE IsActive = true
        ]) {
            String key = PartToProductBatchServiceHelper.generateKey(product);
            existingProductMap.put(key, product);
        }
    }

    public List<SQX_Part__c> fetchEligibleParts() {
        return [
            SELECT Id, Name, Part_Number__c, Product__c 
            FROM SQX_Part__c 
            WHERE Active__c = true AND Product__c = null
        ];
    }

    Public void updatePartsWithNewProducts() {
        for (SQX_Part__c part : partsToUpdate) {
            if (part.Product__c == null) {
                String key = PartToProductBatchServiceHelper.generateKey(part);
                part.Product__c = insertedProductKeyMap.get(key);
            }
        }
        update partsToUpdate;
    }
}