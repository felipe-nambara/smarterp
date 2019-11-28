/*
gross_value => valor serviço/mercadororia + juros/mora
net_value => valor serviço/mercadororia + juros/mora - taxa operadora
interest_value => juros/mora
*/

select 	
	otc.id
	,otc.erp_business_unit
	,recg.erp_source_name
	,recg.erp_type_transaction
    ,recg.erp_payments_terms
    ,recg.erp_currency_code
    ,recg.erp_currency_conversion_type
    ,rec.erp_clustered_receivable_id
    ,crc.identification_financial_responsible
    ,rftv.bank_number
    ,rftv.bank_branch
    ,rftv.bank_account
    ,rftv.quantity_of_days_to_due_date
    ,rec.net_value
    ,rec.price_list_value
    ,rec.conciliator_id
    ,rec.credit_card_brand
    ,rec.contract_number
    ,rec.transaction_type
    ,rec.truncated_credit_card
    ,rec.current_credit_card_installment
    ,rec.total_credit_card_installment
    ,rec.nsu
    ,rec.authorization_code
    ,rec.administration_tax_percentage
    ,rec.administration_tax_value
    ,rec.billing_date
    ,rec.credit_date
from receivable rec

inner join order_to_cash otc
on otc.id = rec.order_to_cash_id

inner join customer crc
on crc.identification_financial_responsible = otc.erp_receivable_customer_identification

left join receivable_erp_configurations recg
on recg.country = otc.country
and recg.origin_system = otc.origin_system
and recg.operation = otc.operation
and recg.transaction_type = rec.transaction_type
and recg.memoline_setting = 'gross_value'

left join receipt_from_to_version rftv
on rftv.origin_system = otc.origin_system
and rftv.order_to_cash_operation = otc.operation
and rftv.erp_business_unit = otc.erp_business_unit
and rftv.receivable_transaction_type = rec.transaction_type
and rftv.erp_receivable_customer_identification = crc.identification_financial_responsible
and rftv.created_at = 	(
							select
								max(rftv_v2.created_at) as created_at
							from receipt_from_to_version rftv_v2
							where rftv_v2.origin_system = rftv.origin_system
							and rftv_v2.order_to_cash_operation = rftv.order_to_cash_operation
                            and rftv_v2.erp_business_unit = rftv.erp_business_unit
							and rftv_v2.receivable_transaction_type = rftv.receivable_transaction_type
							and rftv_v2.erp_receivable_customer_identification = rftv.erp_receivable_customer_identification
						)

where otc.country = 'Brazil' -- Integração em paralalo por operação do país
and otc.erp_subsidiary = 'BR020001' -- Filtro por filial (loop automático) -- não considerar subsidiary BR020001 que representa a Smartfin - ela terá um job específico
and otc.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'person_plan' -- Integração em paralalo por operação (plano de alunos, plano corporativo, etc...)
and otc.erp_receivable_status_transaction = 'clustered_receivable_created' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and rec.erp_clustered_receivable_id is not null -- Filtrar somente os receivables que possui relacionamento com a clustered_receivable
and rec.erp_clustered_receivable_customer_id is not null -- Filtrar somente os receivables que possui relacionamento com a customer 
and rec.erp_receivable_id is not null -- Filtrar somente os receivables que já foram integrados no erp e devem ser baixados
and rec.erp_receivable_id is not null -- Filtrar somente os receivables que já foram integrados no erp e devem ser baixados
and rec.net_value > 0
and rec.transaction_type in ('debit_account_recurring','cash','boleto') -- Neste caso a integração deverá filtrar somente os receivables cujos métodos de recebimentos são débito em conta corrente, dinheiro ou boleto 