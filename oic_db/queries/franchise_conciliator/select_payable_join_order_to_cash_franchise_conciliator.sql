select 
	 pay.erp_business_unit
    ,pay.erp_legal_entity
    ,pay.erp_subsidiary
    ,pecg.erp_source_name
    ,pecg.erp_currency_code
    ,pecg.erp_payment_code
    ,pecg.erp_invoice_type
    ,pecg.erp_payments_terms
    ,sup.identification_financial_responsible    
    ,sup.full_name
    ,sup.erp_supplier_id
    ,rec.erp_receivable_id
    ,pay.gross_value
    ,if(month(pay.issue_date)=month(current_date()),pay.issue_date,current_date()) as erp_trx_date
    ,if(month(pay.issue_date)=month(current_date()),pay.issue_date,current_date()) as erp_gl_date     
from payable pay

inner join supplier sup
on sup.identification_financial_responsible = pay.supplier_identification

inner join receivable rec
on rec.id = pay.receivable_id

inner join order_to_cash otc
on otc.id = rec.order_to_cash_id

left join payable_erp_configurations pecg
on pecg.country = otc.country
and pecg.origin_system = otc.origin_system
and pecg.operation = otc.operation
and pecg.transaction_type = rec.transaction_type
and pecg.converted_smartfin = rec.converted_smartfin

where otc.country = 'Brazil' -- Integração em paralalo por operação do país
and otc.erp_subsidiary = 'BR020001' -- Neste caso fixar esse valor para a integração de conciliador de franquias
and otc.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'franchise_conciliator' -- Neste caso fixar esse valor para a integração de conciliador de franquias
and rec.transaction_type = 'boleto' -- Integração em paralalo por tipo de transação (Cartão de crédito recorrente, cartão de débito recorrente, débito em conta, boleto etc...)
and rec.erp_receivable_id is not null
and rec.erp_receipt_id is not null
and pay.erp_supplier_id is not null
and pay.erp_payable_status_transaction = 'waiting_to_be_process' -- Filtrar somente os registros que ainda não foram integrados com o erp e estão aguardando processamento
and pay.erp_payable_id is null; -- Filtrar somente os receivables que ainda não foram integrados com o erp
