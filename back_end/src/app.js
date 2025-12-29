const express = require('express')
require('dotenv').config({ silent: true })
const { connectDB } = require('./config/database')

const app = express()

// Middleware phan tich JSON
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Route hello world
app.get('/', (req, res) => {
    res.json({ message: 'Hello World!' })
})

// Kết nối database
connectDB()

module.exports = app