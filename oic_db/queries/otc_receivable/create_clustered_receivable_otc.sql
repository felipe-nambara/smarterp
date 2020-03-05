DROP PROCEDURE IF EXISTS sp_create_clustered_receivable; 
DELIMITER //
CREATE PROCEDURE sp_create_clustered_receivable ( IN p_country varchar(45) , IN p_origin_system varchar(45) , IN p_operation varchar(45) , IN  p_transaction_type varchar(45), IN p_limit integer )

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
declare v_fullname varchar(255);
declare v_transaction_type varchar(45);
declare v_credit_card_brand varchar(45);
declare v_contract_number varchar(45);
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
declare v_qtd_of_receivable int;
declare done int;
declare v_message_text varchar(255);
declare v_keycontrol varchar(150);
declare v_created_at timestamp;
declare param1 varchar(10);
declare param2 varchar(10);
declare param3 varchar(10);
declare param4 varchar(10);
declare cur1 cursor for select * from vw_clustered_receivable 
						where country = p_country 
                        and origin_system = p_origin_system 
                        and operation = p_operation
                        and transaction_type = p_transaction_type 
                        order by country
								,origin_system
                                ,unity_identification
                                ,operation
                                ,transaction_type
                                ,credit_card_brand
                                ,billing_date;
declare continue handler for not found set done=1;
declare exit handler for sqlexception 
begin
    get diagnostics condition 1  @v_message_text = message_text;
    select @v_message_text;
    rollback; 
end;

select concat("before: ",current_timestamp());

set @v_keycontrol 	:= concat_ws('_','clus_rec',left(rtrim(p_country),2),left(rtrim(p_origin_system),2),left(rtrim(p_operation),2),left(rtrim(p_transaction_type),2));
set @v_created_at	:= current_timestamp;

