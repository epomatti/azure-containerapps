const dotenv = require('dotenv')
dotenv.config();
const express = require('express')
const cors = require('cors')
const request = require('request');

// Express
const app = express();
app.use(express.json());
app.use(cors())
const port = 3000

app.get('/api/foo', (req, res) => {
  const url = `${process.env.SERVICE2_URL}/api/hello`
  request(url, { json: true }, (err, req_res, body) => {
    if (err) { return console.log(err); }
    res.send(body)
  });
})

app.get('/liveness', (req, res) => {
  res.sendStatus(200);
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
