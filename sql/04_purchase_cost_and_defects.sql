/*==============================================================
 Project     : Procurement & Supplier MIS Reporting System
 File        : 04_purchase_cost_and_defects.sql
 Module      : Purchase Cost and Quality Analysis
 Purpose     : Analyze procurement spend, unit costs, supplier
               cost variations, and product quality issues
 Data Grain  : One row per purchase order item
 Source      : Procurement and master schema tables
 Output      : Cost analysis, defect metrics, and quality insights
==============================================================*/



/*==============================================================
 QUERY 01: PURCHASE COST AND DEFECT ANALYSIS
==============================================================*/

SELECT po.purchase_order_id,
	   poi.purchase_order_item_id,
	   po.order_date,
	   po.status AS po_status,

	   s.supplier_id,
	   s.supplier_name,
	   s.supplier_type,
	   s.region AS supplier_region,

	   w.warehouse_id,
	   w.warehouse_name,
	   w.region AS warehouse_region,

	   p.product_id,
	   p.product_name,
	   cat.category_name,
	   p.brand,
	   
	   poi.quantity_ordered,
	   poi.quantity_received,
	   poi.unit_cost,
	   p.unit_cost AS product_standard_unit_cost,
	   poi.quantity_ordered * poi.unit_cost AS purchase_ordered_value,
	   poi.quantity_received * poi.unit_cost AS purchase_received_value,
	   poi.unit_cost - p.unit_cost AS unit_cost_variance,
	   ROUND((poi.unit_cost - p.unit_cost) / p.unit_cost * 100, 2) AS unit_cost_variance_pct,

	   poi.defect_quantity,
	   ROUND(poi.defect_quantity::NUMERIC / NULLIF(poi.quantity_received, 0) * 100, 2) AS defect_rate_pct,
	   CASE
	   		WHEN poi.defect_quantity = 0 OR poi.quantity_received = 0 THEN 'Unknown'
    		WHEN poi.defect_quantity > 0 THEN 'Defective'
    		ELSE 'No Defects'
	   END AS quality_status

FROM master.categories cat
JOIN master.products p
	ON cat.category_id = p.category_id
JOIN procurement.purchase_order_items poi
	ON p.product_id = poi.product_id
JOIN procurement.purchase_orders po
	ON poi.purchase_order_id = po.purchase_order_id
JOIN master.suppliers s
	ON po.supplier_id = s.supplier_id
JOIN master.warehouses w
	ON po.warehouse_id = w.warehouse_id
;



/*==============================================================
 END OF FILE
 Description : Purchase cost, unit-cost variance, and quality
               analysis by product, supplier, and warehouse.
==============================================================*/
