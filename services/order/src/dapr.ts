import { DaprClient, HttpMethod, CommunicationProtocolEnum } from '@dapr/dapr';

const DAPR_HTTP_PORT = process.env.DAPR_APP_PORT;

const daprHost = "127.0.0.1";
const PUBSUB_NAME = "order-pub-sub"
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

export const getDelivery = async () => {
  const client = new DaprClient(daprHost, DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP);
  return await client.invoker.invoke('delivery', "api/deliveries", HttpMethod.GET);
}
