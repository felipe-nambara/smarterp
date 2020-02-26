delete from invoice_items where id_invoice in ( select id from invoice where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee'  ) ) ;
delete from invoice where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' )  ;
delete from payable where receivable_id in ( select id from receivable where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' ) ) ;
delete from supplier where identification_financial_responsible in ( select supplier_identification from payable where receivable_id in ( select id from receivable where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee'  ) ) ) ;
delete from receivable where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' )  ;
delete from invoice_customer where order_to_cash_id in (select id from order_to_cash where operation = 'smartfin_fee' )  ;
delete from order_to_cash where operation = 'smartfin_fee' ;