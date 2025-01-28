import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'; // Import pour la navigation
import getOpportunityLineItems from '@salesforce/apex/OpportunityProductController.getOpportunityLineItems';
import deleteOpportunityLineItem from '@salesforce/apex/OpportunityProductController.deleteOpportunityLineItem';
import updateQuantityInStock from '@salesforce/apex/OpportunityProductController.updateQuantityInStock';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { refreshApex } from '@salesforce/apex'; //Import de la méthode refreshApex


// Importation des étiquettes personnalisées pour l'internationalisation
import productDeletedSuccess from '@salesforce/label/c.Product_Deleted_Success';
import productDeleteError from '@salesforce/label/c.Product_Delete_Error';
import stockUpdatedSuccess from '@salesforce/label/c.Stock_Updated_Success';
import stockUpdateError from '@salesforce/label/c.Stock_Update_Error';
import invalidQuantityError from '@salesforce/label/c.Invalid_Quantity_Error';
import quantityError from '@salesforce/label/c.Quantity_Error';
import opportunityProductsLabel from '@salesforce/label/c.Opportunity_Products_Label';
import quantityErrorMessage from '@salesforce/label/c.Quantity_Error_Message';
import seeProduct from '@salesforce/label/c.See_Product_Label';
import deletelabel from '@salesforce/label/c.Delete_Label';


export default class OpportunityProducts extends NavigationMixin(LightningElement) { // Ajout de NavigationMixin pour la navigation
   @api recordId; // ID de l'opportunité récupéré automatiquement
   @track products = []; // Liste des OpportunityLineItems
   @track isLoading = true; // Pour afficher un spinner lors du chargement des données
   @track error; // Gestion des erreurs
   userProfile; // Stockage du profil de l'utilisateur actuel
   productsResults; // Stockage des résultats des produits


   /**
    * Récupère le profil de l'utilisateur connecté grâce à `getRecord`.
    */
   @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
   wiredUser({ error, data }) {
       if (data) {
           this.userProfile = data.fields.Profile.value.fields.Name.value;
           console.log('Profil utilisateur récupéré :', this.userProfile); // Log du profil utilisateur
       } else if (error) {
           console.error('Erreur lors de la récupération du profil utilisateur :', error); // Log en cas d'erreur
       }
   }


   /**
    * Vérifie si l'utilisateur est un administrateur système.
    * @returns {boolean} - Vrai si l'utilisateur est administrateur système.
    */
   get isSystemAdmin() {
       const result = this.userProfile === 'System Administrator';
       console.log('L\'utilisateur est-il un administrateur système ?', result); // Log du résultat
       return result;
   }


   /**
    * Vérifie si l'utilisateur est un commercial.
    * @returns {boolean} - Vrai si l'utilisateur est un commercial.
    */
   get isCommercial() {
       const result = this.userProfile === 'Commercial';
       console.log('L\'utilisateur est-il un commercial ?', result); // Log du résultat
       return result;
   }


   /**
    * Méthode appelée lors de l'initialisation du composant.
    */
   connectedCallback() {
       console.log('Composant initialisé, chargement des produits...'); // Log initial
       this.loadOpportunityLineItems(); // Charge les données des produits
   }


   /**
    * Charge les OpportunityLineItems liés à l'opportunité.
    */
   loadOpportunityLineItems() {
       this.isLoading = true;
       console.log('Chargement des OpportunityLineItems pour l\'opportunité ID :', this.recordId); // Log du chargement


       getOpportunityLineItems({ opportunityId: this.recordId })
           .then((result) => {
               this.products = result;
               this.productsResults= result;  // Stocke les produits récupérés
               console.log('Produits récupérés avec succès :', JSON.stringify(result)); // Log des produits récupérés
               this.isLoading = false; // Désactive le spinner
              


           })
           .catch((error) => {
               console.error('Erreur lors du chargement des produits :', error); // Log de l'erreur
           this.error = error.body.message; // Stocke le message d'erreur
               this.isLoading = false; // Désactive le spinner même en cas d'erreur
           });
   }


   /**
    * Supprime un OpportunityLineItem après avoir cliqué sur le bouton "Supprimer".
    * @param {Event} event - Événement contenant l'ID de la ligne.
    */
   handleDelete(event) {
       const lineItemId = event.target.dataset.id; // Récupère l'ID de la ligne
       console.log('Suppression du produit avec OpportunityLineItem ID :', lineItemId); // Log avant suppression
       this.isLoading = true;


       deleteOpportunityLineItem({ lineItemId })
           .then(() => {
               console.log('Produit supprimé avec succès :', lineItemId); // Log après suppression
               this.showToast(productDeletedSuccess, 'Le produit a été supprimé.', 'success');
               let tempProducts = this.products;
               this.products = tempProducts.filter(product => product.Id !== lineItemId);
               this.isLoading = false;
              
               // Recharge les données après suppression
               this.handleRafreshOpportunity();
           })
           .catch((error) => {
               console.error('Erreur lors de la suppression du produit :', error); // Log en cas d'erreur
               this.showToast(productDeleteError, 'Impossible de supprimer le produit.', 'error');
               this.isLoading = false;
           });
   }


