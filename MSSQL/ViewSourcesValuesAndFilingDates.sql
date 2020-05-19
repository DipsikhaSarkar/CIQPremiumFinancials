/************************************************************************************************
View the sources, values and filing dates

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Base Foundation Company
Base Security
Data Item Master

Primary ID's used:
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId

The following sample SQL query displays the sources, values and filing dates for a specific 
company and data item as of a specific period end date.

***********************************************************************************************/

SELECT c.companyName
,c.companyId
,ti.tickerSymbol
,e.exchangeSymbol
,co.country
,fi.filingDate,
fi.formType
,fi.periodEndDate
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
WHERE 1=1 
AND fd.dataItemId = 15 --Net Income (IS)
AND fp.periodTypeId = 1 --Annual
AND e.exchangeSymbol = 'TSE' 
AND ti.tickerSymbol = '7267' --Honda Motor Company
AND fi.periodEndDate = '3/31/2007'  
ORDER BY fi.filingDate
 