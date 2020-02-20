select 
     otc.erp_business_unit
    ,otc.erp_legal_entity
    ,otc.erp_subsidiary
    ,otc.acronym
	,otc.erp_receivable_customer_identification
    ,otc.minifactu_id
    ,otc.front_id
    ,otc.erp_receivable_customer_identification
    ,rec.gross_value
    ,if(month(rec.billing_date)=month(current_date()),rec.billing_date,current_date()) as erp_trx_date
    ,if(month(rec.billing_date)=month(current_date()),rec.billing_date,current_date()) as erp_gl_date 
	,iec.warehouse_id
    ,iec.erp_interface_line_context
    ,iec.erp_set_of_books_id
    ,iec.erp_type_transaction
    ,iec.erp_payments_terms
    ,iec.erp_receipt_method
    ,iec.erp_currency_code
    ,iec.erp_source_name
    ,iec.erp_interface_line_context
    ,iec.erp_payment_code
    ,ivcr.full_name
    ,ivcr.identification_financial_responsible
    ,iit.erp_gl_segment_product
    ,iit.erp_item_ar_id
    ,iit.erp_item_ar_name
    ,iit.list_price
    ,iit.quantity
    ,iit.sale_price
from invoice

inner join invoice_items iit
on iit.id_invoice = invoice.id

inner join order_to_cash otc
on otc.id = invoice.order_to_cash_id

inner join invoice_customer ivcr
on ivcr.order_to_cash_id = otc.id

inner join receivable rec
on otc.id = rec.order_to_cash_id

left join invoice_erp_configurations iec -- Acrescentei para incluir o .erp_interface_line_context na query conforme mapeamento
on iec.country = otc.country
and iec.erp_business_unit = otc.erp_business_unit
and iec.erp_legal_entity = otc.erp_legal_entity
and iec.erp_subsidiary = otc.erp_subsidiary
and iec.origin_system = otc.origin_system
and iec.operation = otc.operation
and iec.to_generate_fiscal_document = 'yes'

where otc.country = 'Brazil' -- Integração em paralelo por operação do país
and otc.erp_subsidiary = 'BR030001' -- No caso de Roaylties sempre será essa filial (Franqueadora)
and otc.origin_system = 'smartsystem' -- Integração em paralelo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'royalties' -- Integração em paralelo por operação (plano de alunos, plano corporativo, etc...)
and otc.to_generate_invoice = 'yes'
and otc.erp_invoice_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and invoice.erp_invoice_customer_id is not null -- Filtrar somente as invoices cujos os clientes já foram integrados anteriormente
and invoice.erp_invoice_id is null -- Filtrar somente as invoices que ainda não foram integrados com o erp