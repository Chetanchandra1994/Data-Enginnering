CREATE OR REPLACE STORAGE INTEGRATION ADVWORKS_GCS_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://advworks-dev-ingestion/fact_internet_sales/');

/*
status
Integration ADVWORKS_GCS_INT successfully created.
*/


DESC INTEGRATION ADVWORKS_GCS_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
STORAGE_PROVIDER	String	GCS	
STORAGE_ALLOWED_LOCATIONS	List	gcs://advworks-dev-ingestion/fact_internet_sales/	[]
STORAGE_BLOCKED_LOCATIONS	List		[]
USE_PRIVATELINK_ENDPOINT	Boolean	false	false
STORAGE_GCP_SERVICE_ACCOUNT	String	kerg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/

CREATE OR REPLACE NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_INT
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = GCP_PUBSUB
  ENABLED = TRUE
  GCP_PUBSUB_SUBSCRIPTION_NAME = 'projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub';
/*
status
Integration ADVWORKS_GCS_PUBSUB_INT successfully created.
*/

DESC NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
DIRECTION	String	INBOUND	
GCP_PUBSUB_SUBSCRIPTION_NAME	String	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub	
GCP_PUBSUB_SERVICE_ACCOUNT	String	kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/

CREATE OR REPLACE FILE FORMAT ADVWORKS_DEV.LANDING.FF_FACT_INTERNET_SALES_JSONL
  TYPE = JSON
  STRIP_OUTER_ARRAY = FALSE;

/*
status
File format FF_FACT_INTERNET_SALES_JSONL successfully created.
*/

-- ADVWORKS_GCS_INT

CREATE OR REPLACE STAGE ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES
  URL = 'gcs://advworks-dev-ingestion/fact_internet_sales/'
  STORAGE_INTEGRATION = ADVWORKS_GCS_INT
  FILE_FORMAT = ADVWORKS_DEV.LANDING.FF_FACT_INTERNET_SALES_JSONL;
/*
status
Stage area STG_FACT_INTERNET_SALES successfully created.
*/

DESC STAGE ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES;
/*
parent_property	property	property_type	property_value	property_default
STAGE_FILE_FORMAT	FORMAT_NAME	String	ADVWORKS_DEV.LANDING.FF_FACT_INTERNET_SALES_JSONL	
STAGE_COPY_OPTIONS	ON_ERROR	String	ABORT_STATEMENT	ABORT_STATEMENT
STAGE_COPY_OPTIONS	SIZE_LIMIT	Long		
STAGE_COPY_OPTIONS	PURGE	Boolean	false	false
STAGE_COPY_OPTIONS	RETURN_FAILED_ONLY	Boolean	false	false
STAGE_COPY_OPTIONS	ENFORCE_LENGTH	Boolean	true	true
STAGE_COPY_OPTIONS	TRUNCATECOLUMNS	Boolean	false	false
STAGE_COPY_OPTIONS	FORCE	Boolean	false	false
STAGE_LOCATION	URL	String	["gcs://advworks-dev-ingestion/fact_internet_sales/"]	
STAGE_INTEGRATION	STORAGE_INTEGRATION	String	ADVWORKS_GCS_INT	
DIRECTORY	ENABLE	Boolean	false	false
DIRECTORY	AUTO_REFRESH	Boolean	false	false
PRIVATELINK	USE_PRIVATELINK_ENDPOINT	Boolean	false	false
*/

