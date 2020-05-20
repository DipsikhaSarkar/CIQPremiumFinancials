/************************************************************************************************
View summary debt information for a company

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Premium Financials Capital Structure
Base Foundation Company
Data Item Master

Primary ID's Used:
pk_ciqFinCollection
pk_ciqFinCollectionData
pk_ciqFinInstance
pk_ciqFinInstanceToCollection
pk_ciqFinInstanceType
pk_ciqFinPeriod

The following sample SQL query demonstrates how to view summary debt information for IBM over a 10-year period.

Note: This sample query is for the Capital Structure Add-On delivered through the 
ciqFinCollectionData table in the Premium Financials Core Package.


***********************************************************************************************/

SELECT * FROM 
 
 (SELECT DISTINCT
 di.dataItemName AS 'Data Item',
 CAST (fccsd.dataItemValue AS NUMERIC (28, 1)) AS 'Total',
 fp.fiscalYear
 FROM ciqCompany comp (NOLOCK)
 JOIN ciqFinPeriod fp (NOLOCK)
 ON comp.companyId = fp.companyId
 JOIN ciqFinInstance fi (NOLOCK)
 ON fp.financialPeriodID = fi.financialPeriodID
 JOIN ciqFinInstanceToCollection fitc (NOLOCK)
 ON fi.financialInstanceID = fitc.financialInstanceID
 JOIN ciqFinInstanceType it (NOLOCK)
 ON it.InstanceTypeID = fi.instanceTypeID
 JOIN ciqFinCollection fc (NOLOCK)
 ON fitc.financialCollectionID = fc.financialCollectionID
 JOIN ciqFinCollectionData fccsd (NOLOCK)
 ON fccsd.financialCollectionID = fc.financialCollectionID
 JOIN ciqDataItem di (NOLOCK)
 ON di.dataItemId = fccsd.dataItemID
 JOIN ciqDataItemGroupToDataItem digdi (NOLOCK)
 ON digdi.dataItemId = di.dataItemId
 AND digdi.dataItemGroupId = 8 --Standardized DCS Subtotal Items
 WHERE comp.companyID = 112350 --International Business Machines
 AND fp.periodTypeID = 1 --Annual
 AND fi.latestFilingForInstanceFlag = 1
 AND fi.latestForFinancialPeriodFlag = 1) AS SourceQuery 
 
 PIVOT (
 SUM (Total)
 FOR FiscalYear
 IN (
 [2001],
 [2002],
 [2003],
 [2004],
 [2005],
 [2006],
 [2007],
 [2008],
 [2009],
 [2010])) AS PivotTable
ORDER BY 1, 2
 

