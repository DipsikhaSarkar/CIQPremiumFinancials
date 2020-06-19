/************************************************************************************************
Pulling Beta value for a particular company.

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
Base Equity Security
Base Foundation Company Daily
Base Security

Universal Identifiers:
companyId
securityId
tradingItemId

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

This query  pulls the BETA value for IBM (Current Period) from the CIQ tables in Xpressfeed.
Note: Here the ticker symbol is used to identify the company.

***********************************************************************************************/

SELECT c.companyName, 
c.companyId, 
ti.tickerSymbol, 
e.exchangeSymbol,
fi.periodEndDate, 
fi.filingDate, 
pt.periodTypeName, 
fp.calendarQuarter, 
fp.calendarYear, 
fd.dataItemId, 
di.dataItemName, 
fd.dataItemValue 

FROM ciqCompany c

JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = ic.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId 

WHERE fd.dataItemId IN ( 4017 )

AND fp.periodTypeId = 4 --LTM 
AND e.exchangeSymbol = 'NYSE' 
AND ti.tickerSymbol = 'IBM'
AND fi.latestForFinancialPeriodFlag = 1 --Latest Instance For Financial Period 
AND fp.latestPeriodFlag = 1 --Current Period 

ORDER BY di.dataItemName

