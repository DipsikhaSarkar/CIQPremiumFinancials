/***********************************************************************
TEV/EBITDA time series

Packages Required:
CIQ Premium Financials Core
CIQ Premium Financials Detail
Market Capitalization

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

Calculates a quarterly time series of TEV/EBITDA by joining pricing 
date to period end date

***********************************************************************/  

DECLARE @CompanyID AS INT   
DECLARE @StrtDate AS DATE   
DECLARE @EndDate AS DATE   

SET @CompanyID = '415798' --Verizon  
SET @StrtDate = '1900-01-01' --INSERT the START date here   
SET @EndDate = GETDATE () --INSERT the END date here   

---Dropping Temp Tables before each query execution  

IF OBJECT_ID ( 'tempdb..#1' ) IS NOT NULL DROP TABLE #1   
IF OBJECT_ID ( 'tempdb..#2' ) IS NOT NULL DROP TABLE #2     

---Step 1 - Retrieve financial data time series    

SELECT fi.periodEndDate    
,fp.fiscalYear     
,fp.fiscalQuarter    
,fcd.dataitemvalue  
INTO #1   
FROM ciqfinperiod fp   
JOIN ciqFinInstance fi on fp.financialPeriodId = fi.financialPeriodId   
JOIN ciqFinInstanceToCollection fitc on fi.financialInstanceId = fitc.financialInstanceId   
JOIN ciqFinCollection fc on fitc.financialCollectionId = fc.financialCollectionId   
JOIN ciqFinCollectionData fcd on fc.financialCollectionId = fcd.financialCollectionId   
WHERE fp.companyId = @CompanyID   
AND fcd.dataitemId= '4051' ---EBITDA   
AND fp.periodTypeId = '4' ---LTM   
AND fi.periodEndDate BETWEEN DATEADD ( YEAR,-1,@StrtDate ) AND @EndDate     AND fi.RestatementTypeId = 2 --Original Filings   

ORDER BY fi.periodEndDate   

--- Step 2 - Get TEV History    
SELECT mc.companyid    
,mc.pricingdate    
,mc.TEV  
INTO #2  
FROM ciqMarketCap mc  
WHERE mc.companyid = @CompanyID   
and mc.TEV is not null  
ORDER BY mc.pricingdate desc    

--- Step 3 - Join timeseries together and output    

SELECT p.pricingDate    
,p.TEV    
,i.dataItemValue 'LTM EBITDA'    
,p.TEV/i.dataitemvalue 'TEV / LTM EBITDA'    
FROM #1 i   
join #2 p ON p.pricingdate = i.periodenddate     
ORDER BY p.pricingDate DESC 