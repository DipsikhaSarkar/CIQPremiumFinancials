/************************************************************************************************

View the original filings for a single data item

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement


Primary ID's Used:
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId
restatementTypeId

The following sample SQL query displays the original filings for a single data item 
for a given company

***********************************************************************************************/

SELECT fp.companyID
,fp.financialPeriodID
,fp.calendarYear
,fp.calendarQuarter
,fp.fiscalYear
,fp.fiscalQuarter
,pt.PeriodTypeName
,fi.financialInstanceID
,fi.filingDate
,rt.restatementTypeName
,fc.financialCollectionID
,fcd.dataItemID,fcd.dataItemValue

FROM ciqFinPeriod fp
JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqRestatementType rt ON rt.restatementTypeID = fi.restatementTypeID
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceID = fitc.financialInstanceID
JOIN ciqFinCollection fc ON fc.financialCollectionID = fitc.financialCollectionID
JOIN ciqFinCollectionData fcd ON fc.financialCollectionID = fcd.financialCollectionID 

WHERE fp.companyID = 23021 --Sony
AND pt.PeriodTypeName LIKE 'Annual'
AND rt.restatementTypeName LIKE 'original'
AND fcd.dataItemID = 28 --Total Revenue
ORDER BY fp.fiscalYear, fp.fiscalQuarter, fi.financialInstanceID, fc.financialCollectionID
 
 
 
