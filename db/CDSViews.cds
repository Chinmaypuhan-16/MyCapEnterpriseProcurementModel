namespace chinmay.views.myviews;

using {
   chinmay.db.master,
   chinmay.db.transaction
} from './data-model';

context CDSViews {
   // if we want the object name and column name alias to be exactly same as in the db
   // then if its sql then its fine , it will take as we will mention here , its case will not be change
   // but in hana (the actual db we will be using )they automatically becomes to upper case ,
   //so to avoid that and having the same respecting case we will use ![ObjectName]
   define view ![POWorklist] as
      select from transaction.purchaseorder {
         key PO_ID                             as ![PurchaseOrderId],
         key Items.PO_ITEM_POS                 as ![ItemPosition],
             PARTNER_GUID.BP_ID                as ![PartnerGuid],
             PARTNER_GUID.COMPANY_NAME         as ![CompanyName],
             Items.GROSS_AMOUNT                as ![GrossAmount],
             Items.NET_AMOUNT                  as ![NetAmount],
             Items.TAX_AMOUNT                  as ![TaxAmount],
             Items.CURRENCY                    as ![CurrencyCode],
             OVERALL_STATUS                    as ![Status],
             Items.PRODUCT_GUID.CATEGORY       as ![Catagory],
             Items.PRODUCT_GUID.DESCRIPTION    as ![ProductName],
             PARTNER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
             PARTNER_GUID.ADDRESS_GUID.CITY    as ![City]
      };

   define view ![ProductHelpView] as
      select from master.product {
         @EndUserText.Label : [
            {language: 'EN', text: 'Product Id'},
            {language: 'HI', text: 'उत्पाद आयडी'}
         ]
         key PRODUCT_ID                 as ![productId],
         DESCRIPTION                as ![Description],
         CATEGORY                   as ![Catagory],
         PRICE                      as ![Price],
         CURRENCY_CODE              as ![CurrencyCode],
         SUPPLIER_GUID.COMPANY_NAME as ![SuplierName]
      };
     define view ![ItemView] as
        select from transaction.poitems {
            key PARENT_KEY.PARTNER_GUID.NODE_KEY as ![SupplierId],
            key PRODUCT_GUID.NODE_KEY            as ![ProductKey],
            GROSS_AMOUNT                     as ![GrossAmount],
            TAX_AMOUNT                       as ![TaxAmount],
            CURRENCY                         as ![CurrencyCode],
            PARENT_KEY.OVERALL_STATUS        as ![Status]
        };
      // view on view along with lazy loading 
      define view ![ProductView] as select from master.product
      ///Mixin - it is a keyword to define loose coupling on dependent data 
      ///which tells the framework to never load the dependent data until requested
      Mixin{
         //$projection - predicate indicate the selection list of the defined fields with alias 
         PO_ITEMS: Association to many ItemView on PO_ITEMS.ProductKey = $projection.ProductId
      } into {
         NODE_KEY as ![ProductId],
         DESCRIPTION as ![ProductName],
         CATEGORY as ![Catagory],
         SUPPLIER_GUID.BP_ID as ![SupplierId],
         SUPPLIER_GUID.COMPANY_NAME as ![SupplierName],
         SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
         //exposed association , @Runtime the data will be loaded on-demand - lazy loading 
         PO_ITEMS as ![To_Items]
      };
   //Create a consumption view - view on view , aggregartion
   define view CProductSalesAnalytics as select from ProductView {
      key ProductName,
      Country,
      round(sum(To_Items.GrossAmount),2) as ![TotalPurchaseAmount] : Decimal(15,2),
      To_Items.CurrencyCode
   } group by ProductName , Country , To_Items.CurrencyCode;
   
}
