import { DaprClient, CommunicationProtocolEnum } from '@dapr/dapr';
import { config } from './config';

const { DAPR_HTTP_PORT } = config;

const daprHost = "127.0.0.1";
const PUBSUB_NAME = "orders-pub-sub"
const TOPIC_NAME = "orders"

export const publishOrder = async (orderId: string) => {
  const client = new DaprClient(daprHost, DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP);
  console.log(`Published order data: [${orderId}]`)
  const data = {
    orderId: orderId
  }
  // { "dapr-app-id": "publisher" }
  await client.pubsub.publish(PUBSUB_NAME, TOPIC_NAME, data);
}
