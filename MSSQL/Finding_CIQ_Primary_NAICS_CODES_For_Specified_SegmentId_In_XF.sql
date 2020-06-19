/************************************************************************************************
Finding_CIQ_Primary_NAICS_CODES_For_Specified_SegmentId_In_XF

Packages Required:
Finl Premium Segment Profiles
Base Company
Base Foundation Company Daily

Universal Identifiers:
companyId

Primary columns Used:
segmentClassificationTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query displays North American Industry Classification System (NAICS) codes for the 
designated segment id using the Capital IQ data tables in Xpressfeed.

***********************************************************************************************/

SELECT *FROM ciqSegmentClassification a


JOIN ciqsegmentclassificationtype b ON a.segmentClassificationTypeId = b.segmentClassificationTypeId
JOIN ciqSubType c ON a.subTypeId = c.subTypeId

WHERE a.companyId = 18527 ---ABB LTD.

AND a.segmentId = 904865031 --- Robotics segment
AND a.segmentClassificationTypeId = 6 ---6 = primary NAICS classification

ORDER BY c.subTypeId
