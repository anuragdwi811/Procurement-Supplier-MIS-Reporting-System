/*==============================================================
 Project     : Procurement & Supplier MIS Reporting System
 File        : 01_purchase_order_detail.sql
 Module      : Purchase Order Detail Analysis
 Purpose     : Prepare detailed purchase order item data for
               Excel PO Tracker and procurement MIS reporting
 Data Grain  : One row per purchase order item
 Source      : Procurement and master schema tables
 Output      : PO, supplier, warehouse, product, quantity,
               cost, delivery, and exception details
==============================================================*/



/*==============================================================
 01: PURCHASE ORDER ITEM DETAIL
==============================================================*/

SELECT 
	-- Purchase Order Details
	po.purchase_order_id,
	poi.purchase_order_item_id,
	po.status AS po_status,
	po.order_date,
	po.expected_date,
	po.received_date,

	-- Supplier Details
	s.supplier_id,
	s.supplier_name,
	s.supplier_type,
	s.city AS supplier_city,
	s.state AS supplier_state,
	s.region AS supplier_region,
	s.rating AS supplier_rating,
	s.lead_time_days AS standard_lead_time_days,

	-- Warehouse Details
	w.warehouse_id,
	w.warehouse_name,
	w.region AS warehouse_region,
	W.warehouse_type,

	-- Product and Category Details
	p.product_id,
	p.product_name,
	p.brand,
	cat.category_id,
	cat.category_name,

	-- Quantity and Cost Details
	poi.quantity_ordered,
	poi.quantity_received,
	poi.defect_quantity,
	poi.unit_cost,

	-- Pending Quantity
	CASE
		WHEN poi.quantity_received IS NULL THEN NULL
		ELSE GREATEST(poi.quantity_ordered - poi.quantity_received, 0)
	END AS pending_quantity,

	-- Item-Level Purchase Value
	poi.quantity_ordered * poi.unit_cost AS purchase_value,

	-- Actual Lead Time
	CASE
		WHEN po.received_date IS NOT NULL THEN po.received_date - po.order_date
		ELSE NULL
	END AS actual_lead_time_days,

	-- Delivery Delay Days
	CASE
		WHEN po.status = 'Cancelled' THEN NULL
		WHEN po.expected_date IS NULL THEN NULL
		WHEN po.received_date IS NOT NULL THEN GREATEST(po.received_date - po.expected_date, 0)
		WHEN po.expected_date < DATE '2026-01-01' THEN DATE '2026-01-01' - po.expected_date
		ELSE 0
	END AS delay_days,

	-- Delay Status
	CASE
		WHEN po.status = 'Cancelled' THEN 'Cancelled'
		WHEN po.status = 'Received' AND po.received_date IS NULL THEN 'Verify Received Date'
		WHEN po.expected_date IS NULL THEN 'Verify Expected Date'
		WHEN po.received_date IS NOT NULL AND po.received_date > po.expected_date THEN 'Received Late'
		WHEN po.received_date IS NOT NULL THEN 'Received On Time'
		WHEN po.expected_date < DATE '2026-01-01' THEN 'Overdue'
		ELSE 'Not Due'
	END AS delay_status,

	-- Operational Exception Status
	CASE
		WHEN po.status = 'Cancelled' THEN 'Cancelled - No Follow-up'
		WHEN po.status = 'Received' AND po.received_date IS NULL THEN 'Verify Received Date'
		WHEN po.expected_date IS NULL THEN 'Verify Expected Date'	
		WHEN poi.unit_cost IS NULL THEN 'Verify Missing Unit Cost'
		WHEN poi.quantity_received IS NULL THEN 'Verify Received Quantity'
		WHEN poi.defect_quantity IS NULL THEN 'Verify Defect Quantity'
		WHEN poi.defect_quantity > poi.quantity_received THEN 'Verify Defect Quantity'
        WHEN poi.defect_quantity > 0 AND poi.quantity_received IS NOT NULL THEN 'Review Quality Issue'
		WHEN poi.quantity_received < poi.quantity_ordered
        	AND poi.quantity_received IS NOT NULL AND po.expected_date < DATE '2026-01-01'
        THEN 'Follow Up - Overdue Shortage'
        WHEN poi.quantity_received < poi.quantity_ordered THEN 'Check Pending Quantity'
        WHEN po.received_date > po.expected_date THEN 'Review Late Delivery'
        ELSE 'No Exception'
    END AS exception_status
	
FROM procurement.purchase_orders po
JOIN master.suppliers s
	ON po.supplier_id = s.supplier_id
JOIN master.warehouses w
	ON po.warehouse_id = w.warehouse_id
JOIN procurement.purchase_order_items poi
	ON po.purchase_order_id = poi.purchase_order_id
JOIN master.products p
	ON poi.product_id = p.product_id
JOIN master.categories cat
	ON p.category_id = cat.category_id
ORDER BY po.order_date DESC,
    	 po.purchase_order_id,
    	 poi.purchase_order_item_id;



/*==============================================================
 END OF FILE
 Description : Detailed PO item dataset for Excel MIS reporting.
==============================================================*/
