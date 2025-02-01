public class DataCreationScript {
    public static void createTestData() {
        // Suffixe unique pour tous les SKU (ex: timestamp)
        String uniqueSuffix = String.valueOf(System.now().getTime()); // Ex: "1691234567890"

        // Créer un Pricebook2 personnalisé
        Pricebook2 pb = new Pricebook2(Name = 'Liste des prix - FRANCE', IsActive = true);
        insert pb;

        // Créer des produits avec des SKU uniques
        List<Product2> products = new List<Product2>();
        products.add(new Product2(
            Name = 'Tesla Model S', 
            ProductCode = 'TES-MS', 
            StockKeepingUnit = 'TES-MS-2022-' + uniqueSuffix, // SKU unique
            Family = 'Voitures électriques',
            QuantityInStock__c = 50
        ));
        products.add(new Product2(
            Name = 'Ford Mustang Mach-E', 
            ProductCode = 'FORD-MM', 
            StockKeepingUnit = 'FORD-MM-2022-' + uniqueSuffix, // SKU unique
            Family = 'Voitures électriques',
            QuantityInStock__c = 75
        ));
        products.add(new Product2(
            Name = 'Audi e-Tron', 
            ProductCode = 'AUDI-ET', 
            StockKeepingUnit = 'AUDI-ET-2022-' + uniqueSuffix, // SKU unique
            Family = 'Voitures électriques',
            QuantityInStock__c = 100
        ));
        products.add(new Product2(
            Name = 'Toyota Corolla Hybride', 
            ProductCode = 'TOY-CH', 
            StockKeepingUnit = 'TOY-CH-2022-' + uniqueSuffix, // SKU unique
            Family = 'Voitures hybrides',
            QuantityInStock__c = 150
        ));
        products.add(new Product2(
            Name = 'Honda Civic', 
            ProductCode = 'HON-CIV', 
            StockKeepingUnit = 'HON-CIV-2022-' + uniqueSuffix, // SKU unique
            Family = 'Voitures à essence',
            QuantityInStock__c = 200
        ));
        insert products;

        // Récupérer le Pricebook standard
        Pricebook2 standardPb = Test.isRunningTest() 
            ? new Pricebook2(Id = Test.getStandardPricebookId()) 
            : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        // Créer les PricebookEntries
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for (Product2 prod : products) {
            // Pricebook standard
            pbeList.add(new PricebookEntry(
                Pricebook2Id = standardPb.Id,
                Product2Id = prod.Id,
                UnitPrice = 25000,
                IsActive = true
            ));
            // Pricebook personnalisé
            pbeList.add(new PricebookEntry(
                Pricebook2Id = pb.Id,
                Product2Id = prod.Id,
                UnitPrice = 99990,
                IsActive = true
            ));
        }
        insert pbeList;
    }
}
