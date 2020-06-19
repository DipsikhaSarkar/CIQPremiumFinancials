/************************************************************************************************
Restatement Types For CIQ Premium Financials.

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
03\06\2020

DatasetKey:
10

This query returns the data values, restatement types, and filing dates of the 
different sources for Earnings from Continuing Operations (dataItem Id = 7) 
from the Capital IQ Premium Financials.

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
fi.restatementTypeId, 
rt.restatementTypeName, 
fc.financialCollectionID, 
fcd.dataItemID, 
fcd.dataItemValue

FROM ciqFinPeriod fp

JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqRestatementType rt ON rt.RestatementTypeID = fi.RestatementTypeID
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceID = fitc.financialInstanceID
JOIN ciqFinCollection fc ON fc.financialCollectionID = fitc.financialCollectionID
JOIN ciqFinCollectionData fcd ON fc.financialCollectionID = fcd.financialCollectionID

WHERE fp.companyID = 336160 -- Darden Restaurants

AND pt.periodTypeId = 1 --annual
AND fp.fiscalYear = 2013
AND fcd.dataItemID = 7 -- Earnings from Continuing Operations

ORDER BY fp.fiscalYear, 
fp.fiscalQuarter, 
fi.financialInstanceID, 
fc.financialCollectionID

