/************************************************************************************************
Display the order of items in a financial statement

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Statement
Finl Premium Segment Financials

Primary ID's Used:
dataCollectionTypeId
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId
reportingTemplateId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample SQL query displays the order of Items in an Income Statement. The 
description corresponding to the reportingTemplateId is provided within the query.

***********************************************************************************************/

SELECT fp.fiscalYear, di.dataItemId, di.dataItemName, fd.dataitemvalue, c.dataCollectionTypeName,
CASE find.reportingTemplateId
WHEN 1 THEN 'Standard'
WHEN 2 THEN 'Banks'
WHEN 3 THEN 'Insurance'
WHEN 4 THEN 'Utility'
WHEN 5 THEN 'Real Estate'
WHEN 7 THEN 'Financial Services'
WHEN 8 THEN 'Capital Markets'
ELSE '' END AS 'ReportingTemplate'
, find.lineorder, find.detailDisplay, find.summaryDisplay

FROM ciqFinPeriod fp
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = ic.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId
JOIN ciqFinDisplay find ON find.dataItemId=di.dataItemId
JOIN ciqFinDataCollectionType c ON find.dataCollectionTypeId = c.dataCollectionTypeId
WHERE c.dataCollectionTypeName = 'Balance Sheet'

AND find.reportingTemplateId = '1' --standard
--and summaryDisplay = '1' --summary version
--and detailDisplay = '1' --detail version
AND fp.companyId = 112350 --IBM
AND fp.periodTypeId = 1 --annual
AND fp.fiscalYear = 2012
AND fi.latestFilingForInstanceFlag=1
AND fi.latestForFinancialPeriodFlag=1

ORDER BY lineOrder
 