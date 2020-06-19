/************************************************************************************************
Pulling CIQ Bank Regulatory Items.

Packages Required:
Finl Bank Regulatory
Finl Latest Core
Finl Premium Core
Base Data Item Master

Universal Identifiers:
companyId

Primary Columns Used:
dataItemId
dataSetId
periodId
periodTypeId
unitTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns a time series of Total Risk-Weighted Assets - FFIEC 
(dataItemId 33442) for CNB Bancshares, Inc. (companyID 45599080) in Xpressfeed

***********************************************************************************************/

SELECT *

FROM ciqBankRegulatoryPeriod a 

JOIN ciqBankRegulatoryData b ON a.periodId=b.periodId
JOIN ciqDataItemBankRegulatory c ON b.dataItemId=c.dataItemId
JOIN ciqFinUnitType d ON c.unitTypeId=d.unitTypeId
JOIN ciqFinancialDataSet e ON c.dataSetId=e.dataSetId
JOIN ciqBankRegulatoryPeriodType f ON a.periodTypeId=f.periodTypeId 

WHERE a.companyId = 45599080 -- company ID 

AND a.periodTypeId = 1 -- 1 annual, 2 quarterly
AND b.dataItemId = 33442 -- dataitem 

ORDER BY peoDate DESC
