/************************************************************************************************
Groups COUNT's of CompanyID's within CIQ Latest Financials with non-Null revenue for each Calendar Year broken into Bands

Packages Required:
Financials Latest Intraday Ratio
Premium Financials Detail
Finl Latest Ratio
Finl Latest Supplemental
Finl Latest Statement
Base Foundation Company
Base Exchange Rates

Primary ID's Used:

pk_ciqFinancialData


The following sample query below retrieves Groups COUNT's of CompanyID's within CIQ Latest Financials 
with non-Null revenue for each Calendar Year broken into Bands of  <10 Mil, between 10 and 50 Mil and >50 Mil
This converts Total Revenue to USD before adding to Bands

***********************************************************************************************/



SELECT  Count (DISTINCT c.companyid) AS COUNT_CIQID, 
       CASE 
         WHEN ( fd.dataitemvalue / er.priceclose ) <= 10 THEN '<10Mil' 
         WHEN ( fd.dataitemvalue / er.priceclose ) > 10 
              AND ( fd.dataitemvalue / er.priceclose ) < 50 THEN '10-50Mil' 
         ELSE '>50Mil' 
       END                          AS REVBands, 
       ifp.calendaryear 
FROM   ciqlatestinstancefinperiod ifp 
       JOIN ciqcompany c 
         ON ifp.companyid = c.companyid 
       JOIN ciqfinancialdata fd 
         ON fd.financialperiodid = ifp.financialperiodid 
       JOIN ciqexchangerate er 
         ON er.currencyid = ifp.currencyid 
            AND er.pricedate = ifp.periodenddate 
WHERE  1 = 1 
       AND fd.dataitemid = '28' --Total Revenue  
       AND ifp.periodtypeid = 1 -- Annual' 
       AND er.latestsnapflag = '1' 
	   AND fd.dataitemvalue is not null --Rev is not null
GROUP  BY CASE 
            WHEN ( fd.dataitemvalue / er.priceclose ) <= 10 THEN '<10Mil' 
            WHEN ( fd.dataitemvalue / er.priceclose ) > 10 
                 AND ( fd.dataitemvalue / er.priceclose ) < 50 THEN '10-50Mil' 
            ELSE '>50Mil' 
          END, 
          ifp.calendaryear 
ORDER  BY ifp.calendaryear DESC, REVBands 
