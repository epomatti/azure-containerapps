import * as dotenv from 'dotenv';
import * as appi from './appi'
import * as server from './server'

(async () => {
  try {
    dotenv.config();
    appi.start();
    await server.start();
  } catch (e) {
    console.error(e);
  }
})();