/************************************************************************************************
Display multiple instances for one period

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement


Primary ID's Used:
financialInstanceId
financialPeriodId
periodTypeId

The following sample SQL queries display multiple instances for one period for a single company.


***********************************************************************************************/


SELECT fp.financialPeriodID
,fp.calendarYear
,fp.calendarQuarter
, fp.fiscalYear
,fp.fiscalQuarter
,fi.financialInstanceID
, fi.periodEndDate
,fi.filingDate
,fi.latestForFinancialPeriodFlag
, fi.latestFilingForInstanceFlag
,fi.amendmentFlag
,fi.currencyID
, fi.accessionNumber
,fi.formType
,fi.restatementTypeID

FROM ciqFinPeriod fp
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID

WHERE fp.companyID = 394466 --BP Plc
AND fp.fiscalYear = 2008
AND fp.fiscalQuarter = 2
AND pt.periodTypeName = 'quarterly'

ORDER BY fi.filingdate
