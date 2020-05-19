
/************************************************************************************************
Identify same-day updates for income statement data

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Base Foundation Company
Data Item Master

Primary ID's Used:
financialCollectionId
financialInstanceId
financialPeriodId

The following sample SQL query pulls all S&P Capital IQ same-day income statement 
data for the first quarter of 2012

***********************************************************************************************/


SELECT c.companyid
,c.companyname
,fi.periodEndDate
,fi.filingDate
,fi.instanceTypeId
,fc.currencyId
,fcd.dataItemId
,fcd.dataItemValue
,fct.dataItemValueText AS datasource

FROM ciqCompany c (nolock)
INNER JOIN ciqFinPeriod fp (nolock)
 ON c.companyId = fp.companyId
INNER JOIN ciqFinInstance fi (nolock)
 ON fp.financialPeriodId = fi.financialPeriodId
INNER JOIN ciqFinInstanceToCollection fict (nolock)
 ON fi.financialInstanceId = fict.financialInstanceId
INNER JOIN ciqFinCollectionTextData fct (nolock)
 ON fict.financialCollectionId = fct.financialCollectionId
 AND fct.dataItemId = 36393
INNER JOIN ciqFinInstanceToCollection fic
 ON fi.financialInstanceId = fic.financialInstanceId
INNER JOIN ciqFinCollection fc (nolock)
 ON fic.financialCollectionId = fc.financialCollectionId
INNER JOIN ciqFinCollectionData fcd (nolock)
 ON fc.financialCollectionId = fcd.financialCollectionId
WHERE fct.dataItemValueText = 'CIQ-FF'
AND fp.calendarYear = 2020
AND fp.calendarQuarter = 1
AND fc.dataCollectionTypeId = 1 --income statement
AND fp.periodTypeId = 2 --quarterly
ORDER BY c.companyName, fi.periodEndDate, fi.filingDate, fcd.dataItemId
 