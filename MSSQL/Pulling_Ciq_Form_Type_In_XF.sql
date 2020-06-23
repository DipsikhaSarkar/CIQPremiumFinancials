/************************************************************************************************
Finding CIQ Form type

Packages Required:
Finl Premium Core

Universal Identifiers:
NA

Primary columns Used:
financialInstanceId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns all of the available FormTypes in Xpressfeed for a particular
finanacialPeriodId

***********************************************************************************************/

SELECT DISTINCT formtype 

FROM ciqFinInstance
WHERE financialPeriodId = 1203450474 

