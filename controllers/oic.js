"use strict";

const yup = require("yup");

module.exports = app => {
  const schema = yup.object().shape({
    otc: yup.object({
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
    })
  });

  app.get("/transactions", (req, res) => {
    res.status(200).send({ message: "listing transactions" });
  });

  app.post("/transaction", (req, res) => {
    const data = req.body;

    schema.isValid(data).then(valid => {
      if (valid) {
        res.status(201).send({ message: "creating a transaction" });
      } else {
        res.status(422).send({ message: "Schema validation fail" });
      }
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
