/************************************************************************************************
Number Of CIQ private Comoanies with Revenue.

Packages Required:
Finl Premium Core
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Segments
Finl Premium Statement
Finl Premium Supplemental
Base Company
Base Data Item Master
Base Equity Security
Base Foundation Company Daily
Base Security

Universal Identifiers:
companyId

Primary Columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query screens the Capital IQ files for the number of private companies with data available 
for Total Revenues:.

***********************************************************************************************/

SELECT count( DISTINCT c.companyName )
FROM ciqCompany c

JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemIdWHERE ( fd.dataItemId = 28 OR fd.dataItemId = 29 ) --Total Revenues

AND fp.periodTypeId = 1 --Quarterly
AND fi.latestForFinancialPeriodFlag = 1
AND periodEndDate = '12/31/2012'
AND c.companyTypeId = 5