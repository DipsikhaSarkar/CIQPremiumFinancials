/************************************************************************************************
Pulling PIK Bonds Using CIQ Tables.

Packages Required:
Finl Capital Structure Debt

Universal Identifiers:
companyId

Primary columns Used:
componentId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns the Payment-In-Kind (PIK) bonds for a company using the SP Capital 
IQ tables in Xpressfeed

***********************************************************************************************/

SELECT *

FROM ciqCapStDtComponent

WHERE companyId = 31275536 -- INSERT COMPANY ID HERE


AND activeFlag = 1
AND capitalStructureSubTypeId = 4
AND capitalStructureDescription LIKE '%PIK%'