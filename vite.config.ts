import { defineConfig, loadEnv, Plugin } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

function netlifyFunctionsDevPlugin(): Plugin {
  const handlerMiddleware = async (req: any, res: any, next: any) => {
    const rawUrl = req.url || '';
    const url = rawUrl.split('?')[0];

    if (url.startsWith('/.netlify/functions/')) {
      const functionName = url.replace('/.netlify/functions/', '').replace(/\/$/, '');

      let bodyStr = '';
      req.on('data', (chunk: any) => {
        bodyStr += chunk;
      });

      req.on('end', async () => {
        try {
          // Live reload environment variables from .env
          const env = loadEnv('development', process.cwd(), '');
          Object.keys(env).forEach(key => {
            process.env[key] = env[key];
          });

          let handlerModule: any;
          if (functionName === 'send-whatsapp') {
            handlerModule = await import('./netlify/functions/send-whatsapp.ts');
          } else if (functionName === 'send-email') {
            handlerModule = await import('./netlify/functions/send-email.ts');
          } else if (functionName === 'notification-status') {
            handlerModule = await import('./netlify/functions/notification-status.ts');
          } else {
            res.statusCode = 404;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({ error: `Function ${functionName} not found` }));
            return;
          }

          const event: any = {
            httpMethod: req.method,
            body: bodyStr,
            headers: req.headers,
          };

          const result = await handlerModule.handler(event, {} as any, () => {});
          res.statusCode = result?.statusCode || 200;
          if (result?.headers) {
            Object.entries(result.headers).forEach(([k, v]) => {
              res.setHeader(k, v as string);
            });
          } else {
            res.setHeader('Content-Type', 'application/json');
          }
          res.end(result?.body || '{}');
          return;
        } catch (err: any) {
          console.error(`[Dev Functions Proxy] Error in ${functionName}:`, err.message);
          res.statusCode = 500;
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify({ success: false, status: 'failed', error: err.message }));
          return;
        }
      });
      return;
    }

    next();
  };

  return {
    name: 'netlify-functions-dev-middleware',
    configureServer(server) {
      server.middlewares.use(handlerMiddleware);
    },
    configurePreviewServer(server) {
      server.middlewares.use(handlerMiddleware);
    },
  };
}

export default defineConfig({
  plugins: [react(), netlifyFunctionsDevPlugin()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    open: false,
  },
  preview: {
    port: 3000,
    open: false,
  },
});