LIST @ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES;
/*
name	size	md5	last_modified
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_001.jsonl	670039	3ddcdb9a07a608a611f513ff549daccb	Mon, 7 Sep 2026 16:40:02 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_002.jsonl	670270	e16f1119444aa36c46831d5b3c9b8a4e	Mon, 7 Sep 2026 16:40:04 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_003.jsonl	671676	4f2a4c6fdfe25c7633497b32e10ff3aa	Mon, 7 Sep 2026 16:40:06 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_004.jsonl	671583	c6415f3816d71bf7a6e18d9d3b6f11ed	Mon, 7 Sep 2026 16:40:09 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_005.jsonl	671701	8bbef4db51d60752ec67c8336e16f439	Mon, 7 Sep 2026 16:40:11 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_006.jsonl	664444	622dadea826a3ceca1ed12bc5738b5bc	Mon, 7 Sep 2026 16:40:14 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_007.jsonl	658363	095246154b52afc92d612f6ace69b6f7	Mon, 7 Sep 2026 16:40:16 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_008.jsonl	655758	a4fa15ada64a9414d8eda783bc24656b	Mon, 7 Sep 2026 16:40:18 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_009.jsonl	655806	d78f19a5fb5a393ef1af1ed1ec69bae5	Mon, 7 Sep 2026 16:40:21 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_010.jsonl	656076	a8c1d89fd897781aec6a7a333943d087	Mon, 7 Sep 2026 16:40:23 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_011.jsonl	655969	6c8af2282dcb5f7c9c3d77e1ce471356	Mon, 7 Sep 2026 16:40:25 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_012.jsonl	656168	0374d7eb0c3912116e1bfbb0150b1dbf	Mon, 7 Sep 2026 16:40:28 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_013.jsonl	655982	0c9265bc48e7d457fc54b2d5f0579a34	Mon, 7 Sep 2026 16:40:30 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_014.jsonl	656330	c0b3ab0f3b4083c9fc60d93ebe771c17	Mon, 7 Sep 2026 16:40:32 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_015.jsonl	655932	b0f67ad5f5295c2c94fc6aa80b759ade	Mon, 7 Sep 2026 16:40:35 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_016.jsonl	656185	2c69d4c5677220a8c88d52d361d3d9d8	Mon, 7 Sep 2026 16:40:37 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_017.jsonl	656190	8e23e84584d81b65876b41de249e0dbc	Mon, 7 Sep 2026 16:40:40 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_018.jsonl	655995	b2178243dfc3d89d477cb4c10a53eace	Mon, 7 Sep 2026 16:40:43 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_019.jsonl	656347	b2908fadcbbd1af1eb24e6df919589ae	Mon, 7 Sep 2026 16:40:46 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_020.jsonl	656196	114128c582966a2171f183d8b71f4f56	Mon, 7 Sep 2026 16:40:48 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_021.jsonl	656435	13889a79fb463c26795d62ffe46bab32	Mon, 7 Sep 2026 16:40:50 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_022.jsonl	656376	133f6c450c0079e4f953cc37432a2f05	Mon, 7 Sep 2026 16:40:53 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_023.jsonl	656416	ce0e76b06d112cf1606f3fbed299bf43	Mon, 7 Sep 2026 16:40:55 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_024.jsonl	657057	0ed50ae0423251d9756a2977328b54ce	Mon, 7 Sep 2026 16:40:57 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_025.jsonl	656862	d3c4bd0dde6ed4bc70c24d846e9b2d72	Mon, 7 Sep 2026 16:41:00 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_026.jsonl	657004	d450c43413de84fa626f170b6525cb74	Mon, 7 Sep 2026 16:41:02 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_027.jsonl	656797	576b8176e1e8d7dd4de4f35faa156867	Mon, 7 Sep 2026 16:41:05 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_028.jsonl	656913	e56cf1997d797c897c62fff326dabe77	Mon, 7 Sep 2026 16:41:07 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_029.jsonl	656211	52a97b3cb72f9370b18c669094ac98de	Mon, 7 Sep 2026 16:41:09 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_030.jsonl	656488	e1db6c36559a3e6f1bf7618acf700be7	Mon, 7 Sep 2026 16:41:12 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_031.jsonl	656243	606858583f8275dbfdae49029a657709	Mon, 7 Sep 2026 16:41:14 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_032.jsonl	656532	b935e7e87659d895c4db05b8273b078d	Mon, 7 Sep 2026 16:41:16 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_033.jsonl	656413	6cf042142464fffb96d318bebfff172e	Mon, 7 Sep 2026 16:41:19 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_034.jsonl	656874	780dbba359276d94a452cdbb71bb5a77	Mon, 7 Sep 2026 16:41:21 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_035.jsonl	656347	310fafdf4a1e94a8f727e29683dbf58c	Mon, 7 Sep 2026 16:41:25 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_036.jsonl	656530	60c4f3ce70aa6c51fa145558b7c8d3cc	Mon, 7 Sep 2026 16:41:27 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_037.jsonl	656475	9dfb44ba329633d75d5b5b8c80fd6c62	Mon, 7 Sep 2026 16:41:29 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_038.jsonl	656499	e0476945c08f8f8c821322f939b6deae	Mon, 7 Sep 2026 16:41:32 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_039.jsonl	656944	13575b40765a88011090096df610a442	Mon, 7 Sep 2026 16:41:34 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_040.jsonl	656673	4978f2f8a2191d814da7ee194e7af30e	Mon, 7 Sep 2026 16:41:36 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_041.jsonl	656748	380f0f80bf64d42269b64fd8de26839a	Mon, 7 Sep 2026 16:41:39 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_042.jsonl	656512	2bc602c8cbc52b8719477c915e9d651b	Mon, 7 Sep 2026 16:41:41 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_043.jsonl	656477	c82550b6a0a00297c7f8bd057cdbf41f	Mon, 7 Sep 2026 16:41:43 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_044.jsonl	656859	3b58667e7999d81c4bd022e418e8b425	Mon, 7 Sep 2026 16:41:46 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_045.jsonl	656687	36aff3858c0387af40ff8aac5f0f2f18	Mon, 7 Sep 2026 16:41:48 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_046.jsonl	656731	cfe702a826bb8779d2fe3434d7285f6b	Mon, 7 Sep 2026 16:41:50 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_047.jsonl	656955	cd0c1095f7b29e1658791cbce2886e99	Mon, 7 Sep 2026 16:41:53 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_048.jsonl	656554	d4ca3c78599fbc2c7b29d64e362bacb4	Mon, 7 Sep 2026 16:41:55 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_049.jsonl	656943	9ddb173dae270f0066bf1db237e1caa8	Mon, 7 Sep 2026 16:41:57 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_050.jsonl	656518	6707207838df97b02827a3a8034e6179	Mon, 7 Sep 2026 16:42:00 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_051.jsonl	657403	a5b40f8fe7a3c48933e5f3218cb75e6f	Mon, 7 Sep 2026 16:42:02 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_052.jsonl	657038	8119acd737e419e452372a2a398ecd52	Mon, 7 Sep 2026 16:42:04 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_053.jsonl	656780	608af3cb2fb1f913a2f7bd1b651a2bcc	Mon, 7 Sep 2026 16:42:07 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_054.jsonl	657129	54c636b05b2261060e908056a73a5241	Mon, 7 Sep 2026 16:42:09 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_055.jsonl	657031	698b049a26416f757b80e3c54f62bb45	Mon, 7 Sep 2026 16:42:11 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_056.jsonl	657243	5a1a79d9ee526766cc42511c68156eb3	Mon, 7 Sep 2026 16:42:14 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_057.jsonl	657008	bf116892c956545edd0a1f5274828d07	Mon, 7 Sep 2026 16:42:16 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_058.jsonl	657031	c0d1d082a882e14838e406e25e01aba6	Mon, 7 Sep 2026 16:42:18 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_059.jsonl	655038	a9b411b4a4042f7a4bd2c63476872cc6	Mon, 7 Sep 2026 16:42:21 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_060.jsonl	654767	9b08db3192e5e8eb9b4574aa95568981	Mon, 7 Sep 2026 16:42:23 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_061.jsonl	260598	e300c3fbbba43b1ca07a5470e943e4b9	Mon, 7 Sep 2026 16:42:25 GMT
gcs://advworks-dev-ingestion/fact_internet_sales/test/FactInternetSales_batch_001.jsonl	671039	d6e8074134b3f756942fad8286b01e9b	Sun, 6 Sep 2026 18:11:31 GMT
*/

