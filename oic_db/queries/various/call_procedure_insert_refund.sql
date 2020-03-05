set @json_request = cast( '{
    "refund": {
      "header": {
        "country": "Brazil",
        "unity_identification": 1,
        "origin_system": "smartsystem",
        "front_refund_id": 123545,
        "refund_requester_name": "João da Silva",
        "refund_requester_identification": 12365478984,
        "issue_date": "2019-12-26",
        "due_date": "2019-12-30",
        "refund_value": 999.9,
        "bank_number": "341",
        "bank_branch": "5290",
        "bank_branch_digit": "1", --
        "bank_account_number": "29460",
        "bank_account_number_digit": "1", --
        "bank_account_owner_name": "Maria da Silva",
        "bank_account_owner_identification": "32165498778"
      },
      "refund_items": [
        {
          "front_id": 1354844,
          "refund_item_value": 333.33,
          "billing_date": "2019-08-10"
        },
        {
          "front_id": 1356848,
          "refund_item_value": 333.33,
          "billing_date": "2019-09-10"
        },
        {
          "front_id": 1556847,
          "refund_item_value": 333.33,
          "billing_date": "2019-10-10"
        }
      ]
    }' as json );

call sp_insert_refund( @json_request ,@p_return ,	@p_code ,@p_message, @p_front_refund_id); 
                            
select @p_return,@p_code,cast(@p_message as char),@p_front_refund_id;

-- Missing node otc.header.erp_receivable_customer_identification at Json request ! Check the documentation https://app.swaggerhub.com/apis-docs/Smartfit/OrderToCash/1.0.0