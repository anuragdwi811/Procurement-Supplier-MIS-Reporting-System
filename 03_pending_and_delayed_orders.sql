/*==============================================================
 Project     : Procurement & Supplier MIS Reporting System
 File        : 03_pending_and_delayed_orders.sql
 Module      : Pending and Delayed Purchase Order Analysis
 Purpose     : Identify pending, partially received, and overdue
               purchase orders for operational follow-up
 Data Grain  : One row per purchase order item
 Source      : Procurement and master schema tables
 Output      : Pending orders, overdue orders, and follow-up details
==============================================================*/



/*==============================================================
 01: PENDING AND DELAYED PURCHASE ORDER TRACKER
==============================================================*/

SELECT po.purchase_order_id,
	   poi.purchase_order_item_id,
	   po.order_date,
	   po.expected_date,
	   po.received_date,
	   po.status,

	   s.supplier_id,
	   s.supplier_name,
	   s.city AS supplier_city,
	   s.state AS supplier_state,
	   s.region AS supplier_region,

	   w.warehouse_id,
	   w.warehouse_name,
	   w.city AS warehouse_city,
	   w.state AS warehouse_state,
	   w.region AS warehouse_region,

	   p.product_id,
	   p.product_name,
	   poi.quantity_ordered,
	   poi.quantity_received,
	   CASE
    		WHEN po.status = 'Pending' THEN poi.quantity_ordered
    		WHEN po.status = 'Partially Received' THEN poi.quantity_ordered - poi.quantity_received
	   END AS pending_quantity,

	   CASE
			WHEN po.expected_date < DATE '2026-01-01' THEN DATE '2026-01-01' - po.expected_date
			ELSE 0
	   END AS days_past_expected_date,

	   CASE
    		WHEN po.expected_date < DATE '2026-01-01' THEN 'Overdue'
    		WHEN po.expected_date = DATE '2026-01-01' THEN 'Due Today'
    		ELSE 'Not Due'
	   END AS delay_status,

	   CASE
    		WHEN po.expected_date < DATE '2026-01-01' THEN 'High'
    		WHEN po.expected_date = DATE '2026-01-01' THEN 'Medium'
    		ELSE 'Low'
	   END AS follow_up_priority

FROM procurement.purchase_orders po
JOIN procurement.purchase_order_items poi
	ON po.purchase_order_id = poi.purchase_order_id
JOIN master.suppliers s
	ON po.supplier_id = s.supplier_id
JOIN master.warehouses w
	ON po.warehouse_id = w.warehouse_id
JOIN master.products p
	ON poi.product_id = p.product_id
WHERE po.status IN ('Pending', 'Partially Received')
ORDER BY days_past_expected_date DESC,
    	 po.expected_date ASC,
    	 po.purchase_order_id,
    	 poi.purchase_order_item_id;



/*==============================================================
 END OF FILE
 Description : Operational tracker for pending and overdue
               purchase order items requiring follow-up.
==============================================================*/