USE DATABASE ADVWORKS_DEV;
USE SCHEMA LANDING;

CREATE OR REPLACE TABLE FACT_INTERNET_SALES (
    PRODUCTKEY                NUMBER,
    ORDERDATEKEY              NUMBER,
    DUEDATEKEY                NUMBER,
    SHIPDATEKEY               NUMBER,
    CUSTOMERKEY               NUMBER,
    PROMOTIONKEY              NUMBER,
    CURRENCYKEY               NUMBER,
    SALESTERRITORYKEY         NUMBER,
    SALESORDERNUMBER          VARCHAR,
    SALESORDERLINENUMBER      NUMBER,
    REVISIONNUMBER            NUMBER,
    ORDERQUANTITY             NUMBER,
    UNITPRICE                 NUMBER(19,4),
    EXTENDEDAMOUNT             NUMBER(19,4),
    UNITPRICEDISCOUNTPCT      NUMBER(19,4),
    DISCOUNTAMOUNT             NUMBER(19,4),
    PRODUCTSTANDARDCOST       NUMBER(19,4),
    TOTALPRODUCTCOST          NUMBER(19,4),
    SALESAMOUNT                NUMBER(19,4),
    TAXAMT                    NUMBER(19,4),
    FREIGHT                   NUMBER(19,4),
    CARRIERTRACKINGNUMBER     VARCHAR,
    CUSTOMERPONUMBER          VARCHAR,
    ORDERDATE                 TIMESTAMP_NTZ,
    DUEDATE                   TIMESTAMP_NTZ,
    SHIPDATE                  TIMESTAMP_NTZ
);
/*
status
Table FACT_INTERNET_SALES successfully created.
*/

DESC TABLE ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
name	type	kind	null?	default	primary key	unique key	check	expression	comment	policy name	privacy domain	write default
PRODUCTKEY	NUMBER(38,0)	COLUMN	Y		N	N						
ORDERDATEKEY	NUMBER(38,0)	COLUMN	Y		N	N						
DUEDATEKEY	NUMBER(38,0)	COLUMN	Y		N	N						
SHIPDATEKEY	NUMBER(38,0)	COLUMN	Y		N	N						
CUSTOMERKEY	NUMBER(38,0)	COLUMN	Y		N	N						
PROMOTIONKEY	NUMBER(38,0)	COLUMN	Y		N	N						
CURRENCYKEY	NUMBER(38,0)	COLUMN	Y		N	N						
SALESTERRITORYKEY	NUMBER(38,0)	COLUMN	Y		N	N						
SALESORDERNUMBER	VARCHAR(16777216)	COLUMN	Y		N	N						
SALESORDERLINENUMBER	NUMBER(38,0)	COLUMN	Y		N	N						
REVISIONNUMBER	NUMBER(38,0)	COLUMN	Y		N	N						
ORDERQUANTITY	NUMBER(38,0)	COLUMN	Y		N	N						
UNITPRICE	NUMBER(19,4)	COLUMN	Y		N	N						
EXTENDEDAMOUNT	NUMBER(19,4)	COLUMN	Y		N	N						
UNITPRICEDISCOUNTPCT	NUMBER(19,4)	COLUMN	Y		N	N						
DISCOUNTAMOUNT	NUMBER(19,4)	COLUMN	Y		N	N						
PRODUCTSTANDARDCOST	NUMBER(19,4)	COLUMN	Y		N	N						
TOTALPRODUCTCOST	NUMBER(19,4)	COLUMN	Y		N	N						
SALESAMOUNT	NUMBER(19,4)	COLUMN	Y		N	N						
TAXAMT	NUMBER(19,4)	COLUMN	Y		N	N						
FREIGHT	NUMBER(19,4)	COLUMN	Y		N	N						
CARRIERTRACKINGNUMBER	VARCHAR(16777216)	COLUMN	Y		N	N						
CUSTOMERPONUMBER	VARCHAR(16777216)	COLUMN	Y		N	N						
ORDERDATE	TIMESTAMP_NTZ(9)	COLUMN	Y		N	N						
DUEDATE	TIMESTAMP_NTZ(9)	COLUMN	Y		N	N						
SHIPDATE	TIMESTAMP_NTZ(9)	COLUMN	Y		N	N						
*/

