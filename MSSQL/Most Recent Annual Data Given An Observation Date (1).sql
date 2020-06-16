/************************************************************************************************
Universe of companies determines the most recent annual filing as of the observation date

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Statement
Finl Latest Core

Primary ID's Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId
restaementTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

This query takes an observation date, and then for a universe of companies determines the most
recent annual filing as of the observation date. Query can be customized for other period types and data items.

***********************************************************************************************/

---Declare and set variables

DECLARE @obsDate DATETIME
DECLARE @dataitemid INT
DECLARE @periodtypeid INT
SET @obsDate = '2016-01-01 00:00:00.000'
SET @dataitemid = 28 --Total Revenue
SET @periodtypeid = 1 --Annual

---Set universe of companies
IF OBJECT_ID(N'tempdb.dbo.#Companies') IS NOT NULL
DROP TABLE #Companies
SELECT a.* INTO #Companies
FROM ( SELECT com.companyId FROM ciqCompany com WHERE com.companyTypeId=4 and com.companystatustypeid=1
		) a

---Order all annual filings for each company, given the obsdate

IF OBJECT_ID(N'tempdb.dbo.#LastFY') IS NOT NULL
DROP TABLE #LastFY
SELECT b.* INTO #LastFY
FROM ( SELECT ROW_NUMBER () OVER (PARTITION BY per.companyid ORDER BY per.fiscalyear desc, ins.filingdate desc) as 'rownum'
		,ins.financialInstanceId
		FROM ciqFinPeriod per 
			join ciqFinInstance ins on ins.financialperiodid=per.financialperiodid
		WHERE per.companyid in (SELECT companyId FROM #Companies)
			and per.periodtypeid = @periodtypeid
			and ins.filingdate < @obsdate
		 ) b

--Select Data
SELECT @obsDate as ObservationDate
		,c.companyName
		,c.companyId
		,fi.filingDate
		,fi.formType
		,rt.restatementtypename
		,pt.periodTypeName
		,fp.calendarQuarter
		,fp.calendarYear
		,fd.dataItemId
		,di.dataItemName
		,fd.dataItemValue

FROM ciqCompany c 
		join ciqFinPeriod fp on fp.companyId = c.companyId
		join ciqPeriodType pt on pt.periodTypeId = fp.periodTypeId
		join ciqFinInstance fi on fi.financialPeriodId = fp.financialPeriodId
		join ciqrestatementtype rt on rt.restatementtypeid = fi.restatementtypeid
		join ciqFinInstanceToCollection ic on ic.financialInstanceId = fi.financialInstanceId
		join ciqFinCollection fc on fc.financialCollectionId = ic.financialCollectionId
		join ciqFinCollectionData fd on fd.financialCollectionId = fc.financialCollectionId
		join ciqDataItem di on di.dataItemId = fd.dataItemId
		---Select only the top instance for each company from the ordered list above
		join #LastFY fy on fy.financialInstanceId=fi.financialInstanceId and fy.rownum=1

WHERE fd.dataItemId = @dataitemid

ORDER BY c.companyname