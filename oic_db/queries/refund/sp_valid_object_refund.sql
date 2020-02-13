drop procedure if exists sp_valid_object_refund;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `sp_valid_object_refund`( p_refund JSON ,out p_return boolean ,out p_code integer ,out p_message varbinary(5000), out p_front_refund_id integer)
begin

    set p_return = true;
    set p_code = 0;
    set p_message = "";
    
    if json_contains_path(p_refund,'one','$.refund') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund at Json request ! ");
    end if;

    if json_contains_path(p_refund,'one','$.refund.header') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header at Json request ! ");
    end if;

    if json_contains_path(p_refund,'one','$.refund.header.front_refund_id') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.front_refund_id at Json request ! ");
    else
        set p_front_refund_id = cast(json_extract(p_refund,'$.refund.header.front_refund_id') as unsigned);
    end if; 
    
    if json_contains_path(p_refund,'one','$.refund.header.country') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.country at Json request ! ");
    end if;
    
    if json_contains_path(p_refund,'one','$.refund.header.unity_identification') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.unity_identification at Json request ! ");
    end if;        
    
    if json_contains_path(p_refund,'one','$.refund.header.origin_system') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.origin_system at Json request ! ");
    end if;            

    if json_contains_path(p_refund,'one','$.refund.header.refund_requester_name') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.refund_requester_name at Json request ! ");
    end if;                    
    
    
    if json_contains_path(p_refund,'one','$.refund.header.refund_requester_identification') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.refund_requester_identification at Json request ! ");
		
	else
		set @p_refund_requester_identification = cast(json_extract(p_refund,'$.refund.header.refund_requester_identification') as unsigned);
		if @p_refund_requester_identification = "" then
			set p_return = false;
			set p_code = 1;
			set p_message = concat(p_message,"Missing node refund.header.refund_requester_identification at Json request ! ");
		end if;
    end if;       
    
    if json_contains_path(p_refund,'one','$.refund.header.issue_date') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.issue_date at Json request ! ");
    end if;

    if json_contains_path(p_refund,'one','$.refund.header.due_date') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.due_date at Json request ! ");
    end if;
    
        if json_contains_path(p_refund,'one','$.refund.header.refund_value') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.refund_value at Json request ! ");
    end if;
    
        if json_contains_path(p_refund,'one','$.refund.header.bank_number') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.bank_number at Json request ! ");
    end if;
    
        if json_contains_path(p_refund,'one','$.refund.header.bank_branch') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.bank_branch at Json request ! ");
    end if;
    
        if json_contains_path(p_refund,'one','$.refund.header.bank_account_number') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.bank_account_number at Json request ! ");
    end if;

        if json_contains_path(p_refund,'one','$.refund.header.bank_account_owner_name') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.bank_account_owner_name at Json request ! ");
    end if;
    
        if json_contains_path(p_refund,'one','$.refund.header.bank_account_owner_identification') = 0 then
        set p_return = false;
        set p_code = 1;
        set p_message = concat(p_message,"Missing node refund.header.bank_account_owner_identification at Json request ! ");
    end if;
    
    
end$$
DELIMITER ;