SELECT $1 FROM @ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES/FactInternetSales_batch_001.jsonl LIMIT 3;
/*
$1
{
  "CarrierTrackingNumber": null,
  "CurrencyKey": 19,
  "CustomerKey": 21768,
  "CustomerPONumber": null,
  "DiscountAmount": 0,
  "DueDate": "2011-01-10T00:00:00",
  "DueDateKey": 20110110,
  "ExtendedAmount": 3578.27,
  "Freight": 89.4568,
  "OrderDate": "2010-12-29T00:00:00",
  "OrderDateKey": 20101229,
  "OrderQuantity": 1,
  "ProductKey": 310,
  "ProductStandardCost": 2171.2942,
  "PromotionKey": 1,
  "RevisionNumber": 1,
  "SalesAmount": 3578.27,
  "SalesOrderLineNumber": 1,
  "SalesOrderNumber": "SO43697",
  "SalesTerritoryKey": 6,
  "ShipDate": "2011-01-05T00:00:00",
  "ShipDateKey": 20110105,
  "TaxAmt": 286.2616,
  "TotalProductCost": 2171.2942,
  "UnitPrice": 3578.27,
  "UnitPriceDiscountPct": 0
}
{
  "CarrierTrackingNumber": null,
  "CurrencyKey": 39,
  "CustomerKey": 28389,
  "CustomerPONumber": null,
  "DiscountAmount": 0,
  "DueDate": "2011-01-10T00:00:00",
  "DueDateKey": 20110110,
  "ExtendedAmount": 3399.99,
  "Freight": 84.9998,
  "OrderDate": "2010-12-29T00:00:00",
  "OrderDateKey": 20101229,
  "OrderQuantity": 1,
  "ProductKey": 346,
  "ProductStandardCost": 1912.1544,
  "PromotionKey": 1,
  "RevisionNumber": 1,
  "SalesAmount": 3399.99,
  "SalesOrderLineNumber": 1,
  "SalesOrderNumber": "SO43698",
  "SalesTerritoryKey": 7,
  "ShipDate": "2011-01-05T00:00:00",
  "ShipDateKey": 20110105,
  "TaxAmt": 271.9992,
  "TotalProductCost": 1912.1544,
  "UnitPrice": 3399.99,
  "UnitPriceDiscountPct": 0
}
{
  "CarrierTrackingNumber": null,
  "CurrencyKey": 100,
  "CustomerKey": 25863,
  "CustomerPONumber": null,
  "DiscountAmount": 0,
  "DueDate": "2011-01-10T00:00:00",
  "DueDateKey": 20110110,
  "ExtendedAmount": 3399.99,
  "Freight": 84.9998,
  "OrderDate": "2010-12-29T00:00:00",
  "OrderDateKey": 20101229,
  "OrderQuantity": 1,
  "ProductKey": 346,
  "ProductStandardCost": 1912.1544,
  "PromotionKey": 1,
  "RevisionNumber": 1,
  "SalesAmount": 3399.99,
  "SalesOrderLineNumber": 1,
  "SalesOrderNumber": "SO43699",
  "SalesTerritoryKey": 1,
  "ShipDate": "2011-01-05T00:00:00",
  "ShipDateKey": 20110105,
  "TaxAmt": 271.9992,
  "TotalProductCost": 1912.1544,
  "UnitPrice": 3399.99,
  "UnitPriceDiscountPct": 0
}
*/

COPY INTO ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
FROM (
    SELECT
        $1:"ProductKey"::NUMBER,
        $1:"OrderDateKey"::NUMBER,
        $1:"DueDateKey"::NUMBER,
        $1:"ShipDateKey"::NUMBER,
        $1:"CustomerKey"::NUMBER,
        $1:"PromotionKey"::NUMBER,
        $1:"CurrencyKey"::NUMBER,
        $1:"SalesTerritoryKey"::NUMBER,
        $1:"SalesOrderNumber"::VARCHAR,
        $1:"SalesOrderLineNumber"::NUMBER,
        $1:"RevisionNumber"::NUMBER,
        $1:"OrderQuantity"::NUMBER,
        $1:"UnitPrice"::NUMBER(19,4),
        $1:"ExtendedAmount"::NUMBER(19,4),
        $1:"UnitPriceDiscountPct"::NUMBER(19,4),
        $1:"DiscountAmount"::NUMBER(19,4),
        $1:"ProductStandardCost"::NUMBER(19,4),
        $1:"TotalProductCost"::NUMBER(19,4),
        $1:"SalesAmount"::NUMBER(19,4),
        $1:"TaxAmt"::NUMBER(19,4),
        $1:"Freight"::NUMBER(19,4),
        $1:"CarrierTrackingNumber"::VARCHAR,
        $1:"CustomerPONumber"::VARCHAR,
        $1:"OrderDate"::TIMESTAMP_NTZ,
        $1:"DueDate"::TIMESTAMP_NTZ,
        $1:"ShipDate"::TIMESTAMP_NTZ
    FROM @ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES/FactInternetSales_batch_001.jsonl
)
FILE_FORMAT = (FORMAT_NAME = ADVWORKS_DEV.LANDING.FF_FACT_INTERNET_SALES_JSONL);
/*
file	status	rows_parsed	rows_loaded	error_limit	errors_seen	first_error	first_error_line	first_error_character	first_error_column_name
gcs://advworks-dev-ingestion/fact_internet_sales/FactInternetSales_batch_001.jsonl	LOADED	1000	1000	1	0				
*/

