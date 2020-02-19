drop procedure if exists sp_valid_franchise_conciliator;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `sp_valid_franchise_conciliator`( p_franchine_conciliator JSON ,out p_return boolean ,out p_code integer ,out p_message varbinary(5000), out p_front_franchise_conciliator_id integer)
begin   

    set p_return = true;
    set p_code = 0;
    set p_message = "";
    
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator at Json request ! ");
    end if;

    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header at Json request ! ");
    end if;
    
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header.unity_identification') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header.unity_identification at Json request ! ");
    end if;

    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header.origin_system') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header.origin_system at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header.operation') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header.operation at Json request ! ");
    end if;
    
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header.front_franchise_conciliator_id') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header.front_franchise_conciliator_id at Json request ! ");
    else
        set p_front_franchise_conciliator_id = cast(json_extract(p_franchine_conciliator,'$.franchise_conciliator.header.front_franchise_conciliator_id') as unsigned);
    end if;
		
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header.issue_date') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header.issue_date at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.header.due_date') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.header.due_date at Json request ! ");
    end if;
		
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.receivable.erp_receivable_customer_identification') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.receivable.erp_receivable_customer_identification at Json request ! ");
    end if;  
        
       
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.receivable.gross_value') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.receivable.gross_value at Json request ! ");
    end if;

	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.full_name') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.full_name at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.type_person') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.type_person at Json request ! ");
    end if;
	
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.identification_financial_responsible') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.identification_financial_responsible at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.nationality_code') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.nationality_code at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.state') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.state at Json request ! ");
    end if;
    
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.city') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.city at Json request ! ");
    end if;
    
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.adress') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.adress at Json request ! ");
    end if;
    
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.adress_number') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.adress_number at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.adress_complement') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.adress_complement at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.district') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.district at Json request ! ");
    end if; 
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.postal_code') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.postal_code at Json request ! ");
    end if;
    
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.area_code') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.area_code at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.cellphone') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.cellphone at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.email') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.email at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.state_registration') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.state_registration at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.municipal_registration') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.municipal_registration at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.final_consumer') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.final_consumer at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.icms_contributor') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.icms_contributor at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.bank_number') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.bank_number at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.bank_branch') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.bank_branch at Json request ! ");
    end if;
    
    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.bank_account_number') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.bank_account_number at Json request ! ");
    end if;    


    if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.bank_account_owner_name') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.bank_account_owner_name at Json request ! ");
    end if;
    
	if json_contains_path(p_franchine_conciliator,'one','$.franchise_conciliator.supplier.bank_account_owner_identification') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node franchise_conciliator.supplier.bank_account_owner_identification at Json request ! ");
    end if;
    
end$$
DELIMITER ;