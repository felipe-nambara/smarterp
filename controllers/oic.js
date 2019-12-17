"use strict";

const yup = require("yup");
const config = require("config");
const mysql = require("serverless-mysql")({
  config: {
    host: config.get("RDS_HOST"),
    database: config.get("RDS_DBNAME"),
    user: config.get("RDS_USER"),
    password: config.get("RDS_PASSWORD")
  }
});

module.exports = app => {
  const schema = yup.object().shape({
    header: yup.object({
      country: yup.string().required(),
      unity_identification: yup.number().required(),
      origin_system: yup.string().required(),
      operation: yup.string().required(),
      minifactu_id: yup.number().required(),
      conciliator_id: yup.number().required(),
      fin_id: yup.number().required(),
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
      invoice_items: yup.array()
    })
  });

  app.get("/transactions", (req, res) => {
    res.status(200).send({ message: "listing transactions" });
  });

  app.post("/transaction", (req, res) => {
    const data = req.body;

    data.otc.forEach(otc => {
      schema.isValid(otc).then(valid => {
        if (valid) {
          const { header, invoice_customer, receivable, invoice } = otc;

          mysql.connect().then(async conn => {
            global.order_to_cash = 0;
            let inserts = await mysql
              .transaction()
              .query(
                "INSERT INTO order_to_cash(country,unity_identification,origin_system,operation,minifactu_id,conciliator_id,fin_id,front_id) VALUES (?,?,?,?,?,?,?,?)",
                [
                  header.country,
                  header.unity_identification,
                  header.origin_system,
                  header.operation,
                  header.minifactu_id,
                  header.conciliator_id,
                  header.fin_id,
                  header.front_id
                ]
              )
              .query(r => {
                r.order_to_cash_id = r.insertId;
                [
                  "INSERT INTO receivable(order_to_cash_id,is_smartfin,transaction_type,contract_number,credit_card_brand,truncated_credit_card,current_credit_card_installment,total_credit_card_installment,nsu,authorization_code,price_list_value,gross_value,net_value,interest_value,administration_tax_percentage,administration_tax_value,billing_date,credit_date,conciliator_filename,acquirer_bank_filename,registration_gym_student,fullname_gym_student,identification_gym_student) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                  [
                    r.order_to_cash_id,
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
              .query(r => {
                "INSERT INTO invoice_customer(order_to_cash_id,full_name,type_person,identification_financial_responsible,nationality_code,state,city,adress,adress_complement,district,postal_code,area_code,cellphone,email,state_registration,federal_registration,final_consumer,icms_contributor) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",
                  [
                    r.order_to_cash_id,
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
                  ];
              })
              .query(r => {
                "INSERT INTO invoice(order_to_cash_id,transaction_type,is_overdue_recovery) VALUES (?,?,?);",
                  [
                    r.order_to_cash_id,
                    invoice.transaction_type,
                    invoice.is_overdue_recovery
                  ];
              })
              .rollback(e => {
                console.log(e);
                res.status(422).send({ message: "[422] Business error: " + e });
              })
              .commit();

            res.status(201).send({
              message: "created a transaction",
              data: data.otc,
              transactions: data.otc.length
            });
          });
        } else {
          res.status(422).send({ message: "Schema validation fail" });
        }
      });
    });
  });

  app.put("/transaction/:id", (req, res) => {
    const id = req.params.id;
    const data = req.body;

    schema.isValid(data).then(valid => {
      if (valid) {
        res.status(201).send({ message: "update a transaction" });
      } else {
        res.status(422).send({ message: "Schema validation fail" });
      }
    });

    res.status(200).send({ message: `update transaction ${id}` });
  });
};
