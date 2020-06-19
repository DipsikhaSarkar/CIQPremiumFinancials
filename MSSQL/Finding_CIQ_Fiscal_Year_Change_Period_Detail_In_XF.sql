/************************************************************************************************
Finding_CIQ_Fiscal_Year_Change_Period_Detail_In_XF

Packages Required:
Financial Premium Capital Structure
Financial Premium Detail
Financial Premium Market
Financial Premium Ratio
Financial Premium Segments
Financial Premium Statement
Financial Premium Supplemental
Financial Premium Core

Universal Identifiers:
companyId

Primary columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
instanceToCollectionTypeId
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

This query can be used to validate differences for the same periods that may occur when a 
company has a fiscal-year change with details for 
Calculated vs. Reported periods and the number of months covered

***********************************************************************************************/

SELECT fp.companyID, 
fp.financialPeriodID, 
fp.calendarYear, 
fp.fiscalChainSeriesId, 
nonstandardlengthflag, 
nummonths, 
fp.calendarQuarter, 
fp.fiscalYear, 
fp.fiscalQuarter, 
pt.PeriodTypeName, 
fi.financialInstanceID, 
fcd.dataItemValue, 
fi.filingDate, 
fitcy.instanceToCollectionTypeName, 
rt.restatementTypeName, 
fc.financialCollectionID, 
fcd.dataItemID

FROM ciqFinPeriod fp

JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqRestatementType rt ON rt.restatementTypeID = fi.restatementTypeID
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceID = fitc.financialInstanceID
JOIN ciqFinInstanceToCollectType fitcy ON fitcy.instanceToCollectionTypeId = fitc.instanceToCollectionTypeId
JOIN ciqFinCollection fc ON fc.financialCollectionID = fitc.financialCollectionID
JOIN ciqFinCollectionData fcd ON fc.financialCollectionID = fcd.financialCollectionID

WHERE fp.CompanyId=5464612 -- Hanwha Life


AND pt.PeriodTypeName LIKE 'Annual'
AND rt.restatementTypeName LIKE 'original'
AND fcd.dataItemID = 28 --Total Revenue


ORDER BY fp.fiscalYear DESC
, fp.fiscalQuarter, fi.financialInstanceID, fc.financialCollectionID

