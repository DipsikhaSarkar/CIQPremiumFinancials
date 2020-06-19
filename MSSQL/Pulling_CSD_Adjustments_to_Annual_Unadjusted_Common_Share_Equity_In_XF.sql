/************************************************************************************************
Pulling CSD Adjustments to Annual Unadjusted Common Share Equity

Packages Required:
Credit Stats Corp Daily
Credit Stats FI Daily
Base Company
Base Data Item Master
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary Columns Used:
dataItemId
finPeriodId
periodTypeId
sectorTypeId
templateSectionId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns adjustments made to annual unadjusted common share equity using the 
SP Credit Stats (CSD) packages in Xpressfeed

***********************************************************************************************/

SELECT fp.companyid, 
c.companyName, 
di.dataitemname, 
fd.dataitemid, 
fd.dataitemvalue, 
fp.periodenddate, 
templatesortorder

FROM ciqcsdfindata fd

JOIN ciqcsdfinperiod fp (NOLOCK) ON fp.finperiodid = fd.finperiodid
JOIN ciqCompany c (NOLOCK) ON c.companyId = fp.companyId
JOIN ciqcsdfintemplate ft (NOLOCK) ON ft.dataitemid = fd.dataitemid
JOIN ciqcsdtemplatesectiontype ftst (NOLOCK) ON ft.templatesectionid = ftst.templatesectionid
JOIN ciqcsdsectortype st(NOLOCK) ON st.sectortypeid = fp.sectortypeid
JOIN ciqcsdfinperiodtype fpt(NOLOCK) ON fpt.periodtypeid = fp.periodtypeid
JOIN ciqdataitem di (NOLOCK) ON di.dataitemid = fd.dataitemid

WHERE fp.companyid = 19049 --- Bank of America

AND fpt.periodtypeid = 1--- Annual
AND ft.templatesectionid = '10160' --- Equity
AND fp.fiscalyear = '2014' ---Fiscal Year

ORDER BY fp.fiscalyear DESC
, fp.fiscalquarter DESC, 
templatesortorder ASC