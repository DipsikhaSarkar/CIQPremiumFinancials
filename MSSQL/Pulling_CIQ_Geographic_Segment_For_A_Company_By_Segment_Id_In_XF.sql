/************************************************************************************************
Finding Geographic segement for a company by using segment Id.

Packages Required:
Finl Premium Segment Profiles

Universal Identifiers:
companyId

Primary Columns Used:
companyId
segmentId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns the geographic segment name for a specified Segment ID using the 
Capital IQ (CIQ) files in Xpressfeed.
NOTE: For reference Not all records from the segment table have records in the segment classification table.
This second query accommodates this. (Uncomment To run the particular query)

***********************************************************************************************/

SELECT *
FROM ciqSegmentClassification a 

JOIN ciqSegment b ON a.segmentId = b.segmentId

WHERE a.companyId = 26175 

AND a.segmentId = 900845415



/**Not all records from the segment table have records in the segment classification table. This query accommodates this:


SELECT *FROM ciqSegment a


LEFT OUTER JOIN ciqSegmentClassification b ON a.segmentId = b.segmentIdAND a.companyId = b.companyId


WHERE a.companyId = 874526 


AND a.segmentId = 911547286**/

