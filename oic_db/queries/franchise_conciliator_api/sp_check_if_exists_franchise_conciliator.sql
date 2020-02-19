drop procedure if exists sp_check_if_exists_franchise_conciliator;
DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `sp_check_if_exists_franchise_conciliator`(p_franchine_conciliator JSON ,out p_return boolean ,out p_code integer ,out p_message varbinary(5000), out p_front_franchise_conciliator_id integer)
begin	
	declare v_id integer;
    declare v_country varchar(45);
    declare v_unity_identification integer;
    declare v_origin_system varchar(45);
    declare v_operation varchar(45);
    declare v_erp_receivable_status_transaction varchar(45);
    declare v_erp_supplier_status_transaction varchar(45);
    declare v_erp_payable_status_transaction varchar(45);
    declare v_created_at timestamp;
    declare v_front_franchise_conciliator_id varchar(45);
    	
    
    
    set v_front_franchise_conciliator_id = cast(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.front_franchise_conciliator_id') as unsigned);
    select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.country'),'"',""),"null",null) into @v_otc_country_json;
	select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.origin_system'),'"',""),"null",null) into @v_otc_origin_system_json;
    select replace(replace(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.operation'),'"',""),"null",null) into @v_otc_operation_json;

    select
		 otc.front_id -- este campo esquivale a front_franchise_conciliator_id
        ,otc.country
        ,otc.unity_identification
        ,otc.origin_system
        ,otc.operation
        ,otc.erp_receivable_status_transaction
        ,sup.erp_supplier_status_transaction
        ,pay.erp_payable_status_transaction
        ,otc.created_at as created_at 
        into
		 v_id -- front_refund_id
        ,v_country -- country
        ,v_unity_identification -- unity_identification
        ,v_origin_system -- origin_system
        ,v_operation -- operation
        ,v_erp_receivable_status_transaction -- erp_receivable_status_transaction
        ,v_erp_supplier_status_transaction -- erp_supplier_status_transaction
        ,v_erp_payable_status_transaction -- erp_payable_status_transaction
        ,v_created_at -- created_at
        
    from order_to_cash otc
	
    inner join receivable rec
	on rec.order_to_cash_id = otc.id
    
    inner join payable pay
	on pay.receivable_id = rec.id
    
    inner join supplier sup
	on sup.identification_financial_responsible = pay.supplier_identification
    
    where otc.front_id = v_front_franchise_conciliator_id and otc.country = @v_otc_country_json and otc.origin_system = @v_otc_origin_system_json and otc.operation = @v_otc_operation_json
    and otc.id = (select max(otc2.id) from order_to_cash otc2 where otc2.front_id = otc.front_id and otc2.country = @v_otc_country_json and otc2.origin_system = @v_otc_origin_system_json and otc2.operation = @v_otc_operation_json);
    
    if (v_id is null or v_erp_receivable_status_transaction = 'error_at_trying_to_process' or v_erp_supplier_status_transaction = 'error_at_trying_to_process'
    or v_erp_payable_status_transaction = 'error_at_trying_to_process' ) then

		set p_return = true;
		set p_code = 0;
		set p_message = "";
		set p_franchine_conciliator = v_front_franchise_conciliator_id;
	
    else
        
		set p_return = false;
		set p_code = 2;
		set p_message = concat('The franchise conciliator transaction was already added to oic_db and is waiting to be process ! => { "id" : ',v_id 
							    ,', "created_at:" ',ifnull(v_created_at,"null")
								,', "erp_receivable_status_transaction: " ',ifnull(v_erp_receivable_status_transaction,"null")
                                ,', "erp_supplier_status_transaction: " ',ifnull(v_erp_supplier_status_transaction,"null")
								,', "erp_payable_status_transaction: " ',ifnull(v_erp_payable_status_transaction,"null")
								,'} ');
		set p_franchine_conciliator = v_front_franchise_conciliator_id;  	
                
    end if;
    
end$$
DELIMITER ;