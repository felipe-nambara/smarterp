select 
	 otc.unity_identification as unity_id
    ,otc.erp_business_unit
    ,otc.erp_subsidiary
    ,otc.acronym
    ,rec.transaction_type
	,otc.erp_invoice_customer_status_transaction
    ,otc.erp_receivable_status_transaction
    ,otc.erp_invoice_status_transaction
    ,count(1)
from order_to_cash otc 

inner join receivable rec
on rec.order_to_cash_id = otc.id

where otc.erp_subsidiary in ('BR140001','BR010236','BR010050')

group by otc.unity_identification
		,otc.erp_business_unit
		,otc.erp_subsidiary
		,otc.acronym
        ,rec.transaction_type
		,otc.erp_invoice_customer_status_transaction
		,otc.erp_receivable_status_transaction
		,otc.erp_invoice_status_transaction
        
order by 1;

-- select * from order_to_cash where id in ( select max_otc_id from ctrl_regs3 nolock ) and erp_invoice_customer_status_transaction = 'error_trying_to_create_at_erp';
-- select * from order_to_cash where id in ( select max_otc_id from ctrl_regs3 nolock ) and erp_receivable_status_transaction = 'error_trying_to_create_at_erp';
-- select * from order_to_cash where id in ( select max_otc_id from ctrl_regs3 nolock ) and erp_invoice_status_transaction = 'error_trying_to_create_at_erp';
-- select erp_clustered_receivable_id, rec.* from receivable rec where order_to_cash_id in ( select id from order_to_cash where id in ( select max_otc_id from ctrl_regs3 nolock ) and erp_receivable_status_transaction = 'clustered_receivable_created' ) and erp_clustered_receivable_id is not null ;

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

/*

-- BR140001
-- BR010236
-- BR010050

-- BR140001
-- BR010236
-- BR010050

select 
	otc.* 
from order_to_cash otc 
where otc.erp_subsidiary in ('BR140001','BR010236','BR010050')
and otc.to_generate_customer = 'no'
and otc.to_generate_receivable = 'no'
and otc.to_generate_invoice = 'no'
and otc.erp_invoice_status_transaction in ('waiting_to_be_process','error_trying_to_create_at_erp');

update order_to_cash otc

inner join invoice_customer ivc
on ivc.order_to_cash_id = otc.id

inner join receivable rec
on rec.order_to_cash_id = otc.id

inner join invoice inv
on inv.order_to_cash_id = otc.id

inner join invoice_items iit
on iit.id_invoice = inv.id

set otc.erp_invoice_customer_send_to_erp_at = null
,otc.erp_invoice_customer_returned_from_erp_at = null
,otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process'
,otc.erp_invoice_customer_log = null
,otc.erp_receivable_sent_to_erp_at = null
,otc.erp_receivable_returned_from_erp_at = null
,otc.erp_receivable_status_transaction = 'waiting_to_be_process'
,otc.erp_receivable_log = null
,otc.erp_invoice_send_to_erp_at = null
,otc.erp_invoice_returned_from_erp_at = null
,otc.erp_invoice_status_transaction = 'waiting_to_be_process'
,otc.erp_invoice_log = null
,otc.erp_receipt_send_to_erp_at = null
,otc.erp_receipt_returned_from_erp_at = null
,otc.erp_receipt_status_transaction = 'waiting_to_be_process'
,otc.erp_receipt_log = null
,ivc.erp_customer_id = null
,ivc.erp_filename = null
,ivc.erp_line_in_file = null
,rec.erp_receivable_id = null
,rec.erp_clustered_receivable_id = null
,rec.erp_filename = null
,rec.erp_line_in_file = null
,inv.erp_invoice_id = null
,inv.erp_invoice_customer_id = null
,inv.erp_filename = null
,inv.erp_line_in_file = null
,iit.erp_filename = null 
,iit.erp_line_in_file = null
,otc.minifactu_id = otc.minifactu_id + 10000000
,otc.to_generate_customer = 'yes'
,otc.to_generate_receivable = 'yes'
,otc.to_generate_invoice = 'yes'
,ivc.municipal_registration = null
,ivc.state_registration = null
,ivc.federal_registration = null
,rec.erp_receivable_customer_id = rec.erp_clustered_receivable_customer_id

where otc.erp_subsidiary in ('BR140001','BR010236','BR010050');

*/