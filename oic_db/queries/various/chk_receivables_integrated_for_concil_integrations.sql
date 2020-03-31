select
	 otc.erp_business_unit
	,otc.erp_subsidiary
	,rec.transaction_type
	,cus.full_name
    ,if(rec.erp_receivable_id is not null,'receivable_created','receivable_not_created')
    ,cpr.erp_receipt_status_transaction
    ,count(1)
from conciliated_payed_receivable cpr

inner join receivable rec
on rec.conciliator_id = cpr.conciliator_id
and rec.erp_clustered_receivable_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.erp_clustered_receivable_customer_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.converted_smartfin <> 'yes'

inner join customer cus
on cus.erp_customer_id = rec.erp_receivable_customer_id

inner join order_to_cash otc
on otc.country = cpr.country
and otc.id = rec.order_to_cash_id

where cpr.country = 'Brazil' -- Cada país deverá ter um processamento separado
and otc.origin_system = 'smartsystem' -- Cada origem deverá ter um processamento separado
and otc.operation = 'person_plan' -- Cada operação deverá ter um processamento separado
and rec.transaction_type = 'credit_card_recurring' -- Cada tipo de transação deverá ter um processamento separado
-- and rec.erp_receivable_id is null
and cpr.conciliation_type = 'PCV'
and otc.erp_subsidiary = 'BR010006'

group by otc.erp_business_unit
	,otc.erp_subsidiary
	,rec.transaction_type
	,cus.full_name
    ,if(rec.erp_receivable_id is not null,'receivable_created','receivable_not_created')
    ,cpr.erp_receipt_status_transaction
    
order by otc.erp_business_unit
	,otc.erp_subsidiary
	,rec.transaction_type
	,cus.full_name;
    
/*    
update conciliated_payed_receivable cpr
    
inner join receivable rec
on rec.conciliator_id = cpr.conciliator_id
and rec.erp_clustered_receivable_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.erp_clustered_receivable_customer_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.converted_smartfin <> 'yes'

inner join customer cus
on cus.erp_customer_id = rec.erp_receivable_customer_id

inner join order_to_cash otc
on otc.country = cpr.country
and otc.id = rec.order_to_cash_id

set cpr.erp_receipt_id = null
,cpr.erp_receipt_status_transaction = 'waiting_to_be_process'
,cpr.erp_receipt_sent_to_erp_at = null
,cpr.erp_receipt_returned_from_erp_at = null
,cpr.erp_receipt_log = null
,cpr.erp_filename = null
,cpr.erp_line_in_file = null

where cpr.country = 'Brazil' -- Cada país deverá ter um processamento separado
and otc.origin_system = 'smartsystem' -- Cada origem deverá ter um processamento separado
and otc.operation = 'person_plan' -- Cada operação deverá ter um processamento separado
and rec.transaction_type = 'credit_card_recurring' -- Cada tipo de transação deverá ter um processamento separado
and cpr.conciliation_type = 'PCV'
and otc.erp_subsidiary = 'BR010006';
*/