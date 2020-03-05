select
		otc.origin_system,
		ivc.identification_financial_responsible,
		ivc.full_name,
		ivc.adress,
		ivc.adress_number,
		ivc.adress_complement,
		ivc.district,
		ivc.city,
		ivc.state,
		ivc.postal_code,
		ivc.nationality_code,
		ivc.area_code,
		ivc.cellphone,
		ivc.email,
		ivc.erp_customer_id
from order_to_cash otc

inner join invoice_customer ivc
on otc.id = ivc.order_to_cash_id

inner join receivable rec
on otc.id = rec.order_to_cash_id

inner join invoice_customer_comparation ivcc 
on ivc.identification_financial_responsible = ivcc.identification_financial_responsible

where otc.country = 'Brazil' -- Integração em paralelo por operação do país
and otc.erp_subsidiary = 'BR010001' -- Filtro por filial (loop automático)
and otc.origin_system = 'smartsystem' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'person_plan' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and otc.to_generate_customer = 'yes'
and rec.transaction_type = 'credit_card_recurring' /*'credit_card_recurring', 'debit_card_recurring', 'debit_account_recurring', 'credit_card_tef', 'debit_card_tef', 'credit_card_pos', 'debit_card_pos', 'cash', 'boleto', 'bank_transfer', 'online_credit_card', 'online_debit_card'*/
and (
	   ivc.full_name <> ivcc.full_name
	or ivc.type_person <> ivcc.type_person
	or ivc.nationality_code <> ivcc.nationality_code
	or ivc.state <> ivcc.state
	or ivc.city <> ivcc.city
	or ivc.adress <> ivcc.adress
	or ivc.adress_number <> ivcc.adress_number
	or ivc.adress_complement <> ivcc.adress_complement 
	or ivc.district <> ivcc.district
	or ivc.postal_code <> ivcc.postal_code
	or ivc.area_code <> ivcc.area_code
	or ivc.cellphone <> ivcc.cellphone
	or ivc.email <> ivcc.email
	or ivc.state_registration <> ivcc.state_registration
	or ivc.federal_registration <> ivcc.federal_registration
	or ivc.final_consumer <> ivcc.final_consumer
	or ivc.icms_contributor <> ivcc.icms_contributor
)
                
union

select
		otc.origin_system,
		ivc.identification_financial_responsible,
		ivc.full_name,
		ivc.adress,
		ivc.adress_number,
		ivc.adress_complement,
		ivc.district,
		ivc.city,
		ivc.state,
		ivc.postal_code,
		ivc.nationality_code,
		ivc.area_code,
		ivc.cellphone,
		ivc.email,
		ivc.erp_customer_id
from order_to_cash otc

inner join invoice_customer ivc
on otc.id = ivc.order_to_cash_id

inner join receivable rec
on otc.id = rec.order_to_cash_id

where otc.country = 'Brazil' -- Integração em paralelo por operação do país
and otc.erp_subsidiary = 'BR010001' -- Filtro por filial (loop automático)
and otc.origin_system = 'smartsystem' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'person_plan' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and otc.to_generate_customer = 'yes'
and rec.transaction_type = 'credit_card_recurring' /*'credit_card_recurring', 'debit_card_recurring', 'debit_account_recurring', 'credit_card_tef', 'debit_card_tef', 'credit_card_pos', 'debit_card_pos', 'cash', 'boleto', 'bank_transfer', 'online_credit_card', 'online_debit_card'*/
and not exists ( select 1 from invoice_customer_comparation ivcc where ivc.identification_financial_responsible = ivcc.identification_financial_responsible )
and ivc.erp_customer_id is null;