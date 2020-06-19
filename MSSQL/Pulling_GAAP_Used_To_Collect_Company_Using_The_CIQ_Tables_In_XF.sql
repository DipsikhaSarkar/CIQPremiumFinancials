/************************************************************************************************
Pulling GAAP used to collect Company Information.

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
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary Columns Used:
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

This query This query returns the GAAP used to collect data for a 
specific company for a specific period using the SP Capital IQ packages in Xpressfeed

***********************************************************************************************/

SELECT a.*, c.dataItemValueText AS ACCTSTD
FROM

( SELECT c0.companyId, 
p0.financialPeriodId, 
i0.financialInstanceId, 
i0.instanceTypeId, 
fd0.financialCollectionId,
i0.filingDate, 
i0.periodEndDate, 
p0.calendarYear, 
p0.calendarQuarter, 
p0.periodTypeId,
fd0.dataItemId, 
fd0.dataItemValue, 
i0.currencyId

FROM ciqCompany c0

JOIN ciqFinPeriod p0 ON c0.companyId = p0.companyId

AND p0.periodTypeId = 1 AND p0.companyId = '285107109'

JOIN ciqFinInstance i0 ON i0.financialPeriodId = p0.financialPeriodId

AND i0.filingDate BETWEEN '1/1/2014' AND  '6/1/2017'

JOIN ciqFinInstanceToCollection ic0 ON ic0.financialInstanceId = i0.financialInstanceId

JOIN ciqFinCollectionData fd0

ON fd0.financialCollectionId = ic0.financialCollectionId

AND fd0.dataItemId = '1007' ) a

LEFT JOIN ciqFinCollectionTextData c ON c.financialCollectionId = a.financialCollectionId AND c.dataItemId in ( 25491 , 21680 , 25492 ) ---linking with the subquery

ORDER BY calendarYear