update invoice 

inner join order_to_cash
on order_to_cash.id = invoice.order_to_cash_id

set order_to_cash.erp_invoice_not_fiscal_returned_from_erp_at = current_timestamp -- colocar aqui o timestamp de retorno do processamento do erp
,order_to_cash.erp_invoice_not_fiscal_status_transaction = if(true /*colocar aqui o boolean que define se a operação foi executada com sucesso ou não*/,'created_at_erp','error_trying_to_create_at_erp')
,order_to_cash.erp_not_fiscal_invoice_log = if(false /*colocar aqui o boolean que define se a operação foi executada com sucesso ou não*/,'Aqui deve ser gravado o erro de processamento do oracle (verificar a possibilidade de tratamento do erro para melhor entendimento)',null)
,invoice.erp_not_fiscal_invoice_id = if(true /*colocar aqui o boolean que define se a operação foi executada com sucesso ou não*/,'Aqui deve ser gravado o id único e imutável que representa o cliente no oracle',null)

where order_to_cash.id = '<Colocar aqui o Id order_to_cash do registro que foi enviado para o Oracle>'
and invoice.id = '<Colocar aqui o Id invoice_customer do registro que foi enviado para o Oracle>';