SELECT COUNT(*) AS ROW_COUNT FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES; -- 1000

SELECT *
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
LIMIT 10;
/*
PRODUCTKEY	ORDERDATEKEY	DUEDATEKEY	SHIPDATEKEY	CUSTOMERKEY	PROMOTIONKEY	CURRENCYKEY	SALESTERRITORYKEY	SALESORDERNUMBER	SALESORDERLINENUMBER	REVISIONNUMBER	ORDERQUANTITY	UNITPRICE	EXTENDEDAMOUNT	UNITPRICEDISCOUNTPCT	DISCOUNTAMOUNT	PRODUCTSTANDARDCOST	TOTALPRODUCTCOST	SALESAMOUNT	TAXAMT	FREIGHT	CARRIERTRACKINGNUMBER	CUSTOMERPONUMBER	ORDERDATE	DUEDATE	SHIPDATE
310	20101229	20110110	20110105	21768	1	19	6	SO43697	1	1	1	3578.2700	3578.2700	0.0000	0.0000	2171.2942	2171.2942	3578.2700	286.2616	89.4568			2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000
346	20101229	20110110	20110105	28389	1	39	7	SO43698	1	1	1	3399.9900	3399.9900	0.0000	0.0000	1912.1544	1912.1544	3399.9900	271.9992	84.9998			2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000
346	20101229	20110110	20110105	25863	1	100	1	SO43699	1	1	1	3399.9900	3399.9900	0.0000	0.0000	1912.1544	1912.1544	3399.9900	271.9992	84.9998			2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000
336	20101229	20110110	20110105	14501	1	100	4	SO43700	1	1	1	699.0982	699.0982	0.0000	0.0000	413.1463	413.1463	699.0982	55.9279	17.4775			2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000
346	20101229	20110110	20110105	11003	1	6	9	SO43701	1	1	1	3399.9900	3399.9900	0.0000	0.0000	1912.1544	1912.1544	3399.9900	271.9992	84.9998			2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000
311	20101230	20110111	20110106	27645	1	100	4	SO43702	1	1	1	3578.2700	3578.2700	0.0000	0.0000	2171.2942	2171.2942	3578.2700	286.2616	89.4568			2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000
310	20101230	20110111	20110106	16624	1	6	9	SO43703	1	1	1	3578.2700	3578.2700	0.0000	0.0000	2171.2942	2171.2942	3578.2700	286.2616	89.4568			2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000
351	20101230	20110111	20110106	11005	1	6	9	SO43704	1	1	1	3374.9900	3374.9900	0.0000	0.0000	1898.0944	1898.0944	3374.9900	269.9992	84.3748			2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000
344	20101230	20110111	20110106	11011	1	6	9	SO43705	1	1	1	3399.9900	3399.9900	0.0000	0.0000	1912.1544	1912.1544	3399.9900	271.9992	84.9998			2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000
312	20101231	20110112	20110107	27621	1	100	4	SO43706	1	1	1	3578.2700	3578.2700	0.0000	0.0000	2171.2942	2171.2942	3578.2700	286.2616	89.4568			2010-12-31 00:00:00.000	2011-01-12 00:00:00.000	2011-01-07 00:00:00.000
*/

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT(DISTINCT SALESORDERNUMBER || '-' || SALESORDERLINENUMBER) AS DISTINCT_ORDER_LINES
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
TOTAL_ROWS	DISTINCT_ORDER_LINES
1000	1000
*/

SELECT
    COUNT(*) AS ROW_COUNT,
    SUM(SALESAMOUNT) AS TOTAL_SALES,
    SUM(TOTALPRODUCTCOST) AS TOTAL_PRODUCT_COST,
    SUM(TAXAMT) AS TOTAL_TAX,
    SUM(FREIGHT) AS TOTAL_FREIGHT
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*ROW_COUNT	TOTAL_SALES	TOTAL_PRODUCT_COST	TOTAL_TAX	TOTAL_FREIGHT
1000	3223116.8784	1928831.4494	257849.3552	80577.9714
*/

CREATE OR REPLACE PIPE ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES
  AUTO_INGEST = TRUE
  INTEGRATION = 'ADVWORKS_GCS_PUBSUB_INT'
AS
COPY INTO ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
FROM (
    SELECT
        $1:"ProductKey"::NUMBER,
        $1:"OrderDateKey"::NUMBER,
        $1:"DueDateKey"::NUMBER,
        $1:"ShipDateKey"::NUMBER,
        $1:"CustomerKey"::NUMBER,
        $1:"PromotionKey"::NUMBER,
        $1:"CurrencyKey"::NUMBER,
        $1:"SalesTerritoryKey"::NUMBER,
        $1:"SalesOrderNumber"::VARCHAR,
        $1:"SalesOrderLineNumber"::NUMBER,
        $1:"RevisionNumber"::NUMBER,
        $1:"OrderQuantity"::NUMBER,
        $1:"UnitPrice"::NUMBER(19,4),
        $1:"ExtendedAmount"::NUMBER(19,4),
        $1:"UnitPriceDiscountPct"::NUMBER(19,4),
        $1:"DiscountAmount"::NUMBER(19,4),
        $1:"ProductStandardCost"::NUMBER(19,4),
        $1:"TotalProductCost"::NUMBER(19,4),
        $1:"SalesAmount"::NUMBER(19,4),
        $1:"TaxAmt"::NUMBER(19,4),
        $1:"Freight"::NUMBER(19,4),
        $1:"CarrierTrackingNumber"::VARCHAR,
        $1:"CustomerPONumber"::VARCHAR,
        $1:"OrderDate"::TIMESTAMP_NTZ,
        $1:"DueDate"::TIMESTAMP_NTZ,
        $1:"ShipDate"::TIMESTAMP_NTZ
    FROM @ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES
);
/*
status
Pipe PIPE_FACT_INTERNET_SALES successfully created.
*/

