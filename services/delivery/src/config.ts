import * as dotenv from 'dotenv';
dotenv.config();

interface Config {
  DAPR_APP_PORT: string,
  DAPR_HTTP_PORT: string,
  APPLICATIONINSIGHTS_CONNECTION_STRING: string
}

const getConfig = (): Config => {
  const config: Config = {
    DAPR_APP_PORT: process.env.DAPR_APP_PORT!,
    DAPR_HTTP_PORT: process.env.DAPR_HTTP_PORT!,
    APPLICATIONINSIGHTS_CONNECTION_STRING: process.env.APPLICATIONINSIGHTS_CONNECTION_STRING!
  };
  return config;
}

export const config = getConfig();