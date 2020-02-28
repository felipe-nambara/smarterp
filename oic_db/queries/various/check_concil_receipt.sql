select 
cpr.conciliator_id
,rec.erp_clustered_receivable_id
,rec.gross_value as rec_gross_value
,rec.net_value as rec_net_value
,rec.administration_tax_value as rec_administration_tax_value
,rec.interest_value as rec_interest_value
,cpr.gross_value as cpr_gross_value
,cpr.net_value as cpr_net_value
,cpr.interest_value as cpr_interest_value
,cpr.administration_tax_value as cpr_administration_tax_value
from conciliated_payed_receivable cpr

inner join receivable rec
on rec.conciliator_id = cpr.conciliator_id
and rec.erp_clustered_receivable_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.erp_clustered_receivable_customer_id is not null -- Considerar somente os receivables que já foram convertidos em clustered_receivable, ou seja, que já foram aglutinados
and rec.converted_smartfin <> 'yes'

where rec.erp_clustered_receivable_id = 244355;