SHOW PIPES LIKE 'PIPE_FACT_INTERNET_SALES'
IN SCHEMA ADVWORKS_DEV.LANDING;
/*
created_on	name	database_name	schema_name	definition	owner	notification_channel	comment	integration	pattern	error_integration	owner_role_type	invalid_reason	kind	is_snowflake_managed
2026-09-08 01:08:22.806 -0700	PIPE_FACT_INTERNET_SALES	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
FROM (
    SELECT
        $1:"ProductKey"::NUMBER,
        $1:"OrderDateKey"::NUMBER,
        $1:"DueDateKey"::NUMBER,
        $1:"ShipDateKey"::NUMBER,
        $1:"CustomerKey"::NUMBER,
        $1:"PromotionKey"::NUMBER,
        $1:"CurrencyKey"::NUMBER,
        $1:"SalesTerritoryKey"::NUMBER,
        $1:"SalesOrderNumber"::VARCHAR,
        $1:"SalesOrderLineNumber"::NUMBER,
        $1:"RevisionNumber"::NUMBER,
        $1:"OrderQuantity"::NUMBER,
        $1:"UnitPrice"::NUMBER(19,4),
        $1:"ExtendedAmount"::NUMBER(19,4),
        $1:"UnitPriceDiscountPct"::NUMBER(19,4),
        $1:"DiscountAmount"::NUMBER(19,4),
        $1:"ProductStandardCost"::NUMBER(19,4),
        $1:"TotalProductCost"::NUMBER(19,4),
        $1:"SalesAmount"::NUMBER(19,4),
        $1:"TaxAmt"::NUMBER(19,4),
        $1:"Freight"::NUMBER(19,4),
        $1:"CarrierTrackingNumber"::VARCHAR,
        $1:"CustomerPONumber"::VARCHAR,
        $1:"OrderDate"::TIMESTAMP_NTZ,
        $1:"DueDate"::TIMESTAMP_NTZ,
        $1:"ShipDate"::TIMESTAMP_NTZ
    FROM @ADVWORKS_DEV.LANDING.STG_FACT_INTERNET_SALES
)	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub		ADVWORKS_GCS_PUBSUB_INT			ROLE		STAGE	false
*/

SELECT SYSTEM$PIPE_STATUS(
    'ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES'
);
/*
"SYSTEM$PIPE_STATUS(
    'ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES'
)"
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-08T08:09:25.509Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT SYSTEM$PIPE_STATUS(
    'ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES'
);
/*
"SYSTEM$PIPE_STATUS(
    'ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES'
)"
{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-08T08:48:44.56Z","lastIngestedFilePath":"Snowpipe_test_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub","numOutstandingMessagesOnChannel":1,"lastReceivedMessageTimestamp":"2026-09-08T08:48:43.949Z","lastForwardedMessageTimestamp":"2026-09-08T08:48:47.71Z","lastPulledFromChannelTimestamp":"2026-09-08T08:50:25.48Z","lastForwardedFilePath":"advworks-dev-ingestion/fact_internet_sales/Snowpipe_test_001.jsonl","pendingHistoryRefreshJobsCount":0}
*/

SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
ROW_COUNT
2000
*/

SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES',
        START_TIME => DATEADD('hour', -1, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME DESC;
/*
FILE_NAME	STATUS	ROW_COUNT	LAST_LOAD_TIME
Snowpipe_test_001.jsonl	Loaded	1000	2026-09-08 01:49:10.712 -0700
*/


SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES',
        START_TIME => DATEADD('hour', -2, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME;
/*
FILE_NAME	STATUS	ROW_COUNT	LAST_LOAD_TIME
FactInternetSales_batch_001.jsonl	Loaded	1000	2026-09-08 00:29:58.113 -0700
Snowpipe_test_001.jsonl	Loaded	1000	2026-09-08 01:49:10.712 -0700
*/

DELETE FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
WHERE SALESORDERNUMBER || '-' || SALESORDERLINENUMBER IN (
    SELECT SALESORDERNUMBER || '-' || SALESORDERLINENUMBER
    FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
    GROUP BY SALESORDERNUMBER, SALESORDERLINENUMBER
    HAVING COUNT(*) > 1
);
/*
number of rows deleted
2000
*/

SELECT
    COUNT(*) AS ROW_COUNT,
    COUNT(DISTINCT SALESORDERNUMBER || '-' || SALESORDERLINENUMBER) AS DISTINCT_ORDER_LINES
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
ROW_COUNT	DISTINCT_ORDER_LINES
0	0
*/

SELECT
    COUNT(*) AS ROW_COUNT,
    SUM(SALESAMOUNT) AS TOTAL_SALES,
    SUM(TOTALPRODUCTCOST) AS TOTAL_PRODUCT_COST,
    SUM(TAXAMT) AS TOTAL_TAX,
    SUM(FREIGHT) AS TOTAL_FREIGHT
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
ROW_COUNT	TOTAL_SALES	TOTAL_PRODUCT_COST	TOTAL_TAX	TOTAL_FREIGHT
0				
*/

SELECT SYSTEM$PIPE_STATUS(
    'ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES'
);
/*
"SYSTEM$PIPE_STATUS(
    'ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES'
)"
{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-08T08:48:44.56Z","lastIngestedFilePath":"Snowpipe_test_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-08T08:48:43.949Z","lastForwardedMessageTimestamp":"2026-09-08T08:48:47.71Z","lastPulledFromChannelTimestamp":"2026-09-08T09:05:55.477Z","lastForwardedFilePath":"advworks-dev-ingestion/fact_internet_sales/Snowpipe_test_001.jsonl","pendingHistoryRefreshJobsCount":0}
*/


SELECT *
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES',
        START_TIME => DATEADD('hour', -6, CURRENT_TIMESTAMP())
    )
)
WHERE FILE_NAME ILIKE '%Snowpipe_restore_001.jsonl%'
ORDER BY LAST_LOAD_TIME DESC;
/*
FILE_NAME	STAGE_LOCATION	LAST_LOAD_TIME	ROW_COUNT	ROW_PARSED	FILE_SIZE	FIRST_ERROR_MESSAGE	FIRST_ERROR_LINE_NUMBER	FIRST_ERROR_CHARACTER_POS	FIRST_ERROR_COLUMN_NAME	ERROR_COUNT	ERROR_LIMIT	STATUS	TABLE_CATALOG_NAME	TABLE_SCHEMA_NAME	TABLE_NAME	PIPE_CATALOG_NAME	PIPE_SCHEMA_NAME	PIPE_NAME	PIPE_RECEIVED_TIME	BYTES_BILLED
Snowpipe_restore_001.jsonl	gcs://advworks-dev-ingestion/fact_internet_sales/	2026-09-08 02:08:10.715 -0700	1000	1000	671039					0	1	Loaded	ADVWORKS_DEV	LANDING	FACT_INTERNET_SALES	ADVWORKS_DEV	LANDING	PIPE_FACT_INTERNET_SALES	2026-09-08 02:07:44.207 -0700	671039
*/

SELECT COUNT(*) AS ROW_COUNT,
       COUNT(DISTINCT SALESORDERNUMBER || '-' || SALESORDERLINENUMBER) AS DISTINCT_ORDER_LINES,
       SUM(SALESAMOUNT) AS TOTAL_SALES,
       SUM(TOTALPRODUCTCOST) AS TOTAL_PRODUCT_COST,
       SUM(TAXAMT) AS TOTAL_TAX,
       SUM(FREIGHT) AS TOTAL_FREIGHT
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
ROW_COUNT	DISTINCT_ORDER_LINES	TOTAL_SALES	TOTAL_PRODUCT_COST	TOTAL_TAX	TOTAL_FREIGHT
1000	1000	3223116.8784	1928831.4494	257849.3552	80577.9714
*/



ALTER PIPE ADVWORKS_TEST.LANDING.PIPE_DIM_CUSTOMER SET PIPE_EXECUTION_PAUSED = TRUE;

ALTER PIPE ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT SET PIPE_EXECUTION_PAUSED = TRUE;

ALTER PIPE ADVWORKS_TEST.LANDING.PIPE_FACT_INTERNET_SALES SET PIPE_EXECUTION_PAUSED = TRUE;

SHOW PIPES IN SCHEMA ADVWORKS_TEST.LANDING;
/*
created_on	name	database_name	schema_name	definition	owner	notification_channel	comment	integration	pattern	error_integration	owner_role_type	invalid_reason	kind	is_snowflake_managed
2026-09-10 10:28:28.367 -0700	PIPE_DIM_CUSTOMER	ADVWORKS_TEST	LANDING	COPY INTO ADVWORKS_TEST.LANDING.DIM_CUSTOMER
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_TEST.LANDING.STAGE_DIM_CUSTOMER
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_TEST.LANDING.FF_DIM_CUSTOMER_JSON_FF'
)
ON_ERROR = 'CONTINUE'	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub		TEST_GCS_PUBSUB_INT			ROLE		STAGE	false
2026-09-10 10:28:30.160 -0700	PIPE_DIM_PRODUCT	ADVWORKS_TEST	LANDING	COPY INTO ADVWORKS_TEST.LANDING.DIM_PRODUCT
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_TEST.LANDING.STAGE_DIM_PRODUCT
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_TEST.LANDING.FF_DIM_PRODUCT_JSON_FF'
)
ON_ERROR = 'CONTINUE'	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub		TEST_GCS_PUBSUB_INT			ROLE		STAGE	false
2026-09-10 10:28:28.398 -0700	PIPE_FACT_INTERNET_SALES	ADVWORKS_TEST	LANDING	COPY INTO ADVWORKS_TEST.LANDING.FACT_INTERNET_SALES
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_TEST.LANDING.STAGE_FACT_INTERNET_SALES
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_TEST.LANDING.FF_FACT_INTERNET_SALES_JSON_FF'
)
ON_ERROR = 'CONTINUE'	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub		TEST_GCS_PUBSUB_INT			ROLE		STAGE	false
*/

-- Step 10A — Verify TEST Snowpipes are paused

