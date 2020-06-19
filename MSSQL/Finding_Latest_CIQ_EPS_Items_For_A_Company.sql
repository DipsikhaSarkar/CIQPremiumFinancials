/************************************************************************************************
Calculate  most recent EPS items for a specific company.

Packages Required:
Finl Premium Core
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Segments
Finl Premium Statement
Finl Premium Supplemental
Base Company 
Base Data Item Master
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query pulls in the most recent EPS items for a specific company, period type, and filing type from the SP Capital IQ files in Xpressfeed.
Note:Here IBM is taken as an example and periodType is Annual.

***********************************************************************************************/

SELECT a.companyId, 
a.periodTypeId, 
a.fiscalYear, 
a.fiscalQuarter, 
b. formType, 
g. dataItemName, 
g.dataItemId, 
e. dataItemValue


FROM ciqFinPeriod a


JOIN ciqFinInstance b ON a.financialPeriodId = b.financialPeriodId
JOIN ciqFinInstanceToCollection c ON b.financialInstanceId = c.financialInstanceId
JOIN ciqFinCollection d ON c.financialCollectionId = d.financialCollectionId
JOIN ciqFinCollectionData e ON d.financialCollectionId = e.financialCollectionId
JOIN ciqCompany f ON a.companyId = f.companyId
JOIN ciqDataItem g ON e.dataItemId = g.dataItemId


WHERE a.latestPeriodFlag = 1

AND a.periodTypeId = '1' --- Annual
AND a.companyId = '112350' --- IBM ( Example Company )
AND b.formType = '10-K' ---Filing Type
AND g.dataItemName LIKE '%EPS%'


