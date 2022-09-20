const express = require('express');

// create and configure express webserver
const app = express()

// configure a template renderer
app.set('view engine', 'ejs')
app.set('views', `${__dirname}/views`)

// configure a router for the application
const router = express.Router()
router.get('/', (req, res) => {
  // render 'views/index.ejs'
  //   - under the hood, the mapping from
  //     - index.ejs -> src/views/index.ejs
  //   - is configured on lines 7/8
  res.render('index.ejs')
});

// use the router middleware for the application
app.use(router)

// start the webserver listening
//  - on port 3000
app.listen(3000)
