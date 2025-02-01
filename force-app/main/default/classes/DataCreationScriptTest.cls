@isTest
public class DataCreationScriptTest {
    @isTest
    static void testCreateTestData() {
        // Supprimer les produits existants avec les mêmes motifs de SKU
        delete [SELECT Id FROM Product2 WHERE StockKeepingUnit LIKE 'TES-MS-2022-%' 
                OR StockKeepingUnit LIKE 'FORD-MM-2022-%' 
                OR StockKeepingUnit LIKE 'AUDI-ET-2022-%' 
                OR StockKeepingUnit LIKE 'TOY-CH-2022-%' 
                OR StockKeepingUnit LIKE 'HON-CIV-2022-%'];

        // Activer le Pricebook standard pour le test
        Pricebook2 standardPb = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPb;

        // Exécuter la méthode
        Test.startTest();
        DataCreationScript.createTestData();
        Test.stopTest();

        // Vérifier que les 5 produits sont créés
        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(5, products.size(), '5 produits devraient être créés');
    }
}
