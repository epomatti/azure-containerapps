import express, { Response, Request } from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));
app.use(cors())

export const start = async () => {

  app.get('/dapr/subscribe', (_req, res) => {
    res.json([
      {
        pubsubname: "order-pub-sub",
        topic: "orders",
        route: "api/deliveries",
      }
    ]);
  });

  app.post('/api/deliveries', async (req: Request, res: Response) => {
    const rawBody = JSON.stringify(req.body);
    console.log(`Data received: ${rawBody}`)
    res.status(200).send({ status: "SUCCESS" });
  });

  app.get('/api/deliveries', (req, res) => {
    const delivery = { status: "DELIVERED" }
    res.status(200).send(delivery);
  });

  app.get('/liveness', (req, res) => {
    res.sendStatus(200);
  });

  const port = process.env.DAPR_APP_PORT;
  app.listen(port, () => {
    console.log(`Server started on port ${port}`)
  })
}
