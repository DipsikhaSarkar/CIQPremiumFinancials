/************************************************************************************************
Calculating number of CIQ segment companies.

Packages Required:
Finl Premium Core
Finl Premium Segment Financials

Universal Identifiers:
companyId

Primary Columns Used:
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

This query returns the number of companies that have segment data available before and after a specified date:
Note: This example uses April 19, 2009 for the date.

***********************************************************************************************/

SELECT 'Before' AS cntType, COUNT ( DISTINCT a.companyId ) AS cnt

FROM ciqFinPeriod a


INNER JOIN ciqFinInstance i ON a.financialPeriodId = i.financialPeriodId

INNER JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = i.financialInstanceId


WHERE EXISTS


( SELECT *

FROM ciqSegCollectStandCmpntData seg

WHERE seg.financialCollectionId = ic .financialCollectionId )


AND i.instanceTypeId in ( 1,2 ) --PR / Original Instance

AND i.filingDate<'2009-04-19'

AND a.periodTypeId = 1 --Annual


UNION ALL

SELECT 'After' AS cntType, COUNT ( DISTINCT a.companyId ) AS cnt

FROM ciqFinPeriod a


INNER JOIN ciqFinInstance i ON a.financialPeriodId = i.financialPeriodId

INNER JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = i.financialInstanceId


WHERE EXISTS


( SELECT *

FROM ciqSegCollectStandCmpntData seg

WHERE seg.financialCollectionId = ic.financialCollectionId )


AND i.instanceTypeId in ( 1,2 ) --PR / Original Instance

AND i.filingDate> '2009-04-19'

AND a.periodTypeId = 1 --Annual