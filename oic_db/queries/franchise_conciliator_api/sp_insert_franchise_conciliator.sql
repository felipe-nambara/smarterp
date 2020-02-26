drop procedure if exists sp_insert_franchise_conciliator;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `sp_insert_franchise_conciliator`( p_franchine_conciliator JSON ,out p_return boolean, out p_code integer ,out p_message varbinary(1000), out p_front_franchise_conciliator_id integer )
begin
    declare v_otc_country varchar(45);
    declare v_otc_unity_identification integer default 0;
    declare v_otc_origin_system varchar(45);
    declare v_otc_operation varchar(45);
    declare v_otc_front_franchise_conciliator_id integer; -- Neste campo será gravado o front id vindo do JSON
    declare v_otc_issue_date integer default null;
    declare v_otc_due_date integer default null;
    declare v_customer_identification_financial_responsible varchar(45);
    declare v_receivable_erp_receivable_customer_id varchar(45);
    declare v_receivable_contract_number varchar(45);
    declare v_receivable_credit_card_brand varchar(45);
    declare v_receivable_gross_value varchar(45);
    declare v_supplier_full_name varchar(45);
    declare v_supplier_type_person varchar(45);
    declare v_suplier_identification_financial_responsible varchar(45);
    declare v_suplier_nationality_code varchar(45);
    declare v_supplier_state varchar(45);
    declare v_supplier_city varchar(45);
    declare v_supplier_adress varchar(45);
    declare v_supplier_adress_number varchar(45);
    declare v_supplier_adress_complement varchar(45);
    declare v_supplier_district varchar(45);
    declare v_supplier_postal_code varchar(45);
    declare v_supplier_area_code varchar(45);
    declare v_supplier_cellphone varchar(45);
    declare v_supplier_email varchar(45);
    declare v_supplier_state_registration varchar(45);
    declare v_supplier_municipal_registration varchar(45);
    declare v_supplier_final_consumer varchar(45);
    declare v_supplier_icms_contributor varchar(45);
    declare p_return_v2 boolean;
    declare p_code_v2 boolean;
    declare p_message_v2 varbinary(10000);
    declare p_front_franchise_conciliator_id_v2 integer;
	  declare p_return_v3 boolean;
    declare p_code_v3 boolean;
    declare p_message_v3 varbinary(10000);
    declare p_front_franchise_conciliator_id_v3 integer;
    
    declare exit handler for sqlexception
    begin

      get diagnostics condition 1  @v_message_text = message_text;
      set p_return = false;
      set p_code = -1;
      set p_message = @v_message_text;
      rollback;
    
	  end;

    set sql_mode = traditional;
    set p_return = true;
    set p_code = 0;
    set p_message = "";
    set p_front_franchise_conciliator_id = 0;

    call sp_valid_franchise_conciliator(p_franchine_conciliator, @p_return_v2 , @p_code_v2 , @p_message_v2, @p_front_franchise_conciliator_id_v2);

