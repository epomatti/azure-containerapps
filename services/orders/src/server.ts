import express, { Response, Request } from 'express';
import cors from 'cors';
import { config } from './config'
import { publishOrder } from './dapr'

const app = express();
app.use(express.json());
app.use(cors())

export const start = async () => {

  app.post('/api/orders', async (req: Request<{}, {}, { orderId: string, }>, res: Response) => {
    const { orderId } = req.body;
    await publishOrder(orderId);
    res.sendStatus(201);
  });

  app.get('/liveness', (req, res) => {
    res.sendStatus(200);
  });

  const port = config.DAPR_APP_PORT;
  app.listen(port, () => {
    console.log(`Server started on port ${port}`)
  })
}
