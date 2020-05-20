/************************************************************************************************
View a time series for a single data item

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement


Primary ID's Used:
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId

The following sample SQL query displays a time series for a single data item for a company.

***********************************************************************************************/




SELECT fp.companyID
,fp.financialPeriodID
,fp.calendarYear
, fp.calendarQuarter
,fp.fiscalYear
,fp.fiscalQuarter
,pt.periodTypeName
,fi.financialInstanceID
,fi.latestForFinancialPeriodFlag
,fi.filingDate
,fc.financialCollectionID,
fcd.dataItemID,fcd.dataItemValue

FROM ciqFinPeriod fp
JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceID = fitc.financialInstanceID
JOIN ciqFinCollection fc ON fc.financialCollectionID = fitc.financialCollectionID
JOIN ciqFinCollectionData fcd ON fc.financialCollectionID = fcd.financialCollectionID 

WHERE fp.companyID IN (256565) --British Airways
AND pt.periodTypeName LIKE 'Annual'
AND fi.latestForFinancialPeriodFlag = 1 --latest instance
AND fcd.dataItemID = 15 --net income

ORDER BY fp.companyID,fp.fiscalYear,fp.fiscalQuarter, fi.financialInstanceID,fc.financialCollectionID
 