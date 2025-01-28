/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-21-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class DataCreationScriptTest {

    @isTest
    public static void testCreateTestData() {
        // Step 1: Set up the test data for Pricebook2, Product2, and PricebookEntry
        
        // Create a custom Pricebook2 ('Liste des prix - FRANCE')
        Pricebook2 pb = new Pricebook2(Name = 'Liste des prix - FRANCE', IsActive = true);
        insert pb;

        // Create Products with unique Stock Keeping Units (SKUs)
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Tesla Model S', ProductCode = 'TES-MS', Description = 'Voiture électrique haut de gamme', Family = 'Voitures électriques', StockKeepingUnit = 'TES-MS-2022', QuantityInStock__c = 50));
        products.add(new Product2(Name = 'Ford Mustang Mach-E', ProductCode = 'FORD-MM', Description = 'SUV électrique', Family = 'Voitures électriques', StockKeepingUnit = 'FORD-MM-2022', QuantityInStock__c = 75));
        products.add(new Product2(Name = 'Audi e-Tron', ProductCode = 'AUDI-ET', Description = 'SUV électrique', Family = 'Voitures électriques', StockKeepingUnit = 'AUDI-ET-2022', QuantityInStock__c = 100));
        products.add(new Product2(Name = 'Toyota Corolla Hybride', ProductCode = 'TOY-CH', Description = 'Voiture hybride compacte', Family = 'Voitures hybrides', StockKeepingUnit = 'TOY-CH-2022', QuantityInStock__c = 150));
        products.add(new Product2(Name = 'Honda Civic', ProductCode = 'HON-CIV', Description = 'Voiture compacte', Family = 'Voitures à essence', StockKeepingUnit = 'HON-CIV-2022', QuantityInStock__c = 200));
        insert products;

        // Skip querying the Standard Pricebook. Just create a custom Pricebook for testing.
        // Create a custom Pricebook (like a standard pricebook)
        Pricebook2 standardPb = new Pricebook2(Name = 'Standard Pricebook', IsStandard = true, IsActive = true);
        insert standardPb;

        // Step 2: Create PricebookEntries for both the standard and custom Pricebook2
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        // PricebookEntries in the standard Pricebook
        pbeList.add(new PricebookEntry(Pricebook2Id = standardPb.Id, Product2Id = products[0].Id, UnitPrice = 25000, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = standardPb.Id, Product2Id = products[1].Id, UnitPrice = 25000, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = standardPb.Id, Product2Id = products[2].Id, UnitPrice = 25000, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = standardPb.Id, Product2Id = products[3].Id, UnitPrice = 25000, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = standardPb.Id, Product2Id = products[4].Id, UnitPrice = 25000, IsActive = true));

        // PricebookEntries in the custom Pricebook
        pbeList.add(new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = products[0].Id, UnitPrice = 99990, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = products[1].Id, UnitPrice = 69900, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = products[2].Id, UnitPrice = 82400, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = products[3].Id, UnitPrice = 28990, IsActive = true));
        pbeList.add(new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = products[4].Id, UnitPrice = 26990, IsActive = true));
        
        // Insert PricebookEntries
        insert pbeList;

        // Step 3: Start the test
        Test.startTest();
        
        // Call the createTestData method
        DataCreationScript.createTestData();
        
        // Step 4: Assert the results to verify the data
        // Check if the products were inserted correctly
        List<Product2> productList = [SELECT Id, Name FROM Product2];
        System.assertEquals(5, productList.size(), 'The number of products inserted should be 5.');

        // Check if the Pricebooks were inserted correctly
        List<Pricebook2> pricebookList = [SELECT Id, Name FROM Pricebook2];
        System.assertEquals(2, pricebookList.size(), 'The number of Pricebooks inserted should be 2.');

        // Check if the PricebookEntries were inserted correctly
        List<PricebookEntry> pbeListInserted = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry];
        System.assertEquals(10, pbeListInserted.size(), 'The number of PricebookEntries inserted should be 10.');

        Test.stopTest();
    }
}
