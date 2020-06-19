/************************************************************************************************
Finding CIQ Data Item Values for a-Single Data Item from Original Filings For A Company.

Packages Required:
Finl Premium Core
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Segments
Finl Premium Statement
Finl Premium Supplemental

Universal Identifiers:
companyId

Primary columns Used:
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
03\06\2020

DatasetKey:
10

This query  returns the data values reported in the original filings for a single data item for a company.
Note: Here Sony is the company name and the period type is annual and restatement type is original.

***********************************************************************************************/

SELECT fp.companyID, 
fp.financialPeriodID, 
fp.calendarYear, 
fp.calendarQuarter, 
fp.fiscalYear, 
fp.fiscalQuarter, 
pt.PeriodTypeName, 
fi.financialInstanceID, 
fi.filingDate, 
rt.restatementTypeName, 
fc.financialCollectionID, 
fcd.dataItemID, 
fcd.dataItemValue

FROM ciqFinPeriod fp

JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqRestatementType rt ON rt.restatementTypeID = fi.restatementTypeID
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceID = fitc.financialInstanceID
JOIN ciqFinCollection fc ON fc.financialCollectionID = fitc.financialCollectionID
JOIN ciqFinCollectionData fcd ON fc.financialCollectionID = fcd.financialCollectionID

WHERE fp.companyId = 23021 --Sony

AND pt.periodTypeName LIKE 'Annual'
AND rt.restatementTypeName LIKE 'original'
AND fcd.dataItemId = 28 --Total Revenue

ORDER BY fp.fiscalYear, 
fp.fiscalQuarter, 
fi.financialInstanceID, 
fc.financialCollectionID

