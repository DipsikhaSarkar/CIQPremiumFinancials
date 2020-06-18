/************************************************************************************************
Retrieves a specific company Business Segment Revenue as per Period End Date

Packages Required:
Finl Premium Core
Finl Premium Segment Financials
Finl Premium Segment Profiles
Base Company 
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary Columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
segmentClassificationTypeId
segmentId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample query below retrieves a specific company Business Segment Revenue as per Period End Date,
primary NAIC classification and primary SIC classification.

***********************************************************************************************/

DECLARE @companyid AS INT 
DECLARE @periodenddate AS DATETIME 
DECLARE @segmentTypeId AS TINYINT 
DECLARE @dataitemid AS INT 

SET @companyid='877646' 
SET @periodenddate= '12-31-2018' 
SET @segmenttypeid = '1' --Business  
SET @dataitemid = '3508' --BusinessSegmentRevenue  

SELECT REV.companyid, 
       REV.companyname, 
       @periodenddate AS PeriodEndDate, 
       REV.segmentid, 
       REV.segmentname, 
       REV.bussegrevenue, 
       NAIC.primarynaic, 
       SIC.primarysic 
FROM   (SELECT s.companyid, 
               s.segmentid, 
               s.segmentname, 
               c.companyname, 
               cfi.periodenddate, 
               scd.dataitemvalue AS BusSegRevenue 
					FROM   ciqsegment s 
						   JOIN ciqsegcollectstandcmpntdata scd 
							 ON scd.segmentid = s.segmentid 
								AND scd.dataitemid = @dataitemid 
						   JOIN ciqfincollection fc 
							 ON scd.financialcollectionid = fc.financialcollectionid 
						   JOIN ciqfininstancetocollection fitc 
							 ON fc.financialcollectionid = fitc.financialcollectionid 
						   JOIN ciqfininstance cfi 
							 ON fitc.financialinstanceid = cfi.financialinstanceid 
								AND cfi.latestfilingforinstanceflag = '1' 
								AND cfi.latestforfinancialperiodflag = '1' 
						   JOIN ciqfinperiod cfp 
							 ON cfi.financialperiodid = cfp.financialperiodid 
								AND cfp.periodtypeid = '1' --Annual  
						   JOIN ciqcompany c 
							 ON c.companyid = s.companyid 
						   WHERE  1 = 1 
						   AND s.segmenttypeid = @segmenttypeid 
						   AND s.companyid = @companyid 
						   AND cfi.periodenddate = @PeriodEndDate) AS REV 
						   
       LEFT JOIN (SELECT cc.companyid, 
                         s.segmentid, 
                         c.subtypevalue AS PrimaryNAIC 
							FROM   ciqsegment s 
							LEFT JOIN ciqsegmentclassification a 
                                ON a.segmentid = s.segmentid 
                                   AND a.companyid = s.companyid 
                                   AND a.segmentclassificationtypeid = '6' ---6 = primary NAIC classification  
							LEFT JOIN ciqsegmentclassificationtype b 
                                ON a.segmentclassificationtypeid = 
                                   b.segmentclassificationtypeid 
							LEFT JOIN ciqsubtype c 
                                ON a.subtypeid = c.subtypeid 
							JOIN ciqcompany cc 
								ON cc.companyid = a.companyid 
							LEFT JOIN ciqdocument d 
                                ON d.documentid = a.documentid 
							  WHERE  1 = 1 
									 AND s.companyid = @CompanyID 
									 AND s.segmenttypeid = @segmentTypeId 
									 AND d.perioddate = @PeriodEndDate) AS NAIC 
						  ON NAIC.companyid = REV.companyid AND NAIC.segmentid = REV.segmentid 
       LEFT JOIN (SELECT cc.companyid, 
                         cc.companyname, 
                         s.segmentid, 
                         c.subtypevalue AS PrimarySIC 
						FROM   ciqsegment s 
							LEFT JOIN ciqsegmentclassification a 
                                ON a.segmentid = s.segmentid 
                                   AND a.companyid = s.companyid 
                                   AND a.segmentclassificationtypeid = '4' ---4 = primary SIC classification  
							LEFT JOIN ciqsegmentclassificationtype b 
                                ON a.segmentclassificationtypeid = 
                                   b.segmentclassificationtypeid 
							LEFT JOIN ciqsubtype c 
                                ON a.subtypeid = c.subtypeid 
							JOIN ciqcompany cc 
								ON cc.companyid = a.companyid 
							LEFT JOIN ciqdocument d 
                                ON d.documentid = a.documentid 
							 WHERE  1 = 1 
									 AND s.companyid = @CompanyID 
									 AND d.perioddate = @PeriodEndDate 
									 AND s.segmenttypeid = @segmentTypeId) AS SIC 
ON REV.companyid = SIC.companyid AND REV.segmentid = SIC.segmentid
              
ORDER BY rev.bussegrevenue DESC