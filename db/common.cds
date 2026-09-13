namespace chinmay.common;
using { Currency } from '@sap/cds/common';
// Domain fixed values
type Gender : String(1) enum {
    male ='M';
    female ='F';
    undisclosed = 'U';
};
// when we put ammount in SAP , we always provide a reference field for currency, so we can create a reusable type for currency
// when we put quantity in SAP , we always provide a - UoM
type AmountT : Decimal(10,2) @(
    Semantics.amount.currencycode : 'CURRENCY_code',
    sap.unit : 'CURRENCY_code'
);


//aspect - structure which can be reused in multiple entities
aspect Amount :{
    CURRENCY : Currency @title : '{i18n>XLBL_CURR}';
    GROSS_AMOUNT : AmountT @title : '{i18n>XLBL_GROSS}';
    NET_AMOUNT : AmountT @title : '{i18n>XLBL_NET}';
    TAX_AMOUNT : AmountT @title : '{i18n>XLBL_TAX}';
}


// reusable type that to be used as primary key in all entity(name it as GUID)
type Guid : String(32);
//Adding phone number and and email type with validation
type PhoneNumber : String(30) @assert.format : '^\+?[1-9]\d{9,14}$';
type Email : String(105) @assert.format : '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';