/************************************************************************************************
Retrieve GICS classifications for segments

Packages Required:
Premium Financials Segment Profiles
Intel Key Documents
Base Foundation Company
CIQ Primary GICS

Primary ID's Used:
companyId
GIC
segmentId
subTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
25\05\2020

DatasetKey:
10

The following sample SQL query demonstrates how to provide the GICS classifications for 
each segment associated to a filing date. The sample query below retrieves company information 
for International Business Machines (companyId 112350).
Note: This query uses the GICS package (in the Symbol/Helper files) and the S and P Capital IQ 
Key Documents package

***********************************************************************************************/

SELECT DISTINCT
 seg.companyId,
 seg.segmentId,
 seg.segmentName,
 gic.GIC,
 CASE
 WHEN segc.segmentClassificationTypeId = 2 THEN 'PRIMARY'
 ELSE 'SECONDARY'
 END
 AS primOrSecond,
 segc.documentId,
 kdoc.formTypeName,
 kdoc.filingDate
 FROM ciqSegment seg
 INNER JOIN ciqSegmentClassification segc
 ON seg.segmentId = segc.segmentId
 AND seg.companyId = segc.companyId
 INNER JOIN ciqKeyDocument kdoc --Key Documents package
 ON segc.documentId = kdoc.documentId
 AND segc.companyId = kdoc.companyId
 INNER JOIN (SELECT s4.subTypeId AS id4, s5.subTypeId AS id5
				FROM (SELECT subTypeId, subTypeValue
						FROM ciqSubType
						WHERE childLevel = 4) s4
						INNER JOIN
						(SELECT subTypeId, subTypeValue, subParentId
						 FROM ciqSubType
						 WHERE childLevel = 5) s5
 ON s4.subTypeId = s5.subParentId) codes
 ON segc.subTypeId = codes.id5
 LEFT OUTER JOIN (SELECT c.subTypeId, a.subTypeValue, b.GIC
					FROM ciqSubType a
					INNER JOIN ciqSubTypeToGICS b --part of GICS package
					ON a.subTypeId = b.subTypeId
					INNER JOIN ciqSubType c
					 ON a.subTypeValue = c.subTypeValue
					 AND a.childLevel = c.childLevel
					 AND a.subTypeId <> c.subTypeId
					 WHERE a.childLevel = 4) gic
 ON codes.id4 = gic.subTypeId
 WHERE seg.segmentTypeId = 1 --Business Segment
 AND segc.segmentClassificationTypeId IN (2, 3) -- 2 = Primary and 3 = Secondary GICS Classification
 AND seg.companyId = 112350 --International Business Machines 
 
ORDER BY kdoc.filingDate
 
 