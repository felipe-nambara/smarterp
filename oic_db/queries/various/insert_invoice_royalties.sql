insert into order_to_cash
				(order_to_cash_id_smartfin,
				country,
				unity_identification,
				erp_business_unit,
				erp_legal_entity,
				erp_subsidiary,
				acronym,
				to_generate_customer,
				to_generate_receivable,
				to_generate_invoice,
				origin_system,
				operation,
				minifactu_id,
				conciliator_id,
				fin_id,
				front_id,
				erp_invoice_customer_send_to_erp_at,
				erp_invoice_customer_returned_from_erp_at,
				erp_invoice_customer_status_transaction,
				erp_invoice_customer_log,
				erp_receivable_sent_to_erp_at,
				erp_receivable_returned_from_erp_at,
				erp_receivable_customer_identification,
				erp_receivable_status_transaction,
				erp_receivable_log,
				erp_invoice_send_to_erp_at,
				erp_invoice_returned_from_erp_at,
				erp_invoice_status_transaction,
				erp_invoice_log,
				erp_receipt_send_to_erp_at,
				erp_receipt_returned_from_erp_at,
				erp_receipt_status_transaction,
				erp_receipt_log)
				values(
				null, -- order_to_cash_id_smartfin
				'Brazil', -- country
				308, -- unity_identification
				"BR03 - FRANQUEADORA", -- erp_business_unit
				null, -- erp_legal_entity
				'BR030001', -- erp_subsidiary
				null, -- acronym
				'yes', -- to_generate_customer
				'no', -- to_generate_receivable
				'yes', -- to_generate_invoice
				'smartsystem', -- origin_system
				'royalties', -- operation
				null, -- minifactu_id
				null, -- conciliator_id
				null, -- fin_id
				4448815, -- front_id
				null, -- erp_invoice_customer_send_to_erp_at
				null, -- erp_invoice_customer_returned_from_erp_at
				'waiting_to_be_process', -- erp_invoice_customer_status_transaction
				null, -- erp_invoice_customer_log
				null, -- erp_receivable_sent_to_erp_at
				null, -- erp_receivable_returned_from_erp_at
				null, -- erp_receivable_customer_identification
				'doesnt_need_to_be_process', -- erp_receivable_status_transaction
				null, -- erp_receivable_log
				null, -- erp_invoice_send_to_erp_at
				null, -- erp_invoice_returned_from_erp_at
				'waiting_to_be_process', -- erp_invoice_status_transaction
				null, -- erp_invoice_log
				null, -- erp_receipt_send_to_erp_at
				null, -- erp_receipt_returned_from_erp_at
				null, -- erp_receipt_status_transaction
				null); -- erp_receipt_log

-- saves the auto increment id from order_to_cash table
set @order_to_cash_id = last_insert_id();

-- updates the organizations fields from order_to_cash table. Note that the last version from organization_from_to_version must be always considered
update order_to_cash 

inner join organization_from_to 
on order_to_cash.unity_identification = organization_from_to.unity_identification

inner join organization_from_to_version
on organization_from_to_version.organization_from_to_unity_identification = organization_from_to.unity_identification
and organization_from_to_version.created_at = ( 
												select 
													max(organization_from_to_version_v2.created_at) as max_created_at
												from organization_from_to_version organization_from_to_version_v2
                                                where organization_from_to_version_v2.organization_from_to_unity_identification = organization_from_to_version.organization_from_to_unity_identification
												)

set order_to_cash.erp_business_unit = organization_from_to_version.erp_business_unit,
order_to_cash.erp_legal_entity = organization_from_to_version.erp_legal_entity,
order_to_cash.erp_subsidiary = organization_from_to_version.erp_subsidiary,
order_to_cash.acronym = organization_from_to_version.acronym

where order_to_cash.id = @order_to_cash_id;

-- create the invoice_customer 
insert into invoice_customer
(order_to_cash_id,
erp_customer_id,
full_name,
type_person,
identification_financial_responsible,
nationality_code,
state,
city,
adress,
adress_number,
adress_complement,
district,
postal_code,
area_code,
cellphone,
email,
state_registration,
federal_registration,
final_consumer,
icms_contributor,
erp_filename,
erp_line_in_file)
values
(@order_to_cash_id, -- order_to_cash_id
null, -- erp_customer_id
'ESCOLA DE DANÇA NASCIMENTO', -- full_name
'legal_person', -- type_person
'25012933000182', -- identification_financial_responsible
'BR', -- nationality_code
'SP', -- state
'São Paulo', -- city
'Rua Leoncio', -- adress
2195, -- adress_number
null, -- adress_complement
'AV.Paulista', -- district
'04209034', -- postal_code
'11', -- area_code
'970718989', -- cellphone
'felipe.reis@bioritmo.com.br', -- email
null, -- state_registration
null, -- federal_registration
'yes', -- final_consumer
'no', -- icms_contributor
null, -- erp_filename
null); -- erp_line_in_file

set @invoice_customer = last_insert_id(); 
 
