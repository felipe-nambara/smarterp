set @json_request = cast(  '{
    "franchise_conciliator": {
      "header": {
        "country": "Mexico",
        "unity_identification": 123,
        "origin_system": "smartsystem",
        "operation": "franchise_conciliator",
        "front_franchise_conciliator_id": 15677134,
        "issue_date": "2020-01-15",
        "due_date": "2020-01-20"  
      },
      "receivable": {
        "erp_receivable_customer_identification": "00360305000104",
        "contract_number": "1040380465",
        "credit_card_brand": "MASTER",
        "gross_value": 191.58
      },
      "supplier": {
        "full_name": "M14 ACADEMIA DE GINASTICA LTDA",
        "type_person": "legal_person",
        "identification_financial_responsible": "912343519870",
        "nationality_code": "BR",
        "state": "SP",
        "city": "SAO JOSE DO RIO PRETO",
        "adress": "AV ALFREDO ANTONIO DE OLIVEIRA",
        "adress_number": 2077,
        "adress_complement": null,
        "district": "JARDIM MARAJO",
        "postal_code": "231231",
        "area_code": "11",
        "cellphone": "912345678",
        "email": "felipe.nambara@bioritmo.com.br",
        "state_registration": "ISENTO",
        "municipal_registration": null,
        "final_consumer": "yes",
        "icms_contributor": "no",
        "bank_number": "341",
        "bank_branch": "5290",
        "bank_branch_digit": "1",
        "bank_account_number": "29460",
        "bank_account_number_digit": "1",
        "bank_account_owner_name": "M14 ACADEMIA DE GINASTICA LTDA",
        "bank_account_owner_identification": "32139383000170"
      }
    }
  }' as json );

call sp_insert_franchise_conciliator( @json_request ,@p_return ,   @p_code ,@p_message, @p_front_franchise_conciliator_id); 
                            
select @p_return as retorno ,@p_code,cast(@p_message as char),@p_front_franchise_conciliator_id;