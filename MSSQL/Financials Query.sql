/***********************************************************************
Latest Financials Coverage

Packages Required:
Base Data Item Master
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Statement
Finl Premium Supplemental
Finl Premium Core

Primary ID's Used:
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

Extract the top 500 companies related annual financials data considering 
filing date on or before inputted date and considering the latest filings 
for each financial instance.

***********************************************************************/

IF Object_id(N'TEMPDB..#CIQ_Fundamental_Map') IS NOT NULL 
DROP TABLE #CIQ_Fundamental_Map

DECLARE @REFDATE AS DATE
SET @REFDATE = '01-31-2020'

select @REFDATE as ReferenceDate, fp.companyId, fp.periodTypeId, fp.financialPeriodId, fi.financialInstanceId, fi.periodEndDate, fi.filingDate
	   into #CIQ_Fundamental_Map
       from  ciqFinPeriod fp
              join ciqPeriodType pt on pt.periodTypeId = fp.periodTypeId
              join ciqFinInstance fi on fi.financialPeriodId = fp.financialPeriodId
       where 1=1
              and fp.periodTypeId = 1 -- Annual Filing
              and fp.companyid in 
			  (select top 500 [companyId] from ciqCompany) ---This is where we could set the population we are interested in
              and fi.latestFilingForInstanceFlag = 1 -- Latest Filing For Instance
              and fi.filingDate <= @REFDATE
       order by companyId, periodEndDate, filingDate

SELECT * FROM(
              SELECT map.*, di.dataItemId, di.dataItemName, fd.dataitemvalue,
              case when filingDate = max(filingDate) over (partition by map.financialPeriodId, fd.dataItemId) then 1 else 0 end latestItemFlag
              FROM #CIQ_Fundamental_Map map
              JOIN ciqFinInstanceToCollection ic on ic.financialInstanceId = map.financialInstanceId
              JOIN ciqFinCollectionData fd on fd.financialCollectionId = ic.financialCollectionId
              JOIN ciqDataItem di on di.dataItemId = fd.dataItemId
              where map.referenceDate = @REFDATE
                     --and map.companyId in (select * from #test)
) f 
	where 1=1 
	AND f.latestItemFlag = 1