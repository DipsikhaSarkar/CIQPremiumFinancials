/************************************************************************************************
Moving Averages in CIQ Price Equity for company Andeavor Logistics LP

Packages Required:
Base Company
Base Exchange Rates
Market Capitalization
Prices Intraday 1990s
Base Security

Primary ID's Used:
companyId
securityId
tradingItemId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10, 17

The following sample query below Calculating Moving Averages in CIQ Price Equity for company Andeavor Logistics LP (Tradingitemid - 119026799).

***********************************************************************************************/

DECLARE @FROMDATE as DateTime
DECLARE @TODATE as DateTime
DECLARE @TRADINGITEMID as INT

SET @FROMDATE = '01/01/2014'
SET @TODATE = getdate()
SET @TRADINGITEMID='119026799' --Andeavor Logistics LP (NYSE:ANDX) NYSE:ANDX


SELECT * FROM ( SELECT 

ti.tradingItemId, pe.pricingDate, cp.companyId
,(pe.priceClose*isnull(daf.divAdjFactor,1)/isnull(er.priceclose,1))
ClosePrice 

,avg((pe.priceClose*isnull(daf.divAdjFactor,1)/isnull(er.priceclose,1
))) OVER (PARTITION by pe.tradingItemId ORDER BY pe.pricingDate ROWS 49
PRECEDING) AS MA50 

,avg((pe.priceClose*isnull(daf.divAdjFactor,1)/isnull(er.priceclose,1
))) OVER (PARTITION by pe.tradingItemId ORDER BY pe.pricingDate ROWS 99
PRECEDING) AS MA100 

,avg((pe.priceClose*isnull(daf.divAdjFactor,1)/isnull(er.priceclose,1
))) OVER (PARTITION by pe.tradingItemId ORDER BY pe.pricingDate ROWS 199
PRECEDING) AS MA200 

FROM ciqTradingItem ti (nolock) 
	left join ciqExchange ex (nolock)

	on ex.exchangeId = ti.exchangeId 
	join ciqPriceEquity pe (nolock) on
	pe.tradingItemId = ti.tradingItemId 

join ciqexchangerate er (nolock) on
er.currencyid=ti.currencyid and er.pricedate=pe.pricingdate 

left join ciqPriceEquityDivAdjFactor daf (nolock) on
pe.tradingItemId=daf.tradingItemId 

join ciqsecurity sc (nolock) on
sc.securityId=ti.securityId 

join ciqcompany cp (nolock) on
cp.companyId=sc.companyId 

join ciqMarketCap mc (nolock) on
mc.companyId=sc.companyId and mc.pricingdate=pe.pricingdate 

and pe.pricingDate between isnull (daf.fromDate, @FROMDATE) and
isnull(daf.toDate, @TODATE) 

and pe.pricingDate between @FROMDATE and @TODATE and
(pe.priceClose*isnull(daf.divAdjFactor,1)/isnull(er.priceclose,1)) is
not null
	AND ti.tradingitemid=@TRADINGITEMID ) as tab1 

where tab1.pricingDate between @FROMDATE and @TODATE 

ORDER BY tab1.tradingItemId, tab1.pricingDate desc
