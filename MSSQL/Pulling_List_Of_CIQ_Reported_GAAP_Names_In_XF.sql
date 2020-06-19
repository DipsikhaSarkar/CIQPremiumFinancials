/************************************************************************************************
Finding List of CIQ reported GAAP names.

Packages Required:
Finl Premium Statement
Base Data Item Master

Universal Identifier:
NA

Primary Columns Used:
dataItemId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns a list of reported GAAP names in Xpressfeed

***********************************************************************************************/

SELECT DISTINCT fct.dataItemId, 
fct.dataItemValueText, 
di.dataItemName

FROM ciqFinCollectionTextData fct

JOIN ciqDataItem di ON di.dataItemId = fct.dataItemId

WHERE fct.dataItemId = 21680
