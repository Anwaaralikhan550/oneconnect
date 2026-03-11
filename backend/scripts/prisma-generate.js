require('dotenv').config();

const { spawnSync, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const port = Number(process.env.PORT || 3000);
const thisPid = process.pid;
const clientDir = path.join(__dirname, '..', 'node_modules', '.prisma', 'client');
const prismaCmd = process.platform === 'win32'
  ? path.join(__dirname, '..', 'node_modules', '.bin', 'prisma.cmd')
  : path.join(__dirname, '..', 'node_modules', '.bin', 'prisma');

function run(command) {
  try {
    return execSync(command, { stdio: ['ignore', 'pipe', 'ignore'] }).toString();
  } catch (_) {
    return '';
  }
}

function unique(values) {
  return [...new Set(values)];
}

function getPortPids(targetPort) {
  if (process.platform === 'win32') {
    const output = run(`netstat -ano -p tcp | findstr :${targetPort}`);
    if (!output) return [];

    return unique(
      output
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line.includes('LISTENING'))
        .map((line) => line.split(/\s+/).pop())
        .filter(Boolean)
        .map((pid) => Number(pid))
        .filter((pid) => Number.isInteger(pid))
    );
  }

  const output = run(`lsof -ti tcp:${targetPort}`);
  if (!output) return [];

  return unique(
    output
      .split(/\r?\n/)
      .map((value) => value.trim())
      .filter(Boolean)
      .map((pid) => Number(pid))
      .filter((pid) => Number.isInteger(pid))
  );
}

function killPid(pid) {
  if (process.platform === 'win32') {
    run(`taskkill /PID ${pid} /F`);
    return;
  }

  run(`kill -9 ${pid}`);
}

function stopLocalServer() {
  const targets = getPortPids(port).filter((pid) => pid !== thisPid);
  if (targets.length === 0) {
    return;
  }

  console.log(`[prisma:generate] Releasing port ${port}: ${targets.join(', ')}`);
  for (const pid of targets) {
    killPid(pid);
  }
}

function cleanupEngineTemps() {
  if (!fs.existsSync(clientDir)) {
    return;
  }

  const entries = fs.readdirSync(clientDir);
  const targets = entries.filter((name) =>
    /^query_engine-.*\.dll\.node\.tmp\d+$/i.test(name)
  );

  for (const name of targets) {
    const filePath = path.join(clientDir, name);
    try {
      fs.rmSync(filePath, { force: true });
      console.log(`[prisma:generate] Removed stale temp file: ${name}`);
    } catch (error) {
      console.warn(`[prisma:generate] Could not remove ${name}: ${error.message}`);
    }
  }
}

function main() {
  stopLocalServer();
  cleanupEngineTemps();

  const result = spawnSync(prismaCmd, ['generate'], {
    cwd: path.join(__dirname, '..'),
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });

  if (result.error) {
    throw result.error;
  }

  process.exit(result.status ?? 1);
}

main();
