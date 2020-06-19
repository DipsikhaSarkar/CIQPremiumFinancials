/************************************************************************************************
Finding Latest Annual Fundamental Data. 

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
Base Foundation Company daily

Universal Identifiers:
companyId

Primary Columns Used:
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

This query returns the most recent(Latest Period Flag=1) annual(periodTypeId=1) fundamental
financial data for Teletech Holdings Inc (companyId = 348722) in the 
SP Capital IQ feed in the Latest Financials package.

***********************************************************************************************/

SELECT a.*, 
b. formType, 
g. dataItemName, 
e. dataItemValue 

FROM ciqFinPeriod a ( NOLOCK )

JOIN ciqFinInstance b ( NOLOCK ) ON a.financialPeriodId = b.financialPeriodId 
JOIN ciqFinInstanceToCollection c ( NOLOCK ) ON b.financialInstanceId = c.financialInstanceId 
JOIN ciqFinCollection d ( NOLOCK ) ON c.financialCollectionId = d.financialCollectionId 
JOIN ciqFinCollectionData e ( NOLOCK ) ON d.financialCollectionId = e.financialCollectionId 
JOIN ciqCompany f ( NOLOCK ) ON a.companyId = f.companyId 
JOIN ciqDataItem g ( NOLOCK ) ON e.dataItemId = g.dataItemId 

WHERE a.latestPeriodFlag = 1 

AND a.periodTypeId = 1 
AND a.companyId = 348722 

