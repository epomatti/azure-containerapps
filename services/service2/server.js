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

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})