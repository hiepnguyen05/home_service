const express = require('express')
require('dotenv').config()
const { connectDB } = require('./config/database')


const app = express()

// Middleware
app.use(express.json())
app.use(express.urlencoded({ extended: true }))


// Kết nối database
connectDB()

module.exports = app
