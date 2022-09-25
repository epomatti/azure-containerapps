import * as server from './server'

(async () => {
  try {
    await server.start();
  } catch (e) {
    console.error(e);
  }
})();