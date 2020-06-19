/************************************************************************************************
Calculate Unit Type Name for the data items.

Packages Required:
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Segments
Finl Premium Statement
Finl Premium Supplemental
Finl Premium Core
Base Data Item Master

Universal Identifiers:
NA

Primary Columns Used:
dataItemId
unitTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns the Unit Type Name (unitTypename) for data items using the SP Capital IQ tables in Xpressfeed.

***********************************************************************************************/

SELECT c.dataItemID, 
c.dataItemName, 
b.unitTypename 

FROM ciqFinCollectionData a 

JOIN ciqFinUnitType b ON a.unitTypeId = b.unitTypeId 
JOIN ciqDataItem c ON a.dataItemId = c.dataItemId

