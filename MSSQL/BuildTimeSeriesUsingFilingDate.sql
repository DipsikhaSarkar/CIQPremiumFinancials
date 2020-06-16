/************************************************************************************************
Build a time series using filing dates

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Statement

Primary ID's Used:
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
25\05\2020

DatasetKey:
10

The following example demonstrates how to build a time series using filing dates. The sample 
query below retrieves one data item, quarterly cost of goods sold, for Anadarko Petroleum 
Corp (GVKEY 011923) that will be presented in a time series.

***********************************************************************************************/

DECLARE @obsdate AS datetime
SET @obsdate = '2003-4-15' --Setting your observation DATE
 
SELECT c.companyName,c.companyId,ti.tickerSymbol,e.exchangeSymbol, fi.periodEndDate,fi.filingDate,
pt.periodTypeName,fp.calendarQuarter, fp.calendarYear,fd.dataItemId,di.dataItemName,fd.dataItemValue

FROM ciqCompany c JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
CROSS apply 
 ( --subquery to get latest FinInstance data for period as of observation date
 SELECT top 1 * FROM ciqFinInstance
 WHERE financialPeriodId = fp.financialPeriodId
 AND filingDate <= @obsdate
 AND restatementTypeId != '1' --No press releases option
 ORDER BY filingDate DESC, latestFilingForInstanceFlag
 ) fi 
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId 
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId

WHERE fd.dataItemId = 34 --Cost of Goods Sold
AND fp.periodTypeId = 2 --Quarterly
AND ti.tickerSymbol = 'APC' --Anadarko Petroleum Corp.
AND e.exchangeSymbol = 'NYSE'

ORDER BY fi.periodEndDate, fi.filingDate
 