drop procedure if exists sp_insert_refund; 
delimiter //

CREATE PROCEDURE sp_insert_refund( p_refund JSON ,out p_return boolean  ,out p_code integer ,out p_message varbinary(10000), out p_front_refund_id integer )
begin 
    declare p_refund_country varchar(45);
    declare p_refund_unity_identification integer default 0;
    declare p_refund_origin_system varchar(45);
    declare p_refund_front_refund_id varchar(45);
    declare p_refund_requester_name varchar(45);     
    declare p_refund_requester_identification varchar(45);
    declare p_refund_issue_date integer default null;
    declare p_refund_due_date integer default null;
    declare p_refund_refund_value float;
    declare p_refund_bank_number varchar(45);
    declare p_refund_bank_branch varchar(45); 
	declare p_refund_bank_branch_digit varchar(45);
    declare p_refund_bank_account_number varchar(45);    
    declare p_refund_bank_account_number_digit varchar(45);
    declare p_refund_bank_account_owner_name varchar(255);
    declare refund_bank_account_owner_identification varchar(255);
    declare p_refund_items_json JSON;    
	declare p_refund_id integer;
    declare p_return_v2 boolean;
    declare p_code_v2 boolean;
    declare p_message_v2 varbinary(10000);
    declare p_front_refund_id_v2 integer;   
    declare p_return_v3 boolean;
    declare p_code_v3 boolean;
    declare p_message_v3 varbinary(10000);
    declare p_front_refund_id_v3 integer;    
    declare p_front_id integer;
    declare p_refund_item_value float;
    declare p_billing_date date;
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
	set p_front_refund_id = 0;
        
	call sp_valid_object_refund(p_refund, @p_return_v2 , @p_code_v2 , @p_message_v2, @p_front_refund_id_v2);
    
    if ( @p_return_v2 ) then 
    
		start transaction;

		select replace(replace(json_extract(p_refund,'$.refund.header.country'),'"',""),"null",null) into @p_refund_country;
		select cast(replace(json_extract(p_refund,'$.refund.header.unity_identification'),"null",null) as unsigned) into @p_refund_unity_identification;
		select replace(replace(json_extract(p_refund,'$.refund.header.origin_system'),'"',""),"null",null)  into @p_refund_origin_system;
		select replace(replace(json_extract(p_refund,'$.refund.header.front_refund_id'),'"',""),"null",null)  into @p_refund_front_refund_id;
		select replace(replace(json_extract(p_refund,'$.refund.header.refund_requester_name'),'"',""),"null",null)  into @p_refund_requester_name;
		select replace(replace(json_extract(p_refund,'$.refund.header.refund_requester_identification'),'"',""),"null",null)  into @p_refund_requester_identification;
		select replace(replace(json_extract(p_refund,'$.refund.header.issue_date'),'"',""),"null",null)  into @p_refund_issue_date;
		select replace(replace(json_extract(p_refund,'$.refund.header.due_date'),'"',""),"null",null)  into @p_refund_due_date;
		select cast(replace(json_extract(p_refund,'$.refund.header.refund_value'),"null",null) as decimal(18,4) ) into @p_refund_refund_value;
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_number'),'"',""),"null",null)  into @p_refund_bank_number;         
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_branch'),'"',""),"null",null)  into @p_refund_bank_branch;
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_branch_digit'),'"',""),"null",null)  into @p_refund_bank_branch_digit;
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_account_number'),'"',""),"null",null)  into @p_refund_bank_account_number;
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_account_number_digit'),'"',""),"null",null)  into @p_refund_bank_account_number_digit;
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_account_owner_name'),'"',""),"null",null)  into @p_refund_bank_account_owner_name;
		select replace(replace(json_extract(p_refund,'$.refund.header.bank_account_owner_identification'),'"',""),"null",null)  into @refund_bank_account_owner_identification;
		select cast( json_extract(p_refund,'$.refund.refund_items') as json ) into @p_refund_items_json;   
		
		call sp_check_if_exists_refund(p_refund, @p_return_v3 , @p_code_v3 , @p_message_v3, @p_front_refund_id_v3);
            
        if ( @p_return_v3 ) then 
         
			set @v_erp_business_unit = null;
			set @v_erp_legal_entity = null;
			set @v_erp_subsidiary = null;
			set @v_acronym = null;
            
			select
				oftv.erp_business_unit
				,oftv.erp_legal_entity
				,oftv.erp_subsidiary
				,oftv.acronym

			into      
				 @v_erp_business_unit 
				,@v_erp_legal_entity 
				,@v_erp_subsidiary 
				,@v_acronym 

			from organization_from_to_version oftv
			where oftv.organization_from_to_unity_identification = @p_refund_unity_identification
			and oftv.created_at = (
									select 
										max(oftv_v2.created_at) as created_at
									from organization_from_to_version oftv_v2
									where oftv_v2.organization_from_to_unity_identification = oftv.organization_from_to_unity_identification
									);
                                    
                                    
			if ( @v_erp_business_unit is not null ) then

				insert into refund(country,
									unity_identification,
									erp_business_unit,
									erp_legal_entity,
									erp_subsidiary,
									acronym,
									origin_system,
                                    erp_refund_status_transaction,
									refund_requester_name,                                 
									refund_requester_identification,                                 
									issue_date,      
									due_date,                                 
									front_refund_id, 
									refund_value,
									bank_number,
									bank_branch,
									bank_branch_digit,
									bank_account_number,
									bank_account_number_digit,
									bank_account_owner_name,
									bank_account_owner_identification)
							values(@reund_cash_country, -- country
									@refund_cash_unity_identification, -- unity_identification
									@v_erp_business_unit, -- erp_business_unit
									@v_erp_legal_entity, -- erp_legal_entity
									@v_erp_subsidiary, -- erp_subsidiary
									@v_acronym, -- acronym
									@p_refund_origin_system, -- origin_system
									'waiting_to_be_process', -- erp_refund_status_transaction                                    
									@p_refund_requester_name, -- refund_requester_name
									@p_refund_requester_identification, -- refund_requester_identification
									@p_refund_issue_date, -- issue_date                          
									@p_refund_due_date, -- due_date                                 
									@p_refund_front_refund_id, -- front_refund_id
									@p_refund_refund_value, -- refund_value                                 
									@p_refund_bank_number, -- bank        
									@p_refund_bank_branch, -- bank_branch
									@p_refund_bank_branch_digit, -- bank_branch_digit
									@p_refund_bank_account_number, -- bank_account_number 
									@p_refund_bank_account_number_digit, -- bank_account_number_digit 
									@p_refund_bank_account_owner_name, -- bank_accont_owner_name
									@refund_bank_account_owner_identification );-- bank_account_owner_identification
					 
				-- saves the auto increment id from order_to_cash table
				set @p_refund_id = last_insert_id();  			
                
				if (@p_refund_items_json is not null) then     									
                    
					refund_items_lopp: while i <= json_length(@p_refund_items_json) - 1 do											
                        
						set @p_front_id = null;
						set @p_refund_item_value = null;
						set @p_billing_date = null;
						
                        -- select json_contains_path(@p_refund_items_json,'one',concat('$[',i,'].front_id'));
										
						if (  json_contains_path(@p_refund_items_json,'one',concat('$[',i,'].front_id')) = 1 
						and json_contains_path(@p_refund_items_json,'one',concat('$[',i,'].refund_item_value')) = 1 
						and json_contains_path(@p_refund_items_json,'one',concat('$[',i,'].billing_date')) = 1 
						) then
							
							select cast(replace(json_extract(@p_refund_items_json,concat('$[',i,'].front_id')),"null",null) as unsigned) into @p_front_id;
							select cast(replace(json_extract(@p_refund_items_json,concat('$[',i,'].refund_item_value')),"null",null) as decimal(18,4)) into @p_refund_item_value;
							select replace(replace(json_extract(@p_refund_items_json,concat('$[',i,'].billing_date')),'"',""),"null",null)  into @p_billing_date;													

							insert into refund_items(refund_id,
													front_id,
													refund_item_value,
													billing_date)
													values
													(@p_refund_id, -- @refund_id
													@p_front_id, -- front_id
													@p_refund_item_value, -- refund_item_value
													@p_billing_date); -- billing_date																		  
							
						end if;
						
                        set i = i + 1 ;
                        
					end while refund_items_lopp;
					
				end if;
                
				if ( p_return ) then
					
					commit;
					set p_return = true;
					set p_code = 0;
					set p_message = concat("The refund transaction was added to oic_db successfully. Id: ",ifnull(@p_refund_id,"null"));
					set p_front_refund_id = @p_refund_front_refund_id;
				
				end if;                
			
            else
            
				rollback;
				set p_return = false;
				set p_code = 3;
				set p_message = concat("The unity identification sent ", ifnull(@p_refund_unity_identification,"null") ," doesn't exist at oic_db. Please talk to ERP Team !");
				set p_front_refund_id = @p_refund_front_refund_id;
            
			end if;
        
        else
        
			rollback;
			set p_return = @p_return_v3;
			set p_code = @p_code_v3;
			set p_message = @p_message_v3;
			set p_front_refund_id = @p_front_refund_id_v3;		        
                
		end if;        
	
    else
		
        rollback;        
		set p_return = @p_return_v2;
		set p_code = @p_code_v2;
		set p_message = @p_message_v2;
		set p_front_refund_id = @p_front_refund_id_v2;		
    
	end if; 
    
end;
//