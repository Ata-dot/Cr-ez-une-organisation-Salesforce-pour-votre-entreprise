/**
 * @description       : Classe de test pour OpportunityProductController
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : Tests unitaires
 * @last modified on  : 01-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class OpportunityProductControllerTest {
    
    /**
     * Méthode de configuration des données de test
     * Crée un ensemble de données réutilisables pour tous les tests
     */
    @TestSetup
    static void makeData(){
        // Création d'un compte de test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        System.debug('Test Account créé : ' + testAccount);
        
        // Création d'une opportunité de test
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpportunity;
        System.debug('Test Opportunity créée : ' + testOpportunity);
        
        // Création d'un produit de test
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true
        );
        insert testProduct;
        System.debug('Test Product créé : ' + testProduct);
        
        // Création d'une entrée de prix standard
        PricebookEntry testPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPBE;
        System.debug('Test PricebookEntry créé : ' + testPBE);
        
        // Création d'un élément de ligne d'opportunité
        OpportunityLineItem testOLI = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPBE.Id,
            Product2Id = testProduct.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert testOLI;
        System.debug('Test OpportunityLineItem créé : ' + testOLI);
    }
    
    /**
     * Test de la méthode getOpportunityLineItems
     * Vérifie la récupération des éléments de ligne d'une opportunité
     */
    @isTest
    static void testGetOpportunityLineItems() {
        // Récupération de l'opportunité créée dans makeData()
        Opportunity testOpp = [SELECT Id FROM Opportunity Where Name = 'Test Opportunity' LIMIT 1];
        
        Test.startTest();
        System.debug('Début du test getOpportunityLineItems avec l\'ID: ' + testOpp.Id);
        
        // Appel de la méthode à tester avec l'ID de l'opportunité
        List<OpportunityLineItem> result = OpportunityProductController.getOpportunityLineItems(testOpp.Id);
        
        Test.stopTest();
        System.debug('Fin du test getOpportunityLineItems, résultats récupérés: ' + result.size());
        
        // Assertions pour vérifier le résultat
        System.assertEquals(1, result.size(), 'Devrait retourner 1 élément de ligne');
        System.assertNotEquals(null, result[0].Product2.Name, 'Le nom du produit ne doit pas être null');
        System.assertNotEquals(null, result[0].UnitPrice, 'Le prix unitaire ne doit pas être null');
        System.assertNotEquals(null, result[0].TotalPrice, 'Le prix total ne doit pas être null');
        System.assertNotEquals(null, result[0].Quantity, 'La quantité ne doit pas être null');
    }
}