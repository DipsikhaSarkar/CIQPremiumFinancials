/************************************************************************************************
Finding PE, P-BV, and TEV For A company 

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Segments
Finl Premium Statement
Finl Premium Supplemental
Base Equity Security
Base Security

Universal Identifiers:
companyId

Primary columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns the Price-to-Earnings (P/E) ratio, Price to Book Value (P/BV), and Total Enterprise Value (TEV) 
for Verizon on a daily basis using the SP Capital IQ Premium Financials packages in Xpressfeed.
Note: The Variables are declared in the body of a batch or procedure with the DECLARE statement 
and are assigned values by using either a SET or SELECT statement.

***********************************************************************************************/

DECLARE @CompanyID  INT

DECLARE @StrtDate  DATE

DECLARE @EndDate  DATE

 
SET @CompanyID = '415798'--Verizon --INSERT the CIQ Company ID here
SET @StrtDate = '1983-11-21' --INSERT the START date hereS
SET @EndDate = '2020-06-22' --INSERT the END date here

 
IF OBJECT_ID ( 'tempdb.dbo.#1', 'U' ) IS NOT NULL

DROP TABLE #1

 
IF OBJECT_ID ( 'tempdb.dbo.#2','U' ) IS NOT NULL

DROP TABLE #2

 
IF OBJECT_ID ( 'tempdb.dbo.#3','U' ) IS NOT NULL

DROP TABLE #3

--STEP 01: Retrieving all the CIQ Financials Data
SELECT fi.periodEndDate,
fp.fiscalYear,
fp.fiscalQuarter, --,fp.periodTypeId,
MAX ( CASE WHEN fcd.dataItemId = 1006 THEN fcd.dataItemValue END ) AS CommonEquity,
MAX ( CASE WHEN fcd.dataItemId = 1002 THEN fcd.dataItemValue END ) AS CashAndSTInvestments,
MAX ( CASE WHEN fcd.dataItemId = 1046 THEN fcd.dataItemValue END ) AS ShorTermBorrowings,
MAX ( CASE WHEN fcd.dataItemId = 1049 THEN fcd.dataItemValue END ) AS LongTermDebt,
MAX ( CASE WHEN fcd.dataItemId = 4020 THEN fcd.dataItemValue END ) AS BVPS,
MAX ( CASE WHEN fcd.dataItemId = 24153 THEN fcd.dataItemValue END ) AS SharesOutFiling,
MAX ( CASE WHEN fcd.dataItemId = 24152 THEN fcd.dataItemValue END ) AS SharesOutPeriodEnd,
MAX ( CASE WHEN fcd.dataItemId = 9 AND fp.periodTypeId =4 THEN fcd.dataItemValue END ) AS BasicEPS,
MAX ( CASE WHEN fcd.dataItemId = 3064 AND fp.periodTypeId =4 THEN fcd.dataItemValue END ) AS BasicEPSAdjusted,
MAX ( CASE WHEN fcd.dataItemId = 8 AND fp.periodTypeId =4 THEN fcd.dataItemValue END ) AS DilutedEPS,
MAX ( CASE WHEN fcd.dataItemId = 142 AND fp.periodTypeId =4 THEN fcd.dataItemValue END ) AS DilutedEPSAdjusted  

INTO #1
FROM ciqfinperiod fp

JOIN ciqFinInstance fi ON fp.financialPeriodId = fi.financialPeriodId
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceId = fitc.financialInstanceId
JOIN ciqFinCollection fc ON fitc.financialCollectionId = fc.financialCollectionId
JOIN ciqFinCollectionData fcd ON fc.financialCollectionId = fcd.financialCollectionId

WHERE fp.companyId = @CompanyID

AND fi.periodEndDate BETWEEN DATEADD ( YEAR,-1,@StrtDate ) AND @EndDate
AND fcd.dataItemId IN ( 1006,1002,1046,1049,4020,24152,24153,9,3064,8,142 )
AND fp.periodTypeId IN ( 2,4 ) --Quarterly LTM
AND fi.RestatementTypeId = 2 --Original Filings

GROUP BY fi.periodEndDate, fp.fiscalYear, fp.fiscalQuarter--, fp.periodTypeId
ORDER BY fi.periodEndDate


--STEP 02: Retrieving all the CIQ Pricing Data
SELECT tradingItemId,
pricingDate,
priceClose

INTO #2

FROM ciqPriceEquity

WHERE tradingitemid IN

( SELECT tradingItemId

FROM ciqsecurity s

JOIN ciqtradingitem t ON s.securityid = t.securityid

WHERE t.primaryflag = 1 AND s.primaryflag = 1 AND s.companyid = @CompanyID )

AND pricingDate BETWEEN @StrtDate AND @EndDate

ORDER BY pricingDate DESC



--STEP 03: Joining/matching of financial periods to pricing dates

SELECT p.pricingDate,
MAX ( i.periodEndDate ) AS periodEndDate

INTO #3

FROM #1 i

JOIN #2 p ON p.pricingDate = i.periodEndDate

--WHERE NOT EXISTS

--( SELECT 1FROM #2 p1WHERE p1.pricingDate = i.periodenddate AND p1.pricingDate  p.pricingDate )

GROUP BY p.pricingDate

ORDER BY 2,1



--STEP 04: Final calculations

SELECT p.pricingDate
, p.priceClose, 
( p.priceClose / i.BasicEPS ) AS PE_Basic --LTMNormalized
, 
( p.priceClose / i.BasicEPSAdjusted ) AS PE_BasicAdj --LTMNormalized
, ( p.priceClose / i.DilutedEPS ) AS PE_Diluted --LTMNormalized
, ( p.priceClose / i.DilutedEPSAdjusted ) AS PE_DilutedAdj --LTMNormalized
, i.DilutedEPSAdjusted -- This is what the CIQ platform uses for P/E ratio so included for comparison purposes
, ( p.priceClose / i.BVPS ) AS 'P/BV'
, ( ( p.priceClose * i.SharesOutPeriodEnd )+ ISNULL ( i.ShorTermBorrowings,0 ) + ISNULL ( i.LongTermDebt,0 ) - ISNULL ( i.CashAndSTInvestments,0 ) ) AS TEV

FROM #1 i

JOIN #3 d ON i.periodEndDate = d.periodEndDate

JOIN #2 p ON d.pricingDate = p.pricingDate

ORDER BY p.pricingDate DESC
