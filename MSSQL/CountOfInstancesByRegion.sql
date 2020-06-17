/************************************************************************************************
Number of quarterly instances by region using Dynamic Pivot

Packages Required:
Base Foundation Company Daily
Finl Premium Core

Universal Identifiers:
companyId

Primary Columns Used:
financialPeriodId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample query below retrieves count the number of quarterly instances by Region using Dynamic Pivot.

***********************************************************************************************/

IF OBJECT_ID('tempdb..#results') IS NOT NULL
  /*Then it exists*/
  DROP TABLE #results

select
co.companyId,
companyname,
cg.region,
fp.fiscalQuarter,
fp.fiscalYear,
count(*) as instanceCounts
into #results
from
ciqCompany co
join ciqCountryGeo cg 
      on co.countryId = cg.countryId
join ciqFinPeriod fp
      on fp.companyId =co.companyId
join ciqFinInstance fi
      on fi.financialPeriodId = fp.financialPeriodId
where fp.periodTypeId = 2 -- Quarterly
--and fi.latestFilingForInstanceFlag = 1
group by 
co.companyId,
companyname,
cg.region,
fp.fiscalQuarter,
fp.fiscalYear
order by fp.fiscalYear, fp.fiscalQuarter

DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX);

SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(a.region) 
            FROM #results a
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
        
print @cols        
        
set @query = ' with cntryCount as
                        (SELECT fiscalQuarter,fiscalyear,' + @cols + ' from 
            (
                select fiscalQuarter,fiscalYear
                              ,region
                    ,instanceCounts
                from #results
           ) x
            pivot 
            (
                 sum(instanceCounts)
                for region in (' + @cols + ')
            ) p )
            select * from cntryCount
            order by 2,1
            '
            
    print @query   
execute(@query)
