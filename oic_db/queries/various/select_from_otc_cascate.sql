select * from order_to_cash where operation = 'smartfin_fee' and id = 1055438;
select * from invoice_customer where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' and id = 1055438)  ;
select * from receivable where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' and id = 1055438)  ;
select * from invoice where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' and id = 1055438)  ;
select * from invoice_items where id_invoice in ( select id from invoice where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee'  and id = 1055438) ) ;
select * from payable where fee_smartfin_otc_id and fee_smartfin_otc_id = 1055438;	