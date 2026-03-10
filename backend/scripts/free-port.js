const { execSync } = require('child_process');

const port = Number(process.env.PORT || 3000);
const thisPid = process.pid;

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

function pidsOnWindows(targetPort) {
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

function pidsOnPosix(targetPort) {
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

function killPidWindows(pid) {
  run(`taskkill /PID ${pid} /F`);
}

function killPidPosix(pid) {
  run(`kill -9 ${pid}`);
}

function main() {
  const pids =
    process.platform === 'win32' ? pidsOnWindows(port) : pidsOnPosix(port);

  const targets = pids.filter((pid) => pid !== thisPid);
  if (targets.length === 0) {
    console.log(`[dev] Port ${port} is free.`);
    return;
  }

  console.log(`[dev] Releasing port ${port}: ${targets.join(', ')}`);
  for (const pid of targets) {
    if (process.platform === 'win32') {
      killPidWindows(pid);
    } else {
      killPidPosix(pid);
    }
  }
}

main();

