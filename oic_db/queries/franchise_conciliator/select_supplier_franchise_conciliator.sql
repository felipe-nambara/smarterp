select distinct
		pay.erp_business_unit,
		sup.id,
		otc.origin_system,
        otc.operation,
		sup.identification_financial_responsible,
		sup.full_name,
		sup.adress,
		sup.adress_number,
		sup.adress_complement,
		sup.district,
        sup.nationality_code,
		sup.city,
		sup.state,
		sup.postal_code,
		sup.area_code,
		sup.cellphone,
        sup.state_registration,
        sup.municipal_registration,
		sup.email,
        recg.erp_payment_code,
		rftv.bank_number,
		rftv.bank_branch,
		rftv.bank_account,
        recg.erp_currency_code
from supplier sup

inner join payable pay
on pay.supplier_identification = sup.identification_financial_responsible

inner join receivable rec
on rec.id = pay.receivable_id

inner join order_to_cash otc
on otc.id = rec.order_to_cash_id

inner join customer crc
on crc.identification_financial_responsible = otc.erp_receivable_customer_identification

left join receivable_erp_configurations recg
on recg.country = otc.country
and recg.origin_system = otc.origin_system
and recg.operation = otc.operation
and recg.transaction_type = rec.transaction_type
and recg.erp_business_unit = otc.erp_business_unit
and recg.converted_smartfin = rec.converted_smartfin
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
and otc.erp_subsidiary = 'BR020001' -- Neste caso a filial deve ser fixa
and otc.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and otc.operation = 'franchise_conciliator' -- Integração em paralalo por operação (plano de alunos, plano corporativo, etc...)
and sup.erp_supplier_id is null;-- Integração em paralalo por tipo de transação (Cartão de crédito recorrente, cartão de débito recorrente, débito em conta, boleto etc...)