insert into receivable
				(order_to_cash_id,
				erp_receivable_id,
				erp_receipt_id,
				erp_receivable_customer_id,
				erp_clustered_receivable_id,
				erp_clustered_receivable_customer_id,
				is_smartfin,
				converted_smartfin,
				type_smartfin,
				receivable_id_smartfin,
				ecommerce_payment_terms,
				erp_payment_terms,
				conciliator_id,
				transaction_type,
				contract_number,
				credit_card_brand,
				truncated_credit_card,
				current_credit_card_installment,
				total_credit_card_installment,
				nsu,
				authorization_code,
				price_list_value,
				gross_value,
				net_value,
				interest_value,
				administration_tax_percentage,
				administration_tax_value,
				antecipation_tax_percentage,
				antecipation_tax_value,
				billing_date,
				credit_date,
				conciliator_filename,
				acquirer_bank_filename,
				registration_gym_student,
				fullname_gym_student,
				identification_gym_student,
				erp_filename,
				erp_line_in_file)
				values
				(@order_to_cash_id, -- order_to_cash_id
				null, -- erp_receivable_id
				null, -- erp_receipt_id
				null, -- erp_receivable_customer_id
				null, -- erp_clustered_receivable_id
				null, -- erp_clustered_receivable_customer_id
				null, -- is_smartfin
				'no', -- converted_smartfin
				null, -- type_smartfin
				null, -- receivable_id_smartfin
				null, -- ecommerce_payment_terms
				null, -- erp_payment_terms
				null, -- conciliator_id
				'boleto', -- transaction_type
				null, -- contract_number
				null, -- credit_card_brand
				null, -- truncated_credit_card
				null, -- current_credit_card_installment
				null, -- total_credit_card_installment
				null, -- nsu
				null, -- authorization_code
				40000, -- price_list_value
				40000, -- gross_value
				10000, -- net_value
				0, -- interest_value
				0, -- administration_tax_percentage
				0, -- administration_tax_value
				0, -- antecipation_tax_percentage
				0, -- antecipation_tax_value
				'2019-11-28', -- billing_date
				'2019-11-28',-- credit_date
				null, -- conciliator_filename
				null, -- acquirer_bank_filename
				null, -- registration_gym_student
				null, -- fullname_gym_student
				null, -- identification_gym_student
				null, -- erp_filename
				null); -- erp_line_in_file

-- saves the auto increment id from receivable table
set @receivable_id = last_insert_id();

insert into invoice
				(order_to_cash_id,
				erp_invoice_id,
				erp_invoice_customer_id,
				transaction_type,
				is_overdue_recovery,
				fiscal_id,
				fiscal_series,
				fiscal_authentication_code,
				fiscal_model,
				fiscal_authorization_datetime,
				erp_filename,
				erp_line_in_file)
				values
				(@order_to_cash_id, -- order_to_cash_id
				null, -- erp_invoice_id
				@invoice_customer, -- erp_invoice_customer_id
				'invoice_to_other_company', -- transaction_type
				'no', -- is_overdue_recovery
				null, -- fiscal_id
				null, -- fiscal_series
				null, -- fiscal_authentication_code
				null, -- fiscal_model
				null, -- fiscal_authorization_datetime
				null, -- erp_filename
				null); -- erp_line_in_file

-- saves the auto increment id from order_to_cash table
set @invoice_id = last_insert_id();

insert into invoice_items
				(id_invoice,
				front_product_id,
				front_plan_id,
				front_addon_id,
				erp_item_ar_id,
				erp_gl_segment_product,
				quantity,
				sale_price,
				list_price,
				erp_filename,
				erp_line_in_file)
				values
				(@invoice_id, -- id_invoice
				4588715, -- front_product_id
				null, -- front_plan_id
				null, -- front_addon_id
				null, -- erp_item_ar_id
				null, -- erp_gl_segment_product
				1, -- quantity
				300000, -- sale_price
				300000, -- list_price
				null, -- erp_filename
				null); -- erp_line_in_file

-- saves the auto increment id from order_to_cash table
set @invoice_id_item = last_insert_id();

update invoice_items 

inner join invoice
on invoice.id = invoice_items.id_invoice

inner join order_to_cash
on order_to_cash.id = invoice.order_to_cash_id

inner join product_from_to 
on product_from_to.country = order_to_cash.country
and product_from_to.origin_system = order_to_cash.origin_system
and product_from_to.operation = order_to_cash.operation
and product_from_to.front_product_id = invoice_items.front_product_id

inner join product_from_to_version
on product_from_to_version.country = product_from_to.country
and product_from_to_version.product_from_to_origin_system = product_from_to.origin_system
and product_from_to_version.product_from_to_operation = product_from_to.operation
and product_from_to_version.product_from_to_front_product_id = product_from_to.front_product_id
and product_from_to_version.created_at = ( 
												select 
													max(product_from_to_version_v2.created_at) as max_created_at
												from product_from_to_version product_from_to_version_v2
                                                where product_from_to_version_v2.country =  product_from_to_version.country
                                                and product_from_to_version_v2.product_from_to_origin_system = product_from_to_version.product_from_to_origin_system
                                                and product_from_to_version_v2.product_from_to_operation = product_from_to_version.product_from_to_operation
                                                and product_from_to_version_v2.product_from_to_front_product_id = product_from_to_version.product_from_to_front_product_id
												)

set invoice_items.erp_item_ar_id = product_from_to_version.erp_item_ar_id,
invoice_items.erp_gl_segment_product = product_from_to_version.erp_gl_segment_id

where invoice_items.id = @invoice_id_item ;
