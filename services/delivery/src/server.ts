import express, { Response, Request } from 'express';
import cors from 'cors';
import { config } from './config'

const app = express();
app.use(express.json());
app.use(cors())

export const start = async () => {

  app.get('/dapr/subscribe', (_req, res) => {
    res.json([
      {
        pubsubname: "orders-pub-sub",
        topic: "orders",
        route: "api/deliveries",
        metadata: {
          rawPayload: "true",
        }
      }
    ]);
  });

  app.post('/api/deliveries', async (req: Request<{}, {}, { orderId: string }>, res: Response) => {
    console.log(req.body)
    const { orderId } = req.body;
    console.log(`Order [${orderId}] received for delivery!`);
    res.status(200).send({ status: "SUCCESS" });
  });

  app.get('/liveness', (req, res) => {
    res.sendStatus(200);
  });

  const port = config.DAPR_APP_PORT;
  app.listen(port, () => {
    console.log(`Server started on port ${port}`)
  })
}
