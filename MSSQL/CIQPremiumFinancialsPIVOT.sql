/***********************************************************************
CIQ Premium Financials PIVOT
  
Packages Required:
Base Foundation Company 
CIQ Premium Financials Core
CIQ Premium Financials Detail
CIQ Base Data Item Master
 
Primary ID's Used:
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

PIVOT's Premium Financials for a few specific items for a set CompanyID 
for a set Calendar Year. LatestPeriodFinancialFlag=1

***********************************************************************/ 

/**Drop Temporary Table if it already Exists**/  
IF OBJECT_ID ('tempdb..#TempCIQPremium') is NOT NULL  
BEGIN  DROP TABLE #TempCIQPremium  
END 
GO    

/**Declare Variables**/  

 DECLARE @companyid int ,@periodtypeID int ,@calendarYear int,@latestforFinancialPeriodFlag tinyint    

/**Set InstitutionID and PeriodTypeID**/ 
 
SET @companyid = '112350' ---IBM  
SET @periodtypeId = '1' ---Annual=1, Quarterly=2, YTD=3, LTM=4, Semi-Annual=10, Interim=17  
SET @calendarYear = '2014'  
SET @latestforFinancialPeriodFlag = '1' --- Only Latest = 1    

/**Put Stock Period Data and Flow Period Data into a Temp Table using a Union**/  

SELECT * INTO #TempCIQPremium 
FROM (    
/**Bring in CIQ Premium Financials Data**/  
	SELECT a.companyId   
	, b.filingDate   
	, b.latestForFinancialPeriodFlag      
	, b.formType      
	, g.dataItemName     
	, e.dataItemValue       
	, a.calendarYear          
	FROM ciqFinPeriod a ( NOLOCK )      
	JOIN ciqFinInstance b ( NOLOCK ) ON a.financialPeriodId = b.financialPeriodId      
	JOIN ciqFinInstanceToCollection c ( NOLOCK ) ON b.financialInstanceId = c.financialInstanceId      
	JOIN ciqFinCollection d ( NOLOCK ) ON c.financialCollectionId = d.financialCollectionId      
	JOIN ciqFinCollectionData e ( NOLOCK ) ON d.financialCollectionId = e.financialCollectionId      
	JOIN ciqCompany f ( NOLOCK ) ON a.companyId = f.companyId      
	JOIN ciqDataItem g ( NOLOCK ) ON e.dataItemId = g.dataItemId   
	WHERE 1=1      
	AND a.calendarYear= @calendarYear      
	AND a.periodTypeId = @periodtypeID      
	AND a.companyId = @companyid      
	AND b.latestForFinancialPeriodFlag = @latestforFinancialPeriodFlag       
) CIQPremFin    

/**Pivot Listed Data Item Names into Columns**/  
SELECT * FROM #TempCIQPremium   
PIVOT (MAX(dataitemvalue) for dataitemname in (      
	 [Sales]      
	,[Total Assets]      
	,[Total Debt]      
	,[Cost Of Goods Sold]      
	,[Shares Outstanding on Filing Date])) AS dataitemvalues ---Insert Data Item Names to Bring In        