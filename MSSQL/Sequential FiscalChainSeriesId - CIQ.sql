/************************************************************************************************
Pulls from and thru dates for each fiscalChainSeriesId change, including when the Id changes back to a previous fiscalChainSeriesId (i.e., Morgan Stanley 472898)

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Financials Premium Intraday Core
Base Data Item Master

Universal Identifiers:
companyId

Primary Columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample query below retrieves Pulls from and thru dates for each fiscalChainSeriesId change, 
including when the Id changes back to a previous fiscalChainSeriesId (i.e., Morgan Stanley 472898).
Notes -
--Identify single fiscalChainSeriesId for fiscal year for smooth time series (eliminates overlapping data but may result in overlapping periods included in each fiscal year)
--The query only selects the max fiscal period data for any given document so restatements will not be included in the fiscalChain selection
--FiscalYear in the Quarterly table is just the year of the periodEndDate so might not perfectly aline with all companies - FYI

***********************************************************************************************/

IF Object_id('tempdb..#FinancialPeriodInstance') IS NOT NULL
  BEGIN
      DROP TABLE #FinancialPeriodInstance
  END
GO

  IF Object_id('tempdb..#max_filingDate') IS NOT NULL
  BEGIN
      DROP TABLE #max_filingDate
  END
GO

  IF Object_id('tempdb..#FCSID_Annual') IS NOT NULL
  BEGIN
      DROP TABLE #FCSID_Annual
  END
GO

  IF Object_id('tempdb..#Annual') IS NOT NULL
  BEGIN
      DROP TABLE #Annual
  END
GO

  IF Object_id('tempdb..#AnnualFinalPrep') IS NOT NULL
  BEGIN
      DROP TABLE #AnnualFinalPrep
  END
GO

  IF Object_id('tempdb..#AnnualFinal') IS NOT NULL
  BEGIN
      DROP TABLE #AnnualFinal
  END
GO

  IF Object_id('tempdb..#Final') IS NOT NULL
  BEGIN
      DROP TABLE #Final
  END
GO


Declare @companyId int Set @companyId=472898
Declare @periodType smallint Set @periodType = 1 --(1 annual ; 2 quarterly)



SELECT
 fp.financialPeriodID,    
 fp.periodTypeID,  
 --fp.calendarYear,  
 --fp.calendarQuarter,  
 fp.companyID,  
 --fp.simplyStocksID,  
 fp.fiscalChainSeriesID,  
 fp.fiscalYear,  
 fp.fiscalQuarter,  
 fi.financialInstanceId,  
 fi.filingDate,  
 fi.PeriodEndDate,  
 --fi.documentDetailsID, 
 fi.documentId,
 fi.formType,
 fi.InstanceTypeID,  
 fi.latestForFinancialPeriodFlag,  
 fi.amendmentFlag,  
 fi.isRestatementTypeID,  
 fi.bsRestatementTypeID,  
 fi.cfRestatementTypeID,  
 --fi.reportedCurrencyId,  
 fi.latestFilingForInstanceFlag 
 --fi.useAsComponentFlag  
into #FinancialPeriodInstance
from ciqFinPeriod fp (nolock)  
inner join ciqFinInstance fi (nolock)  
            on fp.financialPeriodId=fi.financialPeriodId
			--and fi.latestFilingForInstanceFlag=1
			and fi.instanceTypeId=2
			and fp.periodTypeId in (1)
			--and fi.amendmentFlag=0
where fp.companyid = @companyId

select * from #FinancialPeriodInstance order by companyid, filingDate asc, periodEndDate asc


--Annual
select distinct fi.companyID 
, fi.PeriodEndDate 
, fi.fiscalChainSeriesID
, fiscalQuarter
, fi.fiscalYear
, fi.filingDate
, isnull(lead(fi.fiscalYear) over (partition by fi.companyid order by fi.companyId, fi.periodenddate),fi.fiscalYear+1) as subseq_fiscalYear
--, *
into #FCSID_Annual
from #FinancialPeriodInstance  fi
inner join (
       select  companyID
	   , periodTypeId
	   ,  isnull(DocumentID,1) as DocumentId
	   , MAx(PeriodEndDate) PeriodEndDate
       from #FinancialPeriodInstance t    
       group by t.companyID, t.documentID, periodTypeId --order by periodEndDate desc  
)  fimax 
on fimax.companyID = fi.companyID
and isnull(fimax.DocumentID,1) = isnull(fi.DocumentID,1)
and fimax.PeriodEndDate = fi.PeriodEndDate
and fimax.periodTypeId = fi.periodTypeId
--join #max_filingDate mfd on mfd.companyId=fi.companyId and mfd.fiscalYear=fi.fiscalYear and mfd.max_filingDate=fi.filingDate
where 1=1
--and fi.latestFilingForInstanceFlag=1
order by fi.periodenddate desc




