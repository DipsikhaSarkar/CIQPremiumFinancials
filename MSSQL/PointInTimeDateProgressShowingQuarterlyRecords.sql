
/************************************************************************************************
Point-in-time date progress showing quarterly records

Packages Required:
Base Company
Premium Financials Core 
Premium Financials Detail
Premium Financials Instance Date

Primary ID's Used:
pk_ciqFinInstance
pk_ciqFinInstanceDate
pk_ciqFinInstanceDateType
pk_ciqFinPeriod
pk_ciqPeriodType
pk_ciqRestatementType

The following sample SQL query uses the Premium Financials Instance Date package to display
Apple's filing vs. point-in-time date progression.

***********************************************************************************************/

WITH PIT AS
(
 SELECT a.financialInstanceId,a.instanceDate,a.instanceDateTypeId,t.description
 FROM ciqFinInstanceDate a (nolock)
 JOIN ciqFinInstanceDateType t (nolock) ON a.instanceDateTypeId = t.instanceDateTypeId
 --where a.InstanceDateTypeId = 1 Note: You can choose to use only instanceDateTypeId = 1 which indicates the Xpressfeed feed physical file delivery date.
)
SELECT 
b.financialInstanceId,CAST(b.periodEndDate AS DATE) periodEndDate,p.calendarYear,p.calendarQuarter,rt.restatementTypeName,pt.periodTypeName,
b.formType,CAST(b.filingDate AS DATE) filingDate,PIT.instanceDate,
datediff(DAY,b.filingDate,PIT.instanceDate) AS lagDays,PIT.instanceDateTypeId,PIT.[description]
FROM
PIT 
JOIN ciqFinInstance b (nolock) ON PIT.financialInstanceId = b.financialInstanceId
JOIN ciqRestatementType rt (nolock) ON b.restatementTypeId = rt.restatementTypeId
JOIN ciqFinPeriod p (nolock) ON b.financialPeriodId = p.financialPeriodId
JOIN ciqPeriodType pt (nolock) ON p.periodTypeId = pt.periodTypeId
JOIN ciqCompany c (nolock) ON p.companyId = c.companyId

WHERE c.companyId = 24937 -- AAPL
--and b.formType = '10-Q'
AND rt.restatementTypeName = 'Press Release'
--and rt.restatementTypeName = 'Original'
--and pt.periodTypeName = 'Quarterly'
AND pt.periodTypeId IN (1,2)
AND b.periodEndDate >= '2009-01-01'
ORDER BY b.periodEndDate DESC,b.filingDate DESC
 