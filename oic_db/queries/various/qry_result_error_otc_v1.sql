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

where otc.id in (select id from ctrl_regs nolock)

group by otc.unity_identification
		,otc.erp_business_unit
		,otc.erp_legal_entity
		,otc.erp_subsidiary
		,otc.acronym
		,otc.erp_invoice_customer_status_transaction
		,otc.erp_receivable_status_transaction
		,otc.erp_invoice_status_transaction;

-- select otc.* from order_to_cash otc where otc.unity_identification = 130 and otc.erp_invoice_status_transaction = 'error_trying_to_create_at_erp'  ;
-- select clrec.* from clustered_receivable clrec where clrec.id = 175290;
-- select otc.* from order_to_cash otc where otc.id in (select id from ctrl_regs nolock);
-- 343402

/*
start transaction;
update order_to_cash otc set otc.erp_invoice_status_transaction = 'waiting_to_be_process' where otc.unity_identification = 130 and otc.erp_invoice_customer_status_transaction = 'created_at_erp';
commit;
*/