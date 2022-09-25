import * as server from './server'
import appInsights from 'applicationinsights';
appInsights.start();

(async () => {
  try {
    await server.start();
  } catch (e) {
    console.error(e);
  }
})();