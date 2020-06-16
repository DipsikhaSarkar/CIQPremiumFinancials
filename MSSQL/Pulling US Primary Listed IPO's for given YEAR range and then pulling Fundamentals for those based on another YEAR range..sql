/***********************************************************************
Latest Financials Coverage

Packages Required:
Finl Premium Capital Structure
Finl Premium Detail
Finl Premium Market
Finl Premium Ratio
Finl Premium Statement
Finl Premium Supplemental
Financials Premium Intraday Core

Primary ID's Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId
restatementTypeId
unitTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10, 44

Pulling US Primary Listed IPO's from Transactions for given YEAR range and then pulling Fundamentals for those based on another YEAR range.
Can set Fundamentals Range - Default is 3 Years pre-IPO and 3 Years Post-IPO. Also running a REPLACE on DataItemName to switch commas with hyphens for CSV exporting.
Built for The Capital Group to replace a CIQ screen/excel sequence

***********************************************************************/

/*** DECLARING VARIABLES FOR QUERY **/
	DECLARE @IPOYEARMIN AS INT
	DECLARE @IPOYEARMAX AS INT
	DECLARE @BACKRANGE AS INT
	DECLARE @FORWARDRANGE AS INT

/** SET IPO YEAR MINIMUM AND MAXIMUM **/
	SET @IPOYEARMIN='2005'
	SET @IPOYEARMAX='2006'

/** SET BACK RANGE OF FUNDAMENTALS WE WANT TO CONSIDER PRIOR TO IPO ANNOUNCEMENT YEAR **/
/** SETTING THIS TO "3" FOR AN IPO IN 2015 WOULD PULL ALL FUNDAMENTALS STARTING IN 2012**/
	SET @BACKRANGE = '3' 

/** SET FORWARD RANGE OF FUNDAMENTALS WE WANT TO CONSIDER AFTER THE IPO ANNOUNCEMENT YEAR **/
/** SETTING THIS TO "3" FOR AN IPO IN 2015 WOULD PULL ALL FUNDAMENTALS THROUGH 2018**/
	SET @FORWARDRANGE = '3'

	SELECT 
		 fp.companyid
		,c.companyname
		,cs.symbolValue AS 'SEDOL'
		,s.gic as 'GICS_Code'
		,st.subtypevalue AS 'GICS_Desc'
		,CONCAT(cto.announcedYear,'-',cto.announcedMonth,'-',cto.announcedDay) as IPOAnnouncementDate
		,CAST (fi.periodenddate AS DATE) AS periodEndDate
		,CAST (fi.filingdate AS DATE) AS filingDate
		,fp.fiscalyear
		,fp.fiscalquarter
		,pt.periodtypename
		,rt.restatementtypename
		,dft.formtypename
		,di.dataitemid
		,REPLACE(di.dataitemname, ',', ' -') as dataitemname
		,(fcd.dataitemvalue * er.priceclose) AS USDDataItemValue
		,fut.unittypename
	FROM ciqfinperiod fp
		
		JOIN ciqfininstance fi ON fi.financialperiodid = fp.financialperiodid 
		JOIN ciqrestatementtype rt ON rt.restatementtypeid = fi.restatementtypeid
		JOIN ciqdocumenttoformtype kd ON kd.documentid = fi.documentid
		JOIN ciqdocumentformtype dft ON dft.documentformtypeid = kd.documentformtypeid
		JOIN ciqfininstancetocollection fitc ON fitc.financialinstanceid = fi.financialinstanceid
		JOIN ciqfincollection fc ON fc.financialcollectionid = fitc.financialcollectionid
		JOIN ciqfincollectiondata fcd ON fcd.financialcollectionid = fc.financialcollectionid
		JOIN ciqdataitem di ON di.dataitemid = fcd.dataitemid
		JOIN ciqfinunittype fut ON fut.unittypeid = fcd.unittypeid
		JOIN ciqperiodtype pt ON pt.periodtypeid = fp.periodtypeid
		JOIN ciqexchangerate er ON er.currencyid = fi.currencyid
			AND er.pricedate = fi.periodenddate--Price Conversion on PeriodEndDate 
			AND er.snapid = 6 --London Close Exchange Rate 
		JOIN ciqcurrency cc ON cc.currencyid = fi.currencyid
		JOIN ciqcompany c ON c.companyid = fp.companyid
		JOIN ciqcompanyindustry ci ON ci.companyid = fp.companyid
		JOIN ciqsubtypetogics s ON s.subtypeid = ci.industryid
		JOIN ciqsubtype st ON st.subtypeid = ci.industryid
		JOIN ciqSecurity ss on ss.companyid = fp.companyid
		JOIN ciqTradingItem ti on ss.securityid = ti.securityid
			AND ti.primaryflag='1' --PrimaryTradingItem for Security
			AND ss.primaryflag='1' --PrimarySecurity
		JOIN ciqSymbol cs ON cs.objectid = ti.tradingitemid
			AND cs.activeflag='1'
			AND cs.symbolTypeId IN (22,5701) --SEDOL
		JOIN ciqTransOffering cto ON cto.companyid = fp.companyid
			AND cto.transactionIdTypeId='6' --PublicOffering
		JOIN ciqTransOfferToPrimaryFeat ctot ON ctot.transactionid = cto.transactionid
			AND ctot.transactionPrimaryFeatureID='5' --IPO
		JOIN ciqExchange e on e.exchangeid = ti.exchangeid
		
	WHERE 1 = 1
		AND fi.latestforfinancialperiodflag = '1' --Latest Data for Period Flag 
		AND fp.periodtypeid IN (1) --Annual --2 is Quarterly 
		AND di.dataitemid IN (28,34,10,380,21,15,400,353,82,4051,9,1002,1008,1007,1009,1276,1084,1171,1049,1046,1275,1100,4364,4173,2150,2006,2021,2161,2166,2093,24139,24141,24142,4193,4192,21988,23314,23313,21989)
		AND e.countryid='213' --Exchange Country For Primary Security is USA
		AND (cto.announcedYear >= @IPOYEARMIN AND cto.announcedyear <=@IPOYEARMAX)
		AND YEAR(fi.periodEndDate) >=  cto.announcedYear - @BACKRANGE
		AND YEAR(fi.periodEndDate) <=  cto.announcedYear + @FORWARDRANGE
		AND c.companyID = 24246
	
	---ORDER BY cto.announcedYear --, fi.periodenddate DESC -- fp.companyid,


