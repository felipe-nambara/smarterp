"use strict";

const yup = require("yup");
const config = require("config");
const mysql = require("serverless-mysql")({
  config: {
    host: config.get("RDS_HOST"),
    database: config.get("RDS_DBNAME"),
    user: config.get("RDS_USER"),
    password: config.get("RDS_PASSWORD")
  },
  onError: (e) => {
    console.log('MYSQL Error:' + e);
  },
  onConnectError: (e) => { console.log('Connect Error: ' + e.code) },
  onRetry: (err,retries,delay,type) => { console.log('RETRY') }
});

async function gravaOTCnobanco(otc) {
  const { header, invoice_customer, receivable, invoice, orgfromtoversion, productfromtoversion, planfromtoversion } = otc.otc;
  let order_to_cash_id = 0;
  let inserts = await mysql
    .transaction()
    .query(
      "INSERT INTO order_to_cash(country,unity_identification,origin_system,operation,minifactu_id,conciliator_id,fin_id,front_id,erp_business_unit,erp_legal_entity,erp_subsidiary,acronym,to_generate_customer,to_generate_receivable,to_generate_invoice) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
      [
        header.country,
        header.unity_identification,
        header.origin_system,
        header.operation,
        header.minifactu_id,
        header.conciliator_id,
        header.fin_id,
        header.front_id,
        orgfromtoversion[0].erp_business_unit,
        orgfromtoversion[0].erp_legal_entity,
        orgfromtoversion[0].erp_subsidiary,
        orgfromtoversion[0].acronym,
        orgfromtoversion[0].to_generate_customer,
        orgfromtoversion[0].to_generate_receivable,
        orgfromtoversion[0].to_generate_invoice
      ]
    )
    .query((r) => {
      global.order_to_cash_id = r.insertId;
      return [
        "INSERT INTO receivable(order_to_cash_id,is_smartfin,transaction_type,contract_number,credit_card_brand,truncated_credit_card,current_credit_card_installment,total_credit_card_installment,nsu,authorization_code,price_list_value,gross_value,net_value,interest_value,administration_tax_percentage,administration_tax_value,billing_date,credit_date,conciliator_filename,acquirer_bank_filename,registration_gym_student,fullname_gym_student,identification_gym_student) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          global.order_to_cash_id,
          receivable.is_smartfin,
          receivable.transaction_type,
          receivable.contract_number,
          receivable.credit_card_brand,
          receivable.truncated_credit_card,
          receivable.current_credit_card_installment,
          receivable.total_credit_card_installment,
          receivable.nsu,
          receivable.authorization_code,
          receivable.price_list_value,
          receivable.gross_value,
          receivable.net_value,
          receivable.interest_value,
          receivable.administration_tax_percentage,
          receivable.administration_tax_value,
          receivable.billing_date,
          receivable.credit_date,
          receivable.conciliator_filename,
          receivable.acquirer_bank_filename,
          receivable.registration_gym_student,
          receivable.fullname_gym_student,
          receivable.identification_gym_student
        ]
      ];
    })
    .query((r) => {
      return [
      "INSERT INTO invoice_customer(order_to_cash_id,country,full_name,type_person,identification_financial_responsible,nationality_code,state,city,adress,adress_complement,district,postal_code,area_code,cellphone,email,state_registration,federal_registration,final_consumer,icms_contributor) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",
        [
          global.order_to_cash_id,
          header.country,
          invoice_customer.full_name,
          invoice_customer.type_person,
          invoice_customer.identification_financial_responsible,
          invoice_customer.nationality_code,
          invoice_customer.state,
          invoice_customer.city,
          invoice_customer.adress,
          invoice_customer.adress_complement,
          invoice_customer.district,
          invoice_customer.postal_code,
          invoice_customer.area_code,
          invoice_customer.cellphone,
          invoice_customer.email,
          invoice_customer.state_registration,
          invoice_customer.federal_registration,
          invoice_customer.final_consumer,
          invoice_customer.icms_contributor
        ]
      ]
    })
    .query((r) => {
      return [
      "INSERT INTO invoice(order_to_cash_id,transaction_type,is_overdue_recovery) VALUES (?,?,?);",
        [
          global.order_to_cash_id,
          invoice.transaction_type,
          invoice.is_overdue_recovery
        ]
      ]
    })
    .query((r) => {
      for (let indexit = 0; indexit < invoice.invoice_items.length; indexit++) {
        const it = invoice.invoice_items[indexit];
        
        return [
          "INSERT INTO invoice_items(id_invoice,front_product_id,front_plan_id,front_addon_id,quantity,list_price,sale_price) VALUES (?,?,?,?,?,?,?);",
            [
              r.insertId,
              it.front_product_id,
              it.front_plan_id,
              it.front_addon_id,
              it.quantity,
              it.list_price,
              it.sale_price
            ]
          ]
      }
    })
    .rollback(e => {
      let status = 422;
      let message = "Business error - " + e;
      console.log(`[${status}] - ${message}`);
      return false;
    })
    .commit();
    return true;
}