if get_lock(@v_keycontrol,1) = 1 then 
	
	if ( select not exists(
							select 
								1 
							from information_schema.tables 
							where table_schema = database()
							and table_name = 'control_clustered_receivable'
							)
		) then		
        
        CREATE TABLE control_clustered_receivable (  id int(11) NOT NULL AUTO_INCREMENT, keycontrol varchar(150) DEFAULT NULL,  created_at timestamp NULL DEFAULT NULL, PRIMARY KEY (id), KEY ccr_idx (keycontrol,created_at)) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    
    end if;
    
    set done = 0;
    open cur1;
    
    ClusteredReceivableLoop: loop
        fetch cur1 into  v_country
						,v_origin_system
						,v_unity_identification
						,v_erp_business_unit
                        ,v_erp_legal_entity
                        ,v_erp_subsidiary
                        ,v_acronym
                        ,v_operation
                        ,v_erp_customer_id
                        ,v_fullname
                        ,v_transaction_type
                        ,v_credit_card_brand
                        ,v_contract_number
                        ,v_administration_tax_percentage
                        ,v_antecipation_tax_percentage
                        ,v_billing_date
                        ,v_credit_date
                        ,v_is_smarftin;
                        
		if done = 1 then leave ClusteredReceivableLoop; end if;
	      
        start transaction;
        
        insert into control_clustered_receivable 
								select 
									order_to_cash.id as id
									,@v_keycontrol as keycontrol
                                    ,@v_created_at as created_at
								from order_to_cash
                                
								inner join receivable
								on receivable.order_to_cash_id = order_to_cash.id
								                                
								where order_to_cash.country = v_country                                
								and order_to_cash.origin_system = v_origin_system
								and order_to_cash.operation = v_operation
								and order_to_cash.unity_identification = v_unity_identification
								and order_to_cash.erp_receivable_status_transaction = 'waiting_to_be_process'    
                                and order_to_cash.to_generate_receivable = 'yes'
                                and receivable.erp_clustered_receivable_customer_id = v_erp_customer_id
								and receivable.transaction_type = v_transaction_type
								and receivable.contract_number = v_contract_number
								and ( ( receivable.credit_card_brand is not null and receivable.credit_card_brand = v_credit_card_brand) or (receivable.credit_card_brand is null) )
								and receivable.billing_date = v_billing_date
								and receivable.credit_date = v_credit_date
								and receivable.is_smartfin = v_is_smarftin                                 
       							and not exists ( 
													select 
														1 
													from order_to_cash order_to_cash_v3
													
													inner join receivable receivable_v2
													on receivable_v2.order_to_cash_id = order_to_cash_v3.id
													and	receivable_v2.erp_clustered_receivable_id is not null 

													where order_to_cash_v3.unity_identification = order_to_cash.unity_identification
                                                    and order_to_cash_v3.minifactu_id =  order_to_cash.minifactu_id 
													and ( 
																( order_to_cash_v3.erp_receivable_status_transaction = 'clustered_receivable_being_created' ) 
															or	( order_to_cash_v3.erp_receivable_status_transaction = 'clustered_receivable_created' ) 															
															or	( order_to_cash_v3.erp_receivable_status_transaction = 'created_at_erp' ) 															
														)
												)  
                                                
								order by order_to_cash.country 
										,order_to_cash.origin_system
                                        ,order_to_cash.operation
                                        ,order_to_cash.unity_identification
										,order_to_cash.erp_receivable_status_transaction
                                        ,order_to_cash.to_generate_receivable
                                        
                                        limit p_limit ;											
		
		if exists ( select id from control_clustered_receivable where keycontrol = @v_keycontrol and created_at = @v_created_at order by id limit 1)  then 
			            
			update order_to_cash 
			
			inner join receivable
			on receivable.order_to_cash_id = order_to_cash.id
			
			set order_to_cash.erp_receivable_status_transaction = 'clustered_receivable_being_created'
			
			where order_to_cash.id in ( select id from control_clustered_receivable where keycontrol = @v_keycontrol and created_at = @v_created_at);
			
			select 	
				 round(sum(receivable.gross_value),2) as gross_value
				,round(sum(receivable.price_list_value),2) as price_list_value
				,round(sum(receivable.net_value),2) as net_value
				,round(sum(receivable.interest_value),2) as interest_value
				,round(sum(receivable.administration_tax_value),2) as administration_tax_value
				,round(sum(receivable.antecipation_tax_value),2) as antecipation_tax_value
				,count(1) as qtd
				
				into @v_gross_value
					,@v_price_list_value
					,@v_net_value
					,@v_interest_value
					,@v_administration_tax_value
					,@v_antecipation_tax_value
					,@v_qtd_of_receivable
				
			from receivable 
			
			inner join order_to_cash
			on order_to_cash.id = receivable.order_to_cash_id
			
			where order_to_cash.id in ( select id from control_clustered_receivable where keycontrol = @v_keycontrol and created_at = @v_created_at)
			and order_to_cash.erp_receivable_status_transaction = 'clustered_receivable_being_created' ;			
			
			insert into clustered_receivable
								(country,
								unity_identification,
								erp_business_unit,
								erp_legal_entity,
								erp_subsidiary,
								acronym,
								erp_clustered_receivable_customer_id,
								contract_number,
								credit_card_brand,
								billing_date,
								credit_date,
								price_list_value,
								gross_value,
								net_value,
								interest_value,
								administration_tax_percentage,
								administration_tax_value,
								antecipation_tax_percentage,
								antecipation_tax_value,
								quantity_of_receivable)
								VALUES
								(v_country,
								v_unity_identification,
								v_erp_business_unit,
								v_erp_legal_entity,
								v_erp_subsidiary,
								v_acronym,
								v_erp_customer_id,
								v_contract_number,
								v_credit_card_brand,
								v_billing_date,
								v_credit_date,
								@v_price_list_value,
								@v_gross_value,
								@v_net_value,
								@v_interest_value,
								v_administration_tax_percentage,
								@v_administration_tax_value,
								v_antecipation_tax_percentage,
								@v_antecipation_tax_value,
								@v_qtd_of_receivable);
			     
			set @clustered_receivable_id = last_insert_id();
			
			update receivable
			
			inner join order_to_cash
			on order_to_cash.id = receivable.order_to_cash_id
			
			set receivable.erp_clustered_receivable_id = @clustered_receivable_id
			, order_to_cash.erp_receivable_status_transaction = 'clustered_receivable_created'

			where order_to_cash.id in ( select id from control_clustered_receivable where keycontrol = @v_keycontrol and created_at = @v_created_at)
			and order_to_cash.erp_receivable_status_transaction = 'clustered_receivable_being_created' ;        

        end if;
        
        delete from control_clustered_receivable where keycontrol = @v_keycontrol and created_at = @v_created_at;
        
        commit;

    end loop ClusteredReceivableLoop;
    
    close cur1;	
    
    do release_lock(@v_keycontrol);

else 
	select concat('Procedure is already running in another thread: ',@v_keycontrol ) as log;
end if;

select concat("after: ",current_timestamp());

END;
//