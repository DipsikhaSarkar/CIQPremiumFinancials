/************************************************************************************************
Displaying CIQ financials in reported and targeted Currency

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
Base Exchange Rates
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

This query returns a data item in the reported currency and translated into a target currency using the 
SP Capital IQ Premium Financials packages and the v2 Exchange packages in Xpressfeed:
NOTE:Displays item from SP Capital IQ Premium Financials package in reported currency and same item translated to target currency

***********************************************************************************************/

SELECT c.companyName, 
c.companyId, 
co.country, 
cu.currencyName, 
fi.formtype, 
fi.restatementTypeId, 
fi.periodEndDate, 
pt.periodTypeName, 
fp.calendarQuarter, 
fp.calendarYear, 
fi.filingDate, 
fd.dataItemId, 
di.dataItemName, 
fd.dataItemValue, 
( fd.dataItemValue * cex2.priceClose ) / cex.priceClose AS DataItemValue_GBP

FROM ciqCompany c

JOIN ciqCountryGeo co ON co.countryId = c.countryId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeId = fp.periodTypeId
JOIN ciqFinInstance fi ON fi.financialPeriodId = fp.financialPeriodId
JOIN ciqFinInstanceToCollection ic ON ic.financialInstanceId = fi.financialInstanceId
JOIN ciqFinCollection fc ON fc.financialCollectionId = ic.financialCollectionId
JOIN ciqFinCollectionData fd ON fd.financialCollectionId = fc.financialCollectionId
JOIN ciqCurrency cu ON cu.currencyid = fc.currencyId
JOIN ciqDataItem di ON di.dataItemId = fd.dataItemId
JOIN ciqExchangeRate cex ON cex.currencyId = fc.currencyId
AND cex.priceDate = fi.periodEndDate
JOIN ciqExchangeRate cex2 ON cex2.priceDate = cex.priceDate
JOIN ciqCurrency cu2 ON cu2.currencyid = cex2.currencyid

WHERE fd .dataItemId = 300 --Sales

AND fp.periodTypeId = 1 --Annual
AND c.Companyid=323452 -- Novo Nordisk A/S
AND fi.periodEndDate = '12/31/2007'
AND cu2.currencyName LIKE 'British Pound%' --Target Currency

ORDER BY filingDate DESC