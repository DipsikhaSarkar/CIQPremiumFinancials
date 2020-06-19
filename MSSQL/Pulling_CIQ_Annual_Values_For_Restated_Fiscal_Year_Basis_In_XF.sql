/************************************************************************************************
Pulling CIQ Annual Values for Restated Fiscal Year Basis.

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
Base Foundatin Company Daily
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

This query returns the SP Capital IQ annual financials data for a company restated for 
the latest fiscal-year change (FiscalChainSeriesId) in Xpressfeed. The fiscal year used are
1994 , 1995 , 1996 , 2008 , 2009.

***********************************************************************************************/

DECLARE @CompanyId INT
SET @CompanyId = '472898' -- Morgan Stanley
SELECT DISTINCT cfcd.FinancialCollectionId, 
cfi.financialPeriodId, 
cfp.CompanyId, 
fec.CompanyName,
cfp.fiscalChainSeriesId, 
cfp.FiscalYear, 
cfcd.DataItemId, 
cdi.DataItemName, 
cfcd.DataItemValue

FROM ciqCompany AS fec

INNER JOIN ciqSecurity AS csec WITH ( NOLOCK ) ON fec.CompanyId = csec.CompanyId
INNER JOIN ciqTradingItem AS cti WITH ( NOLOCK ) ON csec.SecurityId = cti.SecurityId
INNER JOIN ciqExchange AS cex WITH ( NOLOCK ) ON cti.ExchangeId = cex.ExchangeId
INNER JOIN ciqFinPeriod AS cfp WITH ( NOLOCK ) ON fec.CompanyId = cfp.CompanyId
INNER JOIN ciqPeriodType AS cpt WITH ( NOLOCK ) ON cfp.PeriodTypeId = cpt.PeriodTypeId
INNER JOIN ciqFinInstance AS cfi WITH ( NOLOCK ) ON cfp.FinancialPeriodId = cfi.FinancialPeriodId
INNER JOIN ciqFinInstanceToCollection AS cfitc WITH ( NOLOCK ) ON cfi.FinancialInstanceId = cfitc.FinancialInstanceId
INNER JOIN ciqFinCollection AS cfc WITH ( NOLOCK ) ON cfitc.FinancialCollectionId = cfc.FinancialCollectionId
INNER JOIN ciqFinCollectionData AS cfcd WITH ( NOLOCK ) ON cfc.FinancialCollectionId = cfcd.FinancialCollectionId
INNER JOIN ciqDataItem AS cdi WITH ( NOLOCK ) ON cfcd.DataItemId = cdi.DataItemId
INNER JOIN

( SELECT fp.financialPeriodId, 
fp.fiscalYear, 
fp.fiscalChainSeriesId, RANK () OVER ( PARTITION BY fp.fiscalyear ORDER BY fp.fiscalchainseriesId DESC ) N


FROM ciqFinPeriod fp
WHERE fp.companyId = @CompanyId ) AS cfi2


ON cfi2.financialPeriodId = cfi.financialPeriodId
AND cfi2.N = 1

WHERE cfp.PeriodTypeId = 1

AND cfp.LatestPeriodFlag IN ( 0 , 1 )
AND cfi.LatestForFinancialPeriodFlag = 1
AND cfi.LatestFilingForInstanceFlag = 1
AND cfp.companyId = @CompanyId
AND cfc.nonStandardLengthFlag = 0
AND cfp.fiscalYear IN ( 1994 , 1995 , 1996 , 2008 , 2009 )

GROUP BY cfcd.FinancialCollectionId, 
cfi.financialPeriodId, 
cfp.CompanyId, 
fec.CompanyName, 
cfp.fiscalChainSeriesId, 
cfi.restatementTypeId, 
cfp.FiscalYear, 
cfcd.DataItemId, 
cdi.DataItemName, 
cfcd.DataItemValue

ORDER BY cfp.fiscalYear, cfcd.dataItemId