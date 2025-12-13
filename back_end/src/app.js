const express = require('express')
require('dotenv').config()

const app = express()

// Middleware
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

module.exports = app