   /**
    * Met à jour le stock d'un produit.
    * @param {Event} event - Événement contenant l'ID du produit et la nouvelle quantité.
    */
   handleUpdateStock(event) {
       const productId = event.target.dataset.productId; // Récupère ID du produit
       const newQuantityInStock = parseFloat(event.target.value); // Quantité saisie


       console.log('Mise à jour du stock pour le produit ID :', productId, ', Nouvelle quantité :', newQuantityInStock); // Log avant la mise à jour

// Validation de la quantité saisie
       if (isNaN(newQuantityInStock)) {
           console.error('Valeur saisie non valide :', event.target.value); // Log en cas de valeur non valide
           this.showToast(invalidQuantityError, 'Veuillez saisir une valeur valide.', 'error');
           return;
       }


       this.isLoading = true;


       updateQuantityInStock({ productId, newQuantityInStock })
           .then(() => {
               console.log('Stock mis à jour avec succès pour le produit ID :', productId); // Log après la mise à jour
               this.showToast(stockUpdatedSuccess, 'Le stock a été mis à jour avec succès.', 'success');


               // Recharge les produits après mise à jour
               this.loadOpportunityLineItems();
           })
           .catch((error) => {
               console.error('Erreur lors de la mise à jour du stock :', error); // Log en cas d'erreur
               this.showToast(stockUpdateError, 'Impossible de mettre à jour le stock.', 'error');
               this.isLoading = false;
           });
   }


   /**
    * Redirige vers la page détaillée d'un produit après un clic sur "Voir produit".
    * @param {Event} event - Événement contenant l'ID du produit.
    */
   handleViewProduct(event) {
       const productId = event.target.dataset.id; // ID du produit
       console.log('Redirection vers la page du produit avec ID :', productId); // Log avant la redirection


       // Navigation vers la page du produit
       this[NavigationMixin.Navigate]({
           type: 'standard__recordPage',
           attributes: {
               recordId: productId,
               objectApiName: 'Product2', // Nom de l'objet
               actionName: 'view', // Action : voir
           },
       });
   }


   /**
    * Affiche un message toast dans l'interface utilisateur.
    * @param {string} title - Titre du message.
    * @param {string} message - Corps du message.
    * @param {string} variant - Type de message (success, error, warning, etc.).
    */
   showToast(title, message, variant) {
       console.log('Affichage du toast :', { title, message, variant }); // Log des détails du toast
       const event = new ShowToastEvent({
           title,
           message,
           variant,
       });
       this.dispatchEvent(event);
   }
// Ajoutez cette propriété pour détecter les erreurs de quantité
get hasQuantityError() {
   // Vérifie si au moins une ligne a une quantité restante négative
   const hasError = this.products.some(
       (product) => product.QuantityInStock__c - product.Quantity < 0
   );
   console.log('Vérification des erreurs de quantité :', hasError);
   return hasError;
}


// Gestion des styles pour afficher une cellule en rouge si la quantité restante est négative
getCellClass(product) {
   const quantityRemaining = product.QuantityInStock__c - product.Quantity;
   console.log('Calcul de la quantité restante pour le produit :', product.Product2.Name, quantityRemaining);
   return quantityRemaining < 0 ? 'error-cell' : '';
}


// Classe pour la ligne conditionnelle
getRowClass(product) {
   const quantityRemaining = product.QuantityInStock__c - product.Quantity;
   return quantityRemaining < 0 ? 'error-row' : '';
}


   /**
    * Retourne une classe pour les lignes où la quantité restante est négative.
    * @param {Object} product - Produit à vérifier.
    * @returns {string} - Classe CSS conditionnelle.
    */
   getRowClass(product) {
       const isNegative = product.Product2.QuantityInStock__c - product.Quantity < 0;
       console.log(`Classe de la ligne pour le produit ID : ${product.Id}, Est négatif ?`, isNegative); // Log pour chaque ligne
       return isNegative ? 'error-row' : '';
   }
    // Méthode pour rafraîchir manuellement les opportunités
    handleRafreshOpportunity() {
       console.log('Tentative de rafraîchissement des opportunités pour recordId:', this.recordId); // Log avant l'appel
       try {
           return refreshApex(this.productsResults); //Appel à la méthode refreshApex
       } catch (error) {
           console.error('Erreur lors du rafraîchissement des opportunités:', error); // Log de l'erreur
       }     
   }
}

