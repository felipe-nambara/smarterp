select 
	 t1.erp_business_unit
	,t1.front_id
	,t1.fin_id
    ,t1.conciliator_id
    ,t1.minifactu_id
	,t1.id
    ,t1.idx_qry
	,t1.erp_source_name
	,t1.erp_type_transaction
    ,t1.erp_payments_terms
    ,t1.erp_currency_code
    ,t1.erp_currency_conversion_type
    ,t1.erp_interface_line_context
    ,t1.erp_payment_code
    ,t1.erp_set_of_books_id
    ,t1.erp_memo_line
    ,t1.erp_attribute_category
    ,t1.warehouse_id
    ,t1.erp_clustered_receivable_id
    ,t1.identification_financial_responsible
    ,t1.full_name
    ,t1.receivable_item_value
    ,t1.administration_tax_value
    ,t1.interest_value
    ,t1.conciliator_id
    ,t1.credit_card_brand
    ,t1.contract_number
    ,t1.transaction_type
    ,t1.warehouse_id
    ,t1.truncated_credit_card
    ,t1.current_credit_card_installment
    ,t1.total_credit_card_installment
    ,t1.nsu
    ,t1.authorization_code
    ,t1.administration_tax_percentage
    ,t1.billing_date
    ,t1.credit_date
    ,t1.converted_smartfin
    ,if(month(t1.billing_date)=month(current_date()),t1.billing_date,current_date()) as erp_trx_date
    ,if(month(t1.billing_date)=month(current_date()),t1.billing_date,current_date()) as erp_gl_date    
