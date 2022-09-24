const dotenv = require('dotenv')
dotenv.config();
const express = require('express')
const cors = require('cors')

const app = express();
app.use(express.json());
app.use(cors())
const port = 3100

app.get('/api/hello', (req, res) => {
  const json = {
    value: "Hello from Service 2"
  }
  res.send(json)
})

app.post('/api/messages', (req, res) => {
  console.log(`Message received by the application: ${req.body}`);
  res.sendStatus(200);
})

app.get('/liveness', (req, res) => {
  res.sendStatus(200);
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
