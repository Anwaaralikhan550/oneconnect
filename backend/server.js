require('dotenv').config();

const app = require('./src/app');
const { env } = require('./src/config/env');
const { prisma } = require('./src/config/database');

const PORT = env.PORT;

const server = app.listen(PORT, () => {
  console.log(`[OneConnect API] Server running on port ${PORT}`);
  console.log(`[OneConnect API] Environment: ${env.NODE_ENV}`);
  console.log(`[OneConnect API] API docs: http://localhost:${PORT}/api-docs`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`[OneConnect API] Port ${PORT} is already in use.`);
    console.error(`[OneConnect API] Kill the process: npx kill-port ${PORT}`);
    process.exit(1);
  }
  throw err;
});

let isShuttingDown = false;

// Graceful shutdown so port is released on restart/exit.
const shutdown = (signal) => {
  if (isShuttingDown) return;
  isShuttingDown = true;

  console.log('\n[OneConnect API] Shutting down gracefully...');
  if (signal) {
    console.log(`[OneConnect API] Signal received: ${signal}`);
  }

  server.close(async () => {
    try {
      await prisma.$disconnect();
    } catch (_) {
      // Ignore disconnect errors during shutdown.
    }
    process.exit(0);
  });

  setTimeout(() => process.exit(1), 5000).unref();
};

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

// Nodemon uses SIGUSR2 by default for restart.
process.on('SIGUSR2', () => {
  shutdown('SIGUSR2');
  setTimeout(() => process.kill(process.pid, 'SIGUSR2'), 100);
});
