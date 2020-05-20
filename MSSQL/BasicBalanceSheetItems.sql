/************************************************************************************************
View basic balance sheet items

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Base Foundation Company
Base Security
Data Item Master

Primary ID's Used:
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId


The following sample SQL query displays basic balance sheet items for a single company for 
the most recent four quarterly periods.

***********************************************************************************************/


SELECT c.companyName
, c.companyId
, ti.tickerSymbol
, e.exchangeSymbol
, co.country
,fi.filingDate
,fi.formType
,pe.periodEndDate
,pt.periodTypeName
,fp.calendarQuarter
,fp.calendarYear
,fd.dataItemId
,di.dataItemName
,fd.dataItemValue

FROM ciqCompany c JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqCountryGeo co ON co.countryId = c.countryId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId 
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId
JOIN (SELECT DISTINCT top 4(fi.periodEndDate) AS --Most recent 4 periods
	periodEndDate,fp.companyId,ti.tickerSymbol
	FROM ciqFinInstance fi
	JOIN ciqFinPeriod fp ON fi.financialPeriodId = fp.financialPeriodId
	JOIN ciqCompany c ON fp.companyId = c.companyId
	JOIN ciqSecurity s ON c.companyId = s.companyId
	JOIN ciqTradingItem ti ON ti.securityId = s.securityId
	JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
	WHERE e.exchangeSymbol = 'NasdaqGS'
	AND ti.tickerSymbol = 'AMGN' --Amgen Inc.
	ORDER BY fi.periodEndDate DESC) pe ON pe.periodEndDate = fi.periodEndDate
WHERE fd.dataItemId IN (1002, 1001, 1008, 1004, 1007, 1009, 1276, 1006, 1275, 1013, 106) --Balance Sheet Items 
AND fp.periodTypeId = 2 --Quarterly
AND e.exchangeSymbol = 'NasdaqGS'
AND ti.tickerSymbol = 'AMGN' --Amgen Inc.
AND fi.latestForFinancialPeriodFlag = 1
ORDER BY fi.filingDate