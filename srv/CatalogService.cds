using {chinmay.db.master, chinmay.db.transaction} from '../db/data-model';
using {chinmay.views.myviews} from '../db/CDSViews';

service CatalogService @(path: 'CatalogService' , requires : 'authenticated-user') {
    ///Entityset which offers all the GET, PUT, POST, DELETE

    //code for authentication - start
    entity EmployeSet @(restrict :[
        {grant : ['READ'], to : 'Display' , where : 'bankName = $user.BankName'},
        {grant : ['WRITE'], to : 'Editor'}
    ]) as projection on master.employees;
    entity AddressSet @(restrict :[
        {grant : ['READ'], to : 'Viewer' , where : 'COUNTRY = $user.Country'}
    ]) as projection on master.address;
    //code for authentication - end

    entity BusinessPartnerSet as projection on master.businesspartner;
    
    entity POs @(
        odata.draft.enabled : true,
        Common.DefaultValuesFunction : 'getOrderDefault'
    ) as projection on transaction.purchaseorder{
        *,
        case OVERALL_STATUS
         when 'A' then 'Approved'
         when 'D' then 'Delivered'
         when 'X' then 'Rejected'
         when 'N' then 'New'
         else 'Pending'
             end as OverallStatusText: String(10),
        case OVERALL_STATUS
         when 'A' then 3
         when 'D' then 3
         when 'X' then 2
         when 'N' then 1
         else 2
         end as IconColor: Integer
    }
    //actions
    actions{
        action boost() returns POs;
        action setDelivered() returns POs;
    }
    entity POItems as projection on transaction.poitems;
    //Expose the CDS entity
    @cds.redirection.target
    entity ProductSet as projection on myviews.CDSViews.ProductView;
    entity ProductHelpSet as projection on myviews.CDSViews.ProductHelpView;

    //a non instance bound function --- if you want multiple => array of
    function getMostExpensiveOrder() returns POs ;
    function getOrderDefault() returns POs;
};
