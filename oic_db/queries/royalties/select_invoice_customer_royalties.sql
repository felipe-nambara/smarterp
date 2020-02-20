select 
		order_to_cash.origin_system,
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
from order_to_cash 

inner join invoice_customer ivc 
on order_to_cash.id = ivc.order_to_cash_id

inner join invoice_customer_comparation  
on ivc.erp_customer_id = invoice_customer_comparation.erp_customer_id 
and ivc.identification_financial_responsible = invoice_customer_comparation.identification_financial_responsible

where order_to_cash.country = 'Brazil' -- Integração em paralelo por operação do país
and order_to_cash.erp_subsidiary = 'BR030001' -- No caso de Roaylties sempre será essa filial (Franqueadora)
and order_to_cash.origin_system = 'smartsystem' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and order_to_cash.operation = 'royalties' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and order_to_cash.erp_invoice_customer_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and order_to_cash.to_generate_customer = 'yes'
and (
	ivc.erp_customer_id <> invoice_customer_comparation.erp_customer_id
	or ivc.full_name <> invoice_customer_comparation.full_name
	or ivc.type_person <> invoice_customer_comparation.type_person
	or ivc.nationality_code <> invoice_customer_comparation.nationality_code
	or ivc.state <> invoice_customer_comparation.state
	or ivc.city <> invoice_customer_comparation.city
	or ivc.adress <> invoice_customer_comparation.adress
	or ivc.adress_number <> invoice_customer_comparation.adress_number
	or ivc.adress_complement <> invoice_customer_comparation.adress_complement 
	or ivc.district <> invoice_customer_comparation.district
	or ivc.postal_code <> invoice_customer_comparation.postal_code
	or ivc.area_code <> invoice_customer_comparation.area_code
	or ivc.cellphone <> invoice_customer_comparation.cellphone
	or ivc.email <> invoice_customer_comparation.email
	or ivc.state_registration <> invoice_customer_comparation.state_registration
	or ivc.federal_registration <> invoice_customer_comparation.federal_registration
	or ivc.final_consumer <> invoice_customer_comparation.final_consumer
	or ivc.icms_contributor <> invoice_customer_comparation.icms_contributor
)
                
union

select
		order_to_cash.origin_system,
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
from order_to_cash order_to_cash

inner join invoice_customer ivc
on order_to_cash.id = ivc.order_to_cash_id

where order_to_cash.country = 'Brazil' -- Integração em paralelo por operação do país
and order_to_cash.erp_subsidiary = 'BR030001' -- No caso de Roaylties sempre será essa filial (Franqueadora)
and order_to_cash.origin_system = 'smartsystem' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and order_to_cash.operation = 'royalties' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and order_to_cash.erp_invoice_customer_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and order_to_cash.to_generate_customer = 'yes'
and ivc.erp_customer_id is null;
