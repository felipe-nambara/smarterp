select 
	 otc.unity_identification -- na api front unity_identification
	,otc.erp_business_unit
	,otc.erp_subsidiary
	,otc.front_id -- na api front front_id
	,otc.fin_id
    ,otc.minifactu_id
    ,otc.id
    ,cecg.erp_receivable_activity_name
    ,cecg.erp_currency_code
    ,cecg.erp_currency_conversion_type
    ,cecg.erp_payment_code
    ,cecg.erp_set_of_books_id
    ,cecg.erp_attribute_category     
    ,crc.identification_financial_responsible -- na api front identification_financial_responsible
    ,crc.full_name
    ,crc.chargeback_acquirer_label
    ,rec.identification_gym_student -- na api front customer_identification
    ,chbk.erp_clustered_chargeback_id
    ,sum(chbk.gross_value) as gross_value  -- na api front amount
    ,chbk.conciliator_id
    ,chbk.credit_card_brand -- na api front credit_card_brand
    ,chbk.contract_number
    ,chbk.transaction_type as chbk_transaction_type
    ,chbk.truncated_credit_card
    ,chbk.current_credit_card_installment
    ,chbk.total_credit_card_installment
    ,chbk.nsu
    ,chbk.authorization_code
    ,chbk.administration_tax_percentage
    ,chbk.billing_date
    ,chbk.credit_date
    ,convert(chbk.bank_account,unsigned) as bank_account
    ,concat('RD_',rtrim(chbk.bank_number),' ',right(chbk.bank_branch,4),' ',rtrim(convert(chbk.bank_account,unsigned))) as receipt_method
    ,if(month(chbk.credit_date)=month(current_date()),chbk.credit_date,current_date()) as erp_trx_date
    ,if(month(chbk.credit_date)=month(current_date()),chbk.credit_date,current_date()) as erp_gl_date    
from chargeback chbk

inner join clustered_chargeback cchbk
on cchbk.id = chbk.erp_clustered_chargeback_id

inner join receivable rec
on rec.conciliator_id = chbk.conciliator_id
and rec.erp_clustered_receivable_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.erp_clustered_receivable_customer_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.converted_smartfin <> 'yes'

inner join customer crc
on crc.erp_customer_id = rec.erp_clustered_receivable_customer_id

inner join order_to_cash otc
on otc.country = chbk.country
and otc.id = rec.order_to_cash_id

left join chargeback_erp_configurations cecg
on cecg.country = chbk.country
and cecg.erp_business_unit = otc.erp_business_unit
and cecg.origin_system = otc.origin_system
and cecg.operation = otc.operation
and cecg.transaction_type = chbk.transaction_type

where chbk.country = 'Brazil' -- Cada país deverá ter um processamento separado
and otc.origin_system = 'smartsystem' -- Cada origem deverá ter um processamento separado
and otc.operation = 'person_plan' -- Cada operação deverá ter um processamento separado
and rec.transaction_type = 'credit_card_recurring' -- Cada tipo de transação deverá ter um processamento separado
and chbk.erp_receipt_status_transaction = 'clustered_chargeback_created'
and chbk.erp_clustered_chargeback_id is not null
and chbk.erp_receipt_id is null
and chbk.conciliation_type = 'CHBK'

group by chbk.erp_clustered_chargeback_id ;