/*==============================================================
 Project     : Procurement & Supplier MIS Reporting System
 File        : 05_monthly_procurement_summary.sql
 Module      : Monthly Procurement MIS
 Purpose     : Summarize monthly procurement spend, order volume,
               fulfillment, quality, and delivery performance
 Data Grain  : One row per calendar month
 Source      : Procurement and master schema tables
 Output      : Monthly procurement KPIs and operational summary
==============================================================*/



/*==============================================================
 01: MONTHLY PROCUREMENT PERFORMANCE SUMMARY
==============================================================*/
   
WITH order_matrix AS (
		SELECT po.purchase_order_id,
			   po.order_date,
			   DATE_TRUNC('month', po.order_date) AS report_month,
	   		   EXTRACT(YEAR FROM po.order_date) AS report_year,
	     	   DATE_PART('month', po.order_date) AS month_number,
	   		   TO_CHAR(po.order_date, 'Mon') AS month_name,
			   po.expected_date,
			   po.received_date,
			   po.status,
			   po.total_amount,
			   SUM(poi.quantity_ordered) AS total_quantity_ordered,
			   SUM(poi.quantity_received) AS total_quantity_received,
			   SUM(poi.defect_quantity) AS total_defect_quantity
		FROM procurement.purchase_orders po
		LEFT JOIN procurement. purchase_order_items poi
			ON po.purchase_order_id = poi.purchase_order_id
		GROUP BY po.purchase_order_id)

SELECT report_month::DATE,
	   report_year,
	   month_number,
	   month_name,

	   COUNT(purchase_order_id) AS total_po_count,
	   COUNT(CASE WHEN status = 'Received' THEN 1 END) AS received_po_count,
	   COUNT(CASE WHEN status = 'Pending' THEN 1 END) AS pending_po_count,
	   COUNT(CASE WHEN status = 'Partially Received' THEN 1 END) AS partially_received_po_count,
	   COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) AS cancelled_po_count,
	   SUM(total_amount) AS total_purchase_spend,

	   SUM(total_quantity_ordered) AS total_quantity_ordered,
	   SUM(total_quantity_received) AS total_quantity_received,
	   SUM(total_defect_quantity) AS total_defect_quantity,
	   
	   ROUND(SUM(total_quantity_received)::NUMERIC / SUM(total_quantity_ordered) * 100
	   		, 2) AS fill_rate_pct,
			   
	   ROUND(SUM(total_defect_quantity)::NUMERIC / SUM(total_quantity_received) * 100
	   		, 2) AS defect_rate_pct,

	   ROUND(AVG(CASE WHEN status = 'Received' THEN received_date - order_date END)
	   		, 2) AS avg_actual_lead_time_days,	  
			   
	   COUNT(CASE WHEN status IN ('Pending', 'Partially Received') AND expected_date < DATE '2026-01-01'
        		  THEN 1 END) AS delayed_po_count,
				  
	   COUNT(CASE WHEN status = 'Received' AND expected_date >= received_date THEN 1 END) AS on_time_po_count,
	   
	   ROUND(COUNT(CASE WHEN status = 'Received' AND expected_date >= received_date THEN 1 END)::NUMERIC /
	   		 COUNT(CASE WHEN status = 'Received' THEN 1 END) * 100
			   , 2) AS on_time_delivery_rate_pct,	 
			   
	   ROUND(AVG(CASE WHEN status IN ('Pending', 'Partially Received') AND expected_date < DATE '2026-01-01'
            	THEN DATE '2026-01-01' - expected_date END), 2) AS avg_delay_days

FROM order_matrix
GROUP BY report_month,
	   	 report_year,
	   	 month_number,
	   	 month_name
ORDER BY report_month;



/*==============================================================
 END OF FILE
 Description : Monthly procurement spend, fulfillment, quality,
               and delivery performance summary.
==============================================================*/
