select 
	 otc.country
    ,otc.origin_system
    ,otc.operation
    ,count(1)
	,avg(timestampdiff(minute,otc.erp_invoice_customer_send_to_erp_at,otc.erp_invoice_customer_returned_from_erp_at)) as avg_customer
	,avg(timestampdiff(minute,otc.erp_receivable_sent_to_erp_at,otc.erp_receivable_returned_from_erp_at)) as avg_receivable
	,avg(timestampdiff(minute,otc.erp_invoice_send_to_erp_at,otc.erp_invoice_returned_from_erp_at)) as avg_invoice
from order_to_cash otc

group by otc.country
		,otc.origin_system
		,otc.operation
