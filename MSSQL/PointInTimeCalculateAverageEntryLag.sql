/************************************************************************************************
Point-in-time sample query which calculates the average lag for US companies

Packages Required:
Base Company
Base Foundation Company Daily
Financials Premium Intraday Core
Finl Latest Core
Finl Premium Core


Primary ID's Used:
pk_ciqFinInstance
pk_ciqFinPeriod
pk_ciqRestatementType


The following sample SQL query uses the Premium Financials Instance Date package to calculate '
the average lag for US companies, based on the restatement and form types. The query limits 
the universe to US, Original 10-Q collection for post 2009 records.

***********************************************************************************************/


WITH PIT AS
(
 SELECT a.financialInstanceId,a.instanceDate,a.instanceDateTypeId FROM 
 ciqFinInstanceDate a
 WHERE a.instanceDateTypeId = 1  and CONVERT(VARCHAR(10), instanceDate, 105) =  '11-05-2020' -- input required actual date in format 'dd-mm-yyyy'
)
SELECT 
datepart(YEAR,CAST(b.periodEndDate AS DATE)) AS periodYear, b.formType,rt.restatementTypeName,
COUNT(b.financialInstanceID) countInstanceId,
SUM(datediff(DAY,b.filingDate,PIT.instanceDate))/COUNT(b.financialInstanceID) AS avgLagDays
FROM 
PIT 
JOIN ciqFinInstance b ON PIT.financialInstanceId = b.financialInstanceId
JOIN ciqRestatementType rt ON b.restatementTypeId = rt.restatementTypeId
JOIN ciqFinPeriod p ON b.financialPeriodId = p.financialPeriodId
JOIN ciqCompany c ON p.companyId = c.companyId
AND c.countryId = 213 -- USA
JOIN ciqCountryGeo g ON c.countryId = g.countryId

WHERE b.restatementTypeId = 2 AND -- 1 = press release, 2 = original
b.formType = '10-Q' AND -- 10Q only
datepart(YEAR,CAST(b.periodEndDate AS DATE)) >= 2009

GROUP BY datepart(YEAR,CAST(b.periodEndDate AS DATE)),b.formType,rt.restatementTypeName
ORDER BY 2,1 DESC
 