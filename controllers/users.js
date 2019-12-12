"use strict";

module.exports = app => {
  app.get("/users", (req, res) => {
    res.status(200).send({ message: "listing users" });
  });

  app.post("/users", (req, res) => {
    res.status(201).send({ message: "creating a user" });
  });

  app.put("/users/:id", (req, res) => {
    const id = req.params.id;
    res.status(200).send({ message: `update user ${id}` });
  });

  app.delete("/users/:id", (req, res) => {
    const id = req.params.id;
    res.status(422).send({ message: `delete user ${id}` });
  });
};