if ( @p_return_v2 ) then -- if 1

	start transaction;

	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.country'),'"',""),"null",null) into @v_otc_country;
	select cast(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.unity_identification'),"null",null) as unsigned) into @v_otc_unity_identification;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.origin_system'),'"',""),"null",null) into @v_otc_origin_system;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.front_franchise_conciliator_id'),'"',""),"null",null) into @v_otc_front_franchise_conciliator_id;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.origin_system'),'"',""),"null",null) into @v_otc_origin_system;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.operation'),'"',""),"null",null) into @v_otc_operation;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.issue_date'),'"',""),"null",null) into @v_otc_issue_date;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.due_date'),'"',""),"null",null) into @v_otc_due_date;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.receivable.erp_receivable_customer_identification'),'"',""),"null",null) into @v_customer_identification_financial_responsible;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.receivable.contract_number'),'"',""),"null",null) into @v_receivable_contract_number;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.receivable.credit_card_brand'),'"',""),"null",null) into @v_receivable_credit_card_brand;
	select cast(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.receivable.gross_value'),"null",null) as decimal(18,4) ) into @v_receivable_gross_value;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.full_name'),'"',""),"null",null) into @v_supplier_full_name;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.type_person'),'"',""),"null",null) into @v_supplier_type_person;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.identification_financial_responsible'),'"',""),"null",null) into @v_suplier_identification_financial_responsible;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.nationality_code'),'"',""),"null",null) into @v_suplier_nationality_code;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.state'),'"',""),"null",null) into @v_supplier_state;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.city'),'"',""),"null",null) into @v_supplier_city;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.adress'),'"',""),"null",null) into @v_supplier_adress;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.adress_number'),'"',""),"null",null) into @v_supplier_adress_number;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.adress_complement'),'"',""),"null",null) into @v_supplier_adress_complement;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.postal_code'),'"',""),"null",null) into @v_supplier_postal_code;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.area_code'),'"',""),"null",null) into @v_supplier_area_code;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.district'),'"',""),"null",null) into @v_supplier_district;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.cellphone'),'"',""),"null",null) into @v_supplier_cellphone;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.email'),'"',""),"null",null) into @v_supplier_email;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.state_registration'),'"',""),"null",null) into @v_supplier_state_registration;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.municipal_registration'),'"',""),"null",null) into @v_supplier_municipal_registration;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.final_consumer'),'"',""),"null",null) into @v_supplier_final_consumer;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.supplier.icms_contributor'),'"',""),"null",null) into @v_supplier_icms_contributor;

  call sp_check_if_exists_franchise_conciliator(p_franchine_conciliator, @p_return_v3 , @p_code_v3 , @p_message_v3, @p_front_franchise_conciliator_id_v3); -- precisei alterar o local da função por conta do campo operation que se estive no lugar anterior, não teria sido preenchido ainda, resultando em um erro.
	
		if ( @p_return_v3 ) then -- if 2

		set @v_oftv_erp_business_unit = null;
		set @v_oftv_erp_legal_entity = null;
		set @v_oftv_erp_subsidiary = null;
		set @v_oftv_acronym = null;
		set @v_oftv_to_generate_customer = null;
		set @v_oftv_to_generate_receivable = null;
		set @v_oftv_to_generate_invoice = null;
		select
		oftv.erp_business_unit
		,oftv.erp_legal_entity
		,oftv.erp_subsidiary
		,oftv.acronym
		,oftv.to_generate_customer
		,oftv.to_generate_receivable
		,oftv.to_generate_invoice
		into
		 @v_oftv_erp_business_unit
		,@v_oftv_erp_legal_entity
		,@v_oftv_erp_subsidiary
		,@v_oftv_acronym
		,@v_oftv_to_generate_customer
		,@v_oftv_to_generate_receivable
		,@v_oftv_to_generate_invoice

		from organization_from_to_version oftv
		where oftv.organization_from_to_unity_identification = @v_otc_unity_identification
		and oftv.created_at = (
							select
								max(oftv_v2.created_at) as created_at
							from organization_from_to_version oftv_v2
							where oftv_v2.organization_from_to_unity_identification = oftv.organization_from_to_unity_identification
							);



			if ( @v_oftv_erp_business_unit is not null ) then -- If 3
				
                select 
					erp_customer_id
					into @v_receivable_erp_receivable_customer_id
                from customer 
                where identification_financial_responsible = @v_customer_identification_financial_responsible;
                
				if (  @v_receivable_erp_receivable_customer_id is not null ) then -- if 4
                
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
							(@v_otc_country, -- country
							@v_otc_unity_identification, -- unity_identification
							@v_oftv_erp_business_unit, -- erp_business_unit
							@v_oftv_erp_legal_entity, -- erp_legal_entity
							@v_oftv_erp_subsidiary, -- erp_subsidiary
							@v_oftv_acronym, -- acronym
							@v_oftv_to_generate_customer, -- to_generate_customer
							@v_oftv_to_generate_receivable, -- to_generate_receivable
							@v_oftv_to_generate_invoice, -- to_generate_invoice
							@v_otc_origin_system, -- origin_system
							'franchise_conciliator', -- operation
							null, -- minifactu_id
							null, -- conciliator_id
							null, -- fin_id
							@v_otc_front_franchise_conciliator_id, -- front_id
							null, -- erp_invoice_customer_send_to_erp_at
							null, -- erp_invoice_customer_returned_from_erp_at
							'doesnt_need_to_be_process', -- erp_invoice_customer_status_transaction
							null, -- erp_invoice_customer_log
							null, -- erp_receivable_sent_to_erp_at
							null, -- erp_receivable_returned_from_erp_at
							@v_customer_identification_financial_responsible, -- erp_receivable_customer_identification
							'waiting_to_be_process', -- erp_receivable_status_transaction
							null, -- erp_receivable_log
							null, -- erp_invoice_send_to_erp_at
							null, -- erp_invoice_returned_from_erp_at
							'doesnt_need_to_be_process', -- erp_invoice_status_transaction
							null, -- erp_invoice_log
							null, -- erp_receipt_send_to_erp_at
							null, -- erp_receipt_returned_from_erp_at
							'waiting_to_be_process', -- erp_receipt_status_transaction
							null); -- erp_receipt_log

					-- saves the auto increment id from order_to_cash table
					set @v_otc_id = last_insert_id();

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
							(@v_otc_id, -- order_to_cash_id
							null, -- erp_receivable_id
							null, -- erp_receipt_id
							@v_receivable_erp_receivable_customer_id, -- erp_receivable_customer_id
							null, -- erp_clustered_receivable_id
							@v_receivable_erp_receivable_customer_id, -- erp_clustered_receivable_customer_id
							'yes', -- is_smartfin
							'no', -- converted_smartfin
							'franchise', -- type_smartfin
							null, -- receivable_id_smartfin
							null, -- ecommerce_payment_terms
							null, -- erp_payment_terms
							null, -- conciliator_id
							'boleto', -- transaction_type
							@v_receivable_contract_number, -- contract_number
							@v_receivable_credit_card_brand, -- credit_card_brand
							null, -- truncated_credit_card
							1, -- current_credit_card_installment
							1, -- total_credit_card_installment
							null, -- nsu
							null, -- authorization_code
							null, -- price_list_value
							@v_receivable_gross_value, -- gross_value
							@v_receivable_gross_value, -- net_value
							0, -- interest_value
							0, -- administration_tax_percentage
							0, -- administration_tax_value
							0, -- antecipation_tax_percentage
							0, -- antecipation_tax_value
							@v_otc_issue_date, -- billing_date
							@v_otc_due_date, -- credit_date
							null, -- conciliator_filename
							null, -- acquirer_bank_filename
							null, -- registration_gym_student
							null, -- fullname_gym_student
							null, -- identification_gym_student
							null, -- erp_filename
							null); -- erp_line_in_file

					-- saves the auto increment id from receivable table
					set @v_receivable_id = last_insert_id();

						insert into supplier
							(erp_supplier_id,
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
							municipal_registration,
							final_consumer,
							icms_contributor,
							erp_supplier_send_to_erp_at,
							erp_supplier_returned_from_erp_at,
							erp_supplier_status_transaction,
							erp_supplier_log,
							erp_filename,
							erp_line_in_file)
						VALUES
							(null, -- erp_supplier_id
							@v_supplier_full_name, -- full_name
							@v_supplier_type_person, -- type_person
							@v_suplier_identification_financial_responsible, -- identification_financial_responsible
							@v_suplier_nationality_code, -- nationality_code
							@v_supplier_state, -- state
							@v_supplier_city, -- city
							@v_supplier_adress, -- adress
							@v_supplier_adress_number, -- adress_number
							@v_supplier_adress_complement, -- adress_complement
							@v_supplier_district, -- district
							@v_supplier_postal_code, -- postal_code
							@v_supplier_area_code, -- area_code
							@v_supplier_cellphone, -- cellphone
							@v_supplier_email, -- email
							@v_supplier_state_registration, -- state_registration
							@v_supplier_municipal_registration, -- federal_registration
							@v_supplier_final_consumer, -- final_consumer
							@v_supplier_icms_contributor, -- icms_contributor
							null, -- erp_supplier_send_to_erp_at
							null, -- erp_supplier_returned_from_erp_at
							'waiting_to_be_process', -- erp_supplier_status_transaction
							null, -- erp_supplier_log
							null, -- erp_filename
							null  -- erp_line_in_file
							)
							ON DUPLICATE KEY UPDATE
							state = @v_supplier_state,
							city = @v_supplier_city,
							adress = @v_supplier_adress,
							adress_number = @v_supplier_adress_number,
							adress_complement = @v_supplier_adress_complement, 
							district = @v_supplier_district,
							postal_code = @v_supplier_postal_code,
							area_code = @v_supplier_area_code,
							cellphone = @v_supplier_cellphone,
							email = @v_supplier_email,
							state_registration = @v_supplier_state_registration,
							municipal_registration = @v_supplier_state_registration,
							final_consumer = @v_supplier_final_consumer,
							icms_contributor = @v_supplier_icms_contributor; -- fim do insert de supplier

						insert into payable
							(unity_identification,
							erp_business_unit,
							erp_legal_entity,
							erp_subsidiary,
							acronym,
							erp_payable_id,
							receivable_id,
							erp_receivable_id,
							erp_clustered_receivable_id,
							erp_payable_receipt_id,
							erp_supplier_id,
							supplier_identification,
							issue_date,
							due_date,
                            gross_value,
                            net_value,
							erp_payable_send_to_erp_at,
							erp_payable_returned_from_erp_at,
							erp_payable_status_transaction,
							erp_payable_log,
							erp_receipt_send_to_erp_at,
							erp_receipt_returned_from_erp_at,
							erp_receipt_status_transaction,
							erp_receipt_log,
							erp_filename,
							erp_line_in_file)
						VALUES(
							@v_otc_unity_identification, -- unity_identification
							@v_oftv_erp_business_unit, -- erp_business_unit
							@v_oftv_erp_legal_entity, -- erp_legal_entity
							@v_oftv_erp_subsidiary, -- erp_subsidiary
							@v_oftv_acronym,-- acronym
							null, -- erp_payable_id
							@v_receivable_id, -- receivable_id  -- campo utilizando no inner join da procedure sp_check_if_exists_franchise_conciliator
							null, -- erp_receivable_id
							null, -- erp_clustered_receivable_id
							null, -- erp_payable_receipt_id
							null, -- erp_supplier_id
							@v_suplier_identification_financial_responsible, -- supplier_identification
							@v_otc_issue_date, --  issue_date
							@v_otc_due_date	, -- due_date
							@v_receivable_gross_value, -- gross_value
							@v_receivable_gross_value, -- net_value                            
							null, -- erp_payable_send_to_erp_at
							null, -- erp_payable_returned_from_erp_at
							'waiting_to_be_process', -- erp_payable_status_transaction
							null, -- erp_payable_log
							null, -- erp_receipt_send_to_erp_at
							null, -- erp_receipt_returned_from_erp_at
							'waiting_to_be_process', -- erp_receipt_status_transaction
							null, -- erp_receipt_log
							null, -- erp_filename
							null); -- erp_line_in_file

					set @v_payable_id = last_insert_id();

					if ( p_return ) then
					commit;
					set p_return = true;
					set p_code = 0;
					set p_message = concat("The franchise Conciliator transaction was added to oic_db successfully. Id: ", ifnull(@v_otc_id,"null"), " !");
					set p_front_franchise_conciliator_id = @v_otc_front_franchise_conciliator_id;
					end if;

				else
				rollback;
				set p_return = false;
				set p_code = 4;
				set p_message = concat("The Receivable Customer Identification sent  ", ifnull(@v_customer_identification_financial_responsible, "null") ," doesn't exist at oic_db. Please talk to ERP Team !");
				set p_front_franchise_conciliator_id = @v_otc_front_franchise_conciliator_id;
				end if; -- If 4

			else
			rollback;
			set p_return = false;
			set p_code = 3;
			set p_message = concat("The unity identification sent  ", ifnull(@v_otc_unity_identification, "null") ," doesn't exist at oic_db. Please talk to ERP Team !");
			set p_front_franchise_conciliator_id = @v_otc_front_franchise_conciliator_id;
			end if; -- If 3


		else -- 2º else
		rollback;
		set p_return = @p_return_v3;
		set p_code = @p_code_v3;
		set p_message = @p_message_v3;
		set p_front_franchise_conciliator_id = @p_front_franchise_conciliator_id_v3;

		end if; -- If 2

	else -- 1º else
	rollback;
	set p_return = @p_return_v2;
	set p_code = @p_code_v2;
	set p_message = @p_message_v2;
	set p_front_franchise_conciliator_id = @p_front_franchise_conciliator_id_v2;

end if; -- If 1
end$$
DELIMITER ;
