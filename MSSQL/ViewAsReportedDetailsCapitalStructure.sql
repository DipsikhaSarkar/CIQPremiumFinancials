/************************************************************************************************
View as-reported details for a company’s debt capital structure

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Premium Financials Capital Structure
Base Foundation Company
Data Item Master

Primmary ID's Used:
pk_ciqCapStDtCompntAsRptdData
pk_ciqCapStDtComponent
pk_ciqCapStDtConvertibleType
pk_ciqCapStDtInterestRate
pk_ciqCapStDtLevelType
pk_ciqCapStDtSecuredType
pk_ciqCapStDtSubType
pk_ciqFinCollection
pk_ciqFinInstance
pk_ciqFinInstanceToCollection
pk_ciqFinPeriod

The following sample SQL query demonstrates how to view as reported details for IBM’s 
FY 2009 debt capital structure.

Note: This query is for the Debt Capital Structure Add-On delivered via a separate package.

***********************************************************************************************/

SELECT DISTINCT
 c.capitalStructureDescription AS 'Description',
 csst.capitalStructureSubTypeName AS 'Type',
 CAST (crd.dataItemValue AS NUMERIC (28, 1)) AS 'Principal Due',
 CAST (ir.interestRateHighValue AS NUMERIC (28, 3))
 AS 'Coupon Rate (%)',
 c.maturityYearHigh AS 'Maturity Year',
 c.maturityMonthHigh AS 'Maturity Month',
 c.maturityDayHigh AS 'Maturity Day',
 lt.levelTypeName AS 'Seniority',
 st.securedTypeName AS 'Secured',
 CASE
 WHEN ct.convertibleTypeName LIKE 'Convertible' THEN 'YES'
 WHEN ct.convertibleTypeName LIKE 'Not Convertible' THEN 'NO'
 ELSE ct.convertibleTypeName
 END
 AS 'Convertible',
 curr.ISOCode AS 'Repayment Currency',
 c.componentID,
 --fi.financialInstanceId,
 --fc.financialCollectionID,
 fp.fiscalYear,
 MIN(fi.filingDate) AS filingDate
 
 FROM ciqFinPeriod fp (NOLOCK)
 JOIN ciqFinInstance fi (NOLOCK)
 ON fp.financialPeriodID = fi.financialPeriodID
 --AND fi.latestFilingForInstanceFlag = 1
 --AND fi.latestForFinancialPeriodFlag = 1
 JOIN ciqFinInstanceToCollection fitc (NOLOCK)
 ON fi.financialInstanceID = fitc.financialInstanceID
 JOIN ciqFinCollection fc (NOLOCK)
 ON fitc.financialCollectionID = fc.financialCollectionID
 JOIN ciqCompany comp (NOLOCK)
 ON comp.companyID = fp.companyID
 JOIN ciqCapStDtComponent c (NOLOCK)
 ON comp.companyID = c.companyID
 JOIN ciqCapStDtCompntAsRptdData crd (NOLOCK)
 ON crd.componentID = c.componentID
 AND crd.financialCollectionID = fc.financialCollectionID
 JOIN ciqCapStDtSubType csst (NOLOCK)
 ON csst.capitalStructureSubTypeID = c.capitalStructureSubTypeId
 JOIN ciqCapStDtConvertibleType ct (NOLOCK)
 ON ct.convertibleTypeID = c.ConvertibleTypeId
 JOIN ciqCapStDtSecuredType st (NOLOCK)
 ON st.securedTypeID = c.SecuredTypeId
 JOIN ciqCapStDtLevelType lt (NOLOCK)
 ON lt.levelTypeID = c.LevelTypeId
 JOIN ciqCapStDtInterestRate ir (NOLOCK)
 ON ir.componentID = c.componentID
 JOIN ciqCurrency curr (NOLOCK)
 ON curr.currencyId = c.issuedcurrencyID
 
 WHERE comp.companyID = 112350 --International Business Machines
 AND fp.periodTypeID = 1 --Annual
 AND fp.fiscalYear = 2009 
 
 GROUP BY c.capitalStructureDescription,
 csst.capitalStructureSubTypeName,
 CAST (crd.dataItemValue AS NUMERIC (28, 1)),
 CAST (ir.interestRateHighValue AS NUMERIC (28, 3)),
 c.maturityYearHigh,
 c.maturityMonthHigh,
 c.maturityDayHigh,
 lt.levelTypeName,
 st.securedTypeName,
 CASE
 WHEN ct.convertibleTypeName LIKE 'Convertible' THEN 'YES'
 WHEN ct.convertibleTypeName LIKE 'Not Convertible' THEN 'NO'
 ELSE ct.convertibleTypeName
 END,
 curr.ISOCode,
 c.componentID,
 fp.fiscalYear
 
ORDER BY c.componentID, filingDate, 1,2,3,4,5
 