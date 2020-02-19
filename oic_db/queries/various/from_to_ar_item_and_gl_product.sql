select 
	pftv.* 
from product_from_to_version pftv

where pftv.id = (	select 
						max(pftv_v2.id)
					from product_from_to_version pftv_v2 
					where pftv_v2.product_from_to_origin_system =  pftv.product_from_to_origin_system
					and pftv_v2.product_from_to_operation =  pftv.product_from_to_operation
					and pftv_v2.product_from_to_front_product_id =  pftv.product_from_to_front_product_id );
                    
select 
	pftv.* 
from plan_from_to_version pftv

where pftv.id = (	select 
						max(pftv_v2.id)
					from plan_from_to_version pftv_v2 
					where pftv_v2.plan_from_to_origin_system =  pftv.plan_from_to_origin_system
					and pftv_v2.plan_from_to_operation =  pftv.plan_from_to_operation
					and pftv_v2.plan_from_to_front_plan_id =  pftv.plan_from_to_front_plan_id );
                    
                    
select 
	aftv.* 
from addon_from_to_version aftv

where aftv.id = (	select 
						max(aftv_v2.id)
					from addon_from_to_version aftv_v2 
					where aftv_v2.addon_from_to_origin_system =  aftv.addon_from_to_origin_system
					and aftv_v2.addon_from_to_operation = aftv.addon_from_to_operation
					and aftv_v2.addon_from_to_front_addon_id = aftv.addon_from_to_front_addon_id );