drop procedure if exists sp_insert_inter_distrib; 
delimiter //
create procedure sp_insert_inter_distrib ( p_inter_distrib JSON ,out p_return boolean  ,out p_code integer ,out p_message varbinary(10000), out p_front_inter_distrib_id integer )

begin	
    declare v_erp_business_unit_rec varchar(45);
    declare v_erp_legal_entity_rec varchar(45);
    declare v_erp_subsidiary_rec varchar(45);
    declare v_acronym_rec varchar(45);
    declare v_to_generate_customer_rec varchar(45);
    declare v_to_generate_receivable_rec varchar(45);
    declare v_to_generate_invoice_rec varchar(45); 
	declare v_fiscal_federal_identification_rec varchar(45);
    declare v_erp_customer_id varchar(45); 

    
    declare v_erp_business_unit_pay varchar(45);
    declare v_erp_legal_entity_pay varchar(45);
    declare v_erp_subsidiary_pay varchar(45);
    declare v_acronym_pay varchar(45);
    declare v_to_generate_customer_pay varchar(45);
    declare v_to_generate_receivable_pay varchar(45);
    declare v_to_generate_invoice_pay varchar(45);     
    declare v_fiscal_federal_identification_pay varchar(45);
    declare v_erp_supplier_id varchar(45); 
    
    declare v_erp_clustered_receivable_customer_id integer default 0;
    declare v_erp_receivable_customer_id integer default 0;
    declare v_order_to_cash_id integer;    
    declare v_front_product_id integer;
    declare v_front_plan_id integer;
    declare v_front_addon_id integer;
    declare v_quantity integer;
    declare v_list_price float;
    declare v_sale_price float;
    declare v_invoice_id integer;    
    declare v_erp_item_ar_id varchar(45); 
    declare v_erp_gl_segment_id varchar(45);
    declare v_erp_gl_segment_name varchar(255);
    declare v_erp_ncm_code varchar(45);
    declare v_erp_item_ar_overdue_recovery_id varchar(45);

    declare p_inter_distrib_country varchar(45);
	declare p_inter_distrib_origin_system varchar(45);
	declare p_inter_distrib_operation varchar(45);
	declare p_inter_distrib_unity_ident_rec integer;
    declare p_inter_distrib_unity_ident_pay integer;
    declare p_inter_distrib_identification_pay integer;
    declare p_inter_distrib_front_id integer;
    declare p_inter_distrib_issue_date date;
    declare p_inter_distrib_due_date date;
    declare p_inter_distrib_gross_value float;
    
	declare p_inter_distrib_invoice_items_json JSON;
    declare p_return_v2 boolean;
    declare p_code_v2 boolean;
    declare p_message_v2 varbinary(10000);
    declare p_front_inter_distrib_id_v2 integer;
    declare p_return_v3 boolean;
    declare p_code_v3 boolean;
    declare p_message_v3 varbinary(10000);
    declare p_front_inter_distrib_id_v3 integer;
    declare i int default 0;	
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
    set p_front_inter_distrib_id = 0;
	
	call sp_valid_object_intercompany_distribution(p_inter_distrib, @p_return_v2, @p_code_v2, @p_message_v2, @p_front_inter_distrib_id_v2);    
    
    if ( @p_return_v2 ) then 
    
		start transaction;
		        
		select replace(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.country'),'"',""),"null",null) into @p_inter_distrib_country;
		select replace(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.origin_system'),'"',""),"null",null) into @p_inter_distrib_origin_system;
		select replace(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.operation'),'"',""),"null",null) into @p_inter_distrib_operation;
		select cast(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.unity_identification_receivable'),"null",null) as unsigned) into @p_inter_distrib_unity_ident_rec;
		select cast(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.unity_identification_payable'),"null",null) as unsigned) into @p_inter_distrib_unity_ident_pay;
		select cast(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.front_intercompany_distribution_id'),"null",null) as unsigned) into @p_front_inter_distrib_id;
		select replace(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.issue_date'),'"',""),"null",null) into @p_inter_distrib_issue_date;
		select replace(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.due_date'),'"',""),"null",null) into @p_inter_distrib_due_date;
		select  cast(replace(json_extract(p_inter_distrib,'$.intercompany_distribution.header.gross_value'),"null",null)  as decimal(18,4)) into @p_inter_distrib_gross_value;	
		select cast( json_extract(p_inter_distrib,'$.intercompany_distribution.invoice.invoice_items') as json ) into @p_inter_distrib_invoice_items_json;    
		        
		call sp_check_if_exists_intercompany_distribution(p_inter_distrib, @p_return_v3 , @p_code_v3 , @p_message_v3, @p_front_inter_distrib_id_v3);

		if ( @p_return_v3 ) then 
			
            set @v_erp_business_unit_rec = null;
            set @v_erp_legal_entity_rec = null;
            set @v_erp_subsidiary_rec = null;
            set @v_acronym_rec = null;
            set @v_to_generate_customer_rec = null;
            set @v_to_generate_receivable_rec = null;
            set @v_to_generate_invoice_rec = null;
            set @v_fiscal_federal_identification_rec = null;

            set @v_erp_business_unit_pay = null;
            set @v_erp_legal_entity_pay = null;
            set @v_erp_subsidiary_pay = null;
            set @v_acronym_rec = null;
            set @v_to_generate_customer_pay = null;
            set @v_to_generate_receivable_pay = null;
            set @v_to_generate_invoice_pay = null;
            set @v_fiscal_federal_identification_pay = null;
            
			select
				 oftv.erp_business_unit
				,oftv.erp_legal_entity
				,oftv.erp_subsidiary
				,oftv.acronym
				,oftv.to_generate_customer
				,oftv.to_generate_receivable
				,oftv.to_generate_invoice                                        
				,oftv.fiscal_federal_identification
                
				into 		 
				 @v_erp_business_unit_rec 
				,@v_erp_legal_entity_rec 
				,@v_erp_subsidiary_rec 
				,@v_acronym_rec 
				,@v_to_generate_customer_rec 
				,@v_to_generate_receivable_rec 
				,@v_to_generate_invoice_rec 
                ,@v_fiscal_federal_identification_rec
				
			from organization_from_to_version oftv		
            
			where oftv.organization_from_to_unity_identification = @p_inter_distrib_unity_ident_rec
			and oftv.created_at = (
									select 
										max(oftv_v2.created_at) as created_at
									from organization_from_to_version oftv_v2
									where oftv_v2.organization_from_to_unity_identification = oftv.organization_from_to_unity_identification
									);
			
			if ( @v_erp_business_unit_rec is not null ) then							
                
				select
					 oftv.erp_business_unit
					,oftv.erp_legal_entity
					,oftv.erp_subsidiary
					,oftv.acronym
					,oftv.to_generate_customer
					,oftv.to_generate_receivable
					,oftv.to_generate_invoice 
                    ,oftv.fiscal_federal_identification
					
					into 		 
					 @v_erp_business_unit_pay
					,@v_erp_legal_entity_pay
					,@v_erp_subsidiary_pay
					,@v_acronym_pay 
					,@v_to_generate_customer_pay
					,@v_to_generate_receivable_pay
					,@v_to_generate_invoice_pay 
                    ,@v_fiscal_federal_identification_pay
					
				from organization_from_to_version oftv
				where oftv.organization_from_to_unity_identification = @p_inter_distrib_unity_ident_pay
				and oftv.created_at = (
										select 
											max(oftv_v2.created_at) as created_at
										from organization_from_to_version oftv_v2
										where oftv_v2.organization_from_to_unity_identification = oftv.organization_from_to_unity_identification
										);
				
                if ( @v_erp_business_unit_pay is not null ) then										
                    
					select 
						erp_customer_id
                        into @v_erp_customer_id
                    from customer cus
                    where cus.identification_financial_responsible = @v_fiscal_federal_identification_pay;
									
                    if ( @v_erp_customer_id is not null) then								
						
						select 
							erp_supplier_id
							into @v_erp_supplier_id
						from supplier sup
						where sup.identification_financial_responsible = @v_fiscal_federal_identification_rec;                        
							                        
                        if ( @v_erp_supplier_id is not null) then
                        
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
											(@p_inter_distrib_country, -- country
											@p_inter_distrib_unity_ident_rec, -- unity_identification
											@v_erp_business_unit_rec, -- erp_business_unit
											@v_erp_legal_entity_rec, -- erp_legal_entity
											@v_erp_subsidiary_rec, -- erp_subsidiary
											@v_acronym_rec, -- acronym
											@v_to_generate_customer_rec, -- to_generate_customer
											@v_to_generate_receivable_rec, -- to_generate_receivable
											@v_to_generate_invoice_rec, -- to_generate_invoice
											@p_inter_distrib_origin_system, -- origin_system
											@p_inter_distrib_operation, -- operation
											null, -- minifactu_id
											null, -- conciliator_id
											null, -- fin_id
											@p_front_inter_distrib_id, -- front_id
											null, -- erp_invoice_customer_send_to_erp_at
											null, -- erp_invoice_customer_returned_from_erp_at
											'doesnt_need_to_be_process', -- erp_invoice_customer_status_transaction
											null, -- erp_invoice_customer_log
											null, -- erp_receivable_sent_to_erp_at
											null, -- erp_receivable_returned_from_erp_at
											@v_fiscal_federal_identification_pay, -- erp_receivable_customer_identification
											'doesnt_need_to_be_process', -- erp_receivable_status_transaction
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
											'bank_transfer', -- transaction_type
											null, -- contract_number
											null, -- credit_card_brand
											null, -- truncated_credit_card
											1, -- current_credit_card_installment
											1, -- total_credit_card_installment
											null, -- nsu
											null, -- conciliator_id
											null, -- authorization_code
											@p_inter_distrib_gross_value, -- price_list_value
											@p_inter_distrib_gross_value, -- gross_value
											@p_inter_distrib_gross_value, -- net_value
											0, -- interest_value
											null, -- administration_tax_percentage
											null, -- administration_tax_value
											null, -- antecipation_tax_percentage
											null, -- antecipation_tax_value
											@p_inter_distrib_issue_date, -- billing_date
											@p_inter_distrib_due_date, -- credit_date
											null, -- conciliator_filename
											null, -- acquirer_bank_filename
											null, -- registration_gym_student
											null, -- fullname_gym_student
											null, -- identification_gym_student
											null, -- erp_filename
											null); -- erp_line_in_file
							
                            set @v_receivable_id = last_insert_id(); 
                            
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
										'invoice_intercompany', -- transaction_type
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
							
                            if (@p_inter_distrib_invoice_items_json is not null) then 

								intercompany_distribution_loop: while i <= json_length(@p_inter_distrib_invoice_items_json) - 1 do											
									
									set @p_front_product_id = null;
									set @p_quantity = null;
									set @p_sale_price = null;
                                    
									if (  json_contains_path(@p_inter_distrib_invoice_items_json,'one',concat('$[',i,'].front_product_id')) = 1 
									and json_contains_path(@p_inter_distrib_invoice_items_json,'one',concat('$[',i,'].quantity')) = 1 
									and json_contains_path(@p_inter_distrib_invoice_items_json,'one',concat('$[',i,'].sale_price')) = 1 
									) then
										
										select cast(replace(json_extract(@p_inter_distrib_invoice_items_json,concat('$[',i,'].front_product_id')),"null",null) as unsigned) into @p_front_product_id;
										select cast(replace(json_extract(@p_inter_distrib_invoice_items_json,concat('$[',i,'].quantity')),"null",null) as decimal(18,4)) into @p_quantity;
										select cast(replace(json_extract(@p_inter_distrib_invoice_items_json,concat('$[',i,'].sale_price')),"null",null) as decimal(18,4))  into @p_sale_price;																  
										
										if(@p_front_product_id = 0)then
											set @p_front_product_id = null;
										end if;
                                                                                
										if ( @p_front_product_id is not null  ) then
											
											select 
												 erp_item_ar_id
												,erp_gl_segment_id
												,erp_gl_segment_name
												,erp_ncm_code
												,erp_item_ar_overdue_recovery_id
												into @v_erp_item_ar_id
													,@v_erp_gl_segment_id
													,@v_erp_gl_segment_name
													,@v_erp_ncm_code
													,@v_erp_item_ar_overdue_recovery_id
											from product_from_to_version prodftv
											where prodftv.product_from_to_origin_system = @p_inter_distrib_origin_system
											and prodftv.product_from_to_operation = @p_inter_distrib_operation
											and prodftv.product_from_to_front_product_id = @p_front_product_id
											and prodftv.created_at = (
																			select 
																				max(prodftv_v2.created_at) as created_at
																			from product_from_to_version prodftv_v2
																			where prodftv_v2.product_from_to_origin_system = prodftv.product_from_to_origin_system
																			and prodftv_v2.product_from_to_operation = prodftv.product_from_to_operation
																			and prodftv_v2.product_from_to_front_product_id = prodftv.product_from_to_front_product_id);

										else
										
											rollback;
											set p_return = false;
											set p_code = 9;
											set p_message = concat("Intercompany Distribution transactions from ",ifnull(@p_inter_distrib_origin_system,"null")," must have at least front_product_id filled at invoice_items");
											set p_front_inter_distrib_id = @p_front_inter_distrib_id;
                                            
											leave intercompany_distribution_loop;
										
										end if;                                        
                                    
										if  p_return and ( ( @v_erp_item_ar_id is not null ) and ( @v_erp_gl_segment_id is not null) and ( @v_erp_ncm_code is not null) ) then											
												
												insert into invoice_items
												(id_invoice,
												front_product_id,
												front_plan_id,
												front_addon_id,
												erp_item_ar_id,
												erp_item_ar_name,
												erp_gl_segment_product,
												erp_ncm_code,
												quantity,
												sale_price,
												list_price,
												erp_filename,
												erp_line_in_file)
												values
												(@v_invoice_id, -- id_invoice
												@p_front_product_id, -- front_product_id
												null, -- front_plan_id
												null, -- front_addon_id
												@v_erp_item_ar_id, -- erp_item_ar_id
												@v_erp_item_ar_name, -- erp_item_ar_name
												@v_erp_gl_segment_id, -- erp_gl_segment_product
												@v_erp_ncm_code, -- erp_ncm_code
												@p_quantity, -- quantity
												@p_sale_price, -- sale_price
												@p_sale_price, -- list_price
												null, -- erp_filename
												null); -- erp_line_in_file                                            
																									
										else
											

											rollback;
											set p_return = false;
											set p_code = 6;
											set p_message = concat("The Oracle Erp Item Ar, Erp GL Product Segment or product Ncm Code were not found at the from/to tables with these values origin_system or are empty: "
																	,ifnull(@p_inter_distrib_origin_system,"null")
																	,", operation: "
																	,ifnull(@p_inter_distrib_operation,"null")
																	,", front_product_id: "
																	,ifnull(@p_front_product_id,"null")
																	,", front_plan_id: "
																	,ifnull(null,"null")
																	," and front_addon_id: "
																	,ifnull(null,"null") +"");
                                                                    
											set p_front_inter_distrib_id = @p_front_inter_distrib_id;								
											
											leave intercompany_distribution_loop;
																		
										end if;                                      
                                    
                                    else
                                    
										rollback;
										set p_return = false;
										set p_code = 5;
										set p_message = "The structure of invoice_items must have all these atributes: front_product_id, quantity and sale_price ! Please check the documentation https://app.swaggerhub.com/apis-docs/smartfit-v2/IntercompanyDistribution/1.0.0";
										set p_front_inter_distrib_id = @p_front_inter_distrib_id;                                
                                                                        
									end if;
									
									set i = i + 1 ;
									
								end while intercompany_distribution_loop;													
                                
								if ( p_return ) then
									
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
													values
													(@p_inter_distrib_unity_ident_pay, -- unity_identification
													@v_erp_business_unit_pay, -- erp_business_unit
													@v_erp_legal_entity_pay, -- erp_legal_entity
													@v_erp_subsidiary_pay, -- erp_subsidiary
													@v_acronym_pay, -- acronym
													null, -- erp_payable_id
													@v_receivable_id, -- receivable_id
													null, -- erp_receivable_id
													null, -- erp_clustered_receivable_id
													null, -- erp_payable_receipt_id
													@v_erp_supplier_id, -- erp_supplier_id
													@v_fiscal_federal_identification_rec, -- supplier_identification
													@p_inter_distrib_issue_date, -- issue_date
													@p_inter_distrib_due_date, -- due_date
													@p_inter_distrib_gross_value, -- gross_value
													@p_inter_distrib_gross_value, -- net_value
													null, -- erp_payable_send_to_erp_at
													null, -- erp_payable_returned_from_erp_at
													null, -- erp_payable_status_transaction
													null, -- erp_payable_log
													null, -- erp_receipt_send_to_erp_at
													null, -- erp_receipt_returned_from_erp_at
													null, -- erp_receipt_status_transaction
													null, -- erp_receipt_log
													null, -- erp_filename
													null); -- erp_line_in_file
                                
									
									commit;
									set p_return = true;
									set p_code = 0;
									set p_message = concat("The Intercompany Distribution transaction was added to oic_db successfully. Id: ",ifnull(@v_order_to_cash_id,"null"));
									set p_front_inter_distrib_id = @p_front_inter_distrib_id;
								
								end if;                            
                            
                            else

								rollback;
								set p_return = false;
								set p_code = 5;
								set p_message = "The structure of invoice_items must have all these atributes: front_product_id, quantity and sale_price ! Please check the documentation https://app.swaggerhub.com/apis-docs/smartfit-v2/IntercompanyDistribution/1.0.0";
								set p_front_inter_distrib_id = @p_front_inter_distrib_id;
                            
                            end if;

                        else

							rollback;
							set p_return = false;
							set p_code = 4;
							set p_message = concat("The Unity Identification Receivable sent ", ifnull(@p_inter_distrib_unity_ident_rec,"null") ," was not found at the Supplier/Customer tables. Please talk to ERP Team !");
							set p_front_inter_distrib_id = @p_front_inter_distrib_id;
                        
                        end if;

					else
						
						rollback;
						set p_return = false;
						set p_code = 4;
						set p_message = concat("The Unity Identification Payable sent ", ifnull(@p_inter_distrib_unity_ident_pay,"null") ," was not found at the Supplier/Customer tables. Please talk to ERP Team !");
						set p_front_inter_distrib_id = @p_front_inter_distrib_id;
						
					end if;
				
                else

					rollback;
					set p_return = false;
					set p_code = 3;
					set p_message = concat("The Unity Identification Payable sent ", ifnull(@p_inter_distrib_unity_ident_pay,"null") ," doesn't  exist at oic_db. Please talk to ERP Team !");
					set p_front_inter_distrib_id = @p_front_inter_distrib_id;
                
                end if;                
                
			else 
				
				rollback;
				set p_return = false;
				set p_code = 3;
				set p_message = concat("The Unity Identification Receivable sent ", ifnull(@p_inter_distrib_unity_ident_rec,"null") ," doesn't  exist at oic_db. Please talk to ERP Team !");
                set p_front_inter_distrib_id = @p_front_inter_distrib_id;
			
			end if;

		else
        
			set p_return = @p_return_v3;
			set p_code = @p_code_v3;
			set p_message = @p_message_v3; 
            set p_front_inter_distrib_id = @p_front_inter_distrib_id_v3;
		
		end if;
    
    else
    
		set p_return = @p_return_v2;
		set p_code = @p_code_v2;
		set p_message = @p_message_v2;
        set p_front_inter_distrib_id = @p_front_inter_distrib_id_v2;
    
    end if;
	
end;
//