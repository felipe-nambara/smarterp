drop procedure if exists sp_check_if_exists_order_to_cash; 
delimiter //
create procedure sp_check_if_exists_order_to_cash ( p_otc JSON ,out p_return boolean  ,out p_code integer ,out p_message varbinary(5000), out p_minifactu_id integer)

begin	
	declare v_id integer;
    declare v_country varchar(45);
    declare v_unity_identification integer;
    declare v_origin_system varchar(45);
    declare v_operation varchar(45);
    declare v_erp_invoice_customer_status_transaction varchar(45);
    declare v_erp_receivable_status_transaction varchar(45);
    declare v_erp_invoice_status_transaction varchar(45);
    declare v_created_at timestamp;
    declare v_minifactu_id integer;
    
    set v_minifactu_id = cast(json_extract(p_otc,'$.otc.header.minifactu_id') as unsigned);    
    
    select 
		 otc.id
        ,otc.country
        ,otc.unity_identification
        ,otc.origin_system
        ,otc.operation
        ,otc.erp_invoice_customer_status_transaction
        ,otc.erp_receivable_status_transaction
        ,otc.erp_invoice_status_transaction
        ,otc.created_at as created_at
        into
		 v_id
        ,v_country
        ,v_unity_identification
        ,v_origin_system
        ,v_operation
        ,v_erp_invoice_customer_status_transaction
        ,v_erp_receivable_status_transaction
        ,v_erp_invoice_status_transaction
        ,v_created_at        
    from order_to_cash otc
	
    where otc.minifactu_id = v_minifactu_id
    and otc.id = (  select max(otc_v2.id) from order_to_cash otc_v2 where otc_v2.minifactu_id = otc.minifactu_id);
    
    if (v_id is null 
		or ( v_erp_invoice_customer_status_transaction in ('error_trying_to_create_at_erp','exception_at_oic') and v_erp_receivable_status_transaction not in ('waiting_to_be_process','clustered_receivable_being_created','being_processed') )
		or v_erp_receivable_status_transaction in ('error_at_trying_to_process','exception_at_oic')
        or v_erp_receivable_status_transaction in ('error_trying_to_create_at_erp','exception_at_oic')
        or ( v_erp_invoice_status_transaction in ('error_trying_to_create_at_erp','exception_at_oic') and v_erp_receivable_status_transaction not in ('waiting_to_be_process','clustered_receivable_being_created','being_processed') ) ) then

		set p_return = true;
		set p_code = 0;
		set p_message = "";
		set p_minifactu_id = v_minifactu_id;    
			
    else
        
		set p_return = false;
		set p_code = 2;
		set p_message = concat('The order to cash transaction was already added to oic_db and is waiting to be process ! => { "id" : ',v_id 
								,', "created_at:" ',v_created_at
								,', "erp_invoice_customer_status_transaction: " ',v_erp_invoice_customer_status_transaction
								,', "erp_receivable_status_transaction: " ',v_erp_receivable_status_transaction
								,', "erp_invoice_status_transaction: " ',v_erp_invoice_status_transaction 
								,'} ');		
		set p_minifactu_id = v_minifactu_id;    	
                
    end if;
    
end;
//