-- Run these in Snowflake:

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_CUSTOMER');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"PAUSED","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-10T17:40:34.99Z","lastIngestedFilePath":"terraform_test_customer_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-10T17:40:34.753Z","lastForwardedMessageTimestamp":"2026-09-10T17:40:37.865Z","lastPulledFromChannelTimestamp":"2026-09-12T10:04:49.431Z","lastForwardedFilePath":"advworks-dev-ingestion/dim_customer/terraform_test_customer_001.jsonl","pendingHistoryRefreshJobsCount":0}
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT')
{"executionState":"PAUSED","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-10T17:40:34.753Z","lastPulledFromChannelTimestamp":"2026-09-12T10:05:09.532Z","pendingHistoryRefreshJobsCount":0}
*/


SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_FACT_INTERNET_SALES');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_FACT_INTERNET_SALES')
{"executionState":"PAUSED","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-10T17:40:34.753Z","lastPulledFromChannelTimestamp":"2026-09-12T10:05:19.439Z","pendingHistoryRefreshJobsCount":0}
*/


-- Step 15 — Verify DEV Snowpipe Ingestion

-- Now open Snowflake and run:
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-12T10:13:14.442Z","pendingHistoryRefreshJobsCount":0}

SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-12T10:13:59.436Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-12T10:15:44.692Z","lastIngestedFilePath":"DEV_TEST_DimCustomer_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-12T10:15:44.064Z","lastForwardedMessageTimestamp":"2026-09-12T10:15:47.385Z","lastPulledFromChannelTimestamp":"2026-09-12T11:05:29.429Z","lastForwardedFilePath":"advworks-dev-ingestion/dim_customer/DEV_TEST_DimCustomer_001.jsonl","pendingHistoryRefreshJobsCount":0}

SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-12T10:15:44.692Z","lastIngestedFilePath":"DEV_TEST_DimCustomer_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-12T10:15:44.064Z","lastForwardedMessageTimestamp":"2026-09-12T10:15:47.385Z","lastPulledFromChannelTimestamp":"2026-09-12T11:41:49.438Z","lastForwardedFilePath":"advworks-dev-ingestion/dim_customer/DEV_TEST_DimCustomer_001.jsonl","pendingHistoryRefreshJobsCount":0}

{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-12T11:44:29.778Z","lastIngestedFilePath":"terraform_test_customer_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-12T11:42:43.96Z","lastForwardedMessageTimestamp":"2026-09-12T11:42:46.769Z","lastPulledFromChannelTimestamp":"2026-09-12T11:47:19.421Z","lastForwardedFilePath":"advworks-dev-ingestion/dim_customer/DEV_TEST_DimCustomer_001.jsonl","pendingHistoryRefreshJobsCount":0}


*/

--Then:

SELECT COUNT(*) 
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER;
/*
COUNT(*)
5000

COUNT(*)
24484
*/

--And finally:

SELECT SOURCE_FILE, COUNT(*) 
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER
GROUP BY SOURCE_FILE
ORDER BY SOURCE_FILE;
/*
SOURCE_FILE	COUNT(*)
dim_customer/DEV_TEST_DimCustomer_001.jsonl	5000



SOURCE_FILE	COUNT(*)
dim_customer/DEV_TEST_DimCustomer_001.jsonl	5000
dim_customer/DimCustomer_batch_001.jsonl	1000
dim_customer/DimCustomer_batch_002.jsonl	1000
dim_customer/DimCustomer_batch_003.jsonl	1000
dim_customer/DimCustomer_batch_004.jsonl	1000
dim_customer/DimCustomer_batch_005.jsonl	1000
dim_customer/DimCustomer_batch_006.jsonl	1000
dim_customer/DimCustomer_batch_007.jsonl	1000
dim_customer/DimCustomer_batch_008.jsonl	1000
dim_customer/DimCustomer_batch_009.jsonl	1000
dim_customer/DimCustomer_batch_010.jsonl	1000
dim_customer/DimCustomer_batch_011.jsonl	1000
dim_customer/DimCustomer_batch_012.jsonl	1000
dim_customer/DimCustomer_batch_013.jsonl	1000
dim_customer/DimCustomer_batch_014.jsonl	1000
dim_customer/DimCustomer_batch_015.jsonl	1000
dim_customer/DimCustomer_batch_016.jsonl	1000
dim_customer/DimCustomer_batch_017.jsonl	1000
dim_customer/DimCustomer_batch_018.jsonl	1000
dim_customer/DimCustomer_batch_019.jsonl	484
dim_customer/terraform_test_customer_001.jsonl	1000
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-12T11:44:29.778Z","lastIngestedFilePath":"terraform_test_customer_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-12T11:42:43.96Z","lastForwardedMessageTimestamp":"2026-09-12T11:42:46.769Z","lastPulledFromChannelTimestamp":"2026-09-12T11:54:09.431Z","lastForwardedFilePath":"advworks-dev-ingestion/dim_customer/DEV_TEST_DimCustomer_001.jsonl","pendingHistoryRefreshJobsCount":0}
*/

SELECT COUNT(*) 
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER;
/*
COUNT(*)
24484
*/

SELECT SOURCE_FILE, COUNT(*)
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER
WHERE SOURCE_FILE = 'dim_customer/DEV_TEST_DimCustomer_001.jsonl'
GROUP BY SOURCE_FILE;
/*
SOURCE_FILE	COUNT(*)
dim_customer/DEV_TEST_DimCustomer_001.jsonl	5000
*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/



/*

*/


/*

*/



/*

*/



