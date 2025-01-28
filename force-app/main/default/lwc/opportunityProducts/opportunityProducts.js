import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getOpportunityLineItems from '@salesforce/apex/OpportunityProductController.getOpportunityLineItems';
import deleteOpportunityLineItem from '@salesforce/apex/OpportunityProductController.deleteOpportunityLineItem';
import updateQuantityInStock from '@salesforce/apex/OpportunityProductController.updateQuantityInStock';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import productDeletedSuccess from '@salesforce/label/c.Product_Deleted_Success';
import seeProductLabel from '@salesforce/label/c.See_Product_label';
import Product_Not_Found from '@salesforce/label/c.Product_Not_Found';
import admin from '@salesforce/label/c.admin';
import Contact_Admin_Message from '@salesforce/label/c.Contact_Admin_Message';
import Delete_Label from '@salesforce/label/c.Delete_Label';
import Delete_Success_Message from '@salesforce/label/c.Delete_Success_Message';
import Invalid_Price_Error from '@salesforce/label/c.Invalid_Price_Error';
import Invalid_Quantity_Error from '@salesforce/label/c.Invalid_Quantity_Error';
import Opportunity_Products_Label from '@salesforce/label/c.Opportunity_Products_Label';
import Product_Delete_Error from '@salesforce/label/c.Product_Delete_Error';
import Product_Name from '@salesforce/label/c.Product_Name';
import Quantity from '@salesforce/label/c.Quantity';
import Quantity_Error from '@salesforce/label/c.Quantity_Error';
import Quantity_Error_Message from '@salesforce/label/c.Quantity_Error_Message';
import Quantity_Exceeds_Stock from '@salesforce/label/c.Quantity_Exceeds_Stock';
import Quantity_in_Stock from '@salesforce/label/c.Quantity_in_Stock';
import Stock_Update_Error from '@salesforce/label/c.Stock_Update_Error';
import Stock_Updated_Success from '@salesforce/label/c.Stock_Updated_Success';
import Total_Price from '@salesforce/label/c.Total_Price';
import Unit_Price from '@salesforce/label/c.Unit_Price';
import Update_Success_Message from '@salesforce/label/c.Update_Success_Message';
import Updated_Issue from '@salesforce/label/c.Updated_Issue';





export default class OpportunityProducts extends NavigationMixin(LightningElement) {

    @api recordId;
    @track products = [];
    @track isLoading = true;
    @track error;
    userProfile;
    productsResults;
    // Grouped labels for better organization
    label = {
        productDeletedSuccess,
        Product_Delete_Error,
        Quantity_Error_Message,
        Delete_Label,
        seeProductLabel,
        Product_Not_Found,
        admin,
        Contact_Admin_Message,
        Delete_Success_Message,
        Invalid_Price_Error,
        Invalid_Quantity_Error,
        Opportunity_Products_Label,
        Product_Name,
        Quantity,
        Quantity_Error,
        Quantity_Exceeds_Stock,
        Quantity_in_Stock,
        Stock_Update_Error,
        Stock_Updated_Success,
        Total_Price,
        Unit_Price,
        Update_Success_Message,
        Updated_Issue,
        
    };

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.userProfile = data.fields.Profile.value.fields.Name.value;
        } else if (error) {
            console.error('Erreur lors de la récupération du profil utilisateur :', error);
        }
    }

    connectedCallback() {
        console.log('this.recordId '+this.recordId)

        this.loadOpportunityLineItems();
    }
    
    loadOpportunityLineItems() {
        this.isLoading = true;
        getOpportunityLineItems({ opportunityId: this.recordId })
            .then((result) => {
                // Traiter les produits et ajouter une classe dynamique poour la quantité
                this.products = result.map((product) => {
                    let hasError = product.Quantity > product.Product2.QuantityInStock__c;
                    let quantity = product.Quantity;
                    let quantityInStock = product.Product2.QuantityInStock__c;
                    return {
                        ...product,
                        quantityClass: hasError ? 'slds-text-color_error' : 'slds-text-color_success',  // classe dynamique
                        hasError, // Flag for conditional text styling
                        rowClass: hasError ? 'error-row' : '' // classe pour l'arrière-plan de la ligne
                    };
                });
                console.log('this.recordId '+JSON.stringify(this.products))

              // Détecter s'il y a des erreurs de quantité
               // this.hasQuantityError = this.products.some((product) => product.quantityClass=== 'slds-text-color_error');
               // this.quantityErrorMessage = this.labels.quantityErrorMessage;
                this.isLoading = false;
            })
            .catch((error) => {
                this.error = error.body.message;
                this.isLoading = false;
            });
    }    
    
    handleDelete(event) {
        const lineItemId = event.target.dataset.id;
        this.isLoading = true;

        deleteOpportunityLineItem({ lineItemId })
            .then(() => {
                this.showToast(this.label.productDeletedSuccess, 'Produit supprimé.', 'success');
                this.products = this.products.filter(product => product.Id !== lineItemId);
                this.isLoading = false;
                this.handleRefreshOpportunity();
            })
            .catch((error) => {
                this.showToast(this.label.productDeleteError, 'Erreur de suppression.', 'error');
                this.isLoading = false;
            });
    }

    handleViewProduct(event) {
        const productId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                objectApiName: 'Product2',
                actionName: 'view',
            },
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }

    // Détecte si au moins une ligne a une erreur de quantité
    get hasQuantityError() {
        return this.products.some(product => product.Product2.QuantityInStock__c - product.Quantity < 0);
    }

    // Renvoie une classe CSS pour une ligne en fonction de la quantité restante
    getRowClass(product) {
        return product.Product2.QuantityInStock__c - product.Quantity < 0 ? 'error-row' : '';
    }

    // Rafraîchit les opportunités après une modification
    handleRefreshOpportunity() {
        refreshApex(this.productsResults);
    }

   /**
    * Vérifie si l'utilisateur est un administrateur système.
    * @returns {boolean} - Vrai si l'utilisateur est administrateur système.
    */
   get isSystemAdmin() {
    const result = this.userProfile === this.label.admin;
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

}