module.exports = app => {
  console.log('Running app on env:' + config.get("ENV") + ' on version:' + config.get("VERSION"));

  const schema = yup.object().shape({
    otc: yup.object({
      header: yup.object({
        country: yup.string().required(),
        unity_identification: yup.string().required(),
        origin_system: yup.string().required(),
        operation: yup.string().required(),
        minifactu_id: yup.number().required(),
        conciliator_id: yup.string().required(),
        fin_id: yup.string().required(),
        front_id: yup.number().required()
      }),
      invoice_customer: yup.object({
        full_name: yup.string().required(),
        type_person: yup.string().required(),
        identification_financial_responsible: yup.string().required(),
        nationality_code: yup.string().required(),
        state: yup.string().required(),
        city: yup.string().required(),
        adress: yup.string().required(),
        /*adress_complement: yup.string(), */
        district: yup.string().required(),
        postal_code: yup.string().required(),
        area_code: yup.string().required(),
        cellphone: yup.string().required(),
        email: yup
          .string()
          .email()
          .required(),
        /*state_registration: yup.string(),
            federal_registration: yup.string(),*/
        final_consumer: yup.string().required(),
        icms_contributor: yup.string().required()
      }),
      receivable: yup.object({
        is_smartfin: yup.string().required(),
        transaction_type: yup.string().required(),
        contract_number: yup.string().required(),
        credit_card_brand: yup.string().required(),
        truncated_credit_card: yup.string().required(),
        current_credit_card_installment: yup.number().required(),
        total_credit_card_installment: yup.string().required(),
        nsu: yup.string().required(),
        authorization_code: yup.string().required(),
        price_list_value: yup.string().required(),
        gross_value: yup.string().required(),
        net_value: yup.string().required(),
        interest_value: yup.string().required(),
        administration_tax_percentage: yup.string().required(),
        administration_tax_value: yup.string().required(),
        billing_date: yup.string().required(),
        credit_date: yup.string().required(),
        conciliator_filename: yup.string().required(),
        acquirer_bank_filename: yup.string().required(),
        registration_gym_student: yup.string().required(),
        fullname_gym_student: yup.string().required(),
        identification_gym_student: yup.string().required()
      }),
      invoice: yup.object({
        transaction_type: yup.string().required(),
        is_overdue_recovery: yup.string().required(),
        invoice_items: yup.object({
          invoice_items: yup.array()
        })
      })
    })
    
  });

  app.get("/transactions", (req, res) => {
    res.status(200).send({ message: "listing transactions" });
  });

  app.post("/transactions", async (req, res) => {
    const data = req.body;
    let returned = {};
    returned.success = [];
    returned.error = [];

    for (let index = 0; index < data.length; index++) {
      const otc = data[index];

      if (schema.isValidSync(otc)) {
          const { header, invoice_customer, receivable, invoice } = otc.otc;

          if (!header.minifactu_id || header.minifactu_id == "") {
            var message = "Missing node otc.header.minifactu_id at Json request !";
            var return_code = 1;
            console.log(message);
            returned.error.push({ message: message, return_code: return_code, type: "error", otc: otc });
          } else {
            const minifactu = await mysql.query('SELECT * FROM order_to_cash WHERE minifactu_id = ?', [header.minifactu_id]);
            console.log(minifactu);
            otc.otc.minifactu = minifactu; 
            if (minifactu.length > 0) {
              if (minifactu.erp_receivable_status_transaction == "error_at_trying_to_process" || minifactu.erp_receivable_status_transaction == "error_trying_to_create_at_erp" || minifactu.erp_invoice_status_transaction == "error_trying_to_create_at_erp" || minifactu.erp_invoice_customer_status_transaction == "error_trying_to_create_at_erp")  {
                  console.log('The order to cash transaction was already added to oic_db - ' + minifactu);
                  returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 6, message: "The order to cash transaction was already added to oic_db !", order_to_cash: minifactu})
                  continue;
              }
              else {
                const orgfromtoversion = await mysql.query('SELECT * FROM organization_from_to_version WHERE organization_from_to_unity_identification = ? ORDER BY created_at DESC', [header.unity_identification]);
                otc.otc.orgfromtoversion = orgfromtoversion;
                if (orgfromtoversion.length > 0) {
                  if (header.origin_system == "smartsystem" || header.origin_system == "racesystem" || header.origin_system == "nossystem") {
                    if (invoice.invoice_items.invoice_items[0].front_product_id != null && invoice.invoice_items.invoice_items[0].front_plan_id != null ) {
                      const productfromtoversion = await mysql.query('SELECT * FROM product_from_to_version WHERE country = ? AND product_from_to_origin_system = ? AND product_from_to_operation = ? AND product_from_to_front_product_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_product_id]);
                      otc.otc.productfromtoversion = productfromtoversion;
                      if (productfromtoversion.length > 0) {
                        const planfromtoversion = await mysql.query('SELECT * FROM plan_from_to_version WHERE country = ? AND plan_from_to_origin_system = ? AND plan_from_to_operation = ? AND plan_from_to_front_plan_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_plan_id]);
                        otc.otc.planfromtoversion = planfromtoversion;
                        if (planfromtoversion.length < 1) {
                          returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 4, message: "The front_plan_id " +  invoice.invoice_items.invoice_items[0].front_plan_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                          continue;
                        } 
                        //do transaction
                        let returnPersistent = await gravaOTCnobanco(otc);
                        if (returnPersistent) {
                          delete otc.otc.minifactu;
                          delete otc.otc.orgfromtoversion;
                          delete otc.otc.productfromtoversion;
                          delete otc.otc.planfromtoversion;
                          console.log(header.minifactu_id + ' - db insert success');
                          returned.success.push({ minifactu_id: header.minifactu_id, type: "success", return_code: 1, message: "The order to cash transaction was added to oic_db successfully!", order_to_cash: otc})
                        } else {
                          console.log(header.minifactu_id + ' - db insert fail');
                          returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 99, message: "Error on database persistance! Please check logs!", order_to_cash: otc})
                          throw new Error('Error on database persistance! Please check logs');
                        }
                        //do transaction
                      } else {
                        returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 3, message: "The front_product_id " +  invoice.invoice_items.invoice_items[0].front_product_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                        continue;
                      }
                    } else {
                      returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 7, message: "Order to cash transactions from " +  header.origin_system + " must have front_product_id and front_plan_id simultaneously or only front_addon_id filled at invoice_items", order_to_cash: null})
                      continue;
                    }

                    if (invoice.invoice_items.invoice_items[0].front_addon_id != null) {
                      const addonfromtoversion = await mysql.query('SELECT * FROM addon_from_to_version WHERE country = ? AND addon_from_to_origin_system = ? AND addon_from_to_operation = ? AND addon_from_to_front_addon_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_addon_id]);
                      otc.otc.addonfromtoversion = addonfromtoversion;
                        if (planfromtoversion.length < 1) {
                          returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 5, message: "The front_addon_id " +  invoice.invoice_items.invoice_items[0].front_addon_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                          continue;
                        } 
                    }
                  } else if (header.origin_system == "biosystem") {
                    if (invoice.invoice_items.invoice_items[0].front_product_id != null) {
                      const productfromtoversion = await mysql.query('SELECT * FROM product_from_to_version WHERE country = ? AND product_from_to_origin_system = ? AND product_from_to_operation = ? AND product_from_to_front_product_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_product_id]);
                      otc.otc.productfromtoversion = productfromtoversion;
                      if (productfromtoversion.length > 0) {
                        const planfromtoversion = await mysql.query('SELECT * FROM plan_from_to_version WHERE country = ? AND plan_from_to_origin_system = ? AND plan_from_to_operation = ? AND plan_from_to_front_plan_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_plan_id]);
                        otc.otc.planfromtoversion = planfromtoversion;
                        if (planfromtoversion.length < 1) {
                          returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 4, message: "The front_plan_id " +  invoice.invoice_items.invoice_items[0].front_plan_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                          continue;
                        } 
                        //do transaction
                        let returnPersistent = await gravaOTCnobanco(otc);
                        if (returnPersistent) {
                          delete otc.otc.minifactu;
                          delete otc.otc.orgfromtoversion;
                          delete otc.otc.productfromtoversion;
                          delete otc.otc.planfromtoversion;
                          console.log(header.minifactu_id + ' - db insert success');
                          returned.success.push({ minifactu_id: header.minifactu_id, type: "success", return_code: 1, message: "The order to cash transaction was added to oic_db successfully!", order_to_cash: otc})
                        } else {
                          console.log(header.minifactu_id + ' - db insert fail');
                          returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 99, message: "Error on database persistance! Please check logs!", order_to_cash: otc})
                          throw new Error('Error on database persistance! Please check logs');
                        }
                        //do transaction
                      } else {
                        returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 3, message: "The front_product_id " +  invoice.invoice_items.invoice_items[0].front_product_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                        continue;
                      }
                    } else {
                      returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 8, message: "Order to cash transactions from " +  header.origin_system + " must have front_product_id and front_plan_id simultaneously or only front_addon_id filled at invoice_items", order_to_cash: null})
                      continue;
                    }
                  } else if (invoice.invoice_items.invoice_items[0].front_product_id != null) {
                    const productfromtoversion = await mysql.query('SELECT * FROM product_from_to_version WHERE country = ? AND product_from_to_origin_system = ? AND product_from_to_operation = ? AND product_from_to_front_product_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_product_id]);
                    otc.otc.productfromtoversion = productfromtoversion;
                    if (productfromtoversion.length > 0) {
                      const planfromtoversion = await mysql.query('SELECT * FROM plan_from_to_version WHERE country = ? AND plan_from_to_origin_system = ? AND plan_from_to_operation = ? AND plan_from_to_front_plan_id = ? ORDER BY created_at DESC', [header.country, header.origin_system, header.operation, invoice.invoice_items.invoice_items[0].front_plan_id]);
                      otc.otc.planfromtoversion = planfromtoversion;
                      if (planfromtoversion.length < 1) {
                        returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 4, message: "The front_plan_id " +  invoice.invoice_items.invoice_items[0].front_plan_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                        continue;
                      } 
                      //do transaction
                      let returnPersistent = await gravaOTCnobanco(otc);
                      if (returnPersistent) {
                        delete otc.otc.minifactu;
                        delete otc.otc.orgfromtoversion;
                        delete otc.otc.productfromtoversion;
                        delete otc.otc.planfromtoversion;
                        console.log(header.minifactu_id + ' - db insert success');
                        returned.success.push({ minifactu_id: header.minifactu_id, type: "success", return_code: 1, message: "The order to cash transaction was added to oic_db successfully!", order_to_cash: otc})
                      } else {
                        console.log(header.minifactu_id + ' - db insert fail');
                        returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 99, message: "Error on database persistance! Please check logs!", order_to_cash: otc})
                        throw new Error('Error on database persistance! Please check logs');
                      }
                      //do transaction
                    } else {
                      returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 3, message: "The front_product_id " +  invoice.invoice_items.invoice_items[0].front_product_id + " sent doesn't exist at oic_db for " + header.origin_system + " and " + header.operation + ". Please talk to ERP Team !", order_to_cash: null})
                      continue;
                    }
                  } else {
                    returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 9, message: "Order to cash transactions from " +  header.origin_system + " must have front_product_id and front_plan_id simultaneously or only front_addon_id filled at invoice_items", order_to_cash: null})
                    continue;
                  }
                } else {
                  returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 2, message: "The unity_identification sent " + header.unity_identification + " doesn't exist at oic_db. Please talk to ERP Team !", order_to_cash: null})
                  continue;
                }
              }
            } else {
              console.log('The order to cash transaction not exists on oic_db - ' + header.minifactu_id);
              returned.error.push({ minifactu_id: header.minifactu_id, type: "error", return_code: 98, message: "The order to cash transaction not exists on oic_db!", order_to_cash: header.minifactu_id})
              continue;
            }
          }
      } else {
        let status = 422;
        let message = "The request sent was not well formated. Check at https://app.swaggerhub.com/apis-docs/Smartfit/OrderToCash/";
        console.log(`[${status}] - ${message}`);
        returned.error.push({
          message: message,
          return_code: 1,
          type: "error",
        });
        schema.validate(otc).catch((err) => {
          console.log(err);
        });
      }
    }

    await res.status(200).send(
      returned.success.concat(returned.error)
    );
  });
};
