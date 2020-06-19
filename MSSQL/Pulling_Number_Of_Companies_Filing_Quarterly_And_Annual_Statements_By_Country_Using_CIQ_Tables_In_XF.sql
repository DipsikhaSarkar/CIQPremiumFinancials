/************************************************************************************************
Finding Number Of companies filing Annual or Quarterly Statements.

Packages Required:
Finl Premium Core
Base Company
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary Columns Used:
financialInstanceId
financialPeriodId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query compares the number of companies with annual filings to the number of companies 
with quarterly filings for a specific year by country using the SP Capital IQ files in Xpressfeed.
NOTE:Comparing the results between country in the two lists shows you an approximation of 
countries that have a high percentage of companies that file quarterly reports.

***********************************************************************************************/

SELECT COUNT ( DISTINCT fp.companyID ) AS QuarterlyFilers, 
cg.isoCountry3, 
cg.country

FROM ciqCompany c 

JOIN ciqFinPeriod fp ON fp.companyID = c.companyID
JOIN ciqFinINstance fi ON fi.financialPeriodID = fp.financialPeriodID
JOIN ciqCountryGeo cg ON cg.countryID = c.countryId

WHERE YEAR(fi.filingDate) = 2016 --update for the most current FULL year

AND fi.instanceTypeID IN ( 1 , 2 ) ---prelim or original instances only
AND fp.periodTypeId = 2 ---quarterly
AND NOT EXISTS

( SELECT NULL
  FROM ciqFinInstanceToCollection x
  WHERE x.financialInstanceId = fi.financialInstanceID AND x.instanceToCollectionTypeId = 14 )

GROUP BY cg.isoCountry3, cg.country---Comparing the results between country in the two lists shows you an approximation of countries that have a high percentage of companies that file quarterly reports.


SELECT COUNT ( DISTINCT fp.companyID ) AS AnnualFilers, 
cg.isoCountry3, 
cg.country

FROM ciqCompany c 

JOIN ciqFinPeriod fp ON fp.companyID = c.companyID
JOIN ciqFinINstance fi ON fi.financialPeriodID = fp.financialPeriodID
JOIN ciqCountryGeo cg ON cg.countryID = c.countryId

WHERE YEAR ( fi.filingDate ) = 2016 ---update for most current FULL year

AND fi.instanceTypeID IN ( 1 , 2 ) ---prelim or original instances only
AND fp.periodTypeId = 2 ---quarterly

GROUP BY cg.isoCountry3, cg.country
