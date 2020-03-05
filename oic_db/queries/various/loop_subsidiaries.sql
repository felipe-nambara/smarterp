select
	organization_from_to_version.erp_business_unit
  , organization_from_to_version.erp_legal_entity
  , organization_from_to_version.erp_subsidiary
  , invoice_erp_configurations.erp_source_name
from
	organization_from_to
	inner join
		organization_from_to_version
		on
			organization_from_to_version.organization_from_to_unity_identification = organization_from_to.unity_identification
			and organization_from_to_version.created_at                            =
			(
				select
					max(organization_from_to_version_v2.created_at) as created_at
				from
					organization_from_to_version organization_from_to_version_v2
				where
					organization_from_to_version.organization_from_to_unity_identification = organization_from_to_version_v2.organization_from_to_unity_identification
			)
			inner join
				invoice_erp_configurations
				on
					invoice_erp_configurations.erp_business_unit        = organization_from_to_version.erp_business_unit
					and invoice_erp_configurations.erp_legal_entity     = organization_from_to_version.erp_legal_entity
					and invoice_erp_configurations.erp_subsidiary       = organization_from_to_version.erp_subsidiary
					and invoice_erp_configurations.erp_type_transaction = 'NF_VENDA_DE_PLANO'
		where
			organization_from_to_version.erp_business_unit not in ( 'BR02 - SMARTFIN'
																 ,'BR03 - FRANQUEADORA'
																 ,'BR04 - TOTALPASS' )
			and organization_from_to_version.erp_subsidiary like 'BR01029%' -- = 'BR010292'
		order by
			1
		  , 2
		  , 3