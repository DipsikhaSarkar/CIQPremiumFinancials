/************************************************************************************************
Retrieve company information by a different identifier

Packages Required:
Finl Premium Core
Finl Premium Detail
Finl Premium Statement
Financials Premium Intraday Core
Base Company
Base Company Foundation Daily

Universal Identifiers:
companyId
GVKEY

Primary Columns Used:
dataItemId
financialCollectionId
financialInstanceId
financialPeriodId
periodTypeId
restatementTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample SQL query demonstrates how to use the ciqSymbol table to retrieve company 
information by a different identifier. The sample query below retrieves company 
information for Sony Corporation (GVKEY 009818).

***********************************************************************************************/

SELECT c.CompanyName, fp.companyID,fp.calendarYear, fp.calendarQuarter,fp.fiscalYear,fp.fiscalQuarter,pt.PeriodTypeName, fi.filingDate,rt.restatementTypeName, fcd.dataItemID,fcd.dataItemValue

FROM ciqCompany c
JOIN ciqSymbol sy ON sy.relatedcompanyId = c.companyId
JOIN ciqFinPeriod fp ON fp.companyId = c.companyId
JOIN ciqPeriodType pt ON pt.periodTypeID = fp.periodTypeID
JOIN ciqFinInstance fi ON fp.financialPeriodID = fi.financialperiodID
JOIN ciqRestatementType rt ON rt.restatementTypeID = fi.restatementTypeID
JOIN ciqFinInstanceToCollection fitc ON fi.financialInstanceID = fitc.financialInstanceID
JOIN ciqFinCollection fc ON fc.financialCollectionID = fitc.financialCollectionID
JOIN ciqFinCollectionData fcd ON fc.financialCollectionID = fcd.financialCollectionID 

WHERE pt.PeriodTypeName LIKE 'Annual'
AND fcd.dataItemID = 28 --Total Revenue
AND fi.latestForFinancialPeriodFlag = '1' --Latest instance
AND sy.symboltypeid =  '13'  --SymbolTypeID for GVKEY symbols
AND sy.symbolvalue = '6821506' --GVKEY for Sony

ORDER BY fp.fiscalYear DESC, fp.fiscalQuarter
 
 