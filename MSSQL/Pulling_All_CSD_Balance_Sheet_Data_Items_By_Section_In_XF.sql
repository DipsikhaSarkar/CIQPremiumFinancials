/************************************************************************************************
Pulling all CSD Balance Sheet Data Items by section.

Packages Required:
Credit	Stats Reference Daily
Base Data Item Master

Universal Identifiers:
NA

Primary Columns Used:
dataItemId
templateSectionId
templateSortOrder
templateTypeId

Database_Type:
MSSQL

Query_Version:
V1

Query_Added_Date:
03\06\2020

DatasetKey:
10

This query returns all data items from the Balance Sheet
-Adjusted template organized by section using the SP Credit Stats (CSD) data in Xpressfeed​

***********************************************************************************************/

SELECT tt.templatetypeid, 
tt.templatetypename, 
st.templatesectionid, 
st.templatesectionname, 
di.dataitemid, 
di.dataitemname, 
t.templatesortorder

FROM ciqcsdtemplatesectiontype st

JOIN ciqcsdfintemplate t ON t.templatesectionid = st.templatesectionid
JOIN ciqcsdtemplatetype tt ON tt.templatetypeid = t.templatetypeid
JOIN ciqdataitem di ON di.dataitemid = t.dataitemid

WHERE tt.templatetypeid = 5069 -- Select Stats  Ratios - Adjusted - Corporate

ORDER BY tt.templatetypeid, 
st.templatesectionid, 
t.templatesortorder