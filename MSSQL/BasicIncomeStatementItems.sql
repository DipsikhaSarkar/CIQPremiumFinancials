/************************************************************************************************
View basic income statement items

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Base Foundation Company
Base Security
Data Item Master

Primary ID's Used:
financialCollectionId
dataItemId
financialCollectionId
financialInstanceId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId

The following sample SQL query displays basic income statement items for a single company as 
of a specific period end date for original and all restatement filings.

***********************************************************************************************/


SELECT DISTINCT c.companyName, c.companyId, ti.tickerSymbol, e.exchangeSymbol,fi.periodEndDate,fi.filingDate, pt.periodTypeName, fp.calendarYear,fd.dataItemId,di.dataItemName,fd.dataItemValue
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
WHERE fd.dataItemId IN (28, 29, 1, 364, 2, 376, 10, 367, 19, 20, 15) --Income Statement Items
AND fp.periodTypeId = 1 --Annual
AND e.exchangeSymbol = 'SWX'
AND ti.tickerSymbol = 'CSGN' --Credit Suisse Group
AND fi.periodEndDate = '12/31/2007' 
ORDER BY c.companyName,di.dataItemName,fi.filingDate
 