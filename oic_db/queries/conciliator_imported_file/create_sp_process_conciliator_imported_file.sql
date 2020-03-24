DROP PROCEDURE IF EXISTS sp_process_conciliator_imported_file; 
DELIMITER //
CREATE PROCEDURE sp_process_conciliator_imported_file ( in p_limit_transactions integer )
	
BEGIN

declare done int;

declare continue handler for not found set done=1;

declare exit handler for sqlexception 
begin    	
    get diagnostics condition 1  @v_message_text = message_text;
    select @v_message_text;
    rollback;    
end;

set @v_keycontrol 	:= 'process_conciliator_imported_file';

if get_lock(@v_keycontrol,1) = 1  then 

	start transaction;
    
	insert into conciliated_payed_receivable
				(country,
				conciliator_id,
				conciliation_type,
				conciliation_description,
				transaction_type,
				contract_number,
				credit_card_brand,
				truncated_credit_card,
				current_credit_card_installment,
				total_credit_card_installment,
				nsu,
				authorization_code,
				payment_lot,
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
				bank_number,
				bank_branch,
				bank_account,
				conciliator_filename,
				acquirer_bank_filename)

	select 
		cif.country,
		cif.conciliator_id,
		cif.conciliation_type,
		cif.conciliation_description,
		cif.transaction_type,
		cif.contract_number,
		cif.credit_card_brand,
		cif.truncated_credit_card,
		cif.current_credit_card_installment,
		cif.total_credit_card_installment,
		cif.nsu,
		cif.authorization_code,
		cif.payment_lot,
		cif.price_list_value,
		cif.gross_value,
		cif.net_value,
		cif.interest_value,
		cif.administration_tax_percentage,
		cif.administration_tax_value,
		cif.antecipation_tax_percentage,
		cif.antecipation_tax_value,
		cif.billing_date,
		cif.credit_date,
		cif.bank_number,
		cif.bank_branch,
		cif.bank_account,
		cif.conciliator_filename,
		cif.acquirer_bank_filename
	from conciliator_imported_file cif

	inner join receivable rec
	on rec.conciliator_id = cif.conciliator_id
	and rec.converted_smartfin <> 'yes'

	where cif.process_status = 'waiting_to_be_process'
	and cif.conciliation_type = 'PCV'
    
    limit p_limit_transactions

	on duplicate key  update conciliated_payed_receivable.conciliator_id = conciliated_payed_receivable.conciliator_id;

	update conciliator_imported_file 

	inner join conciliated_payed_receivable 
	on conciliated_payed_receivable.conciliator_id = conciliator_imported_file.conciliator_id

	set conciliator_imported_file.process_status = 'sent_to_destination'
	,conciliator_imported_file.process_status_at = current_timestamp()
	,conciliator_imported_file.process_log = 'This PCV transaction was sent or updated at the conciliated_payed_receivable table !'
			
	where conciliator_imported_file.process_status = 'waiting_to_be_process'
	and conciliator_imported_file.conciliation_type = 'PCV';    

	update conciliator_imported_file 

	left join receivable 
	on receivable.conciliator_id = conciliator_imported_file.conciliator_id
	and receivable.converted_smartfin <> 'yes'

	set conciliator_imported_file.process_status = 'errror_with_relation_table'
	,conciliator_imported_file.process_status_at = current_timestamp()
	,conciliator_imported_file.process_log = 'This PCV transaction doesnt have relation to the Receivable table (conciliator_id) !'
			
	where receivable.id is null
	and conciliator_imported_file.process_status = 'waiting_to_be_process'
	and conciliator_imported_file.conciliation_type = 'PCV';   

	insert into chargeback
				(country,
				chargeback_acquirer_label,
				conciliator_id,
				conciliation_type,
				conciliation_description,
				transaction_type,
				contract_number,
				credit_card_brand,
				truncated_credit_card,
				current_credit_card_installment,
				total_credit_card_installment,
				nsu,
				authorization_code,
				payment_lot,
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
				bank_number,
				bank_branch,
				bank_account,
				conciliator_filename,
				acquirer_bank_filename)

	select 
		cif.country,
		cif.chargeback_acquirer_label,
		cif.conciliator_id,
		cif.conciliation_type,
		cif.conciliation_description,
		cif.transaction_type,
		cif.contract_number,
		cif.credit_card_brand,
		cif.truncated_credit_card,
		cif.current_credit_card_installment,
		cif.total_credit_card_installment,
		cif.nsu,
		cif.authorization_code,
		cif.payment_lot,
		if(cif.price_list_value<0,cif.price_list_value*-1,cif.price_list_value),
		if(cif.gross_value<0,cif.gross_value*-1,cif.gross_value),
		if(cif.net_value<0,cif.net_value*-1,cif.net_value),
		if(cif.interest_value<0,cif.interest_value*-1,cif.interest_value),
		if(cif.administration_tax_percentage<0,cif.administration_tax_percentage*-1,cif.administration_tax_percentage),
		if(cif.administration_tax_value<0,cif.administration_tax_value*-1,cif.administration_tax_value),
		if(cif.antecipation_tax_percentage<0,cif.antecipation_tax_percentage*-1,cif.antecipation_tax_percentage),
		if(cif.antecipation_tax_value<0,cif.antecipation_tax_value*-1,cif.antecipation_tax_value),
		cif.billing_date,
		cif.credit_date,
		cif.bank_number,
		cif.bank_branch,
		cif.bank_account,
		cif.conciliator_filename,
		cif.acquirer_bank_filename
	from conciliator_imported_file cif

	inner join receivable rec
	on rec.conciliator_id = cif.conciliator_id
	and rec.converted_smartfin <> 'yes'

	where cif.process_status = 'waiting_to_be_process'
	and cif.conciliation_type = 'CHBK'         
	
    limit p_limit_transactions
    
	on duplicate key  update chargeback.conciliator_id = chargeback.conciliator_id;

	update conciliator_imported_file 

	inner join chargeback 
	on chargeback.conciliator_id = conciliator_imported_file.conciliator_id

	set conciliator_imported_file.process_status = 'sent_to_destination'
	,conciliator_imported_file.process_status_at = current_timestamp()
	,conciliator_imported_file.process_log = 'This CHBK transaction was sent or updated at the conciliated_payed_receivable table !'
			
	where conciliator_imported_file.process_status = 'waiting_to_be_process'
	and conciliator_imported_file.conciliation_type = 'CHBK';    

	update conciliator_imported_file 

	left join receivable 
	on receivable.conciliator_id = conciliator_imported_file.conciliator_id
	and receivable.converted_smartfin <> 'yes'

	set conciliator_imported_file.process_status = 'errror_with_relation_table'
	,conciliator_imported_file.process_status_at = current_timestamp()
	,conciliator_imported_file.process_log = 'This CHBK transaction doesnt have relation to the Receivable table (conciliator_id) !'
			
	where receivable.id is null
	and conciliator_imported_file.process_status = 'waiting_to_be_process'
	and conciliator_imported_file.conciliation_type = 'CHBK';  


	update conciliator_imported_file 

	set conciliator_imported_file.process_status = 'conciliation_type_not_implemented'
	,conciliator_imported_file.process_status_at = current_timestamp()
	,conciliator_imported_file.process_log = concat('This Conciliation Type ',conciliator_imported_file.conciliation_type,' is not implemented yet !')
			
	where conciliator_imported_file.process_status = 'waiting_to_be_process'
	and conciliator_imported_file.conciliation_type not in ('PCV','CHBK');      
    
    commit;
    
    do release_lock(@v_keycontrol);    
    
else 
	
    select concat('Procedure is already running in another thread: ',@v_keycontrol ) as log;
    
end if;

end;
//

DELIMITER $$