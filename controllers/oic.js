"use strict";

module.exports = app => {
  app.get("/transactions", (req, res) => {
    res.status(200).send({ message: "listing users" });
  });

  app.post("/transaction", (req, res) => {
    res.status(201).send({ message: "creating a user" });
  });

  app.put("/transsaction/:id", (req, res) => {
    const id = req.params.id;
    res.status(200).send({ message: `update user ${id}` });
  });

  app.delete("/transaction/:id", (req, res) => {
    const id = req.params.id;
    res.status(422).send({ message: `delete user ${id}` });
  });
};
