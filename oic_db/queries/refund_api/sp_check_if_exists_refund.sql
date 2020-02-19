drop procedure if exists sp_check_if_exists_refund; 
delimiter //

CREATE PROCEDURE sp_check_if_exists_refund( p_refund JSON ,out p_return boolean ,out p_code integer ,out p_message varbinary(5000), out p_front_refund_id integer)
begin	
	declare v_id integer;
    declare v_country varchar(45);
    declare v_unity_identification integer;
    declare v_origin_system varchar(45);
    declare v_erp_refund_status_transaction varchar(45);
    declare v_created_at timestamp;
    declare v_front_refund_id integer;
    
    set v_front_refund_id = cast(json_extract(p_refund,'$.refund.header.front_refund_id') as unsigned);    
    
    select 
		 refund.front_refund_id
        ,refund.country
        ,refund.unity_identification
        ,refund.origin_system
        ,refund.erp_refund_status_transaction
        ,refund.created_at as created_at
        into
		 v_id -- front_refund_id
        ,v_country -- country
        ,v_unity_identification -- unity_identification
        ,v_origin_system -- origin_system
        ,v_erp_refund_status_transaction -- erp_invoice_status_transaction
        ,v_created_at -- created_at
    from refund
	
    where refund.front_refund_id = v_front_refund_id
    and refund.id = (  select max(ref2.id) from refund ref2 where ref2.front_refund_id = refund.front_refund_id);
    
    if (v_id is null or v_erp_refund_status_transaction = 'error_at_trying_to_process' ) then

		set p_return = true;
		set p_code = 0;
		set p_message = "";
		set p_front_refund_id = v_front_refund_id;
	
    else
        
		set p_return = false;
		set p_code = 2;
		set p_message = concat('The refund transaction was already added to oic_db and is waiting to be process ! => { "id" : ',v_id 
								,', "created_at:" ',ifnull(v_created_at,"null")
								,', "erp_refund_status_transaction: " ',ifnull(v_erp_refund_status_transaction,"null")
								,'} ');		
		set p_front_refund_id = v_front_refund_id;    	
                
    end if;
    
end;
//
