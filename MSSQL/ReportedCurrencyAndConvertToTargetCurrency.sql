/************************************************************************************************
Display reported currency and convert to target currency

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Statement

Primary ID's used:
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
25\05\2020

DatasetKey:
10

The following sample SQL queries display the currency in which financials were reported 
and convert the data to a target currency.

***********************************************************************************************/

SELECT c.companyName, c.companyId, ti.tickerSymbol, e.exchangeSymbol, co.country,cu.currencyName,fi.periodEndDate,pt.periodTypeName, fp.calendarQuarter,fp.calendarYear,fi.filingDate,fd.dataItemId,di.dataItemName, fd.dataItemValue, (fd.dataItemValue*cex2.priceClose)/cex.priceClose AS DataItemValue_GBP
FROM ciqCompany c JOIN ciqSecurity s ON c.companyId = s.companyId
JOIN ciqTradingItem ti ON ti.securityId = s.securityId
JOIN ciqExchange e ON e.exchangeId = ti.exchangeId
JOIN ciqCountryGeo co ON co.countryId = c.countryId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId 
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqCurrency cu ON cu.currencyid = fc.currencyId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId
JOIN ciqExchangeRate cex ON cex.currencyId = fc.currencyId AND cex.priceDate = fi.periodEndDate
JOIN ciqExchangeRate cex2 ON cex2.priceDate = cex.priceDate
JOIN ciqCurrency cu2 ON cu2.currencyid = cex2.currencyid
WHERE fd.dataItemId = 300 --Sales
AND fp.periodTypeId = 1 --Annual
AND ti.tickerSymbol = 'VOW' --Volkswagen AG
AND e.exchangeSymbol = 'DB'
AND fi.periodEndDate = '12/31/2007' 
AND cu2.currencyName LIKE 'British Pound%' --Target Currency
ORDER BY c.companyName,di.dataItemName
 