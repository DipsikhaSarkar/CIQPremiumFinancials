/************************************************************************************************
The following sample query below retrieves Total return calculation for company INTL BUSINESS MACHINES CORP (006066).

Packages Required:
Core

Primary ID's Used:
pk_sec_dtrt

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample query below retrieves Total return calculation for company INTL BUSINESS MACHINES CORP (006066).

***********************************************************************************************/

declare @gvkey as varchar(6); set @gvkey ='006066'; --INTL BUSINESS MACHINES CORP 
declare @iid as varchar(3); set @iid ='01';
declare @retPer as int; set @retPer =1;
with retData as (
    select 
    ROW_NUMBER() over(partition by dp.gvkey, dp.iid order by dp.datadate desc) as relDate,
    dp.*,
    trt.trfd
    from
    sec_dprc dp
    left join sec_dtrt trt
        on trt.gvkey = dp.gvkey
        and trt.iid = dp.iid
        and dp.datadate between trt.datadate and isnull(trt.thrudate,'1/1/2900')
    where dp.gvkey = @gvkey
          and dp.iid = @iid
)
select 
    r1.gvkey,
    r1.iid,
    r1.relDate,
    r1.datadate,
    r1.prccd,
    r1.ajexdi,
    r1.trfd,
    (((((r1.PRCCD/r1.AJEXDI)*ISNULL( r1.TRFD,1))/((r2.PRCCD/r2.AJEXDI)*ISNULL(r2.TRFD,1)))-1)*100)AS TotalReturn
from 
    retData r1
join retData r2
    on r2.gvkey = r1.gvkey
    and r2.iid = r1.iid
    and r1.relDate = r2.relDate-@retper
