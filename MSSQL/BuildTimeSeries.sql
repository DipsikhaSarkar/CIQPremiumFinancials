/************************************************************************************************
Build a time series

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

The following sample query below retrieves one data item, quarterly total revenue, 
for Abbott Laboratories (Ticker ABT) that will be presented in a time series.

***********************************************************************************************/

SELECT c.companyName, c.companyId, ti.tickerSymbol, e.exchangeSymbol,
fi.periodEndDate,fi.filingDate,pt.periodTypeName,fp.calendarQuarter,
fp.calendarYear,fd.dataItemId,di.dataItemName,fd.dataItemValue

FROM ciqCompany c JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId 
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId

WHERE (fd.dataItemId = 28 OR fd.dataItemId = 29) --Total Revenues
AND fp.periodTypeId = 2 --Quarterly
AND ti.tickerSymbol = 'ABT' --Abbott Laboratories
AND e.exchangeSymbol = 'NYSE'
AND fi.latestForFinancialPeriodFlag = 1

ORDER BY fi.periodEndDate,fi.filingDate
 
 