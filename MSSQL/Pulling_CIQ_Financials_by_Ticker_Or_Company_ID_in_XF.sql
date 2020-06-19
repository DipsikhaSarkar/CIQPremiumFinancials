/************************************************************************************************
Pulling CIQ Financials.

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

This query returns  specified CIQ financial data items by ticker or companyid.
Note:Here ticker symbol is used for Amazon (Uncomment c.companyId to search by company Id)
***********************************************************************************************/

IF object_id ('TEMPDB.DBO.#####Universe') IS NOT NULL
DROP TABLE #####Universe

SELECT e.exchangeSymbol, 
ti.tickerSymbol, 
(e.exchangeSymbol+':'+ti.tickerSymbol) AS 'Exchange:Ticker',
s.securityId, 
c.companyId, 
c.companyName, 
s.securityName

INTO #####Universe
FROM ciqCompany c

JOIN ciqSecurity s ON c.companyId = s.companyId 
AND s.primaryFlag = 1 --For Primary Security only
JOIN ciqTradingItem ti ON ti.securityId = s.securityid 
AND ti.primaryFlag=1 --For Primary Trading Item only
JOIN ciqExchange e ON e.exchangeId = ti.exchangeid

WHERE --c.companyId IN() -- Amazon --Insert Company Symbols (Remove -- to search by companyid)
ti.tickersymbol IN ('AMZN') --Insert Ticker Symbols (remove this section to search by companyid)--Pulls company universe from temp table above

SELECT *FROM #####Universe--Pulls financials for the companies in the temp table universe
SELECT u.companyid, 
di.dataItemId, 
di.dataItemName, 
fcd.dataItemValue, 
fi.periodEndDate, 
dig.*, 
fp.*, 
fi.*

FROM (SELECT DISTINCT(companyid) FROM #####Universe) U

JOIN ciqFinPeriod fp ON fp.companyId=U.companyid
JOIN ciqFinInstance fi ON fi.financialPeriodId=fp.financialPeriodId
JOIN ciqFinInstanceToCollection fic ON fic.financialInstanceId=fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId=fic.financialCollectionId
JOIN ciqFinCollectionData fcd ON fcd.financialCollectionId=fc.financialCollectionId
JOIN ciqDataItem di ON di.dataItemId=fcd.dataItemId
JOIN ciqDataItemGroupToDataItem gtd ON gtd.dataItemId=di.dataItemId
JOIN ciqDataItemGroup dig ON dig.dataItemGroupId=gtd.dataItemGroupId

WHERE 1=1

AND fp.periodTypeId=1 -- Annual Sources
AND fcd.dataItemId IN (112,4173,1049,44892,44893,4188,4074,4051,4189) --Insert data items
AND dig.dataItemGroupId IN (1,3) -- Insert data groups

ORDER BY fi.periodEndDate DESC, fi.filingdate