from (
/*
gross_value => valor serviço/mercadororia + juros/mora
net_value => valor serviço/mercadororia + juros/mora - taxa operadora
interest_value => juros/mora
*/
/*Valores bruto da venda*/
select
	 otc.erp_business_unit
	,otc.front_id
	,otc.fin_id
    ,otc.minifactu_id
    ,otc.id
    ,1 as idx_qry
	,recg.erp_source_name
	,recg.erp_type_transaction
    ,recg.erp_payments_terms    
    ,recg.erp_currency_code
    ,recg.erp_currency_conversion_type
    ,recg.erp_interface_line_context
    ,recg.erp_payment_code
    ,recg.erp_set_of_books_id
    ,recg.erp_memo_line
    ,recg.erp_attribute_category
    ,recg.warehouse_id
    ,rec.erp_clustered_receivable_id
    ,crc.identification_financial_responsible
    ,crc.full_name
    ,rec.net_value as receivable_item_value
    ,rec.administration_tax_value*-1 as administration_tax_value
    ,rec.interest_value
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
    ,rec.billing_date
    ,rec.credit_date
    ,rec.converted_smartfin
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
and recg.converted_smartfin = rec.converted_smartfin
and recg.erp_business_unit = otc.erp_business_unit
and recg.memoline_setting = 'gross_value'

where otc.country = 'Brazil' -- Integração em paralalo por operação do país
and otc.erp_subsidiary = 'BR010001' -- Filtro por filial (loop automático)
and otc.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'person_plan' -- Integração em paralalo por operação (plano de alunos, plano corporativo, etc...)
and otc.erp_receivable_status_transaction = 'clustered_receivable_created' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and otc.to_generate_receivable = 'yes'
and rec.erp_clustered_receivable_id is not null -- Filtrar somente os receivables que possui relacionamento com a clustered_receivable
and rec.erp_clustered_receivable_customer_id is not null -- Filtrar somente os receivables que possui relacionamento com a customer 
and rec.erp_receivable_id is null -- Filtrar somente os receivables que ainda não foram integrados com o erp
and rec.transaction_type = 'credit_card_recurring' -- Integração em paralalo por tipo de transação (Cartão de crédito recorrente, cartão de débito recorrente, débito em conta, boleto etc...)

union

/*Valores da taxa de administração da operadora*/
select 
	 otc.erp_business_unit
	,'' as front_id
	,'' as fin_id
    ,'' as minifactu_id
    ,'' as id
    ,2 as idx_qry
	,recg.erp_source_name
	,recg.erp_type_transaction
    ,recg.erp_payments_terms
    ,recg.erp_currency_code
    ,recg.erp_currency_conversion_type
    ,recg.erp_interface_line_context
    ,recg.erp_payment_code
    ,recg.erp_set_of_books_id
    ,recg.erp_memo_line
    ,recg.erp_attribute_category
	,recg.warehouse_id
    ,rec.erp_clustered_receivable_id
    ,crc.identification_financial_responsible
    ,crc.full_name
    ,sum(rec.administration_tax_value*-1) as receivable_item_value
    ,0 as administration_tax_value
    ,0 as interest_value
    ,'' as conciliator_id
    ,rec.credit_card_brand
    ,rec.contract_number
    ,rec.transaction_type
    ,'' as truncated_credit_card
    ,0 as current_credit_card_installment
    ,0 as total_credit_card_installment
    ,'' as nsu
    ,'' as authorization_code
    ,rec.administration_tax_percentage
    ,rec.billing_date
    ,rec.credit_date
    ,rec.converted_smartfin
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
and recg.converted_smartfin = rec.converted_smartfin
and recg.erp_business_unit = otc.erp_business_unit
and recg.memoline_setting = 'administration_tax'

where otc.country = 'Brazil' -- Integração em paralalo por operação do país
and otc.erp_subsidiary = 'BR010001' -- Filtro por filial (loop automático)
and otc.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'person_plan' -- Integração em paralalo por operação (plano de alunos, plano corporativo, etc...)
and otc.erp_receivable_status_transaction = 'clustered_receivable_created' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and otc.to_generate_receivable = 'yes'
and rec.erp_clustered_receivable_id is not null -- Filtrar somente os receivables que possui relacionamento com a clustered_receivable
and rec.erp_clustered_receivable_customer_id is not null -- Filtrar somente os receivables que possui relacionamento com a customer 
and rec.erp_receivable_id is null -- Filtrar somente os receivables que ainda não foram integrados com o erp
and rec.transaction_type = 'credit_card_recurring' -- Integração em paralalo por tipo de transação (Cartão de crédito recorrente, cartão de débito recorrente, débito em conta, boleto etc...)
and rec.administration_tax_value > 0

group by otc.erp_business_unit
	,recg.erp_source_name
	,recg.erp_type_transaction
    ,recg.erp_payments_terms
    ,recg.erp_currency_code
    ,recg.erp_currency_conversion_type
    ,recg.erp_interface_line_context
    ,recg.erp_payment_code
    ,recg.erp_set_of_books_id
    ,recg.erp_memo_line
    ,recg.erp_attribute_category
	,recg.warehouse_id
    ,rec.erp_clustered_receivable_id
    ,rec.credit_card_brand
    ,rec.contract_number
    ,rec.transaction_type
    ,rec.administration_tax_percentage
    ,rec.billing_date
    ,rec.credit_date
    ,rec.converted_smartfin

union

/*Valores de juros/mora*/
select 
	 otc.erp_business_unit
	,'' as front_id
	,'' as fin_id
    ,'' as minifactu_id
    ,'' as id
    ,3 as idx_qry
	,recg.erp_source_name
	,recg.erp_type_transaction
    ,recg.erp_payments_terms
    ,recg.erp_currency_code
    ,recg.erp_currency_conversion_type
    ,recg.erp_interface_line_context
    ,recg.erp_payment_code
    ,recg.erp_set_of_books_id
    ,recg.erp_memo_line
    ,recg.erp_attribute_category
    ,recg.warehouse_id
    ,rec.erp_clustered_receivable_id
    ,crc.identification_financial_responsible
    ,crc.full_name
    ,sum(rec.interest_value) as receivable_item_value
    ,0 as administration_tax_value
    ,0 as interest_value    
    ,'' as conciliator_id
    ,rec.credit_card_brand
    ,rec.contract_number
    ,rec.transaction_type
    ,'' as truncated_credit_card
    ,0 as current_credit_card_installment
    ,0 as total_credit_card_installment
    ,'' as nsu
    ,'' as authorization_code
    ,rec.administration_tax_percentage
    ,rec.billing_date
    ,rec.credit_date
    ,rec.converted_smartfin
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
and recg.converted_smartfin = rec.converted_smartfin
and recg.erp_business_unit = otc.erp_business_unit
and recg.memoline_setting = 'interest'

where otc.country = 'Brazil' -- Integração em paralalo por operação do país
and otc.erp_subsidiary = 'BR010001' -- Filtro por filial (loop automático)
and otc.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'person_plan' -- Integração em paralalo por operação (plano de alunos, plano corporativo, etc...)
and otc.erp_receivable_status_transaction = 'clustered_receivable_created' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and otc.to_generate_receivable = 'yes'
and rec.erp_clustered_receivable_id is not null -- Filtrar somente os receivables que possui relacionamento com a clustered_receivable
and rec.erp_clustered_receivable_customer_id is not null -- Filtrar somente os receivables que possui relacionamento com a customer 
and rec.erp_receivable_id is null -- Filtrar somente os receivables que ainda não foram integrados com o erp
and rec.transaction_type = 'credit_card_recurring' -- Integração em paralalo por tipo de transação (Cartão de crédito recorrente, cartão de débito recorrente, débito em conta, boleto etc...)
and rec.interest_value > 0

group by otc.erp_business_unit
	,recg.erp_source_name
	,recg.erp_type_transaction
    ,recg.erp_payments_terms
    ,recg.erp_currency_code
    ,recg.erp_currency_conversion_type
    ,recg.erp_interface_line_context
    ,recg.erp_payment_code
    ,recg.erp_set_of_books_id
    ,recg.erp_memo_line
    ,recg.erp_attribute_category
    ,recg.warehouse_id
    ,rec.erp_clustered_receivable_id
    ,rec.credit_card_brand
    ,rec.contract_number
    ,rec.transaction_type
    ,rec.current_credit_card_installment
    ,rec.total_credit_card_installment
    ,rec.administration_tax_percentage
    ,rec.billing_date
    ,rec.credit_date
    ,rec.converted_smartfin

) as t1

-- where t1.erp_clustered_receivable_id in ( select erp_clustered_receivable_id from integration_clustered_receivable where keycontrol = ### )

order by t1.erp_business_unit
		,t1.erp_clustered_receivable_id
        ,t1.idx_qry
