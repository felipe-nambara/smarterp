DROP PROCEDURE IF EXISTS sp_create_fee_smartfin;
DELIMITER //
CREATE PROCEDURE sp_create_fee_smartfin ( IN p_country varchar(45), IN p_issue_date_initial date,  IN p_issue_date_final date)

BEGIN

declare v_country varchar(45) ;
declare v_origin_system varchar(45) ;
declare v_unity_identification varchar(45) ;
declare v_erp_business_unit varchar(45);
declare v_erp_legal_entity varchar(45);
declare v_erp_subsidiary varchar(45);
declare v_acronym varchar(45);
declare v_operation varchar(45);
declare v_erp_customer_id varchar(45);
declare v_to_generate_customer varchar(45);
declare v_to_generate_receivable varchar(45);
declare v_to_generate_invoice varchar(45);
declare v_fullname varchar(255);
declare v_supplier_identification varchar(45);
declare v_transaction_type varchar(45);
declare v_credit_card_brand varchar(45);
declare v_contract_number varchar(45);
declare v_customer_full_name varchar(255);
declare v_customer_type_person varchar(45);
declare v_customer_identification_financial_responsible varchar(255);
declare v_customer_nationality_code varchar(45);
declare v_customer_state varchar(45);
declare v_customer_city varchar(45);
declare v_customer_adress varchar(255);
declare v_customer_adress_number integer;
declare v_customer_adress_complement varchar(255);
declare v_customer_district varchar(255);
declare v_customer_postal_code varchar(45);
declare v_customer_area_code varchar(45);
declare v_customer_cellphone varchar(45);
declare v_customer_email varchar(255);
declare v_customer_municipal_registration varchar(45);
declare v_customer_state_registration varchar(45);
declare v_customer_final_consumer varchar(45);
declare v_customer_icms_contributor varchar(45);
declare v_administration_tax_percentage float;
declare v_antecipation_tax_percentage float;
declare v_billing_date date;
declare v_credit_date date;
declare v_is_smarftin varchar(45);
declare v_price_list_value float;
declare v_gross_value float;
declare v_net_value float;
declare v_interest_value float;
declare v_administration_tax_value float;
declare v_antecipation_tax_value float;
declare v_percentage float;
declare done int;
declare v_message_text varchar(255);
declare v_keycontrol varchar(150);
declare v_created_at timestamp;
declare cur1 cursor for select 
							distinct
                            otc.country
							,sup.full_name
							,sup.type_person
							,sup.identification_financial_responsible
							,sup.nationality_code
							,sup.state
							,sup.city
							,sup.adress
							,sup.adress_number
							,sup.adress_complement
							,sup.district
							,sup.postal_code
							,sup.area_code
							,sup.cellphone
							,sup.email
							,sup.state_registration
							,sup.municipal_registration
							,sup.final_consumer
							,sup.icms_contributor
						from payable pay 
                        
                        inner join supplier sup
                        on sup.identification_financial_responsible = pay.supplier_identification

						inner join receivable rec
						on rec.id = pay.receivable_id

						inner join order_to_cash otc
						on otc.id = rec.order_to_cash_id

						where otc.country = p_country
                        and pay.oic_smartfin_status_transaction = 'waiting_to_be_process'
                        and pay.issue_date between p_issue_date_initial and p_issue_date_final
						and rec.type_smartfin is not null
                        and not exists ( select 1 from order_to_cash otc where otc.id = pay.fee_smartfin_otc_id)

						order by pay.supplier_identification ;

declare continue handler for not found set done=1;
declare exit handler for sqlexception 
begin
    get diagnostics condition 1  @v_message_text = message_text;
    select @v_message_text;
    rollback; 
end;

select concat("before: ",current_timestamp());

set @v_keycontrol 	:= concat_ws('_','fee_smartfin',rtrim(p_country));
set @v_created_at	:= current_timestamp;


