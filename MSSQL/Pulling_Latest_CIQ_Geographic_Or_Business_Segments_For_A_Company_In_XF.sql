/************************************************************************************************
Latest CIQ Geographic or Business Segments for a company.

Packages Required:
Finl Premium Core
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Segments
Finl Premium Statement
Finl Premium Supplemental
Finl Premium Segment Financials
Finl Premium Segment Profiles
Base Company
Base Data Item Master
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary Columns Used:
companyId
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
segmentId
segmentTypeId
subTotalDataItemId
unitTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query  returns the most recent annual geographic or business segment data 
in the reported currency for a company from the Capital IQ files in Xpressfeed.

***********************************************************************************************/

SELECT c.companyName,
st.segmentTypeDescription, 
s.segmentName, 
cfp.fiscalYear, 
cc.currencyName, 
di1.dataItemName,
scd.dataItemValue AS SegmentItemValue,
fut1.unitTypeName, 
scd.nmFlag, 
di2.dataItemName, 
fcd.dataItemValue AS TotalItemValue, 
fut2.unitTypeName, 
fcd.nmFlag,

( CASE WHEN ( scd.nmFlag = 1 OR fcd.nmFlag = 1 ) THEN CAST(( scd.dataItemValue/fcd.dataItemValue ) *100 as varchar(100)) ELSE 'Not Meaningful' END ) AS SegmentPercentofTotal

FROM ciqSegment s ( NOLOCK )

JOIN ciqSegmentType st ( NOLOCK ) ON s.segmentTypeId = st.segmentTypeId

JOIN ciqSegCollectStandCmpntData scd ( NOLOCK ) ON s.segmentId = scd.segmentId --segment standardized component data

JOIN ciqCompany c ( NOLOCK ) ON s.companyId = c.companyId

JOIN ciqDataItem di1 ( NOLOCK ) ON scd.dataItemId = di1.dataItemId

JOIN ciqFinUnitType fut1 ( NOLOCK ) ON scd.unitTypeId = fut1.unitTypeId

JOIN ciqFinCollection fc ( NOLOCK ) ON scd.financialCollectionId = fc.financialCollectionId

JOIN ciqFinInstanceToCollection fitc ( NOLOCK ) ON fc.financialCollectionId = fitc.financialCollectionId

JOIN ciqFinInstance cfi ( NOLOCK ) ON fitc.financialInstanceId = cfi.financialInstanceId

JOIN ciqFinPeriod cfp ( NOLOCK ) ON cfi.financialPeriodId = cfp.financialPeriodId

JOIN ciqFinCollectionData fcd ( NOLOCK ) ON fc.financialCollectionId = fcd.financialCollectionId --data from Standardized Segments SubTotal Items package

JOIN ciqDataItem di2 ( NOLOCK ) ON fcd.dataItemId = di2.dataItemId

JOIN ciqFinUnitType fut2 ( NOLOCK ) ON fcd.unitTypeId = fut2.unitTypeId

JOIN ciqCurrency cc ( NOLOCK ) ON fc.currencyId = cc.currencyId

JOIN ciqSegmentSubTotals sst ( NOLOCK ) ON di1.dataItemId = sst.componentDataItemId

AND di2.dataItemId = sst.subTotalDataItemId --provides mapping of segment-level dataItemIDs to the sub-total dataItemIDs

WHERE cfp.companyId = '21835' --Microsoft

AND s.segmentTypeId = 2 --2 for Geographic Segments, 1 for Business

AND cfp.periodTypeId = 1 --Annual

AND cfp.latestPeriodFlag = 1 --Most recent period

AND cfi.latestForFinancialPeriodFlag = 1 --Latest instance

 ORDER BY di2.dataItemName, s.segmentName