/************************************************************************************************
Pulling CSD Companies and Fiscal Periods Updated within A Given date range.

Packages Required:
Credit Stats Corp Daily
Credit Stats FI Daily
Credit Stats Reference Daily
Base Company
Base Data Item Master
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary Columns Used:
finPeriodId
periodTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns companies and fiscal periods updated within a given date range 
using the SP Credit Stats package in Xpressfeed.

***********************************************************************************************/

SELECT c.companyid, 
c.companyname, 
fp.fiscalyear, 
fiscalquarter, 
fpt.periodtypename, 
fp.finperiodid, 
fp.lastupdatedate

FROM ciqcsdfinperiod fp

JOIN ciqcompany c ON c.companyid = fp.companyid
JOIN ciqcsdfinperiodtype fpt ON fp.periodtypeid = fpt.periodtypeid

WHERE fp.lastupdatedate BETWEEN '03-28-2015' AND '03-30-2015'
ORDER BY fp.companyid, 
fp.fiscalyear, 
fp.fiscalquarter