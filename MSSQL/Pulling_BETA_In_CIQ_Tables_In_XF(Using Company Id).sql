/************************************************************************************************
Pulling Beta value for a particular company( Using Company Id)

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
periodTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query  pulls the BETA value for IBM (Current Period) from the CIQ tables in Xpressfeed.
Note: Here the company ID is used to identify the particular company.

***********************************************************************************************/

SELECT a.companyID, 
a.companyName, 
b.fiscalYear, 
b.fiscalQuarter, 
b.periodTypeId, 
c.periodEndDate, 
c.filingDate, 
f.dataItemId, 
f.dataItemName, 
e.dataItemValue

FROM ciqCompany a

JOIN ciqFinPeriod b ON a.companyId = b.companyId
JOIN ciqFinInstance c ON b.financialPeriodId = c.financialPeriodId
JOIN ciqFinInstanceToCollection d ON c.financialInstanceId = d.financialInstanceId
JOIN ciqFinCollectionData e ON d.financialCollectionId = e.financialCollectionId
JOIN ciqDataItem f ON e.dataItemId = f.dataItemId 

WHERE a.companyId = 158387416 --Marathon Patent Group 

AND e.dataItemId IN ( 4017 ) --5 year BETA 

