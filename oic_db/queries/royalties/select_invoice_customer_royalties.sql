select otc.id, 
       cust.id, 
       otc.origin_system, 
       otc.country, 
       cust.identification_financial_responsible, 
       cust.full_name, 
       cust.adress, 
       cust.adress_number, 
       cust.adress_complement, 
       cust.district, 
       cust.city, 
       cust.state, 
       cust.postal_code, 
       cust.nationality_code, 
       cust.area_code, 
       cust.cellphone, 
       cust.email, 
       cust.erp_customer_id 
from order_to_cash otc 

inner join invoice_customer cust 
on otc.id = cust.order_to_cash_id 

inner join invoice_customer_comparation custc 
on cust.erp_customer_id = custc.erp_customer_id 
and cust.identification_financial_responsible = custc.identification_financial_responsible 

inner join receivable rec 
on otc.id = rec.order_to_cash_id 

where  otc.country = 'Brazil' 
and otc.origin_system = 'smartsystem' 
and otc.operation = 'royalties' 
and otc.erp_subsidiary = 'BR030001' -- No caso de Roaylties sempre será essa filial (Franqueadora)
and otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process' 
and cust.erp_customer_id is not null 
and cust.id = (	
				select 
					max(cust_v2.id) 
				from   order_to_cash otc_v2 
                
                inner join invoice_customer cust_v2 
                on otc_v2.id = cust_v2.order_to_cash_id 
                
                inner join receivable rec_v2 
                on otc_v2.id = rec_v2.order_to_cash_id 
                
                where  cust_v2.identification_financial_responsible = cust.identification_financial_responsible 
				and otc_v2.country = otc.country 
                and otc_v2.origin_system = otc.origin_system 
                and otc_v2.operation = otc.operation 
                and rec_v2.transaction_type = rec.transaction_type 
                and otc_v2.erp_subsidiary = otc.erp_subsidiary 
                and otc_v2.erp_invoice_customer_status_transaction = otc.erp_invoice_customer_status_transaction 
				and otc_v2.to_generate_customer = otc.to_generate_customer 
				) 
and ( 	
		cust.full_name <> custc.full_name 
		or cust.type_person <> custc.type_person 
		or cust.nationality_code <> custc.nationality_code 
		or cust.state <> custc.state 
		or cust.city <> custc.city 
		or cust.adress <> custc.adress 
		or cust.adress_number <> custc.adress_number 
		or cust.adress_complement <> custc.adress_complement 
		or cust.district <> custc.district 
		or cust.postal_code <> custc.postal_code 
		or cust.area_code <> custc.area_code 
		or cust.cellphone <> custc.cellphone 
		or cust.email <> custc.email 
		or cust.state_registration <> custc.state_registration 
		or cust.federal_registration <> custc.federal_registration 
		or cust.final_consumer <> custc.final_consumer 
		or cust.icms_contributor <> custc.icms_contributor ) 
and otc.to_generate_customer = 'yes' 

union 

select otc.id, 
       cust.id, 
       otc.origin_system, 
       otc.country, 
       cust.identification_financial_responsible, 
       cust.full_name, 
       cust.adress, 
       cust.adress_number, 
       cust.adress_complement, 
       cust.district, 
       cust.city, 
       cust.state, 
       cust.postal_code, 
       cust.nationality_code, 
       cust.area_code, 
       cust.cellphone, 
       cust.email, 
       cust.erp_customer_id 
from order_to_cash otc 

inner join invoice_customer cust 
on otc.id = cust.order_to_cash_id 

inner join receivable rec 
on otc.id = rec.order_to_cash_id 

where otc.country = 'Brazil' 
and otc.origin_system = 'smartsystem' 
and otc.operation = 'royalties' 
and rec.transaction_type = 'credit_card_recurring' 
and otc.erp_subsidiary = 'BR030001' -- No caso de Roaylties sempre será essa filial (Franqueadora)
and otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process' 
and cust.erp_customer_id is null 
and otc.to_generate_customer = 'yes' 
and cust.id = (	
				select 
					max(cust_v2.id) 
				from order_to_cash otc_v2 
                
                inner join invoice_customer cust_v2 
                on otc_v2.id = cust_v2.order_to_cash_id 
                
                inner join receivable rec_v2 
				on otc_v2.id = rec_v2.order_to_cash_id 
                
                where  cust_v2.identification_financial_responsible = cust.identification_financial_responsible 
				and otc_v2.country = otc.country 
                and otc_v2.origin_system = otc.origin_system 
                and otc_v2.operation = otc.operation 
                and rec_v2.transaction_type = rec.transaction_type 
                and otc_v2.erp_subsidiary = otc.erp_subsidiary 
                and otc_v2.erp_invoice_customer_status_transaction = otc.erp_invoice_customer_status_transaction 
				and otc_v2.to_generate_customer = otc.to_generate_customer 
				) 
and not exists (
				select 
					1 
				from   invoice_customer_comparation ivcc 
				where  cust.identification_financial_responsible = 
				ivcc.identification_financial_responsible
				) ; 