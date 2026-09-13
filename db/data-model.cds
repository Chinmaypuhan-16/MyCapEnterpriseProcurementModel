//refering a reusable module from SAP which offers many types and aspects
//Contains multiple reusable types and aspects whichwe can refer in our entities
using {
    cuid,
    Currency
} from '@sap/cds/common';
using {chinmay.common as com} from './common';

// a namespace represents a unique ID of our project
// we can differentiate projects of different companies by using different namespaces
//e.g company.project.team --> ibm.fin.ap , ibm.hr.payroll
namespace chinmay.db;

//context represents the usage of the entitird - grouping
//e,g. context for master , transactional, analytical, etc
context master {
    
    entity businesspartner {
        key NODE_KEY      : com.Guid @title : '{i18n>XLBL_BPKEY}';
            BP_ROLE       : String(2);
            EMAIL_ADDRESS : String(105);
            PHONE_NUMBER  : String(32);
            FAX_NUMBER    : String(32);
            WEB_ADRESS    : String(44);
            BP_ID         : String(32)  @title : '{i18n>XLBL_BPID}';
            COMPANY_NAME  : String(250) @title : '{i18n>XLBL_COMPANY}';
            //foreign key relationship which is a loose coupling
            ADDRESS_GUID  : Association to one address @title : '{i18n>XLBL_ADDRKEY}';
    }

    entity address {
        key NODE_KEY        : com.Guid @title : '{i18n>XLBL_ADDRKEY}';
            CITY            : String(44);
            POSTAL_CODE     : String(8);
            STREET          : String(44);
            BUILDING        : String(128);
            COUNTRY         : String(44) @title : '{i18n>XLBL_COUNTRY}';
            ADDRESS_TYPE    : String(44);
            VAL_START_DATE  : Date;
            VAL_END_DATE    : Date;
            LATITUDE        : Decimal;
            LONGITUDE       : Decimal;
            //backward relation - help us to read the data of BP from address(this is non mandatory)
            //$self - predicate to refer current table PK column
            businesspartner : Association to one businesspartner
                                  on businesspartner.ADDRESS_GUID = $self;
    }

    entity product {
        key NODE_KEY       : com.Guid @title : '{i18n>XLBL_PRODKEY}';
            PRODUCT_ID     : String(28) @title : '{i18n>XLBL_PRODID}';
            TYPE_CODE      : String(2);
            CATEGORY       : String(32) @title : '{i18n>XLBL_PRODCAT}';
            DESCRIPTION    : localized String(255) @title : '{i18n>XLBL_PRODDESC}';
            SUPPLIER_GUID  : Association to businesspartner @title : '{i18n>XLBL_BPKEY}';
            TAX_TARIF_CODE : Integer;
            MEASURE_UNIT   : String(2);
            WEIGHT_MEASURE : Decimal(5,2);
            WEIGHT_UNIT    : String(2);
            CURRENCY_CODE  : String(4);
            PRICE          : Decimal(15, 2);
            WIDTH          : Decimal(15, 2);
            DEPTH          : Decimal(15, 2);
            HEIGHT         : Decimal(15, 2);
            DIM_UNIT       : String(2);
    }

    entity employees : cuid {
        //key ID: UUID;
        nameFirst     : String(40);
        nameMiddle    : String(40);
        nameLast      : String(40);
        nameInitials  : String(40);
        sex           : com.Gender;
        language      : String(5);
        phoneNumber   : com.PhoneNumber;
        email         : com.Email;
        loginName     : String(32);
        CURRENCY      : Currency;
        salaryAmount  : com.AmountT;
        accountNumber : String(16);
        bankId        : String(8);
        bankName      : String(6);
    }
}
context transaction {
    entity purchaseorder : com.Amount  { // this Amount is an aspect in common.cds file which is reusable in multiple entities
        key NODE_KEY         : com.Guid;
            PO_ID            : String(40) @title : '{i18n>XLBL_POID}';
            PARTNER_GUID     : Association to one master.businesspartner @title : '{i18n>XLBL_BPKEY}';
            LIFECYCLE_STATUS : String(1) @title : '{i18n>XLBL_LIFESTATUS}';
            OVERALL_STATUS   : String(1) @title : '{i18n>XLBL_OVERALLSTATUS}';
            Items            : Composition of many poitems
                                   on Items.PARENT_KEY = $self;
    };

    //poitems = purchaeorder items
    entity poitems : com.Amount{ // this Amount is an aspect in common.cds file which is reusable in multiple entities
            key NODE_KEY     : com.Guid;
            PARENT_KEY   : Association to one purchaseorder @title : '{i18n>XLBL_POID}';
            PRODUCT_GUID : Association to one master.product @title : '{i18n>XCOL_POKEY}';
            PO_ITEM_POS  : Integer @title : '{i18n>ITEMPOS}';
    };
}
