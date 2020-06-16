/***********************************************************************
Total Company Shares Outstanding on a specific date

Packages Required:
Finl Capital Structure Equity

Primary ID's Used:
componentId
securityId
tradingItemId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10, 17

Calculate company-level, aggregated shares outstanding on a particular 
historical date, incorporating both traded and non-traded shares 
outstanding and any relevant conversion factors.

***********************************************************************/  

 DECLARE @CoID INT  
 DECLARE @sharesDate DATE  

 SET @CoID = 24572  
 SET @sharesDate = '2013-01-01'    
 
 SELECT so.companyId, SUM(so.ConvertedTCSO) AS TCSO  
 FROM   (   
		 -- Traded Securities:    
		SELECT      ec.companyId     
		, ec.componentId     
		, ec.securityId     
		, ti.tradingItemId     
		, ti.tickerSymbol     
		, ec.capitalStructureDescription AS 'SecurityName'     
		, ec.TCSOFlag     
		, (CASE WHEN ec.primaryClassForTCSO = 2 THEN '1' ELSE '0' END) AS 'PrimaryFlag'    
		, '0' AS 'NonTradedFlag'     
		, ec.classConversionFactorForTCSO AS 'TSCOConvFactor'     
		, so.sharesOutstanding     
		, so.sharesOutstanding * ec.classConversionFactorForTCSO AS 'ConvertedTCSO'  
		  
		FROM ciqCapStEqComponent ec (NOLOCK)    
		JOIN ciqTradingItem ti (NOLOCK)     ON ti.securityId = ec.securityId     
		AND ti.primaryFlag = 1    
		JOIN ciqPriceEquitySharesOutstdg so (NOLOCK)     ON so.tradingItemId = ti.tradingItemId     
		AND @sharesDate BETWEEN so.fromDate AND ISNULL(so.toDate,'2076-6-6')    
		JOIN ciqSecurity sec (NOLOCK)     ON ti.securityId = sec.securityId 
		  
		WHERE 1=1    
		AND ec.TCSOFlag = 2 -- equity component should be included in total shares outstanding (as of today only, but we assume this flag usually does not change historically)    
		AND @sharesDate BETWEEN ISNULL(sec.securityStartDate,'1/1/1900') AND ISNULL(sec.securityenddate,'2076-6-6')    
		AND ec.companyId = @CoID -- Comment this out if you want full universe    
		  
		UNION       
		-- Non Traded Securities:    
		SELECT ec.companyId     
		, ec.componentId     
		, ec.securityId     
		, NULL AS tradingItemId     
		, NULL AS tickerSymbol     
		, ec.capitalStructureDescription AS 'SecurityName'     
		, ec.TCSOFlag     
		, (CASE WHEN ec.primaryClassForTCSO = 2 THEN '1' ELSE '0' END) AS 'PrimaryFlag'     
		, '1' AS 'NonTradedFlag'          
		, ec.classConversionFactorForTCSO AS 'TSCOConvFactor'     
		, ntso.sharesOutstanding     
		, ntso.sharesOutstanding * ec.classConversionFactorForTCSO AS 'ConvertedTCSO'    

		FROM ciqCapStEqComponent ec (NOLOCK)    
		JOIN ciqNonTradedSharesOutstding ntso (NOLOCK) ON ntso.componentId = ec.componentId     
		AND @sharesDate BETWEEN ntso.fromDate AND ISNULL(ntso.toDate,'2076-6-6')    
		JOIN ciqSecurity sec (NOLOCK)    ON EC.securityId = sec.securityId    

		WHERE 1=1    
		AND ec.TCSOFlag = 2 -- equity component should be included in total shares outstanding (as of today only, but we assume this flag usually does not change historically)    
		AND @sharesDate BETWEEN ISNULL(sec.securityStartDate,'1/1/1900') 
		AND ISNULL(sec.securityenddate,'2076-6-6')    
		AND ec.companyId = @CoID -- Comment this out if you want full universe  
) so  

GROUP BY so.companyId  
ORDER BY so.companyId    