/************************************************************************************************
Filing date for CIQ instance.

Packages Required:
Finl Premium Core

Universal Identifiers:
NA

Primary Columns Used:
financialInstanceId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns turns records with the filing date of 03/30/2018 in SP Capital IQ® Premium Financials in Xpressfeed

***********************************************************************************************/

SELECT * 
FROM ciqFinInstance
WHERE filingDate = '03/30/2018' 