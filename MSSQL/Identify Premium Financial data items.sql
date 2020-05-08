/************************************************************************************************
Identify Premium Financial data items

This query includes the following packages:
-CIQ DataItem Master

Primary ID's Used:
dataItemGroupId
dataItemId

The following sample SQL query displays data items associated with each Premium Financials Package. 
The dataItemGroupId corresponding to each package is listed in the where clause.
***********************************************************************************************/

select
di.dataItemId,
di.dataItemName,
di.dataItemDescription
from ciqDataItem di
join ciqDataItemGroupToDataItem g on g.dataItemId = di.dataItemId
where g.dataItemGroupId in (
	 1,--Premium Financials Statement Package Numeric Items
	 2, --Premium Financials Statement Package Text Items
	 5, --Detail Add-On
	 3,	--Ratio Add-On
	 6, --Market Data Add-On
	 7, --Market Data Plus Add-On
	 21,53, --Segment Data
	 8, --Capital Structure Add-On
	 35, --Supplemental Data Add-On
	 4, --Supplemental Plus Data Add-On
	 52, --Segment Financials Add-On
	 12, --Debt Capital Structure Add-On
	 10 --Equity Capital Structure Add-On
 ) 