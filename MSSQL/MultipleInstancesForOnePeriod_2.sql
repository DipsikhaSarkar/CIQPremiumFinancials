/************************************************************************************************

Display multiple instances for one period

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Base Foundation Company
CIQ Data Item Master
Base Security


Primary ID's Used:
pk_ciqCompany
pk_ciqDataItem
pk_ciqExchange
pk_ciqFinCollection
pk_ciqFinCollectionData
pk_ciqFinInstance
pk_ciqFinInstanceToCollection
pk_ciqFinPeriod
pk_ciqPeriodType
pk_ciqRestatementType
pk_ciqSecurity
pk_ciqTradingItem

The latestFilingForInstanceFlag is used when there are multiple records in the ciqFinInstance 
table that have the same financialPeriodId and the same filingDate.This would occur, for 
example, when a company filed its press release and its 10-Q on the same day. The 
latestFilingForInstanceFlag flag shows you the “best” instance to use if you are trying to 
select between these two instances. A flag indicating that this instance is the latest one 
for the financial period. If there are multiple instances, 1=the latest filing that exists for 
the financial period and 0= other instances. instanceTypeId=4 (Backward column of a press 
release) are excluded from consideration if instanceTypeIds of 2 or 3 exist (Original Instance 
or Encore) for that financial period, as this would be replacing a complete source (e.g., an 
SEC filing) with an incomplete source (e.g., a press release), To view the latest/best source 
for a company, always screen for latestForFinancialPeriodFlag=1.


***********************************************************************************************/

SELECT c.companyName, c.companyId, fp.financialPeriodId, fi.periodEndDate,fi.filingDate, pt.periodTypeName, fp.calendarQuarter, fp.calendarYear,di.dataItemName,fd.dataItemValue,
fi.latestFilingForInstanceFlag, fi.latestForFinancialPeriodFlag, rt.restatementTypeName, fi.formType,exchangeSymbol
FROM ciqCompany c JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqRestatementType rt ON rt.restatementTypeID = fi.restatementTypeID
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId
WHERE (fd.dataItemId = 16) 
AND fp.periodTypeId = 1
AND ti.tickerSymbol = 'bncn' 
AND e.exchangeSymbol = 'NasdaqGM'
AND fp.calendarYear = 2011
ORDER BY fi.periodEndDate,fi.filingDate
 