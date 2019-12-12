"use strict";

const config = require("config");

module.exports = app => {
  app.get("/version", (req, res) => {
    const infos = {
      version: config.get("VERSION"),
      env: config.get("ENV")
    };

    res.status(200).send(infos);
  });
};
