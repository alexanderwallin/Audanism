const express = require('express')
const path = require('path')

const townWeatherApi = require('./api/town-weather.js')

const app = new express()
app.set('port', process.env.PORT || 8229)
app.set('view engine', 'ejs')

// Static files
app.use(express.static(path.join(__dirname, 'public')))

// APIs
app.use('/api/town-weather', townWeatherApi)

// Index
app.get('/', (req, res) => {
  res.render('index')
})

app.listen(app.get('port'), error => {
  if (error) {
    console.error(error)
  } else {
    console.info(
      '==> 🌎  Listening on port %s. Open up http://localhost:%s/ in your browser.',
      app.get('port'),
      app.get('port')
    )
  }
})
