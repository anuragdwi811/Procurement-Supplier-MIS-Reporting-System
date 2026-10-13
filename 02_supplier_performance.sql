/*==============================================================
 Project     : Procurement & Supplier MIS Reporting System
 File        : 02_supplier_performance.sql
 Module      : Supplier Performance Analysis
 Purpose     : Evaluate supplier performance using procurement
               spend, order fulfillment, quality, and delivery KPIs
 Data Grain  : One row per supplier
 Source      : Procurement and master schema tables
 Output      : Supplier scorecard, performance KPIs, and ranking
==============================================================*/



/*==============================================================
 01: SUPPLIER PERFORMANCE SCORECARD
==============================================================*/

WITH supplier_details AS (
		SELECT supplier_id,
			   supplier_name,
			   supplier_type,
			   city AS supplier_city,
			   state AS supplier_state,
			   region AS supplier_region,
			   supplier_status,
			   rating AS supplier_rating,
			   lead_time_days AS standard_lead_time_days
		FROM master.suppliers),

	order_details AS (
		SELECT po.purchase_order_id,
			   po.supplier_id,
			   po.order_date,
			   po.expected_date,
			   po.received_date,
			   po.status,
			   po.total_amount,
			   SUM(poi.quantity_ordered) AS quantity_ordered,
			   SUM(poi.quantity_received) AS quantity_received,
			   SUM(poi.defect_quantity) AS defect_quantity
		FROM procurement.purchase_orders po
		LEFT JOIN procurement.purchase_order_items poi
			ON po.purchase_order_id = poi.purchase_order_id
		GROUP BY po.purchase_order_id),

	supplier_matrix AS (
		SELECT s.supplier_id,
			   s.supplier_name,
			   s.supplier_type,
			   s.supplier_city,
			   s.supplier_state,
			   s.supplier_region,
			   s.supplier_status,
			   s.supplier_rating,
			   s.standard_lead_time_days,

			   COUNT(o.purchase_order_id) AS total_po_count,
			   COUNT(CASE WHEN o.status = 'Received' THEN 1 END) AS received_po_count,
			   COUNT(CASE WHEN o.status = 'Pending' THEN 1 END) AS pending_po_count,
			   COUNT(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS cancelled_po_count,
			   SUM(o.total_amount) AS total_purchase_spend,

			   SUM(o.quantity_ordered) AS total_quantity_ordered,
			   SUM(o.quantity_received) AS total_quantity_received,
			   SUM(o.defect_quantity) AS total_defect_quantity,
			   ROUND(AVG(CASE
            		WHEN o.status = 'Received' THEN o.received_date - o.order_date END)
						, 2) AS avg_actual_lead_time_days,						
			   COUNT(CASE
					WHEN o.status = 'Received' AND o.expected_date >= o.received_date THEN 1 END)
						AS on_time_delivery_count,
			   COUNT(CASE
					WHEN o.status = 'Received' AND o.expected_date < o.received_date THEN 1 END)
						AS late_delivery_count
		FROM supplier_details s
		LEFT JOIN order_details o
			ON s.supplier_id = o.supplier_id
		GROUP BY s.supplier_id,
			     s.supplier_name,
			     s.supplier_type,
			     s.supplier_city,
			     s.supplier_state,
			     s.supplier_region,
			     s.supplier_status,
			     s.supplier_rating,
			     s.standard_lead_time_days),

	supplier_report AS (
		SELECT supplier_id,
		 	   supplier_name,
		 	   supplier_type,
		 	   supplier_city,
		 	   supplier_state,
			   supplier_region,
			   supplier_status,
			   supplier_rating,
			   standard_lead_time_days,
		
			   total_po_count,
			   received_po_count,
			   pending_po_count,
			   cancelled_po_count,
			   total_purchase_spend,
		
			   total_quantity_ordered,
			   total_quantity_received,
			   total_defect_quantity,
			   ROUND(total_quantity_received::NUMERIC / NULLIF(total_quantity_ordered, 0) * 100
			   		, 2) AS fill_rate_pct,
			   ROUND(total_defect_quantity::NUMERIC / NULLIF(total_quantity_received, 0) * 100
			   		, 2) AS defect_rate_pct,
		
			   avg_actual_lead_time_days,
			   on_time_delivery_count,
			   late_delivery_count,
			   ROUND(on_time_delivery_count::NUMERIC / NULLIF(on_time_delivery_count + late_delivery_count, 0)
			   		* 100, 2) AS on_time_delivery_rate_pct
					   
		FROM supplier_matrix)

SELECT *,
	   RANK() 
	   		OVER(ORDER BY
				on_time_delivery_rate_pct DESC NULLS LAST,
				fill_rate_pct DESC NULLS LAST,
				defect_rate_pct ASC NULLS LAST) AS supplier_performance_rank
FROM supplier_report
ORDER BY on_time_delivery_rate_pct DESC NULLS LAST,
    	 fill_rate_pct DESC NULLS LAST,
    	 defect_rate_pct ASC NULLS LAST;



/*==============================================================
 END OF FILE
 Description : Supplier-level procurement performance scorecard.
==============================================================*/