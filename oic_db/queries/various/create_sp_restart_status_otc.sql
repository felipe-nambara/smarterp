drop procedure if exists sp_restart_status_otc; 
delimiter //
create procedure sp_restart_status_otc ( in p_interval_seconds integer )

begin

declare done int;
declare v_message_text varchar(255);
declare v_keycontrol varchar(150);
declare v_created_at timestamp;
declare continue handler for not found set done=1;
declare exit handler for sqlexception 
begin
    get diagnostics condition 1  @v_message_text = message_text;
    select @v_message_text;
    rollback; 
end;

select concat("before: ",current_timestamp());

set @v_keycontrol 	:= concat_ws('_','sp_restart_status_otc');
set @v_created_at	:= current_timestamp;

if get_lock(@v_keycontrol,1) = 1 then 
	
    update order_to_cash otc 
	
    set otc.erp_invoice_customer_send_to_erp_at = null
    ,otc.erp_invoice_customer_returned_from_erp_at = null
    ,otc.erp_invoice_customer_status_transaction = 'waiting_to_be_process'
    ,otc.erp_invoice_customer_log = null
    
    where otc.erp_invoice_customer_status_transaction = 'being_processed'
    and timestampdiff(minute,otc.erp_invoice_customer_send_to_erp_at,current_timestamp()) >= p_interval_seconds;

    update order_to_cash otc 
	
    inner join receivable rec
    on rec.order_to_cash_id = otc.id
    and rec.erp_clustered_receivable_id is not null
    
    set otc.erp_receivable_sent_to_erp_at = null
    ,otc.erp_receivable_returned_from_erp_at = null
    ,otc.erp_receivable_status_transaction = 'clustered_receivable_created'
    ,otc.erp_receivable_log = null
    
    where otc.erp_receivable_status_transaction = 'being_processed'
    and timestampdiff(minute,otc.erp_receivable_sent_to_erp_at,current_timestamp()) >= p_interval_seconds;

    update order_to_cash otc 
	
    set otc.erp_invoice_send_to_erp_at = null
    ,otc.erp_invoice_returned_from_erp_at = null
    ,otc.erp_invoice_status_transaction = 'waiting_to_be_process'
    ,otc.erp_invoice_log = null
    
    where otc.erp_invoice_status_transaction = 'being_processed'
    and timestampdiff(minute,otc.erp_invoice_send_to_erp_at,current_timestamp()) >= p_interval_seconds;

    update order_to_cash otc 
	
    set otc.erp_receipt_send_to_erp_at = null
    ,otc.erp_receipt_returned_from_erp_at = null
    ,otc.erp_receipt_status_transaction = 'waiting_to_be_process'
    ,otc.erp_receipt_log = null
    
    where otc.erp_receipt_status_transaction = 'being_processed'
    and timestampdiff(minute,otc.erp_receipt_send_to_erp_at,current_timestamp()) >= p_interval_seconds;
    
    commit;
    
	do release_lock(@v_keycontrol);

else
 
	select concat('Procedure is already running in another thread: ',@v_keycontrol ) as log;
    
end if;

select concat("after: ",current_timestamp());

end;
//