select a.companyId, a.fiscalYear, max(filingDate) as max_filingDate 
into #max_filingDate
from (
select a.companyId, fiscalYear, filingDate from  #FCSID_Annual a) a
group by a.companyId, a.fiscalYear




select a.* 
into #Annual
from #FCSID_Annual a
join #max_filingDate mfd on mfd.companyId=a.companyId 
	and mfd.fiscalYear=a.fiscalYear 
	and mfd.max_filingDate=a.filingDate



select * 
into #AnnualFinalPrep
from (
select distinct(fcs.fiscalYear) as fiscalYear
, fcs.subseq_fiscalYear
, fcs.fiscalYear -1 as 'fiscalYear-1'
, fcs.companyId
, fcs.fiscalChainSeriesId
, fcs.fiscalQuarter
, fcs.periodEndDate
--, fpi.financialInstanceId
--, fpi.financialPeriodId

from #Annual fcs
	join (select fp.financialPeriodId
		, fp.companyId
		, fp.fiscalChainSeriesId	
		, fp.fiscalYear
		, fp.fiscalQuarter
		, fp.periodTypeId
		, fi.financialInstanceId
		, fi.periodEndDate
		, fi.latestFilingForInstanceFlag
		, fi.latestForFinancialPeriodFlag
	from ciqFinPeriod fp
		join ciqFinInstance fi on fi.financialPeriodId=fp.financialPeriodId where fp.periodtypeid in (1) and latestFilingForInstanceFlag=1 --and latestForFinancialPeriodFlag=1 --I don't think this is needed but just removed on 10/23 - need to check if still needed
		--and fp.companyid=@companyId
		) fpi on fpi.companyId=fcs.companyId and fpi.fiscalChainSeriesId=fcs.fiscalChainSeriesId and fpi.periodEndDate=fcs.periodEndDate
) u
--where fiscalYear!=subseq_fiscalYear
order by companyid, periodEndDate desc


select f.companyId, f.periodEndDate, f.fiscalchainseriesId
, lag(f.fiscalchainseriesId) over (partition by f.companyid order by f.companyId, f.periodenddate) Lag_FCSID
, f.fiscalYear, f.subseq_fiscalYear, f.[fiscalYear-1]
, lag(f.fiscalYear) over (partition by f.companyid order by f.companyId, f.periodenddate) as fiscalYearLag
, case when f.fiscalYear -1 > isnull(lag(f.fiscalYear) over (partition by f.companyid order by f.companyId, f.periodenddate),f.fiscalYear) 
	and f.fiscalChainSeriesId!=isnull(lag(f.fiscalchainseriesId) over (partition by f.companyid order by f.companyId, f.periodenddate),f.fiscalChainSeriesId) then 'Gap in Years & FC'
	when f.fiscalYear -1 > isnull(lag(f.fiscalYear) over (partition by f.companyid order by f.companyId, f.periodenddate),f.fiscalYear) then 'Gap in Years'
	when f.fiscalChainSeriesId=isnull(lag(f.fiscalchainseriesId) over (partition by f.companyid order by f.companyId, f.periodenddate), f.fiscalChainSeriesId) then ''
	else 'Fiscal Change' end as 'FY Change / GAP Flag'
into #AnnualFinal
from #AnnualFinalPrep f
 order by companyId, periodEndDate

 select af.companyId, af.fiscalChainSeriesId, af.fiscalYear, af.periodEndDate, af.[FY Change / GAP Flag]
 from #annualFinal af


select f.companyId, f.fiscalchainseriesId, f.fiscalYear, f.periodEndDate, f.[FY Change / GAP Flag]
, isnull(datediff(month, Lag(f.periodEndDate) over (order by f.companyId, f.fiscalyear asc), f.periodenddate) -12 , 0) as FiscalShift_Months
, fd.dataItemId, fd.dataItemName, fd.dataItemValue--, currencyId
from #AnnualFinal f
left join (select fp.companyId, fp.fiscalChainSeriesId, fp.periodTypeId, fp.fiscalyear, fp.fiscalQuarter, fi.periodEndDate, fcd.dataitemid, di.dataItemName, fcd.dataItemValue, fc.currencyId
from ciqFinPeriod fp 
join ciqFinInstance fi on fi.financialPeriodId=fp.financialPeriodId 
		and fp.periodTypeId in (1) --(1 annual ; 2 quarterly)
		and fp.fiscalQuarter=4 --Include this for annual only
	and fi.latestFilingForInstanceFlag=1 and fi.latestForFinancialPeriodFlag=1
join ciqFinInstanceToCollection fic on fic.financialInstanceId=fi.financialInstanceId
join ciqFinCollection fc on fc.financialCollectionId=fic.financialCollectionId and fc.nonStandardLengthFlag=0
join ciqFinCollectionData fcd on fcd.financialCollectionId=fc.financialCollectionId and fcd.dataItemId=28
	join ciqDataItem di on di.dataitemid=fcd.dataItemId 
	--where fp.companyid=@companyId
) fd on fd.companyid=f.companyId and fd.fiscalChainSeriesId=f.fiscalChainSeriesId and fd.periodEndDate=f.periodEndDate
--where  fd.fiscalYear!=f.subseq_fiscalYear --If multiple records for a fiscal year do occur this will only pull in the latest
order by f.companyId, f.periodenddate


