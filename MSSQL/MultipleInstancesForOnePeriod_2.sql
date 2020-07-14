/************************************************************************************************
Display multiple instances for one period using ticker and exchange symbol.

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Statement

Universal Identifiers:
companyId
tradingItemId
securityId

Primary Columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId
restatementTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

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
 