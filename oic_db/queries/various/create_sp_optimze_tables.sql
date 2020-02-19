drop procedure if exists sp_optimze_tables;

delimiter $$
create procedure `sp_optimze_tables`( )
begin

optimize table addon_from_to;
optimize table addon_from_to_version;
optimize table chargeback;
optimize table chargeback_erp_configurations;
optimize table clustered_chargeback;
optimize table clustered_receivable;
optimize table conciliated_payed_receivable;
optimize table conciliator_imported_file;
optimize table control_clustered_receivable;
optimize table customer;
optimize table department_from_to;
optimize table department_from_to_version;
optimize table integration_clustered_receivable;
optimize table invoice;
optimize table invoice_customer;
optimize table invoice_customer_comparation;
optimize table invoice_customer_erp_configurations;
optimize table invoice_erp_configurations;
optimize table invoice_items;
optimize table natural_account_from_to;
optimize table natural_account_from_to_version;
optimize table order_to_cash;
optimize table organization_from_to;
optimize table organization_from_to_version;
optimize table payable;
optimize table payable_erp_configurations;
optimize table payment_terms_from_to;
optimize table payment_terms_from_to_version;
optimize table plan_from_to;
optimize table plan_from_to_version;
optimize table product_from_to;
optimize table product_from_to_version;
optimize table receipt_from_to;
optimize table receipt_from_to_version;
optimize table receivable;
optimize table receivable_erp_configurations;
optimize table refund;
optimize table refund_erp_configurations;
optimize table refund_items;
optimize table supplier;

end$$
delimiter ;
