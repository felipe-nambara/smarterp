select 
	 otc.unity_identification
    ,otc.erp_business_unit
    ,otc.erp_legal_entity
    ,otc.erp_subsidiary
    ,otc.acronym
	,otc.erp_invoice_customer_status_transaction
    ,otc.erp_receivable_status_transaction
    ,otc.erp_invoice_status_transaction
    ,count(1)
from order_to_cash otc 

inner join receivable rec
on rec.order_to_cash_id = otc.id

where otc.id in ( select id from ctrl_regs2 )

group by otc.unity_identification
		,otc.erp_business_unit
		,otc.erp_legal_entity
		,otc.erp_subsidiary
		,otc.acronym
		,otc.erp_invoice_customer_status_transaction
		,otc.erp_receivable_status_transaction
		,otc.erp_invoice_status_transaction;

-- select oftv.* from organization_from_to_version oftv where oftv.acronym in ('RJCCOP4','DFCSUD1','SPISCS2');
-- select otc.* from order_to_cash otc where otc.unity_identification = 360 and otc.erp_receivable_status_transaction = 'error_trying_to_create_at_erp';
-- select otc.* from order_to_cash otc where otc.unity_identification = 236 and otc.erp_invoice_status_transaction = 'error_trying_to_create_at_erp';

/*
select distinct
	otc.country
    ,otc.unity_identification
    ,otc.erp_business_unit
    ,otc.erp_legal_entity
    ,otc.erp_subsidiary
    ,otc.acronym
    ,otc.origin_system
    ,otc.operation
    ,otc.minifactu_id
    ,otc.front_id
    ,rec.transaction_type
    ,rec.net_value
    ,rec.billing_date
    ,rec.credit_date
    ,inv.*
    ,iit.*
from order_to_cash otc 

inner join invoice_customer ivc
on ivc.order_to_cash_id = otc.id

inner join receivable rec
on rec.order_to_cash_id = otc.id

inner join invoice inv
on inv.order_to_cash_id = otc.id

inner join invoice_items iit
on iit.id_invoice = inv.id

where otc.minifactu_id in ( 1617118, 1617119 ) ;
-- and otc.erp_invoice_customer_status_transaction = 'created_at_erp';
-- and otc.erp_receivable_status_transaction = 'created_at_erp' ;
-- and otc.erp_invoice_status_transaction = 'created_at_erp';
*/

/*
update order_to_cash otc 
set otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process' 
where otc.acronym in ('SPISCS2','RJCCOP4','DFCSUD1') 
and otc.erp_invoice_customer_status_transaction = 'being_processed' ;

update order_to_cash otc 
set otc.erp_receivable_status_transaction = 'clustered_receivable_created' 
where otc.acronym in ('SPISCS2','RJCCOP4','DFCSUD1') 
and otc.erp_receivable_status_transaction = 'being_processed' ;

*/
/*
update order_to_cash otc 

inner join invoice_customer ivc
on ivc.order_to_cash_id = otc.id

set otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process'
,otc.erp_invoice_customer_send_to_erp_at = null
,otc.erp_invoice_customer_returned_from_erp_at = null
,otc.erp_invoice_customer_log = null
,ivc.erp_customer_id = null
,ivc.erp_filename = null
,ivc.erp_line_in_file = null
,otc.erp_receivable_status_transaction = 'clustered_receivable_created'
,otc.erp_receivable_sent_to_erp_at = null
,otc.erp_receivable_returned_from_erp_at = null
,otc.erp_receivable_log = null
,otc.erp_invoice_status_transaction = 'waiting_to_be_process'
,otc.erp_invoice_send_to_erp_at = null
,otc.erp_invoice_returned_from_erp_at = null
,otc.erp_invoice_log = null
where otc.unity_identification = 360
and otc.id in ( select id from ctrl_regs2 );
*/

-- select otc.*, ivc.* from order_to_cash otc inner join invoice_customer ivc on ivc.order_to_cash_id = otc.id where otc.id in ( select id from ctrl_regs2 ) and otc.unity_identification =  236 and otc.erp_invoice_customer_status_transaction = 'error_trying_to_create_at_erp';