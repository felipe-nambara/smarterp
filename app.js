"use strict";

const express = require("express");
const bodyParser = require("body-parser");
const helmet = require("helmet");
const cors = require("cors");
const consign = require("consign");

const app = express();

app.use(cors());
app.use(helmet());
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use(bodyParser.json({limit: '50mb', extended: true}));

consign()
  .include("controllers")
  .into(app);

module.exports = app;
