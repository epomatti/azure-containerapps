import express, { Response, Request } from 'express';
import cors from 'cors';
import { publishOrder, getDelivery } from './dapr'

const app = express();
app.use(express.json());
app.use(cors())

export const start = async () => {

  app.post('/api/orders', async (req: Request<{}, {}, { orderId: string, }>, res: Response) => {
    const { orderId } = req.body;
    await publishOrder(orderId);
    res.sendStatus(201);
  });

  app.get('/api/orders', async (req, res) => {
    const delivery = await getDelivery();
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
