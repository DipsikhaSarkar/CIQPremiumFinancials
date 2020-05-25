/************************************************************************************************
View all business segment financials for a company

Packages Required:
Premium Financials Core 
Premium Financials Detail
Premium Financials Statement
Premium Financials Segment Financials
Base Foundation Company
Data Item Master

Primary ID's Used:
comapnyId
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
segmentId
segmentTypeId
subTotalDataItemId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample SQL query demonstrates how to view the latest annual business segment 
financials for International Business Machines Corp. (in the reported currency).
Note: This sample query includes data from all Segment Add-On packages: the Segment Financial 
Data Add-On package (loads into ciqFinCollectionData table), the Segment Financials Add-On, 
and the Segment Profiles Add-On.

***********************************************************************************************/

SELECT c.companyName
, st.segmentTypeDescription
, s.segmentName
, cfp.fiscalYear
, cc.currencyName
, di1.dataItemName
, scd.dataItemValue AS 'Segment Item Value'
, fut1.unitTypeName
, scd.nmFlag
, di2.dataItemName
, fcd.dataItemValue AS 'Total Item Value'
, fut2.unitTypeName
, fcd.nmFlag
, (CASE
 WHEN (scd.nmFlag <>'1' OR fcd.nmFlag <>'1' )
 THEN (scd.dataItemValue/fcd.dataItemValue)*100 
 ELSE 'Not Meaningful'
 END) AS 'Segment % of Total'
 
FROM ciqSegment s (nolock)
JOIN ciqSegmentType st (nolock) ON s.segmentTypeId = st.segmentTypeId
JOIN ciqSegCollectStandCmpntData scd (nolock) ON s.segmentId = scd.segmentId --segment standardized component data
JOIN ciqCompany c (nolock) ON s.companyId = c.companyId
JOIN ciqDataItem di1 (nolock) ON scd.dataItemId = di1.dataItemId
JOIN ciqFinUnitType fut1 (nolock) ON scd.unitTypeId = fut1.unitTypeId
JOIN ciqFinCollection fc (nolock) ON scd.financialCollectionId = fc.financialCollectionId
JOIN ciqFinInstanceToCollection fitc (nolock) ON fc.financialCollectionId = fitc.financialCollectionId
JOIN ciqFinInstance cfi (nolock) ON fitc.financialInstanceId = cfi.financialInstanceId
JOIN ciqFinPeriod cfp (nolock) ON cfi.financialPeriodId = cfp.financialPeriodId
JOIN ciqFinCollectionData fcd (nolock) ON fc.financialCollectionId = fcd.financialCollectionId --data from Standardized Segments SubTotal Items package
JOIN ciqDataItem di2 (nolock) ON fcd.dataItemId = di2.dataItemId
JOIN ciqFinUnitType fut2 (nolock) ON fcd.unitTypeId = fut2.unitTypeId
JOIN ciqCurrency cc (nolock) ON fc.currencyId = cc.currencyId
JOIN ciqSegmentSubTotals sst (nolock) ON di1.dataItemId = sst.componentDataItemId AND di2.dataItemId = sst.subTotalDataItemId --provides mapping of segment-level dataItemID's to the sub-total dataItemID's

WHERE cfp.companyId = '112350' --IBM
AND s.segmentTypeId = '1' --Business Segments, '2' for Geographic
AND cfp.periodTypeId = '1' --Annual
AND cfp.latestPeriodFlag = '1' --Most recent period
AND cfi.latestForFinancialPeriodFlag = '1' --Latest instance

ORDER BY di2.dataItemName, s.segmentName
 