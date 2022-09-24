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

const protocol = process.env.HTTPS_ENABLED === "true" ? "https" : "http";
const subscriberBaseUrl = `${protocol}://${process.env.SUBSCRIBER_FQDN}`;

app.get('/api/foo', (req, res) => {
  const url = `${subscriberBaseUrl}/api/hello`
  request(url, { json: true }, (err, req_res, body) => {
    if (err) { return console.log(err); }
    res.send(body)
  });
})

app.get('/api/enqueue', (req, res) => {
  request({
    url: `http://${process.env.SUBSCRIBER_DAPR_FQDN}/v1.0/publish/messages-pub-sub/messages`,
    method: 'POST',
    json: { mes: 'heydude' }
  }, function (error, response, body) {
    if (error) { return console.log(error); }
    if (response.statusCode === 200) {
      res.sendStatus(201);
    } else {
      console.error(response.statusCode)
      console.error(response.body)
      res.sendStatus(500);
    }
  });
})

app.get('/liveness', (req, res) => {
  res.sendStatus(200);
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
