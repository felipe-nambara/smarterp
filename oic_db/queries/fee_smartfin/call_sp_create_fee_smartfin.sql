call sp_create_fee_smartfin('Brazil',date_add(current_date(), interval -60 day),current_date());
-- update payable set oic_smartfin_status_transaction = 'waiting_to_be_process', fee_smartfin_otc_id = null
