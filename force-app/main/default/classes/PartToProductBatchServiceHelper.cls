public class PartToProductBatchServiceHelper {

    public static String generateKey(SQX_Part__c part) {
        return part.Name + '-' + part.Part_Number__c;
    }

    public static Product2 createProduct(SQX_Part__c part) {
        return new Product2(
            Name = part.Name,
            ProductCode = part.Part_Number__c,
            IsActive = true
        );
    }

    public static String generateKey(Product2 product) {
        return product.Name + '-' + product.ProductCode;
    }
}