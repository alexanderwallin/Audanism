const express = require('express')
const got = require('got')

const towns = require('./yr-capitals.json')

const app = express.Router()

app.get('/', async (req, res) => {
  const randomIdx = Math.floor(Math.random() * towns.length)
  const town = towns[randomIdx]
  const url = town.pop()

  try {
    const { body } = await got(url)
    res.send(body)
  } catch (err) {
    res.send('')
  }
})

module.exports = app