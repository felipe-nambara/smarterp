select
		order_to_cash.origin_system,
		invoice_customer.identification_financial_responsible,
		invoice_customer.full_name,
		invoice_customer.adress,
		invoice_customer.adress_number,
		invoice_customer.adress_complement,
		invoice_customer.district,
		invoice_customer.city,
		invoice_customer.state,
		invoice_customer.postal_code,
		invoice_customer.nationality_code,
		invoice_customer.area_code,
		invoice_customer.cellphone,
		invoice_customer.email,
		invoice_customer.erp_customer_id
from order_to_cash 

inner join invoice_customer  
on order_to_cash.id = invoice_customer.order_to_cash_id

inner join invoice_customer_comparation  
on invoice_customer.erp_customer_id = invoice_customer_comparation.erp_customer_id 
and invoice_customer.identification_financial_responsible = invoice_customer_comparation.identification_financial_responsible

where order_to_cash.country = 'Brazil' -- Integração em paralelo por operação do país
and order_to_cash.erp_subsidiary = 'BR020001' -- Fixo
and order_to_cash.origin_system = 'oic' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and order_to_cash.operation = 'smartfin_fee' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and order_to_cash.erp_invoice_customer_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and order_to_cash.to_generate_customer = 'yes'
and (
	invoice_customer.erp_customer_id <> invoice_customer_comparation.erp_customer_id
	or invoice_customer.full_name <> invoice_customer_comparation.full_name
	or invoice_customer.type_person <> invoice_customer_comparation.type_person
	or invoice_customer.nationality_code <> invoice_customer_comparation.nationality_code
	or invoice_customer.state <> invoice_customer_comparation.state
	or invoice_customer.city <> invoice_customer_comparation.city
	or invoice_customer.adress <> invoice_customer_comparation.adress
	or invoice_customer.adress_number <> invoice_customer_comparation.adress_number
	or invoice_customer.adress_complement <> invoice_customer_comparation.adress_complement 
	or invoice_customer.district <> invoice_customer_comparation.district
	or invoice_customer.postal_code <> invoice_customer_comparation.postal_code
	or invoice_customer.area_code <> invoice_customer_comparation.area_code
	or invoice_customer.cellphone <> invoice_customer_comparation.cellphone
	or invoice_customer.email <> invoice_customer_comparation.email
	or invoice_customer.state_registration <> invoice_customer_comparation.state_registration
	or invoice_customer.federal_registration <> invoice_customer_comparation.federal_registration
	or invoice_customer.final_consumer <> invoice_customer_comparation.final_consumer
	or invoice_customer.icms_contributor <> invoice_customer_comparation.icms_contributor
)
                
union

select
		order_to_cash.origin_system,
		invoice_customer.identification_financial_responsible,
		invoice_customer.full_name,
		invoice_customer.adress,
		invoice_customer.adress_number,
		invoice_customer.adress_complement,
		invoice_customer.district,
		invoice_customer.city,
		invoice_customer.state,
		invoice_customer.postal_code,
		invoice_customer.nationality_code,
		invoice_customer.area_code,
		invoice_customer.cellphone,
		invoice_customer.email,
		invoice_customer.erp_customer_id
from order_to_cash order_to_cash

inner join invoice_customer 
on order_to_cash.id = invoice_customer.order_to_cash_id

where order_to_cash.country = 'Brazil' -- Integração em paralelo por operação do país
and order_to_cash.erp_subsidiary = 'BR020001' -- Filtro por filial (loop automático)
and order_to_cash.origin_system = 'oic' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and order_to_cash.operation = 'smartfin_fee' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and order_to_cash.erp_invoice_customer_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and order_to_cash.to_generate_customer = 'yes'
and invoice_customer.erp_customer_id is null;