if get_lock(@v_keycontrol,1) = 1 then 
	
	if ( select not exists(
							select 
								1 
							from information_schema.tables 
							where table_schema = database()
							and table_name = 'control_fee_smartfin'
							)
		) then		
        
        CREATE TABLE control_fee_smartfin (  id int(11) NOT NULL AUTO_INCREMENT, keycontrol varchar(150) DEFAULT NULL,  created_at timestamp NULL DEFAULT NULL, PRIMARY KEY (id), KEY ccr_idx (keycontrol,created_at)) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    
    end if;
    
    set done = 0;
    open cur1;
	
    -- select concat("before 1: ",current_timestamp());
    
	select 
		 oftv.organization_from_to_unity_identification 
		,oftv.erp_business_unit 
		,oftv.erp_legal_entity
		,oftv.erp_subsidiary
		,oftv.acronym
		,crc.erp_customer_id
		,crc.erp_customer_id
		,crc.identification_financial_responsible
        ,oftv.to_generate_customer
        ,oftv.to_generate_receivable
        ,oftv.to_generate_invoice
		
		into @v_unity_identification
		,@v_erp_business_unit 
		,@v_erp_legal_entity 
		,@v_erp_subsidiary 
		,@v_acronym 
		,@v_erp_customer_id 
		,@v_erp_clustered_receivable_customer_id 
		,@v_erp_receivable_customer_identification 
		,@v_to_generate_customer 
		,@v_to_generate_receivable 
		,@v_to_generate_invoice 
		
	from customer crc
	
	inner join organization_from_to_version oftv
	on oftv.fiscal_federal_identification = crc.identification_financial_responsible 
	and oftv.id = ( select 
								max(oftv2.id) 
							from organization_from_to_version oftv2 
							where oftv2.erp_business_unit = oftv.erp_business_unit 
							and oftv2.erp_legal_entity = oftv.erp_legal_entity 
							and oftv2.erp_subsidiary = oftv.erp_subsidiary                            
							)
	where crc.is_smartfin = 'yes'  ;
	
    -- select concat("after 1: ",current_timestamp());
    
    FeeSmartFinLoop: loop
		fetch cur1 into  v_country
						,v_customer_full_name
						,v_customer_type_person
						,v_customer_identification_financial_responsible
						,v_customer_nationality_code
						,v_customer_state
						,v_customer_city
						,v_customer_adress
						,v_customer_adress_number
						,v_customer_adress_complement
						,v_customer_district
						,v_customer_postal_code
						,v_customer_area_code
						,v_customer_cellphone
						,v_customer_email
						,v_customer_municipal_registration
						,v_customer_state_registration
						,v_customer_final_consumer
						,v_customer_icms_contributor;
							
		if done = 1 then leave FeeSmartFinLoop; end if;			
            
        start transaction;
		
        -- select concat("before 2: ",current_timestamp());
        
        insert into control_fee_smartfin 
								select 
									pay.id as id
									,@v_keycontrol as keycontrol
                                    ,@v_created_at as created_at
								from payable pay 

								inner join receivable rec
								on rec.id = pay.receivable_id

								inner join order_to_cash otc
								on otc.id = rec.order_to_cash_id

								where otc.country = p_country
								and pay.oic_smartfin_status_transaction = 'waiting_to_be_process'
								and rec.type_smartfin is not null
                                and pay.issue_date between p_issue_date_initial and p_issue_date_final
                                and pay.supplier_identification = v_customer_identification_financial_responsible
                                and not exists ( select 1 from order_to_cash otc where otc.id = pay.fee_smartfin_otc_id)

								order by pay.id;                                														        
        
        -- select concat("after 2: ",current_timestamp());
        
		if exists ( select id from control_fee_smartfin where keycontrol = @v_keycontrol and created_at = @v_created_at order by id limit 1)  then 
			
            -- select concat("before 3: ",current_timestamp());
            
			update payable pay					
			set pay.oic_smartfin_status_transaction = 'fee_smartfin_being_processed'			
			where pay.id in ( select id from control_fee_smartfin where keycontrol = @v_keycontrol and created_at = @v_created_at);
					
			-- select concat("after 3: ",current_timestamp());
            
            -- select concat("before 4: ",current_timestamp());
            
            
            select 
				percentage
				into v_percentage
            from fee_smartfin_percentage fsp
            where fsp.id = ( select max(fsp_v2.id) from fee_smartfin_percentage fsp_v2);
            
			select 	
				 round(sum(pay.gross_value),2)*v_percentage as gross_value
				,round(sum(pay.net_value),2)*v_percentage as net_value
				
				into @v_gross_value
					,@v_net_value
				
			from payable pay
			
			where pay.id in ( select id from control_fee_smartfin where keycontrol = @v_keycontrol and created_at = @v_created_at)
			and pay.oic_smartfin_status_transaction = 'fee_smartfin_being_processed' ;			
            
            -- select concat("after 4: ",current_timestamp());
			
            -- select concat("before 5: ",current_timestamp());
            
			insert into order_to_cash
							(country,
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
							values
							(v_country, -- country
							@v_unity_identification, -- unity_identification
							@v_erp_business_unit, -- erp_business_unit
							@v_erp_legal_entity, -- erp_legal_entity
							@v_erp_subsidiary, -- erp_subsidiary
							@v_acronym, -- acronym
							@v_to_generate_customer, -- to_generate_customer
							@v_to_generate_receivable, -- to_generate_receivable
							@v_to_generate_invoice, -- to_generate_invoice
							'oic', -- origin_system
							'smartfin_fee', -- operation
							null, -- minifactu_id
							null, -- conciliator_id
							null, -- fin_id
							ifnull((select max(ifnull(front_id,0)) + 1 from order_to_cash otc where otc.origin_system = 'oic' and otc.operation = 'smartfin_fee'),1), -- front_id
							null, -- erp_invoice_customer_send_to_erp_at
							null, -- erp_invoice_customer_returned_from_erp_at
							'waiting_to_be_process', -- erp_invoice_customer_status_transaction
							null, -- erp_invoice_customer_log
							null, -- erp_receivable_sent_to_erp_at
							null, -- erp_receivable_returned_from_erp_at
							null, -- erp_receivable_customer_identification
							'waiting_to_be_process', -- erp_receivable_status_transaction
							null, -- erp_receivable_log
							null, -- erp_invoice_send_to_erp_at
							null, -- erp_invoice_returned_from_erp_at
							'waiting_to_be_process', -- erp_invoice_status_transaction
							null, -- erp_invoice_log
							null, -- erp_receipt_send_to_erp_at
							null, -- erp_receipt_returned_from_erp_at
							'waiting_to_be_process', -- erp_receipt_status_transaction
							null); -- erp_receipt_log     
					
			-- saves the auto increment id from order_to_cash table
			set @v_order_to_cash_id = last_insert_id(); 			

			insert into invoice_customer
							(order_to_cash_id,
							country,
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
							municipal_registration,                                    
							state_registration,
							final_consumer,
							icms_contributor,
							erp_filename,
							erp_line_in_file)
							values
							(@v_order_to_cash_id, -- order_to_cash_id
							v_country, -- country
							null, -- erp_customer_id
							v_customer_full_name, -- full_name
							v_customer_type_person, -- type_person
							v_customer_identification_financial_responsible, -- identification_financial_responsible
							v_customer_nationality_code, -- nationality_code
							v_customer_state, -- state
							v_customer_city, -- city
							v_customer_adress, -- adress
							v_customer_adress_number, -- adress_number
							v_customer_adress_complement, -- adress_complement
							v_customer_district, -- district
							v_customer_postal_code, -- postal_code
							v_customer_area_code, -- area_code
							v_customer_cellphone, -- cellphone
							v_customer_email, -- email
							v_customer_municipal_registration, -- municipal_registration                                    
							v_customer_state_registration, -- state_registration
							v_customer_final_consumer, -- final_consumer
							v_customer_icms_contributor, -- icms_contributor
							null, -- erp_filename
							null); -- erp_line_in_file  

			insert into receivable
							(order_to_cash_id,
							erp_receivable_id,
							erp_receivable_customer_id,
							erp_clustered_receivable_id,
							erp_clustered_receivable_customer_id,
							is_smartfin,
							transaction_type,
							contract_number,
							credit_card_brand,
							truncated_credit_card,
							current_credit_card_installment,
							total_credit_card_installment,
							nsu,
							conciliator_id,
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
							(@v_order_to_cash_id, -- order_to_cash_id
							null, -- erp_receivable_id
							@v_erp_customer_id, -- erp_receivable_customer_id
							null, -- erp_clustered_receivable_id
							@v_erp_customer_id, -- erp_clustered_receivable_customer_id
							'no', -- is_smartfin
							'boleto', -- transaction_type
							null, -- contract_number
							null, -- credit_card_brand
							null, -- truncated_credit_card
							1, -- current_credit_card_installment
							1, -- total_credit_card_installment
							null, -- nsu
							null, -- conciliator_id
							null, -- authorization_code
							0, -- price_list_value
							@v_gross_value, -- gross_value
							@v_net_value, -- net_value
							0, -- interest_value
							0, -- administration_tax_percentage
							0, -- administration_tax_value
							0, -- antecipation_tax_percentage
							0, -- antecipation_tax_value
							current_date(), -- billing_date
							date_add(current_date(), interval 30 day), -- credit_date
							null, -- conciliator_filename
							null, -- acquirer_bank_filename
							null, -- registration_gym_student
							null, -- fullname_gym_student
							null, -- identification_gym_student
							null, -- erp_filename
							null); -- erp_line_in_file

			insert into invoice
						(order_to_cash_id,
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
						(@v_order_to_cash_id, -- order_to_cash_id
						null, -- erp_invoice_customer_id
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
			set @v_invoice_id = last_insert_id(); 

			insert into invoice_items
					(id_invoice,
					front_product_id,
					front_plan_id,
					front_addon_id,
					erp_item_ar_id,
					erp_item_ar_name,
					erp_gl_segment_product,
					erp_ncm_code,
					to_generate_fiscal_document,
					quantity,
					sale_price,
					list_price,
					erp_filename,
					erp_line_in_file)
					values
					(@v_invoice_id, -- id_invoice
					1, -- front_product_id
					null, -- front_plan_id
					null, -- front_addon_id
					null, -- erp_item_ar_id
					null, -- erp_item_ar_name
					null, -- erp_gl_segment_product
					null, -- erp_ncm_code
					null, -- to_generate_fiscal_document
					1, -- quantity
					@v_gross_value, -- sale_price
					@v_gross_value, -- list_price
					null, -- erp_filename
					null); -- erp_line_in_file    
			
            set @v_invoice_items_id = last_insert_id(); 
            
            -- select concat("after 5: ",current_timestamp());
            
            -- select concat("before 6: ",current_timestamp());
            
            update invoice_items iit
            
            inner join product_from_to_version pftv
            on pftv.country = v_country
            and pftv.product_from_to_origin_system = 'oic'
            and pftv.product_from_to_operation = 'smartfin_fee'
            and pftv.product_from_to_front_product_id = iit.front_product_id
            and pftv.id = ( 
							select 
								max(pftv_v2.id) 
							from product_from_to_version pftv_v2
                            where pftv_v2.country = pftv.country
                            and pftv_v2.product_from_to_origin_system = pftv.product_from_to_origin_system
                            and pftv_v2.product_from_to_operation = pftv.product_from_to_operation
                            and pftv_v2.product_from_to_front_product_id = pftv.product_from_to_front_product_id
							)
            
            set 	iit.erp_item_ar_id = pftv.erp_item_ar_id
				,	iit.erp_item_ar_name = pftv.erp_item_ar_name
				,	iit.erp_gl_segment_product = pftv.erp_gl_segment_id
				,	iit.erp_ncm_code = pftv.erp_ncm_code
				,	iit.to_generate_fiscal_document = pftv.to_generate_fiscal_document
			
            where iit.id = @v_invoice_items_id;
            
            -- select concat("after 6: ",current_timestamp());
            
            -- select concat("before 7: ",current_timestamp());
            
			update payable pay
					
			set pay.oic_smartfin_status_transaction = 'fee_smartfin_created_at_oic_db', pay.fee_smartfin_otc_id = @v_order_to_cash_id
			
			where pay.id in ( select id from control_fee_smartfin where keycontrol = @v_keycontrol and created_at = @v_created_at)
			and pay.oic_smartfin_status_transaction = 'fee_smartfin_being_processed' ;	
			
            -- select concat("after 7: ",current_timestamp());
            
        end if;
        
        delete from control_fee_smartfin where keycontrol = @v_keycontrol and created_at = @v_created_at;
        
        commit;
		        
    end loop FeeSmartFinLoop;
    
    close cur1;	
    
    do release_lock(@v_keycontrol);

else 
	select concat('Procedure is already running in another thread: ',@v_keycontrol ) as log;
end if;

select concat("after: ",current_timestamp());

END;
//