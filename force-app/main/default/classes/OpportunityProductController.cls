/**
 * @description       : Contrôleur pour gérer les produits d'opportunité
 * @description       : Fournit des méthodes pour récupérer, supprimer et manipuler les OpportunityLineItems
 * @last modified on  : 01-27-2025
**/
public with sharing class OpportunityProductController {
    
    // Définition des étiquettes personnalisées
    public static final String PRODUCT_NAME_LABEL = System.Label.Product_Name;
    public static final String QUANTITY_LABEL = System.Label.Quantity;
    public static final String UNIT_PRICE_LABEL = System.Label.Unit_Price;
    public static final String TOTAL_PRICE_LABEL = System.Label.Total_Price;
    public static final String QUANTITY_IN_STOCK_LABEL = System.Label.Quantity_in_Stock;
    public static final String DELETE_LABEL = System.Label.Delete_Label;
    public static final String SEE_PRODUCT_LABEL = System.Label.See_Product_label;
    public static final String QUANTITY_ERROR_MESSAGE_LABEL = System.Label.Quantity_Error_Message;
    public static final String UPDATE_SUCCESS_MESSAGE_LABEL = System.Label.Update_Success_Message;
    public static final String DELETE_SUCCESS_MESSAGE_LABEL = System.Label.Delete_Success_Message;
    public static final String PRODUCT_DELETED_SUCCESS_LABEL = System.Label.Product_Deleted_Success;
    public static final String PRODUCT_NOT_FOUND_LABEL = System.Label.Product_Not_Found;
    public static final String ADMIN_LABEL = System.Label.admin;
    public static final String Contact_ADMIN_MESSAGE_LABEL = System.Label.Contact_Admin_Message;
    public static final String INVALID_PRICE_ERROR_LABEL = System.Label.Invalid_Price_Error;
    public static final String INVALID_QUANTITY_ERROR_LABEL = System.Label.Invalid_Quantity_Error;
    public static final String OPPORTUNITY_PRODUCTS_LABEL = System.Label.Opportunity_Products_Label;
    public static final String PRODUCT_DELETE_ERROR_LABEL = System.Label.Product_Delete_Error;
    public static final String QUANTITY_ERROR_LABEL = System.Label.Quantity_Error;
    public static final String QUANTITY_EXCEEDS_STOCK_LABEL = System.Label.Quantity_Exceeds_Stock;
    public static final String STOCK_UPDATE_ERROR_LABEL = System.Label.Stock_Update_Error;
    public static final String STOCK_UPDATE_SUCCESS_LABEL = System.Label.Stock_Updated_Success;    
   


    /**
     * Récupère les OpportunityLineItems pour une opportunité donnée.
     * 
     * @param opportunityId L'ID de l'opportunité pour laquelle récupérer les éléments de ligne.
     * @return Liste des OpportunityLineItems associés à l'opportunité.
     */
    
    @AuraEnabled (cacheable=true)
    public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
        // Debug: Vérification de l'entrée de la méthode
        System.debug('Entering getOpportunityLineItems with opportunityId: ' + opportunityId);
        
        // Récupération des OpportunityLineItem liés à l'opportunité
        List<OpportunityLineItem> lineItems = [
            SELECT Id, Product2.Name, Product2.QuantityInStock__c, UnitPrice, TotalPrice, Quantity, Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];
        
        // Debug: Vérification du nombre d'éléments récupérés
        System.debug('Retrieved ' + lineItems.size() + ' OpportunityLineItems for OpportunityId: ' + opportunityId);
        
        return lineItems; // Retourne la liste des éléments
    }

    /**
     * Supprime un OpportunityLineItem par ID.
     * 
     * @param lineItemId L'ID de l'OpportunityLineItem à supprimer.
     * @return Boolean indiquant si la suppression a réussi.
     */
    @AuraEnabled
    public static Boolean deleteOpportunityLineItem(Id lineItemId) {
        // Debug: Vérification de l'entrée de la méthode
        System.debug('Entering deleteOpportunityLineItem with lineItemId: ' + lineItemId);
        
        try {
            // Suppression de l'élément de ligne
            OpportunityLineItem oliToDelete = [SELECT Id FROM OpportunityLineItem WHERE Id = :lineItemId LIMIT 1];
            delete oliToDelete;

            // Debug: Confirmation de la suppression
            System.debug('Successfully deleted OpportunityLineItem with Id: ' + lineItemId);
            return true; // Indique que la suppression a réussi
        } catch (Exception e) {
            // Gestion des erreurs
            System.debug('Error deleting OpportunityLineItem: ' + e.getMessage());
            throw new AuraHandledException('Impossible de supprimer le produit. Raison : ' + e.getMessage());
        }
    }

    /**
     * Met à jour la quantité en stock d'un produit lié à un OpportunityLineItem.
     * 
     * @param productId L'ID du produit (Product2) à mettre à jour.
     * @param newQuantityInStock La nouvelle quantité en stock.
     * @return Boolean indiquant si la mise à jour a réussi.
     */
    @AuraEnabled
    public static Boolean updateQuantityInStock(Id productId, Decimal newQuantityInStock) {
        // Debug: Vérification des paramètres
        System.debug('Entering updateQuantityInStock with productId: ' + productId + ' and newQuantityInStock: ' + newQuantityInStock);
        
        try {
            // Récupération du produit et mise à jour du stock
            Product2 productToUpdate = [SELECT Id, QuantityInStock__c FROM Product2 WHERE Id = :productId LIMIT 1];
            productToUpdate.QuantityInStock__c = newQuantityInStock;
            update productToUpdate;

            // Debug: Confirmation de la mise à jour
            System.debug('Successfully updated QuantityInStock__c for Product2 with Id: ' + productId);
            return true; // Indique que la mise à jour a réussi
        } catch (Exception e) {
            // Gestion des erreurs
            System.debug('Error updating QuantityInStock__c: ' + e.getMessage());
            throw new AuraHandledException('Impossible de mettre à jour la quantité en stock. Raison : ' + e.getMessage());
        }
    }
}
