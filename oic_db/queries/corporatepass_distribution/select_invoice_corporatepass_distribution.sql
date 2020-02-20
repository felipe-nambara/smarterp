select 
     otc.erp_business_unit
    ,iec.erp_source_name
    ,iec.erp_type_transaction
    ,iec.erp_payments_terms
    ,iec.erp_currency_code
    ,iec.erp_currency_conversion_type
    ,iec.erp_interface_line_context
    ,iec.erp_payment_code
    ,iec.erp_set_of_books_id    
    ,iec.erp_product_category_fiscal
    ,iec.erp_attribute_category
    ,iec.warehouse_id
    ,iec.erp_receipt_method
    ,otc.id as id_otc-- id da order_to_cash
    ,rec.erp_clustered_receivable_id -- id do aglutinado
    ,otc.front_id -- id do front
    ,otc.fin_id -- id do fin
    ,otc.conciliator_id -- id do conciliator_id
    ,otc.minifactu_id -- id do minifactu
    ,crc.identification_financial_responsible -- cpf/cnpj do responsável financeiro
    ,crc.full_name -- nome do responsável financeiro
    ,rec.nsu -- nsu
    ,rec.authorization_code -- código de autorização
    ,rec.credit_card_brand
	,rec.contract_number
	,otc.erp_subsidiary
    ,iit.id  as id_otc_item -- id do item da invoice
    ,iit.erp_item_ar_id -- código do item do ar no Oracle 
    ,iit.erp_item_ar_name -- nome do item do ar no Oracle 
    ,iit.erp_gl_segment_product -- código do segmento contábil de produto
    ,iit.quantity -- Quantidade do item de venda
    ,iit.sale_price -- Preço praticado
    ,iit.list_price -- Preço de lista
    ,if(month(rec.billing_date)=month(current_date()),rec.billing_date,current_date()) as erp_trx_date
    ,if(month(rec.billing_date)=month(current_date()),rec.billing_date,current_date()) as erp_gl_date    
from invoice inv

inner join invoice_items iit
on iit.id_invoice = inv.id

inner join order_to_cash otc
on otc.id = inv.order_to_cash_id

inner join receivable rec
on rec.order_to_cash_id = otc.id

inner join customer crc
on crc.identification_financial_responsible = otc.erp_receivable_customer_identification

left join invoice_erp_configurations iec
on iec.country = otc.country
and iec.erp_business_unit = otc.erp_business_unit
and iec.erp_legal_entity = otc.erp_legal_entity
and iec.erp_subsidiary = otc.erp_subsidiary
and iec.origin_system = otc.origin_system
and iec.operation = otc.operation
and iec.to_generate_fiscal_document = 'yes'

inner join organization_from_to_version oftv
on oftv.erp_business_unit = otc.erp_business_unit
and oftv.erp_legal_entity = otc.erp_legal_entity
and oftv.erp_subsidiary = otc.erp_subsidiary
and oftv.created_at = 	(
							select
								max(oftv_v2.created_at) as created_at
							from organization_from_to_version oftv_v2
                            where oftv_v2.erp_business_unit = oftv.erp_business_unit
                            and oftv_v2.erp_legal_entity = oftv.erp_legal_entity
                            and oftv_v2.erp_subsidiary = oftv.erp_subsidiary
						)

where otc.country = 'Brazil' -- Integração em paralelo por operação do país
and otc.erp_subsidiary = 'BR010305' -- Filtro por filial (loop automático)
and otc.origin_system = 'corporatepass' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'distribution' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and otc.to_generate_invoice = 'yes'
and otc.erp_invoice_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and inv.erp_invoice_id is null -- Filtrar somente as invoices que ainda não foram integrados com o erp
and rec.transaction_type = 'bank_transfer' -- Neste caso a integração de corporatepass repasse deve considerar somente boleto
and day(current_date()) <= oftv.cutoff_limit_day--  -- Regra de cutoff