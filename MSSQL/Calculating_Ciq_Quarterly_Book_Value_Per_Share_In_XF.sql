/************************************************************************************************
Quarterly Book Value Per Share.

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
periodTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns quarterly Book Value Per Share for Analog Devices Inc. using the SP Capital IQ database in Xpressfeed

***********************************************************************************************/

SELECT DISTINCT c.companyName, 
c.companyId, 
fi.periodEndDate, 
fi.filingDate, 
pt.periodTypeName, 
fp.calendarYear, 
fd.dataItemId, 
di.dataItemName, 
fd.dataItemValue, 
fp.calendarQuarter

FROM ciqCompany c

JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId

WHERE fd.dataItemId IN ( 4020 ) -- Book Value / Share

AND fp.periodTypeId = 2 --Quarterly
AND c.companyId = 251411

ORDER BY c.companyName, 
di.dataItemName, 
fp.calendarYear, 
fp.calendarQuarter, 
fi.filingDate

