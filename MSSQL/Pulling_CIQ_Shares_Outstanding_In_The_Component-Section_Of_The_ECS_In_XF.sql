/************************************************************************************************
Finding Shares Outstanding in the other component section of the ECS.

Packages Required:
Finl Capital Structure
Finl Premium Core
Base Data Item Master

Universal Identifiers:
companyId

Primary Columns Used:
capStructComponentId
dataItemId
financialCollectionId
financialInstanceId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns the Shares Outstanding in the Other Components section of 
Equity Capital Structure (ECS) for companyID 264707946 in Xpressfeed

***********************************************************************************************/

SELECT csc.companyId, 
fi.periodEndDate, 
fi.filingDate, 
csc.*, 
ar.*, 
di.dataItemName 

FROM ciqCapStComponent csc ( NOLOCK ) 

JOIN ciqCapStCollectionAsRptdData ar ( NOLOCK ) ON csc.capStructComponentId = ar.capStructComponentId 

AND csc.companyId = 264707946
AND csc.capStructSubTypeId IN (10,14) 

JOIN ciqDataItem di ( NOLOCK ) ON ar.dataItemId = di.dataItemId
JOIN ciqFinCollection fc ( NOLOCK ) ON fc.financialCollectionId = ar.financialCollectionId
JOIN ciqFinInstance fi ( NOLOCK ) ON fc.financialInstanceId = fi.financialInstanceId 

ORDER BY fi.periodEndDate DESC
