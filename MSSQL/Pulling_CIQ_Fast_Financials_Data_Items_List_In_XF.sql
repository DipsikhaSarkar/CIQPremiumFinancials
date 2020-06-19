/************************************************************************************************
Pulling CIQ Fast Financials Datat Item List.

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

This query returns the data items collected and calculated for SP Capital IQ Fast Financials in Xpressfeed.

***********************************************************************************************/

SELECT DISTINCT fcd.dataItemId, cdi.dataItemName
FROM ciqCompany c

INNER JOIN ciqFinPeriod fp ON c.companyId = fp.companyId
INNER JOIN ciqFinInstance fi ON fp.financialPeriodId = fi.financialPeriodId
INNER JOIN ciqFinInstanceToCollection fict ON fi.financialInstanceId = fict.financialInstanceId
INNER JOIN ciqFinCollectionTextData fct ON fict.financialCollectionId = fct.financialCollectionId 
AND fct.dataItemId = '36393'
INNER JOIN ciqFinInstanceToCollection fic ON fi.financialInstanceId = fic.financialInstanceId
INNER JOIN ciqFinCollection fc ON fic.financialCollectionId = fc.financialCollectionId
INNER JOIN ciqFinCollectionData fcd ON fc.financialCollectionId = fcd.financialCollectionId
JOIN ciqDataItem cdi ON fcd.dataItemId = cdi.dataItemId

WHERE fct.dataItemValueText = 'CIQ-FF'
ORDER BY fcd.dataItemId
