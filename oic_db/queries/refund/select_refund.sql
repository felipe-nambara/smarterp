select   	
     ref.erp_business_unit
    ,ref.erp_legal_entity    
    ,ref.erp_subsidiary
    ,ref.front_refund_id -- id unico
    ,ref.refund_value    
    ,ref.origin_system
    ,ref.front_refund_id
    ,recg.erp_source_name
    ,recg.erp_type_transaction
    ,recg.erp_set_of_books_id
    ,recg.erp_currency_code
    ,recg.erp_interface_line_context
    ,recg.erp_memo_line
	,recg.erp_payments_terms
	,recg.erp_payment_code
    ,recg.erp_attribute_category
    ,ref.refund_requester_identification
    ,ref.refund_requester_name
    ,if(month(ref.issue_date)=month(current_date()),ref.issue_date,current_date()) as erp_trx_date
    ,if(month(ref.issue_date)=month(current_date()),ref.issue_date,current_date()) as erp_gl_date
from refund ref

left join refund_erp_configurations recg
on  recg.country = ref.country
and recg.origin_system = ref.origin_system
and recg.operation = ref.operation

where ref.country = 'Brazil' -- Integração em paralalo por operação do país
and ref.erp_subsidiary = 'BR010001' -- Filtro por filial (loop automático)
and ref.origin_system = 'smartsystem' -- Integração em paralalo por origem (SmartFit, BioRitmo, etc...)
and ref.operation = 'person_plan' -- Neste caso filtrar somente person_plan, pois a operação de refund só ocorre para os planos de alunos
and ref.id = 1528
and ref.erp_refund_status_transaction = 'waiting_to_be_process';