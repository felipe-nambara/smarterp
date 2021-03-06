DROP PROCEDURE IF EXISTS sp_create_clustered_chargeback; 
DELIMITER //
CREATE PROCEDURE sp_create_clustered_chargeback ( IN p_country varchar(45) , IN p_origin_system varchar(45) , IN p_operation varchar(45) , IN  p_transaction_type varchar(45) )

BEGIN

declare v_country varchar(45) ;
declare v_origin_system varchar(45) ;
declare v_unity_identification varchar(45) ;
declare v_erp_business_unit varchar(45);
declare v_erp_legal_entity varchar(45);
declare v_erp_subsidiary varchar(45);
declare v_acronym varchar(45);
declare v_operation varchar(45);
declare v_erp_clustered_receivable_customer_id varchar(45);
declare v_fullname varchar(255);
declare v_transaction_type varchar(45);
declare v_credit_card_brand varchar(45);
declare v_contract_number varchar(45);
declare v_administration_tax_percentage float;
declare v_antecipation_tax_percentage float;
declare v_billing_date date;
declare v_credit_date date;
declare v_is_smarftin varchar(45);
declare v_converted_smartfin varchar(45);
declare v_price_list_value float;
declare v_gross_value float;
declare v_net_value float;
declare v_interest_value float;
declare v_administration_tax_value float;
declare v_antecipation_tax_value float;
declare v_qtd_of_receivable int;
declare done int;
declare v_message_text varchar(255);
declare cur1 cursor for select * from vw_clustered_chargeback 
						where country = p_country 
                        and origin_system = p_origin_system 
                        and operation = p_operation
                        and transaction_type = p_transaction_type 
                        order by country
								,origin_system
                                ,operation
                                ,transaction_type
                                ,billing_date;
declare continue handler for not found set done=1;

declare exit handler for sqlexception 
begin    
    get diagnostics condition 1  @v_message_text = message_text;
    select @v_message_text;
    rollback;
end;

set @v_keycontrol 	:= concat_ws('_','sp_clus_chbk',left(rtrim(p_country),2),left(rtrim(p_origin_system),2),left(rtrim(p_operation),2),left(rtrim(p_transaction_type),2));

if get_lock(@v_keycontrol,1) = 1 then 
	
    set done = 0;
    open cur1;
    
    ClusteredChargebackLoop: loop
        fetch cur1 into  v_country
						,v_origin_system
						,v_unity_identification
						,v_erp_business_unit
                        ,v_erp_legal_entity
                        ,v_erp_subsidiary
                        ,v_acronym
                        ,v_operation
                        ,v_erp_clustered_receivable_customer_id
                        ,v_fullname
                        ,v_transaction_type
                        ,v_credit_card_brand
                        ,v_contract_number
                        ,v_administration_tax_percentage
                        ,v_antecipation_tax_percentage
                        ,v_billing_date
                        ,v_credit_date
                        ,v_is_smarftin
                        ,v_converted_smartfin;
                        
		if done = 1 then leave ClusteredChargebackLoop; end if;
		
        start transaction;
	
		update chargeback
        
        inner join receivable
        on receivable.conciliator_id = chargeback.conciliator_id
        
        inner join order_to_cash
        on order_to_cash.id = receivable.order_to_cash_id
        
        set chargeback.erp_receipt_status_transaction = 'clustered_chargeback_being_created'
        
        where receivable.erp_clustered_receivable_customer_id = v_erp_clustered_receivable_customer_id
        and chargeback.transaction_type = v_transaction_type
        and chargeback.contract_number = v_contract_number
        and ( ( chargeback.credit_card_brand is not null and chargeback.credit_card_brand = v_credit_card_brand) or (chargeback.credit_card_brand is null) )
        and chargeback.billing_date = v_billing_date
        and chargeback.credit_date = v_credit_date
        and order_to_cash.country = v_country        
        and order_to_cash.origin_system = v_origin_system
        and order_to_cash.operation = v_operation
        and order_to_cash.unity_identification = v_unity_identification
        and receivable.converted_smartfin = v_converted_smartfin
        and receivable.is_smartfin = v_is_smarftin                
        and chargeback.erp_receipt_status_transaction = 'waiting_to_be_process';    
		
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
            
		from chargeback 

        inner join receivable
        on receivable.conciliator_id = chargeback.conciliator_id
        
        inner join order_to_cash
        on order_to_cash.id = receivable.order_to_cash_id	
        
        where order_to_cash.country = v_country
        and order_to_cash.origin_system = v_origin_system
        and order_to_cash.operation = v_operation
        and order_to_cash.unity_identification = v_unity_identification
        and receivable.erp_clustered_receivable_customer_id = v_erp_clustered_receivable_customer_id
        and chargeback.transaction_type = v_transaction_type
        and chargeback.contract_number = v_contract_number
        and ( ( chargeback.credit_card_brand is not null and chargeback.credit_card_brand = v_credit_card_brand ) or (chargeback.credit_card_brand is null)  )
        and chargeback.billing_date = v_billing_date
        and chargeback.credit_date = v_credit_date
        and receivable.is_smartfin = v_is_smarftin 
        and receivable.converted_smartfin = v_converted_smartfin
        and chargeback.erp_receipt_status_transaction = 'clustered_chargeback_being_created' ;
		
        insert into clustered_chargeback
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
                            quantity_of_chargeback)
							VALUES
							(v_country,
							v_unity_identification,
							v_erp_business_unit,
							v_erp_legal_entity,
							v_erp_subsidiary,
							v_acronym,
							v_erp_clustered_receivable_customer_id,
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

        set @clustered_chargeback_id = last_insert_id();
		
        update chargeback

        inner join receivable
        on receivable.conciliator_id = chargeback.conciliator_id
        
        inner join order_to_cash
        on order_to_cash.id = receivable.order_to_cash_id	
        
        set chargeback.erp_clustered_chargeback_id = @clustered_chargeback_id
        , chargeback.erp_receipt_status_transaction = 'clustered_chargeback_created'
        
        where order_to_cash.country = v_country
        and order_to_cash.origin_system = v_origin_system
        and order_to_cash.operation = v_operation
        and order_to_cash.unity_identification = v_unity_identification
        and receivable.erp_clustered_receivable_customer_id = v_erp_clustered_receivable_customer_id
        and chargeback.transaction_type = v_transaction_type
        and chargeback.contract_number = v_contract_number
        and ( ( chargeback.credit_card_brand is not null and chargeback.credit_card_brand = v_credit_card_brand) or (chargeback.credit_card_brand is null) )
        and chargeback.billing_date = v_billing_date
        and chargeback.credit_date = v_credit_date
        and receivable.is_smartfin = v_is_smarftin
        and receivable.converted_smartfin = v_converted_smartfin
        and chargeback.erp_receipt_status_transaction = 'clustered_chargeback_being_created' ;

    end loop ClusteredChargebackLoop;
    
    close cur1;	
    
    do release_lock(@v_keycontrol);

else 
	select concat('Procedure is already running in another thread: ',@v_keycontrol ) as log;
end if;

END;
//